using Toybox.Lang;
using Toybox.System;

/**
 * QRMath
 * @author Kazuhiko Arase 
 */
class QRMath {

	private static const EXP_TABLE = new[256]b;
	private static const LOG_TABLE = new[256]b;
	private static var initialized = false;

	static function staticInitialize() {
	    for (var i = 0; i < 8; i++) {
	      EXP_TABLE[i] = 1 << i;
	    }
	
	    for (var i = 8; i < 256; i++) {
	      EXP_TABLE[i] = EXP_TABLE[i - 4]
	        ^ EXP_TABLE[i - 5]
	        ^ EXP_TABLE[i - 6]
	        ^ EXP_TABLE[i - 8];
	    }
	    
	    for (var i = 0; i < 255; i++) {
	      LOG_TABLE[EXP_TABLE[i]] = i;
	    }
	    
	    initialized = true;
    }

	static function glog(n) {

		if (!initialized) {
			QRMath.staticInitialize();
		}
	
	    return LOG_TABLE[n];
  	}

	static function gexp(n) {

		if (!initialized) {
			QRMath.staticInitialize();
		}

	    return EXP_TABLE[n % 255];
  	}
}
