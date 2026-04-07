# tspl

`tspl` is a BoxLang module for authoring TSPL print jobs with a fluent API. The public entry point is [`TSPLTemplate.bx`](/home/jacob/dev/jbeers/tspl/models/TSPLTemplate.bx).

## Design

- All authored measurements are converted to dots internally.
- The template starts in `dots` mode and can be switched to `metric` or `imperial`.
- `toCommands( vars = {} )` returns a complete printable job, including setup, `CLS`, authored commands, and `PRINT`.
- Template placeholders are flat `{name}` tokens and missing values throw during compilation.
- Raw TSPL remains available through `raw()`, but fluent commands handle positioning, anchoring, and measured `advance()`.

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

commands = template.toCommands( {
	orderNumber  : 1042,
	trackingCode : "ZX-1042-OK"
} );
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

- `raw( command )`
  Emits raw TSPL with placeholder support.
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

## Notes

- Repeated `dimensions()` calls throw once drawable content has been added.
- Raw commands do not participate in measured `advance()` unless you model the same content through the fluent API.
- Vertical centering against the full label is not meaningful when the template height is `auto`; use named regions when you need a bounded layout frame.
