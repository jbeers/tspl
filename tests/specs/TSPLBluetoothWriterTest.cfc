/**
 * Tests for TSPLBluetoothWriter.
 */
component extends="testbox.system.BaseSpec" {

	function testInitReturnsWriter() {
		var writer = new models.TSPLBluetoothWriter();
		var result = writer.init( {} );
		expect( result ).toBe( writer );
	}

	function testFinalizeChunksBinaryOutput() {
		var writer = new models.TSPLBluetoothWriter().init( {} );
		writer.cls();
		writer.print( 1, 1 );
		var chunks = writer.finalize();

		expect( chunks ).toBeArray();
		expect( arrayLen( chunks ) ).toBeGTE( 1 );

		var totalLen = 0;
		for ( var chunk in chunks ) {
			totalLen += len( chunk );
		}

		expect( totalLen ).toBe( len( "CLS\r\nPRINT 1,1\r\n" ) );
	}

	function testChunkSizeDefaultIs20() {
		var writer = new models.TSPLBluetoothWriter().init( {} );
		// Build a command larger than 20 bytes
		writer.text( 100, 200, "3", 0, 1, 1, "Hello World This Is Long" );
		var chunks = writer.finalize();

		expect( arrayLen( chunks ) ).toBeGTE( 2 );
		expect( len( chunks[ 1 ] ) ).toBeLTE( 20 );
	}

	function testSingleSmallCommandProducesOneChunk() {
		var writer = new models.TSPLBluetoothWriter().init( {} );
		writer.cls();
		var chunks = writer.finalize();

		expect( arrayLen( chunks ) ).toBe( 1 );
		expect( toString( chunks[ 1 ], "utf-8" ) ).toBe( "CLS\r\n" );
	}

	function testReusableWriter() {
		var writer = new models.TSPLBluetoothWriter().init( {} );
		writer.cls();
		writer.init( {} );
		writer.print( 1, 1 );
		var chunks = writer.finalize();

		expect( arrayLen( chunks ) ).toBe( 1 );
		expect( toString( chunks[ 1 ], "utf-8" ) ).toBe( "PRINT 1,1\r\n" );
	}

}
