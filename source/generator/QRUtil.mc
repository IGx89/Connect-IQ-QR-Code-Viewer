using Toybox.Lang;

class QRUtil {

	private static const PATTERN_POSITION_TABLE = [
	    []b,
	    [6, 18]b,
	    [6, 22]b,
	    [6, 26]b,
	    [6, 30]b,
	    [6, 34]b,
	    [6, 22, 38]b,
	    [6, 24, 42]b,
	    [6, 26, 46]b,
	    [6, 28, 50]b,
	    [6, 30, 54]b,
	    [6, 32, 58]b,
	    [6, 34, 62]b,
	    [6, 26, 46, 66]b,
	    [6, 26, 48, 70]b,
	    [6, 26, 50, 74]b,
	    [6, 30, 54, 78]b,
	    [6, 30, 56, 82]b,
	    [6, 30, 58, 86]b,
	    [6, 34, 62, 90]b,
	    [6, 28, 50, 72, 94]b,
	    [6, 26, 50, 74, 98]b,
	    [6, 30, 54, 78, 102]b,
	    [6, 28, 54, 80, 106]b,
	    [6, 32, 58, 84, 110]b,
	    [6, 30, 58, 86, 114]b,
	    [6, 34, 62, 90, 118]b,
	    [6, 26, 50, 74, 98, 122]b,
	    [6, 30, 54, 78, 102, 126]b,
	    [6, 26, 52, 78, 104, 130]b,
	    [6, 30, 56, 82, 108, 134]b,
	    [6, 34, 60, 86, 112, 138]b,
	    [6, 30, 58, 86, 114, 142]b,
	    [6, 34, 62, 90, 118, 146]b,
	    [6, 30, 54, 78, 102, 126, 150]b,
	    [6, 24, 50, 76, 102, 128, 154]b,
	    [6, 28, 54, 80, 106, 132, 158]b,
	    [6, 32, 58, 84, 110, 136, 162]b,
	    [6, 26, 54, 82, 110, 138, 166]b,
	    [6, 30, 58, 86, 114, 142, 170]b
	];
	
	private static const PROBE_PATTERN = [
		[0, 0, 0, 0, 0, 0, 0, 0, 0]b,
		[0, 1, 1, 1, 1, 1, 1, 1, 0]b,
		[0, 1, 0, 0, 0, 0, 0, 1, 0]b,
		[0, 1, 0, 1, 1, 1, 0, 1, 0]b,
		[0, 1, 0, 1, 1, 1, 0, 1, 0]b,
		[0, 1, 0, 1, 1, 1, 0, 1, 0]b,
		[0, 1, 0, 0, 0, 0, 0, 1, 0]b,
		[0, 1, 1, 1, 1, 1, 1, 1, 0]b,
		[0, 0, 0, 0, 0, 0, 0, 0, 0]b
	];
	
	// Grouped by type, error correction level, and mode. For example, type=3, ecl=M, mode=8BIT_BYTE gives 42
    private static const MAX_LENGTH = [
        41,  25,  17,  10,    34,  20,  14,  8,     27,  16,  11,  7,    17,  10,  7,   4,
        77,  47,  32,  20,    63,  38,  26,  16,    48,  29,  20,  12,   34,  20,  14,  8,
        127, 77,  53,  32,    101, 61,  42,  26,    77,  47,  32,  20,   58,  35,  24,  15,
        187, 114, 78,  48,    149, 90,  62,  38,    111, 67,  46,  28,   82,  50,  34,  21,
        255, 154, 106, 65,    202, 122, 84,  52,    144, 87,  60,  37,   106, 64,  44,  27,
        322, 195, 134, 82,    255, 154, 106, 65,    178, 108, 74,  45,   139, 84,  58,  36,
        370, 224, 154, 95,    293, 178, 122, 75,    207, 125, 86,  53,   154, 93,  64,  39,
        461, 279, 192, 118,   365, 221, 152, 93,    259, 157, 108, 66,   202, 122, 84,  52,
        552, 335, 230, 141,   432, 262, 180, 111,   312, 189, 130, 80,   235, 143, 98,  60,
        652, 395, 271, 167,   513, 311, 213, 131,   364, 221, 151, 93,   288, 174, 119, 74
    ];
    
	private static const G15 = (1 << 10) | (1 << 8) | (1 << 5)
    	| (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0);

	private static const G18 = (1 << 12) | (1 << 11) | (1 << 10)
    	| (1 << 9) | (1 << 8) | (1 << 5) | (1 << 2) | (1 << 0);

	private static const G15_MASK = (1 << 14) | (1 << 12) | (1 << 10)
    	| (1 << 4) | (1 << 1);


	static function getPatternPosition(typeNumber) {
		return PATTERN_POSITION_TABLE[typeNumber - 1];
	}
	
	static function getProbePattern() {
		return PROBE_PATTERN;
	}
	
    static function getMaxLength(typeNumber, mode, errorCorrectionLevel) {

        var t = typeNumber - 1;
        var e = 0;
        var m = 0;

        switch(errorCorrectionLevel) {
        case ErrorCorrectionLevel.L : e = 0; break;
        case ErrorCorrectionLevel.M : e = 1; break;
        case ErrorCorrectionLevel.Q : e = 2; break;
        case ErrorCorrectionLevel.H : e = 3; break;
        default :
            throw new Lang.Exception("e:" + errorCorrectionLevel);
        }

        switch(mode) {
        case Mode.MODE_NUMBER    : m = 0; break;
        case Mode.MODE_ALPHA_NUM : m = 1; break;
        case Mode.MODE_8BIT_BYTE : m = 2; break;
        case Mode.MODE_KANJI     : m = 3; break;
        default :
            throw new Lang.Exception("m:" + mode);
        }

        return MAX_LENGTH[t*16 + e*4 + m];
    }
    
	static function getErrorCorrectPolynomial(errorCorrectLength) {

    	var a = new Polynomial([1], 0);

		for (var i = 0; i < errorCorrectLength; i++) {
			a = a.multiply(new Polynomial([1, QRMath.gexp(i) ], 0) );
		}

		return a;
	}
  
    static function getMask(maskPattern, i, j) {

		switch (maskPattern) {
		
		case MaskPattern.PATTERN000 : return (i + j) % 2 == 0;
		case MaskPattern.PATTERN001 : return i % 2 == 0;
		case MaskPattern.PATTERN010 : return j % 3 == 0;
		case MaskPattern.PATTERN011 : return (i + j) % 3 == 0;
		case MaskPattern.PATTERN100 : return (i / 2 + j / 3) % 2 == 0;
		case MaskPattern.PATTERN101 : return (i * j) % 2 + (i * j) % 3 == 0;
		case MaskPattern.PATTERN110 : return ( (i * j) % 2 + (i * j) % 3) % 2 == 0;
		case MaskPattern.PATTERN111 : return ( (i * j) % 3 + (i + j) % 2) % 2 == 0;
		
		default :
			throw new Lang.Exception("mask:" + maskPattern);
		}
	}
/*
	static function getLostPoint(qrCode) {

    var moduleCount = qrCode.getModuleCount();

    var lostPoint = 0;


    // LEVEL1

    for (var row = 0; row < moduleCount; row++) {

      for (var col = 0; col < moduleCount; col++) {

        var sameCount = 0;
        var dark = qrCode.isDark(row, col);

        for (var r = -1; r <= 1; r++) {

          if (row + r < 0 || moduleCount <= row + r) {
            continue;
          }

          for (var c = -1; c <= 1; c++) {

            if (col + c < 0 || moduleCount <= col + c) {
              continue;
            }

            if (r == 0 && c == 0) {
              continue;
            }

            if (dark == qrCode.isDark(row + r, col + c) ) {
              sameCount++;
            }
          }
        }

        if (sameCount > 5) {
          lostPoint += (3 + sameCount - 5);
        }
      }
    }

    // LEVEL2

    for (var row = 0; row < moduleCount - 1; row++) {
      for (var col = 0; col < moduleCount - 1; col++) {
        var count = 0;
        if (qrCode.isDark(row,     col    ) ) { count++; }
        if (qrCode.isDark(row + 1, col    ) ) { count++; }
        if (qrCode.isDark(row,     col + 1) ) { count++; }
        if (qrCode.isDark(row + 1, col + 1) ) { count++; }
        if (count == 0 || count == 4) {
          lostPoint += 3;
        }
      }
    }

    // LEVEL3

    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount - 6; col++) {
        if (qrCode.isDark(row, col)
            && !qrCode.isDark(row, col + 1)
            &&  qrCode.isDark(row, col + 2)
            &&  qrCode.isDark(row, col + 3)
            &&  qrCode.isDark(row, col + 4)
            && !qrCode.isDark(row, col + 5)
            &&  qrCode.isDark(row, col + 6) ) {
          lostPoint += 40;
        }
      }
    }

    for (var col = 0; col < moduleCount; col++) {
      for (var row = 0; row < moduleCount - 6; row++) {
        if (qrCode.isDark(row, col)
            && !qrCode.isDark(row + 1, col)
            &&  qrCode.isDark(row + 2, col)
            &&  qrCode.isDark(row + 3, col)
            &&  qrCode.isDark(row + 4, col)
            && !qrCode.isDark(row + 5, col)
            &&  qrCode.isDark(row + 6, col) ) {
          lostPoint += 40;
        }
      }
    }

    // LEVEL4

    var darkCount = 0;

    for (var col = 0; col < moduleCount; col++) {
      for (var row = 0; row < moduleCount; row++) {
        if (qrCode.isDark(row, col) ) {
          darkCount++;
        }
      }
    }

    var ratio = ((100 * darkCount / moduleCount / moduleCount - 50) / 5).abs();
    lostPoint += ratio * 10;

    return lostPoint;
  }
  */
  static function getMode(s) {
    
    if (isNumber(s)) {
      return Mode.MODE_NUMBER;
    } else if (isAlphaNum(s)) {
      return Mode.MODE_ALPHA_NUM;
    } else {
      return Mode.MODE_8BIT_BYTE;
    }
  }

  static function isNumber(s) {
    var arrChar = s.toCharArray();
    for (var i = 0; i < arrChar.size(); i++) {
      var c = arrChar[i];
      if (!('0' <= c && c <= '9') ) {
        return false;
      }
    }
    return true;
  }

  static function isAlphaNum(s) {
    var arrChar = s.toCharArray();
    for (var i = 0; i < arrChar.size(); i++) {
      var c = arrChar[i];
      if (!('0' <= c && c <= '9') && !('A' <= c && c <= 'Z') && " $%*+-./:".find(c.toString()) == null) {
        return false;
      }
    }
    return true;
  }
  
	static function getBCHTypeInfo(data) {
    	var d = data << 10;
    	while (getBCHDigit(d) - getBCHDigit(G15) >= 0) {
			d ^= (G15 << (getBCHDigit(d) - getBCHDigit(G15) ) );
		}
		return ( (data << 10) | d) ^ G15_MASK;
	}

	static function getBCHTypeNumber(data) {
	    var d = data << 12;
	    while (getBCHDigit(d) - getBCHDigit(G18) >= 0) {
			d ^= (G18 << (getBCHDigit(d) - getBCHDigit(G18) ) );
	    }
	    return (data << 12) | d;
	}

	private static function getBCHDigit(data) {
		var digit = 0;
	
	    while (data != 0) {
	    	digit++;
	    	// >>>=
	    	data >>= 1;
	    }
	
	    return digit;
	}
}