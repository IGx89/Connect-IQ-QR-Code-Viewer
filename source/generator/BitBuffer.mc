using Toybox.System as Sys;

/**
 * BitBuffer
 * @author Kazuhiko Arase 
 */
class BitBuffer {
	private var buffer;
  	var length = 0;
  	var inclements;

	function initialize() {
	    inclements = 32;
	    buffer = emptyArray(inclements);
	}

	function getBuffer() {
		return buffer;
  	}

	function getLengthInBits() {
    	return length;
  	}

	function toString() {
	    var strBuffer = "";
	    for (var i = 0; i < getLengthInBits(); i++) {
      		strBuffer += get(i) ? '1' : '0';
	    }
	    return strBuffer;
  	}

	function get(index) {
		// was >>>, an unsigned shift, in Java
		return ( (buffer[index / 8] >> (7 - index % 8) ) & 1) == 1;
	}

	function put(num, length) {
    	for (var i = 0; i < length; i++) {
    		// was >>>, an unsigned shift, in Java
      		putBit( ( (num >> (length - i - 1) ) & 1) == 1);
    	}
  	}

 	function putBit(bit) {

	    if (length == buffer.size() * 8) {
	      	buffer.addAll(emptyArray(inclements));
	    }
	
	    if (bit) {
	    	// was >>>, an unsigned shift, in Java
	      	buffer[length / 8] |= (0x80 >> (length % 8) );
	    }
	
	    length++;
  	}
}
