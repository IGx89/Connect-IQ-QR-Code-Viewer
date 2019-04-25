using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;

class QRCode {

	private var PAD0 = 0xEC;
	private var PAD1 = 0x11;
	
	private var mTypeNumber = 1;
	private var modules = [];
	private var moduleCount;
	private var mErrorCorrectionLevel = ErrorCorrectionLevel.H;
	private var qrDataList = [];

	function initialize() {}

	function getTypeNumber() {
		return self.mTypeNumber;
	}
	
	function setTypeNumber(typeNumber) {
		self.mTypeNumber = typeNumber;
	}
	
	function getErrorCorrectionLevel() {
		return self.mErrorCorrectionLevel;
	}
	
	function setErrorCorrectionLevel(errorCorrectionLevel) {
		self.mErrorCorrectionLevel = errorCorrectionLevel;
	}
	
	function addData(data, mode) {

		switch (mode) {
	
	    case Mode.MODE_NUMBER :
	      addDataInternal(new QRNumber(data));
	      break;
	
	    case Mode.MODE_ALPHA_NUM :
	      addDataInternal(new QRAlphaNum(data));
	      break;
	
	    case Mode.MODE_8BIT_BYTE :
	      addDataInternal(new QR8BitByte(data));
	      break;
	
	    default :
	      throw new Lang.Exception("mode:" + mode);
	    }
	}
	
	function clearData() {
		qrDataList.clear();
	}

	protected function addDataInternal(qrData) {
		qrDataList.add(qrData);
	}

	protected function getDataCount() {
		return qrDataList.size();
	}

	function getData(index) {
		return qrDataList[index];
	}
	
  	function isDark(row, col) {
		return self.modules[row][col];
	}

  function getModuleCount() {
    return self.moduleCount;
  }

  function make() {
    makeInternal(false, 0);
    
    // We're unable to use getBestMaskPattern() due to it being WAY too processor intensive for Garmin devices.
    // Hoping that mask pattern 0 is good enough...
    //makeInternal(false, getBestMaskPattern());
  }

  private function getBestMaskPattern() {

    var minLostPoint = 0;
    var pattern = 0;

    for (var i = 0; i < 8; i++) {

      makeInternal(true, i);

      var lostPoint = QRUtil.getLostPoint(self);

      if (i == 0 || minLostPoint >  lostPoint) {
        minLostPoint = lostPoint;
        pattern = i;
      }
    }

    return pattern;
  }
  
  private function makeInternal(test, maskPattern) {

    self.moduleCount = self.mTypeNumber * 4 + 17;
    self.modules = twoDimensionalArray(moduleCount, moduleCount);

    setupPositionProbePattern(0, 0);
    setupPositionProbePattern(moduleCount - 8, 0);
    setupPositionProbePattern(0, moduleCount - 8);

    setupPositionAdjustPattern();
    setupTimingPattern();

    setupTypeInfo(test, maskPattern);

    if (self.mTypeNumber >= 7) {
      setupTypeNumber(test);
    }

    var data = createData(self.mTypeNumber, self.mErrorCorrectionLevel, qrDataList);

    mapData(data, maskPattern);
  }

  private function mapData(data, maskPattern) {

    var inc = -1;
    var row = moduleCount - 1;
    var bitIndex = 7;
    var byteIndex = 0;

    for (var col = moduleCount - 1; col > 0; col -= 2) {

      if (col == 6) {
      	col--;
	  }

      while (true) {

        for (var c = 0; c < 2; c++) {

          if (modules[row][col - c] == null) {

            var dark = false;

            if (byteIndex < data.size()) {
              // >>>
              dark = ( ( (data[byteIndex] >> bitIndex) & 1) == 1);
            }

            var mask = QRUtil.getMask(maskPattern, row, col - c);

            if (mask) {
              dark = !dark;
            }

            modules[row][col - c] = dark;
            bitIndex--;

            if (bitIndex == -1) {
              byteIndex++;
              bitIndex = 7;
            }
          }
        }

        row += inc;

        if (row < 0 || moduleCount <= row) {
          row -= inc;
          inc = -inc;
          break;
        }
      }
    }
  }

  private function setupPositionAdjustPattern() {

    var pos = QRUtil.getPatternPosition(self.mTypeNumber);

    for (var i = 0; i < pos.size(); i++) {

      for (var j = 0; j < pos.size(); j++) {

        var row = pos[i];
        var col = pos[j];

        if (modules[row][col] != null) {
          continue;
        }

        for (var r = -2; r <= 2; r++) {

          for (var c = -2; c <= 2; c++) {

            if (r == -2 || r == 2 || c == -2 || c == 2
                || (r == 0 && c == 0) ) {
              modules[row + r][col + c] = true;
            } else {
              modules[row + r][col + c] = false;
            }
          }
        }

      }
    }
  }

	private function setupPositionProbePattern(row, col) {

		var probePattern = QRUtil.getProbePattern();
		
		var pRowOffset = row == 0 ? 1 : 0;
		var pColOffset = col == 0 ? 1 : 0;
	
	    for (var r = 0; r < 8; r++) {
			for (var c = 0; c < 8; c++) {
	        	modules[row + r][col + c] = probePattern[r + pRowOffset][c + pColOffset];
			}
		}
	}

  private function setupTimingPattern() {
    for (var r = 8; r < moduleCount - 8; r++) {
      if (modules[r][6] != null) {
        continue;
      }
      modules[r][6] = r % 2 == 0;
    }
    for (var c = 8; c < moduleCount - 8; c++) {
      if (modules[6][c] != null) {
        continue;
      }
      modules[6][c] = c % 2 == 0;
    }
  }

  private function setupTypeNumber(test) {

    var bits = QRUtil.getBCHTypeNumber(self.mTypeNumber);

    for (var i = 0; i < 18; i++) {
      var mod = !test && ( (bits >> i) & 1) == 1;
      modules[i / 3][i % 3 + moduleCount - 8 - 3] = mod;
    }

    for (var i = 0; i < 18; i++) {
      var mod = !test && ( (bits >> i) & 1) == 1;
      modules[i % 3 + moduleCount - 8 - 3][i / 3] = mod;
    }
  }

  private function setupTypeInfo(test, maskPattern) {

    var data = (self.mErrorCorrectionLevel << 3) | maskPattern;
    var bits = QRUtil.getBCHTypeInfo(data);

    for (var i = 0; i < 15; i++) {

      var mod = !test && ( (bits >> i) & 1) == 1;

      if (i < 6) {
        modules[i][8] = mod;
      } else if (i < 8) {
        modules[i + 1][8] = mod;
      } else {
        modules[moduleCount - 15 + i][8] = mod;
      }
    }

    for (var i = 0; i < 15; i++) {

      var mod = !test && ( (bits >> i) & 1) == 1;

      if (i < 8) {
        modules[8][moduleCount - i - 1] = mod;
      } else if (i < 9) {
        modules[8][15 - i - 1 + 1] = mod;
      } else {
        modules[8][15 - i - 1] = mod;
      }
    }

    modules[moduleCount - 8][8] = !test;
  }

  static function createData(typeNumber, errorCorrectionLevel, dataArray) {

    var rsBlocks = RSBlock.getRSBlocks(typeNumber, errorCorrectionLevel);

    var buffer = new BitBuffer();

    for (var i = 0; i < dataArray.size(); i++) {
      var data = dataArray[i];
      buffer.put(data.getMode(), 4);
      buffer.put(data.getLength(), data.getLengthInBits(typeNumber) );
      data.write(buffer);
    }

    var totalDataCount = 0;
    for (var i = 0; i < rsBlocks.size(); i++) {
      totalDataCount += rsBlocks[i].getDataCount();
    }

    if (buffer.getLengthInBits() > totalDataCount * 8) {
      throw new Lang.Exception("code length overflow. ("
        + buffer.getLengthInBits()
        + ">"
        +  totalDataCount * 8
        + ")");
    }

    if (buffer.getLengthInBits() + 4 <= totalDataCount * 8) {
      buffer.put(0, 4);
    }

    // padding
    while (buffer.getLengthInBits() % 8 != 0) {
      buffer.putBit(false);
    }

    // padding
    while (true) {

      if (buffer.getLengthInBits() >= totalDataCount * 8) {
        break;
      }
      buffer.put(PAD0, 8);

      if (buffer.getLengthInBits() >= totalDataCount * 8) {
        break;
      }
      buffer.put(PAD1, 8);
    }

    return createBytes(buffer, rsBlocks);
  }

  private static function createBytes(buffer, rsBlocks) {

    var offset = 0;

    var maxDcCount = 0;
    var maxEcCount = 0;

    var dcdata = new[rsBlocks.size()];
    var ecdata = new[rsBlocks.size()];

    for (var r = 0; r < rsBlocks.size(); r++) {

      var dcCount = rsBlocks[r].getDataCount();
      var ecCount = rsBlocks[r].getTotalCount() - dcCount;

      maxDcCount = max(maxDcCount, dcCount);
      maxEcCount = max(maxEcCount, ecCount);

      dcdata[r] = new[dcCount];
      for (var i = 0; i < dcdata[r].size(); i++) {
        dcdata[r][i] = 0xff & buffer.getBuffer()[i + offset];
      }
      offset += dcCount;

      var rsPoly = QRUtil.getErrorCorrectPolynomial(ecCount);
      var rawPoly = new Polynomial(dcdata[r], rsPoly.getLength() - 1);

      var modPoly = rawPoly.mod(rsPoly);
      ecdata[r] = new[rsPoly.getLength() - 1];
      for (var i = 0; i < ecdata[r].size(); i++) {
        var modIndex = i + modPoly.getLength() - ecdata[r].size();
        ecdata[r][i] = (modIndex >= 0)? modPoly.get(modIndex) : 0;
      }

    }

    var totalCodeCount = 0;
    for (var i = 0; i < rsBlocks.size(); i++) {
      totalCodeCount += rsBlocks[i].getTotalCount();
    }

    var data = new[totalCodeCount];

    var index = 0;
    var rsBlocksSize = rsBlocks.size();

    for (var i = 0; i < maxDcCount; i++) {
      for (var r = 0; r < rsBlocksSize; r++) {
        if (i < dcdata[r].size()) {
          data[index] = dcdata[r][i];
          index++;
        }
      }
    }

    for (var i = 0; i < maxEcCount; i++) {
      for (var r = 0; r < rsBlocksSize; r++) {
        if (i < ecdata[r].size()) {
          data[index] = ecdata[r][i];
          index++;
        }
      }
    }

    return data;
  }

  static function getMinimumQRCode(data, errorCorrectionLevel) {

    var mode = QRUtil.getMode(data);

    var qr = new QRCode();
    qr.setErrorCorrectionLevel(errorCorrectionLevel);
    qr.addData(data, mode);

    var length = qr.getData(0).getLength();

    for (var typeNumber = 1; typeNumber <= 10; typeNumber++) {
      if (length <= QRUtil.getMaxLength(typeNumber, mode, errorCorrectionLevel) ) {
        qr.setTypeNumber(typeNumber);
        break;
      }
    }

    qr.make();

    return qr;
  }
  
	function createImage(cellSize) {
		var moduleCount = getModuleCount();
    	var imageSize = moduleCount * cellSize;

		var image = new Graphics.BufferedBitmap(
			{:width=>imageSize,
			 :height=>imageSize,
			 :palette=>[Graphics.COLOR_BLACK,
                        Graphics.COLOR_WHITE]} );
        var dc = image.getDc();

		var color;
	    for (var col = 0; col < moduleCount; col++) {
	      var y = col * cellSize;
	    
	      for (var row = 0; row < moduleCount; row++) {
	      	  color = self.modules[row][col] ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
	          dc.setColor(color, color);
	          dc.fillRectangle(row * cellSize, y, moduleCount, moduleCount);
	      }
	    }
	
	    return image;
	}
}