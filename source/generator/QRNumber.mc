using Toybox.Lang;
using Toybox.System;

/**
 * QRNumber
 * @author Kazuhiko Arase 
 */
class QRNumber extends QRData {
	function initialize(data) {
		QRData.initialize(Mode.MODE_NUMBER, data);
	}
	
	function write(buffer) {
		var data = getData();
	
	    var i = 0;

	    while (i + 2 < data.length() ) {
	      var num = parseInt(data.substring(i, i + 3));
	      buffer.put(num, 10);
	      i += 3;
	    }

	    if (i < data.length() ) {
	      if (data.length() - i == 1) {
	        var num = parseInt(data.substring(i, i + 1));
	        buffer.put(num, 4);
	      } else if (data.length() - i == 2) {
	        var num = parseInt(data.substring(i, i + 2));
	        buffer.put(num, 7);
	      }
	    }
	}
	
	function getLength() {
		return getData().length();
	}
	
	function parseInt(s) {
		var chars = s.toCharArray();
	    var num = 0;
	    for (var i = 0; i < chars.size(); i++) {
			num = num * 10 + parseIntFromChar(chars[i]);
	    }
	    return num;
	}

	function parseIntFromChar(c) {
	    if ('0' <= c && c <= '9') {
	    	return c.toNumber() - 48; // (c - '0')
	    }

	    throw new Lang.Exception("illegal char :" + c);
  	}
}