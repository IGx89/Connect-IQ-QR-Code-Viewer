using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
module BitBufferTests {
	(:test)
	function test4(logger) {
	    var bb = new BitBuffer();
	    var qd = new QRNumber("0123456789");
	    qd.write(bb);

	    Test.assertEqual(34, bb.getLengthInBits());
	    
	    return true;
	}
}