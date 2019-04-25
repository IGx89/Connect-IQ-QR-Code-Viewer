using Toybox.System;
using Toybox.Test;

(:test)
module PolynomialTests {
	(:test)
	function test1(logger) {
		QRMath.staticInitialize();
	
	    var rs = [0, 43, 139, 206, 78, 43, 239, 123, 206, 214, 147, 24, 99, 150, 39, 243, 163, 136];
	    for (var i = 0; i < rs.size(); i++) {
			rs[i] = QRMath.gexp(rs[i]);
	    }

	    var data = [32,65,205,69,41,220,46,128,236];
	
	    var e = new Polynomial(rs, 0);
	    var e2 = new Polynomial(data, e.getLength() - 1);
	
	    assertEquals([32,65,205,69,41,220,46,128,236,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], e2);
    	assertEquals([1,119,66,83,120,119,22,197,83,249,41,143,134,85,53,125,99,79], e);
    	assertEquals([42,159,74,221,244,169,239,150,138,70,237,85,224,96,74,219,61], e2.mod(e) );
	
		return true;
	}
	
	(:test)
	function test2(logger) {
		QRMath.staticInitialize();
	
	    var a = new Polynomial([1], 0);
	    for (var i = 0; i < 7; i++) {
	    	a = a.multiply(new Polynomial([1, QRMath.gexp(i)], 0) );
	    }
	
	    var log = [0,87,229,146,149,238,102,21];
	    Test.assertEqual(log.size(), a.getLength() );
	    for (var i = 0; i < a.getLength(); i++) {
			Test.assertEqual(log[i], QRMath.glog(a.get(i) ) );
	    }
	
		return true;
	}
	
  	function assertEquals(num, p) {

	    Test.assertEqual(num.size(), p.getLength() );

	    for (var i = 0; i < num.size(); i++) {
			Test.assertEqual(num[i], p.get(i) );
	    }
  	}
}