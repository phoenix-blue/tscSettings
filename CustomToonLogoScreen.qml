import QtQuick 1.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: customToonLogoScreen

	isSaveCancelDialog: true
	screenTitle: "Custom Toon Logo"

	property bool firstShown: true;  // we need this because exiting a keyboard will load onShown again. Without this the input will be overwritten with the app settings again

	onShown: {
		if (firstShown) {
			radioButtonList.currentIndex = globals.tsc["customToonLogo"] 
			customToonLogoURLLabel.inputText = globals.tsc["customToonLogoURL"]
			firstShown = false;
		}
	}

	onSaved: {
			var myTsc = globals.tsc
			myTsc["customToonLogo"] = radioButtonList.currentIndex
			myTsc["customToonLogoURL"] = customToonLogoURLLabel.inputText
			globals.tsc = myTsc
			app.saveGlobalsTsc();
	}

	function saveURL(text) {
		if (text) {
			customToonLogoURLLabel.inputText = text;	
		}
	}

	RadioButtonList {
		id: radioButtonList
		width: Math.round(220 * 1.28)
		height: Math.round(250 * app.scaleNxt)

		anchors.centerIn: parent

		title: "Toon Custom 'TOON' logo?"

		Component.onCompleted: {
			addItem("Disabled");
			addItem("Enabled");
		}
	}
	
	EditTextLabel {
		id: customToonLogoURLLabel
		width: isNxt ? 800 : 650
		leftText: "Icon Url:"
		leftTextAvailableWidth: isNxt ? 125 : 100
		anchors {
			top: radioButtonList.bottom
			left: parent.left
			leftMargin: isNxt ? 60 : 50
		}
	
		onClicked: {
			qkeyboard.open("Custom logo URL", customToonLogoURLLabel.inputText, saveURL);
		}
	}
	
	IconButton {
		id: customToonLogoURLButton
		width: 45
		height: customToonLogoLabel.height
			iconSource: "qrc:/images/edit.svg" 
			anchors {
			top: customToonLogoURLLabel.top
			left: customToonLogoURLLabel.right
			leftMargin: 10
		}
		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Custom logo URL", customToonLogoURLLabel.inputText, saveURL);
		}
	}
}
