/**
 * Tests for TSPLJSBluetoothWriter.
 *
 * These tests require a JavaScript runtime (browser or Node.js).
 * They are automatically skipped when running on the JVM.
 */
component extends="testbox.system.BaseSpec" {

	private boolean function isJS() {
		try {
			createObject( "java", "java.lang.String" );
			return false;
		} catch ( any e ) {
			return true;
		}
	}

	function testInitReturnsWriter() {
		if ( !isJS() ) skip( "Requires JS runtime" );
		var writer = new models.TSPLJSBluetoothWriter();
		var result = writer.init( {} );
		expect( result ).toBe( writer );
	}

	function testFinalizeChunksBinaryOutput() {
		if ( !isJS() ) skip( "Requires JS runtime" );
		var writer = new models.TSPLJSBluetoothWriter().init( {} );
		writer.cls();
		writer.print( 1, 1 );
		var chunks = writer.finalize();

		expect( chunks ).toBeArray();
		expect( arrayLen( chunks ) ).toBeGTE( 1 );

		var totalLen = 0;
		for ( var chunk in chunks ) {
			totalLen += chunk.length;
		}

		expect( totalLen ).toBe( len( "CLS\r\nPRINT 1,1\r\n" ) );
	}

	function testChunkSizeDefaultIs20() {
		if ( !isJS() ) skip( "Requires JS runtime" );
		var writer = new models.TSPLJSBluetoothWriter().init( {} );
		// Build a command larger than 20 bytes
		writer.text( 100, 200, "3", 0, 1, 1, "Hello World This Is Long" );
		var chunks = writer.finalize();

		expect( arrayLen( chunks ) ).toBeGTE( 2 );
		expect( chunks[ 1 ].length ).toBeLTE( 20 );
	}

	function testSingleSmallCommandProducesOneChunk() {
		if ( !isJS() ) skip( "Requires JS runtime" );
		var writer = new models.TSPLJSBluetoothWriter().init( {} );
		writer.cls();
		var chunks = writer.finalize();

		expect( arrayLen( chunks ) ).toBe( 1 );
		expect( chunks[ 1 ].length ).toBe( len( "CLS\r\n" ) );
	}

	function testReusableWriter() {
		if ( !isJS() ) skip( "Requires JS runtime" );
		var writer = new models.TSPLJSBluetoothWriter().init( {} );
		writer.cls();
		writer.init( {} );
		writer.print( 1, 1 );
		var chunks = writer.finalize();

		expect( arrayLen( chunks ) ).toBe( 1 );
		expect( chunks[ 1 ].length ).toBe( len( "PRINT 1,1\r\n" ) );
	}

	function testReturnsUint8ArrayChunks() {
		if ( !isJS() ) skip( "Requires JS runtime" );
		var writer = new models.TSPLJSBluetoothWriter().init( {} );
		writer.cls();
		var chunks = writer.finalize();

		expect( chunks[ 1 ] ).toBeInstanceOf( "Uint8Array" );
	}

}
