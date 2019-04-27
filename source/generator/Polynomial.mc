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
  
  function clone() {
  	return mNum.slice(0, null);
  }

  function multiply(e) {
    var eLength = e.getLength();
  
    var num = emptyArray(mNum.size() + eLength - 1);

    for (var i = 0; i < mNum.size(); i++) {
      var pGLog = QRMath.glog(mNum[i]);
      for (var j = 0; j < eLength; j++) {
        num[i + j] ^= QRMath.gexp(pGLog + QRMath.glog(e.get(j)));
      }
    }

    return new Polynomial(num, 0);
  }
  
	function mod(e) {
		var eLength = e.getLength();
		
		var eGLogs = new[eLength];
		for (var i=0; i<eLength; i++) {
			eGLogs[i] = QRMath.glog(e.get(i));
		}
	
		var p = self;
		while (p.getLength() - eLength >= 0) {
			var num = p.clone();
		
			var ratio = QRMath.glog(num[0]) - eGLogs[0];
			
			for (var i = 0; i < eLength; i++) {
				num[i] ^= QRMath.gexp(eGLogs[i] + ratio);
			}
	    
			p = new Polynomial(num, 0);
		}
    
		return p;
	}
}