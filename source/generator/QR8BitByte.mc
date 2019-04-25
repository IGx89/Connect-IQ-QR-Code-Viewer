using Toybox.Lang;
using Toybox.System;

/**
 * QR8BitByte
 * @author Kazuhiko Arase 
 */
class QR8BitByte extends QRData {
	function initialize(data) {
		QRData.initialize(Mode.MODE_8BIT_BYTE, data);
	}
	
	function write(buffer) {
		var data = getData().toUtf8Array();

		for (var i = 0; i < data.size(); i++) {
			buffer.put(data[i], 8);
		}
	}
	
	function getLength() {
		return getData().toUtf8Array().size();
	}
}