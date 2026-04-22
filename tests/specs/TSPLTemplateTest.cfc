/**
 * Tests for TSPLTemplate writer integration.
 */
component extends="testbox.system.BaseSpec" {

	function testWriteProducesSetupCommands() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" )
			.gap( 3, 0 )
			.direction( 1, 0 )
			.reference( 10, 20 )
			.mediaOffset( 5 )
			.speed( 4 )
			.density( 8 );

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( {}, writer );
		var commands = writer.finalize();

		expect( commands[ 1 ] ).toBe( "SIZE 576 dot" );
		expect( commands[ 2 ] ).toBe( "GAP 3 dot,0 dot" );
		expect( commands[ 3 ] ).toBe( "DIRECTION 1,0" );
		expect( commands[ 4 ] ).toBe( "REFERENCE 10,20" );
		expect( commands[ 5 ] ).toBe( "OFFSET 5 dot" );
		expect( commands[ 6 ] ).toBe( "SPEED 4" );
		expect( commands[ 7 ] ).toBe( "DENSITY 8" );
		expect( commands[ 8 ] ).toBe( "CLS" );
	}

	function testWriteEmitsPrintCommand() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" )
			.print( 2, 1 );

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( {}, writer );
		var commands = writer.finalize();

		expect( commands[ arrayLen( commands ) ] ).toBe( "PRINT 2,1" );
	}

	function testWriteSubstitutesVariables() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" )
			.text( "Order {orderNumber}", "3" );

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( { orderNumber : 1042 }, writer );
		var commands = writer.finalize();

		expect( commands[ 7 ] ).toBe( 'TEXT 0,0,"3",0,1,1,"Order 1042"' );
	}

	function testWriteResolvesAnchoredPosition() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, 400 )
			.anchor( "center" )
			.text( "Hi", "3" );

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( {}, writer );
		var commands = writer.finalize();

		// Font 3 is 16x24, "Hi" = 2 chars * 16 = 32 width
		// Centered in 576 width: (576 - 32) / 2 = 272
		expect( commands[ 7 ] ).toBe( 'TEXT 272,0,"3",0,1,1,"Hi"' );
	}

	function testWriteHandlesRawClosure() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" )
			.raw( ( w, v ) => {
				w.text( 50, 50, "0", 0, 1, 1, "raw-text" );
			} );

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( {}, writer );
		var commands = writer.finalize();

		expect( commands[ 7 ] ).toBe( 'TEXT 50,50,"0",0,1,1,"raw-text"' );
	}

	function testWriteReturnsFinalizeResult() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" );

		var result = template.write( {}, new models.TSPLStringWriter().init( {} ) );
		expect( result ).toBeArray();
	}

	function testWriteEmitsContentCommands() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" )
			.text( "A", "0" )
			.barcode( "B", "128", 80, 1, 0, 2, 2 )
			.qrCode( "C", 4 )
			.box( 10, 10, 1, 0 )
			.bar( 5, 1, "horizontal" )
			.print();

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( {}, writer );
		var commands = writer.finalize();

		expect( commands[ 7 ] ).toBe( 'TEXT 0,0,"0",0,1,1,"A"' );
		expect( commands[ 8 ] ).toBe( 'BARCODE 0,0,"128",80,1,0,2,2,"B"' );
		expect( commands[ 9 ] ).toInclude( "QRCODE" );
		expect( commands[ 10 ] ).toInclude( "BOX" );
		expect( commands[ 11 ] ).toInclude( "BAR" );
	}

	function testBlineMediaSetup() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" )
			.bline( 5, 2 );

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( {}, writer );
		var commands = writer.finalize();

		expect( commands[ 2 ] ).toBe( "BLINE 5 dot,2 dot" );
	}

	function testImageCommandPassesBytes() {
		var template = new models.TSPLTemplate()
			.dimensions( 576, "auto" )
			.image( charsetDecode( "IMG", "utf-8" ), 80, 60, 0 );

		var writer = new models.TSPLStringWriter().init( {} );
		template.write( {}, writer );
		var commands = writer.finalize();

		expect( commands[ 7 ] ).toInclude( "BITMAP" );
	}

}
