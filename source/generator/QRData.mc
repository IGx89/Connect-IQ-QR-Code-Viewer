using Toybox.Lang;
using Toybox.System;

/**
 * QRData
 * @author Kazuhiko Arase 
 */
class QRData {
	private var mMode;
  	private var mData;
  	
  	function initialize(mode, data) {
	    mMode = mode;
	    mData = data;
	}
	
	function getMode() {
		return mMode;
	}
	
	function getData() {
		return mData;
	}
	
	/**
	 * Abstract
	*/
	function getLength() {
		throw new Lang.Exception("Abstract method not overridden");
	}
	
	/**
	 * Abstract
	*/
	function write(buffer) {
		throw new Lang.Exception("Abstract method not overridden");
	}
	
	function getLengthInBits(type) {
	    if (1 <= type && type < 10) {
	
	      // 1 - 9
	
	      switch(mMode) {
	      case Mode.MODE_NUMBER     : return 10;
	      case Mode.MODE_ALPHA_NUM   : return 9;
	      case Mode.MODE_8BIT_BYTE  : return 8;
	      case Mode.MODE_KANJI      : return 8;
	      default :
	        throw new Lang.Exception("mode:" + mode);
	      }
	
	    } else if (type < 27) {
	
	      // 10 - 26
	
	      switch(mMode) {
	      case Mode.MODE_NUMBER     : return 12;
	      case Mode.MODE_ALPHA_NUM   : return 11;
	      case Mode.MODE_8BIT_BYTE  : return 16;
	      case Mode.MODE_KANJI      : return 10;
	      default :
	        throw new Lang.Exception("mode:" + mode);
	      }
	
	    } else if (type < 41) {
	
	      // 27 - 40
	
	      switch(mMode) {
	      case Mode.MODE_NUMBER     : return 14;
	      case Mode.MODE_ALPHA_NUM  : return 13;
	      case Mode.MODE_8BIT_BYTE  : return 16;
	      case Mode.MODE_KANJI      : return 12;
	      default :
	        throw new Lang.Exception("mode:" + mode);
	      }
	
	    } else {
	      throw new Lang.Exception("type:" + type);
	    }
	}
}