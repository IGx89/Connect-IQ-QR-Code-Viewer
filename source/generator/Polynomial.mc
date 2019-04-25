using Toybox.System;

/**
 * Polynomial
 * @author Kazuhiko Arase 
 */
class Polynomial {

  private var mNum;

  function initialize(num, shift) {

    var offset = 0;

    while (offset < num.size() && num[offset] == 0) {
      offset++;
    }

    mNum = num.slice(offset, null);

	if (shift > 0) {
      mNum.addAll(emptyArray(shift));
    }
  }

  function get(index) {
    return mNum[index];
  }

  function getLength() {
    return mNum.size();
  }

  function toString() {

    var strBuffer = "";

    for (var i = 0; i < mNum.size(); i++) {
      if (i > 0) {
        strBuffer += ",";
      }
      strBuffer += mNum[i];
    }

    return strBuffer;
  }

  function toLogString() {

    var strBuffer = "";

    for (var i = 0; i < mNum.size(); i++) {
      if (i > 0) {
        strBuffer += ",";
      }
      strBuffer += QRMath.glog(mNum[i]);

    }

    return strBuffer;
  }

  function multiply(e) {
    var num = emptyArray(mNum.size() + e.getLength() - 1);

    for (var i = 0; i < mNum.size(); i++) {
      for (var j = 0; j < e.getLength(); j++) {
        num[i + j] ^= QRMath.gexp(QRMath.glog(mNum[i]) + QRMath.glog(e.get(j)));
      }
    }

    return new Polynomial(num, 0);
  }
  
  function mod(e) {
    if (mNum.size() - e.getLength() < 0) {
      return self;
    }

    var ratio = QRMath.glog(mNum[0]) - QRMath.glog(e.get(0));

    var num = mNum.slice(0, null);
    
    for (var i = 0; i < e.getLength(); i++) {
      num[i] ^= QRMath.gexp(QRMath.glog(e.get(i)) + ratio);
    }

    return new Polynomial(num, 0).mod(e);
  }
}