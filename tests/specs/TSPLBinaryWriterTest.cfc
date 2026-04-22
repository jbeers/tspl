/**
 * Tests for TSPLBinaryWriter.
 */
component extends="testbox.system.BaseSpec" {

	function testInitReturnsWriter() {
		var writer = new models.TSPLBinaryWriter();
		var result = writer.init( {} );
		expect( result ).toBe( writer );
	}

	function testSizeWithAutoHeight() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.size( 576, "auto" );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "SIZE 576 dot\r\n" );
	}

	function testSizeWithNumericHeight() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.size( 576, 400 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "SIZE 576 dot,400 dot\r\n" );
	}

	function testGapCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.gap( 3, 0 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "GAP 3 dot,0 dot\r\n" );
	}

	function testBlineCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.bline( 5, 2 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "BLINE 5 dot,2 dot\r\n" );
	}

	function testDirectionCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.direction( 1, 0 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "DIRECTION 1,0\r\n" );
	}

	function testReferenceCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.reference( 10, 20 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "REFERENCE 10,20\r\n" );
	}

	function testOffsetCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.offset( 5 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "OFFSET 5 dot\r\n" );
	}

	function testSpeedCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.speed( 4 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "SPEED 4\r\n" );
	}

	function testDensityCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.density( 8 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "DENSITY 8\r\n" );
	}

	function testClsCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.cls();
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "CLS\r\n" );
	}

	function testTextCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.text( 10, 20, "3", 0, 1, 1, "Hello" );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( 'TEXT 10,20,"3",0,1,1,"Hello"\r\n' );
	}

	function testBarcodeCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.barcode( 0, 0, "128", 80, 1, 0, 2, 2, "ABC123" );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( 'BARCODE 0,0,"128",80,1,0,2,2,"ABC123"\r\n' );
	}

	function testQrCodeCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.qrcode( 0, 0, "M", 4, "A", 0, "M2", "S7", "DATA" );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( 'QRCODE 0,0,M,4,A,0,M2,S7,"DATA"\r\n' );
	}

	function testBoxWithoutRadius() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.box( 0, 0, 100, 50, 2, 0 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "BOX 0,0,100,50,2\r\n" );
	}

	function testBoxWithRadius() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.box( 0, 0, 100, 50, 2, 5 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "BOX 0,0,100,50,2,5\r\n" );
	}

	function testBarHorizontal() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.bar( 0, 0, 100, 2, "horizontal" );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "BAR 0,0,100,2\r\n" );
	}

	function testBarVertical() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.bar( 0, 0, 100, 2, "vertical" );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "BAR 0,0,2,100\r\n" );
	}

	function testImageAppendsRawBytes() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		var imgBytes = charsetDecode( "IMG", "utf-8" );
		writer.image( 0, 0, 80, 60, 0, imgBytes );
		var bytes = writer.finalize();
		var text = toString( bytes, "utf-8" );
		expect( text ).toInclude( "BITMAP 0,0,10,60,0," );
		expect( text ).toInclude( "IMG" );
	}

	function testCommandEscapeHatch() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.command( "REVERSE", [ 0, 0, 100, 100 ] );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "REVERSE 0,0,100,100\r\n" );
	}

	function testRawClosure() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.raw( ( w, v ) => {
			w.text( 10, 10, "0", 0, 1, 1, "raw" );
		}, {} );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( 'TEXT 10,10,"0",0,1,1,"raw"\r\n' );
	}

	function testPrintCommand() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.print( 2, 1 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "PRINT 2,1\r\n" );
	}

	function testMultipleCommands() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.size( 576, "auto" );
		writer.cls();
		writer.print( 1, 1 );
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "SIZE 576 dot\r\nCLS\r\nPRINT 1,1\r\n" );
	}

	function testReusableWriter() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.size( 576, "auto" );
		writer.init( {} );
		writer.cls();
		var bytes = writer.finalize();
		expect( toString( bytes, "utf-8" ) ).toBe( "CLS\r\n" );
	}

	function testToSegmentsReturnsSegments() {
		var writer = new models.TSPLBinaryWriter().init( {} );
		writer.cls();
		writer.print( 1, 1 );
		var segments = writer.toSegments();
		expect( segments ).toHaveLength( 2 );
		expect( toString( segments[ 1 ], "utf-8" ) ).toBe( "CLS\r\n" );
		expect( toString( segments[ 2 ], "utf-8" ) ).toBe( "PRINT 1,1\r\n" );
	}

}
