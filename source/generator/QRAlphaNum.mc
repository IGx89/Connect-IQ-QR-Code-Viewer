using Toybox.Lang;
using Toybox.System;

/**
 * QRAlphaNum
 * @author Kazuhiko Arase 
 */
class QRAlphaNum extends QRData {
	function initialize(data) {
		QRData.initialize(Mode.MODE_ALPHA_NUM, data);
	}
	
	function write(buffer) {
	    var c = getData().toCharArray();
	
	    var i = 0;
	
	    while (i + 1 < c.size()) {
	      buffer.put(getCode(c[i]) * 45 + getCode(c[i + 1]), 11);
	      i += 2;
	    }
	
	    if (i < c.size()) {
	      buffer.put(getCode(c[i]), 6);
	    }
	}
	
	function getLength() {
		return getData().length();
	}
	
  	private function getCode(c) {

	    if ('0' <= c && c <= '9') {
			return c.toNumber() - '0'.toNumber();
	    } else if ('A' <= c && c <= 'Z') {
			return c.toNumber() - 'A'.toNumber() + 10;
	    } else {
		  switch (c) {
		  case ' ' : return 36;
		  case '$' : return 37;
		  case '%' : return 38;
		  case '*' : return 39;
		  case '+' : return 40;
		  case '-' : return 41;
		  case '.' : return 42;
		  case '/' : return 43;
		  case ':' : return 44;
		  default :
		    throw new Lang.Exception("illegal char :" + c);
		  }
	    }
	}
}