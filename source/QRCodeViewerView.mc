using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Math;

class QRCodeViewerView extends Ui.View {

	var maxWidth  = 0;
	var maxHeight = 0;
	var offsetHeight = 0;
	var size = 0;

	var requestCounter = 0;
	var image = null;
	var imageWidth = 0;
	var imageHeight = 0;

	 // Set up the responseCallback function to return an image or null
	function onReceiveImage(responseCode, data) {
		requestCounter--;
		if(requestCounter==0) { // handle only the last request
			var app = App.getApp();
	
			if (responseCode == 200) {
				image = data;
			} else {
				image = null;
				app.setProperty("message", responseCode.format("%d"));
			}
			Ui.requestUpdate();
		}
	}

	function initialize() {
		View.initialize();
		
		// Doing as much prework as possible to avoid hitting the watchdog counter
		// when generating the QR code itself.
		QRMath.staticInitialize();
	}

	// Load your resources here
	function onLayout(dc) {
		var app = App.getApp();
		
		maxWidth = dc.getWidth()  * 0.8;
		maxHeight= dc.getHeight() * 0.8;
		if(maxWidth == maxHeight) {
			// For round device... Otherwise image is hidden in corner
			maxWidth = maxWidth * 0.8;
			maxHeight = maxHeight * 0.8;
		}

		if(app.getProperty("displayLabel")) {
			var fontHeight = Gfx.getFontHeight(Gfx.FONT_MEDIUM);
			var marginBottom = (dc.getHeight() - maxHeight) / 2;
			if(marginBottom < fontHeight) {
				offsetHeight = fontHeight - marginBottom;
				maxHeight = maxHeight - offsetHeight;
			}
		}
		size = app.getProperty("size");
		if(size == 0) {
			size = min(maxWidth, maxHeight);
		}
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
		var app = App.getApp();
		var data  = app.getProperty("data");

		if (data != null) {
			image = null;
		
			var qr = QRCode.getMinimumQRCode(data, ErrorCorrectionLevel.M);
			
			var cellSize = Math.floor(size / qr.getModuleCount());
			image = qr.createImage(cellSize);
			imageWidth = qr.getModuleCount() * cellSize;
			imageHeight = imageWidth;
			
			// TODO: use the previous HTTP method of QR code generation for devices
			// not powerful enough to generate it locally?
			/*
			image = null;
			data = Communications.encodeURL(data);
			var strUrl = app.getProperty("QRCodeGeneratingURL");
			var sizeStr = size.format("%d");
			strUrl = stringReplace(strUrl, "${DATA}", data);
			strUrl = stringReplace(strUrl, "${SIZE}", sizeStr);
			strUrl = stringReplace(strUrl, "${MARGIN}", 0);
			requestCounter++;
			Comm.makeImageRequest(
				strUrl,
				{},
				{
					:maxWidth => size,
					:maxHeight=> size
				},
				method(:onReceiveImage)
			);
			*/
		}
	}

	// Update the view
	function onUpdate(dc) {
		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
		
		var app = App.getApp();
		var message = app.getProperty("message");
		var data    = app.getProperty("data");

		if(message != null) {
			dc.setColor (Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
			dc.drawText(
				(dc.getWidth()) / 2,
				(dc.getHeight()) / 2,
				Gfx.FONT_MEDIUM,
				message,
				Gfx.TEXT_JUSTIFY_CENTER
			);
		}
		if(data != null && image != null) {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
			dc.clear();
			if(app.getProperty("displayLabel") && message != null) {
				dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
				dc.drawText(
					(dc.getWidth()) / 2,
					(dc.getHeight() + imageHeight) / 2 - offsetHeight - app.getProperty("offsetY"),
					Gfx.FONT_MEDIUM,
					message,
					Gfx.TEXT_JUSTIFY_CENTER
				);
			}
			dc.drawBitmap(
				(dc.getWidth() - imageWidth ) / 2,
				(dc.getHeight() - imageHeight) / 2 - offsetHeight - app.getProperty("offsetY"),
				image
			);
		}
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

}
