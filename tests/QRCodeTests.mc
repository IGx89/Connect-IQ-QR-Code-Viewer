using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
module QRCodeTests {
	(:test)
	function test1(logger) {
	    var data = new QRNumber("0123");
	    var act = QRCode.createData(1, ErrorCorrectionLevel.H, [data] );
	    var exp = [16,16,12,48,-20,17,-20,17,-20,-50,-20,-24,66,-27,44,-31,-124,-111,13,-69,-37,15,-16,36,-69,104];

	    Test.assertEqual(exp, act);
	    
	    return true;
	}
	
	function assertEquals(expected, actual) {
		Test.assertEqual(expected.size(), actual.size());

	    for (var i = 0; i < expected.size(); i++) {
	    	Test.assertEqual(expected[i], actual[i]);
	    }
	}
}