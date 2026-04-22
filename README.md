# tspl

`tspl` is a BoxLang module for authoring TSPL print jobs with a fluent API. The public entry point is [`TSPLTemplate.bx`](/home/jacob/dev/jbeers/tspl/models/TSPLTemplate.bx).

## Design

- All authored measurements are converted to dots internally.
- The template starts in `dots` mode and can be switched to `metric` or `imperial`.
- `write( vars = {}, writer )` compiles the template through a pluggable writer.
- Template placeholders are flat `{name}` tokens and missing values throw during compilation.
- Raw TSPL is available through closure-based `raw()`, and fluent commands handle positioning, anchoring, and measured `advance()`.

## Writers

The library provides several writer implementations:

- **`TSPLStringWriter`** — Accumulates commands in an array of strings for debugging.
- **`TSPLBinaryWriter`** — Emits raw binary output with CRLF-terminated text commands and raw bitmap bytes.
- **`TSPLJSBluetoothWriter`** — Browser-environment writer that accumulates raw bytes via JS `TextEncoder` and returns `Uint8Array` chunks sized for BLE transmission (default 20 bytes).
- **`TSPLJSCanvasWriter`** — Stub for future browser-based canvas preview (not yet implemented).

## Example

```bx
template = new bxModules.tspl.models.TSPLTemplate()
	.dimensions( 576, "auto" )
	.gap( 0 )
	.moveTo( 0, 20 )
	.anchor( "center" )
	.text( "Order {orderNumber}", "3" )
	.advance( 12 )
	.qrCode( "{trackingCode}", 6 )
	.print();

// For debugging
commands = template.write(
	{
		orderNumber  : 1042,
		trackingCode : "ZX-1042-OK"
	},
	new bxModules.tspl.models.TSPLStringWriter()
);

// For BLE transmission in a browser
chunks = template.write(
	{
		orderNumber  : 1042,
		trackingCode : "ZX-1042-OK"
	},
	new bxModules.tspl.models.TSPLJSBluetoothWriter()
);
```

### Browser + Web Bluetooth Example

When BoxLang is transpiled to JavaScript, `TSPLJSBluetoothWriter` produces an array of `Uint8Array` chunks ready for the Web Bluetooth API:

```js
// 1. Build the template (same BoxLang code, transpiled to JS)
const template = new TSPLTemplate()
    .dimensions(576, "auto")
    .gap(0)
    .moveTo(0, 20)
    .anchor("center")
    .text("Order {orderNumber}", "3")
    .advance(12)
    .qrCode("{trackingCode}", 6)
    .print();

// 2. Compile with the JS Bluetooth writer
const chunks = template.write(
    { orderNumber: 1042, trackingCode: "ZX-1042-OK" },
    new TSPLJSBluetoothWriter()
);

// 3. Connect and print via Web Bluetooth
async function printOverBle() {
    const device = await navigator.bluetooth.requestDevice({
        acceptAllDevices: true,
        optionalServices: ["000018f0-0000-1000-8000-00805f9b34fb"] // Common printer service
    });

    const server = await device.gatt.connect();
    const service = await server.getPrimaryService("000018f0-0000-1000-8000-00805f9b34fb");
    const characteristic = await service.getCharacteristic("00002af1-0000-1000-8000-00805f9b34fb");

    // Send each chunk sequentially
    for (const chunk of chunks) {
        await characteristic.writeValueWithoutResponse(chunk);
    }

    await server.disconnect();
}

printOverBle();
```

## Public API

### Template setup

- `dimensions( width, height = "auto", unitOverride = "" )`
  Maps to `SIZE`.
- `units( mode )`
  Controls how subsequent measurements are interpreted before conversion to dots.
- `gap( distance, offset = 0, unitOverride = "" )`
  Maps to `GAP`.
- `bline( height, offset = 0, unitOverride = "" )`
  Maps to `BLINE`.
- `direction( direction = 0, mirror = 0 )`
  Maps to `DIRECTION`.
- `reference( x, y, unitOverride = "" )`
  Maps to `REFERENCE`.
- `mediaOffset( distance, unitOverride = "" )`
  Maps to `OFFSET`.
- `speed( value )`
  Maps to `SPEED`.
- `density( value )`
  Maps to `DENSITY`.
- `print( copies = 1, sets = 1 )`
  Maps to `PRINT`.

### Layout helpers

- `region( name, x, y, width, height, unitOverride = "" )`
  Defines a named layout region.
- `useRegion( name )`
  Switches the active region.
- `moveTo( x, y, unitOverride = "" )`
  Sets the cursor within the active region.
- `moveBy( dx, dy, unitOverride = "" )`
  Moves the cursor relative to its current position.
- `offset( dx, dy, unitOverride = "" )`
  Alias for `moveBy`.
- `anchor( horizontal, vertical = "top" )`
  Resolves authored content against `left|center|right` and `top|middle|bottom`.
- `newLine( step = 0, unitOverride = "" )`
  Uses a fixed cursor step.
- `lineStep( step, unitOverride = "" )`
  Sets the default `newLine()` step.
- `advance( spacing = 0, unitOverride = "" )`
  Moves by the last measured fluent element height plus optional spacing.

### Content commands

- `raw( callback )`
  Accepts a closure `(writer, vars) => { ... }` that can invoke any writer method directly. If the closure returns `{ width, height }`, it participates in `advance()`.
- `text( value, font = "0", xMultiplier = 1, yMultiplier = 1, rotation = 0, widthOverride = 0 )`
  Maps to `TEXT`.
- `barcode( value, codeType = "128", height = 80, humanReadable = 1, rotation = 0, narrow = 2, wide = 2, unitOverride = "" )`
  Maps to `BARCODE`.
- `qrCode( value, cellWidth = 4, eccLevel = "M", mode = "A", rotation = 0, model = "M2", mask = "S7", unitOverride = "" )`
  Maps to `QRCODE`.
- `box( width, height, thickness = 1, radius = 0, unitOverride = "" )`
  Maps to `BOX`, using the cursor as the origin.
- `bar( length, thickness = 1, orientation = "horizontal", unitOverride = "" )`
  Maps to `BAR`, using the cursor as the origin.
- `image( bytes, width, height, mode = 0, unitOverride = "" )`
  Maps to `BITMAP`. In the current implementation, the bytes are treated as pre-normalized bitmap payload bytes.

### Writer interface

All writers implement `ITSPLWriter`:

- `init( templateState )`
- `size( width, height )`
- `gap( distance, offset )`
- `bline( height, offset )`
- `direction( direction, mirror )`
- `reference( x, y )`
- `offset( distance )`
- `speed( value )`
- `density( value )`
- `cls()`
- `text( x, y, font, rotation, xMultiplier, yMultiplier, value )`
- `barcode( x, y, codeType, height, humanReadable, rotation, narrow, wide, value )`
- `qrcode( x, y, eccLevel, cellWidth, mode, rotation, model, mask, value )`
- `box( x, y, width, height, thickness, radius )`
- `bar( x, y, length, thickness, orientation )`
- `image( x, y, width, height, mode, bytes )`
- `command( name, args )` — Generic escape hatch for unsupported commands.
- `raw( callback, vars )`
- `print( copies, sets )`
- `finalize()` — Returns the output (format varies by writer).

## Notes

- Repeated `dimensions()` calls throw once drawable content has been added.
- Raw closures do not participate in measured `advance()` unless they return `{ width, height }`.
- Vertical centering against the full label is not meaningful when the template height is `auto`; use named regions when you need a bounded layout frame.
