/**
 * Tests for TSPLStringWriter.
 */
component extends="testbox.system.BaseSpec" {

	function testInitReturnsWriter() {
		var writer = new models.TSPLStringWriter();
		var result = writer.init( {} );
		expect( result ).toBe( writer );
	}

	function testSizeWithAutoHeight() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.size( 576, "auto" );
		var commands = writer.finalize();
		expect( commands ).toHaveLength( 1 );
		expect( commands[ 1 ] ).toBe( "SIZE 576 dot" );
	}

	function testSizeWithNumericHeight() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.size( 576, 400 );
		var commands = writer.finalize();
		expect( commands ).toHaveLength( 1 );
		expect( commands[ 1 ] ).toBe( "SIZE 576 dot,400 dot" );
	}

	function testGapCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.gap( 3, 0 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "GAP 3 dot,0 dot" );
	}

	function testBlineCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.bline( 5, 2 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "BLINE 5 dot,2 dot" );
	}

	function testDirectionCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.direction( 1, 0 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "DIRECTION 1,0" );
	}

	function testReferenceCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.reference( 10, 20 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "REFERENCE 10,20" );
	}

	function testOffsetCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.offset( 5 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "OFFSET 5 dot" );
	}

	function testSpeedCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.speed( 4 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "SPEED 4" );
	}

	function testDensityCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.density( 8 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "DENSITY 8" );
	}

	function testClsCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.cls();
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "CLS" );
	}

	function testTextCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.text( 10, 20, "3", 0, 1, 1, "Hello" );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( 'TEXT 10,20,"3",0,1,1,"Hello"' );
	}

	function testTextEscapesQuotes() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.text( 0, 0, "0", 0, 1, 1, 'Say "Hi"' );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( 'TEXT 0,0,"0",0,1,1,"Say \"Hi\""' );
	}

	function testBarcodeCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.barcode( 0, 0, "128", 80, 1, 0, 2, 2, "ABC123" );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( 'BARCODE 0,0,"128",80,1,0,2,2,"ABC123"' );
	}

	function testQrCodeCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.qrcode( 0, 0, "M", 4, "A", 0, "M2", "S7", "DATA" );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( 'QRCODE 0,0,M,4,A,0,M2,S7,"DATA"' );
	}

	function testBoxWithoutRadius() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.box( 0, 0, 100, 50, 2, 0 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "BOX 0,0,100,50,2" );
	}

	function testBoxWithRadius() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.box( 0, 0, 100, 50, 2, 5 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "BOX 0,0,100,50,2,5" );
	}

	function testBarHorizontal() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.bar( 0, 0, 100, 2, "horizontal" );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "BAR 0,0,100,2" );
	}

	function testBarVertical() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.bar( 0, 0, 100, 2, "vertical" );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "BAR 0,0,2,100" );
	}

	function testImageCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		var bytes = charsetDecode( "ABC", "utf-8" );
		writer.image( 0, 0, 80, 60, 0, bytes );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toInclude( "BITMAP 0,0,10,60,0," );
	}

	function testCommandEscapeHatch() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.command( "REVERSE", [ 0, 0, 100, 100 ] );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "REVERSE 0,0,100,100" );
	}

	function testRawClosure() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.raw( ( w, v ) => {
			w.text( 10, 10, "0", 0, 1, 1, "raw" );
		}, {} );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( 'TEXT 10,10,"0",0,1,1,"raw"' );
	}

	function testPrintCommand() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.print( 2, 1 );
		var commands = writer.finalize();
		expect( commands[ 1 ] ).toBe( "PRINT 2,1" );
	}

	function testMultipleCommands() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.size( 576, "auto" );
		writer.cls();
		writer.print( 1, 1 );
		var commands = writer.finalize();
		expect( commands ).toHaveLength( 3 );
		expect( commands[ 1 ] ).toBe( "SIZE 576 dot" );
		expect( commands[ 2 ] ).toBe( "CLS" );
		expect( commands[ 3 ] ).toBe( "PRINT 1,1" );
	}

	function testReusableWriter() {
		var writer = new models.TSPLStringWriter().init( {} );
		writer.size( 576, "auto" );
		writer.init( {} );
		writer.cls();
		var commands = writer.finalize();
		expect( commands ).toHaveLength( 1 );
		expect( commands[ 1 ] ).toBe( "CLS" );
	}

}
