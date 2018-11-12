import QtQuick 1.1

import qb.base 1.0
import qb.components 1.0

Widget {
	id: tscSettingsFrame

	property TscSettingsApp app

	function updateRotateTiles() {
		switch(globals.tsc["rotateTiles"]) {
			case 0: rotateTilesLabel.rightText = "Disabled"; break;
			case 1: rotateTilesLabel.rightText = "Mode 1"; break;
			case 2: rotateTilesLabel.rightText = "Mode 2"; break;
			case 3: rotateTilesLabel.rightText = "Mode 3"; break;
			default: rotateTilesLabel.rightText = "unknown"; break;
		}
	}

	function updateHideErrorSystray() {
		hideErrorSystrayLabel.rightText = globals.tsc["hideErrorSystray"] ? "Enabled" : "Disabled";
	}

	function updateHideToonLogo() {
		switch(globals.tsc["hideToonLogo"]) {
			case 0: hideToonLogoLabel.rightText = "Disabled"; break;
			case 1: hideToonLogoLabel.rightText = "Only during dim"; break;
			case 2: hideToonLogoLabel.rightText = "Always"; break;
			default: hideToonLogoLabel.rightText = "unknown"; break;
		}
	}

	function updateCustomToonLogo() {
		switch(globals.tsc["customToonLogo"]) {
			case 0: customToonLogoLabel.rightText = "Disabled"; break;
			case 1: customToonLogoLabel.rightText = "Enabled"; break;
			default: customToonLogoLabel.rightText = "unknown"; break;
		}
	}

	function validatePin(text, isFinalString) {
		if (isFinalString) {
			if (text === app.localSettings.lockPinCode) {
				return null;
			} else {
				return { content: "You are not authorized to unlock the TSC settings" };
			}
		} else {
			return null;
		}
	}

	function setPin(text, isFinalString) {
		if (isFinalString) {
			var tempSettings = app.localSettings;
			tempSettings.lockPinCode = text; 
			app.localSettings = tempSettings;
			app.saveSettingsTsc();
			return null;
		} else {
			return null;
		}
	}


	function toggleLocking() {
		var tempSettings = app.localSettings; 
		tempSettings.locked = !tempSettings.locked
		app.localSettings = tempSettings;
		app.saveSettingsTsc();
		rotateTilesButton.enabled = !app.localSettings.locked;
		hideToonLogoButton.enabled = !app.localSettings.locked;;
		hideErrorSystrayButton.enabled = !app.localSettings.locked;;
		customToonLogoButton.enabled = !app.localSettings.locked;
		toggleFeaturesButton.enabled = !app.localSettings.locked;
		unlockButton.visible = app.localSettings.locked;
		lockButton.visible = !app.localSettings.locked;
		checkUpdateButton.visible = !app.localSettings.locked;
		flushFirewallButton.visible = !app.localSettings.locked;
		restartGuiButton.visible = !app.localSettings.locked;
		restorePasswordButton.visible = !app.localSettings.locked;
	}

	onShown: {
		updateRotateTiles();
		updateHideToonLogo();
		updateHideErrorSystray();
		updateCustomToonLogo();
	}

	anchors.fill: parent

	Item {
		id: labelContainer
		anchors {
			top: parent.top
			topMargin: 25
			left: parent.left
			leftMargin: Math.round(44 * 1.28)
			right: parent.right
			rightMargin: Math.round(27 * 1.28)
		}

		SingleLabel {
			id: rotateTilesLabel
			anchors {
				left: parent.left
				right: rotateTilesButton.left
				rightMargin: 8
			}
			leftText: qsTr("Rotate tiles")
			rightText: ""

		}

		IconButton {
			id: rotateTilesButton

			width: 45
			height: rotateTilesLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg" 

			anchors {
				top: rotateTilesLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.rotateTilesScreenUrl);
			}
		}

		SingleLabel {
			id: hideErrorSystrayLabel
			anchors {
				top: rotateTilesLabel.bottom
				topMargin: Math.round(15 * app.nxtScale)
				left: parent.left
				right: hideErrorSystrayButton.left
				rightMargin: 8
			}
			leftText: qsTr("Hide error systray icon")
			rightText: ""

		}

		IconButton {
			id: hideErrorSystrayButton

			width: 45
			height: hideErrorSystrayLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg" 

			anchors {
				top: hideErrorSystrayLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.hideErrorSystrayScreenUrl);
			}
		}

		SingleLabel {
			id: hideToonLogoLabel
			anchors {
				top: hideErrorSystrayLabel.bottom
				topMargin: Math.round(15 * app.nxtScale)
				left: parent.left
				right: hideToonLogoButton.left
				rightMargin: 8
			}
			leftText: qsTr("Hide Toon logo")
			rightText: ""

		}

		IconButton {
			id: hideToonLogoButton

			width: 45
			height: hideToonLogoLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg" 

			anchors {
				top: hideToonLogoLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.hideToonLogoScreenUrl);
			}
		}

		SingleLabel {
			id: customToonLogoLabel
			anchors {
				top: hideToonLogoButton.bottom
				topMargin: Math.round(15 * app.nxtScale)
				left: parent.left
				right: hideToonLogoButton.left
				rightMargin: 8
			}
			leftText: qsTr("Custom Toon logo")
			rightText: ""

		}

		IconButton {
			id: customToonLogoButton

			width: 45
			height: customToonLogoLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg"

			anchors {
				top: customToonLogoLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.customToonLogoScreenUrl);
			}
		}

		SingleLabel {
			id: toggleFeaturesLabel
			anchors {
				top: customToonLogoButton.bottom
				topMargin: Math.round(15 * app.nxtScale)
				left: parent.left
				right: hideToonLogoButton.left
				rightMargin: 8
			}
			leftText: "Toggle native Toon features" 
			rightText: ""

		}

		IconButton {
			id: toggleFeaturesButton

			width: 45
			height: toggleFeaturesLabel.height

			iconSource: "qrc:/images/edit.svg"

			enabled: !app.localSettings.locked

			anchors {
				top: toggleFeaturesLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.toggleFeaturesScreenUrl);
			}
		}


		StandardButton {
			id: unlockButton

			text: qsTr("Unlock TSC settings")

			height: 40 

			visible: app.localSettings.locked

			anchors {
				left: parent.left
				top: toggleFeaturesLabel.bottom
				topMargin: Math.round(15 * app.nxtScale)
			}

			topClickMargin: 2
			onClicked: {
				qnumKeyboard.open("TSC unlock PIN code", "", "PIN", "" , toggleLocking, validatePin);
				qnumKeyboard.state = "num_integer_clear_backspace";

			}
		}

		StandardButton {
			id: lockButton

			text: qsTr("Lock TSC settings")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: parent.left
				top: toggleFeaturesLabel.bottom
				topMargin: Math.round(15 * app.nxtScale)
			}

			topClickMargin: 2
			onClicked: {
				qnumKeyboard.open("TSC unlock PIN code", "", "PIN", "" , toggleLocking, setPin);
				qnumKeyboard.state = "num_integer_clear_backspace";
			}
		}


		StandardButton {
			id: checkUpdateButton

			text: qsTr("Check for updates")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: lockButton.right
				top: lockButton.top
				leftMargin: 20
			}

			topClickMargin: 2
			onClicked: {
				// remove old TSC notifications first
				notifications.removeByTypeSubType("tsc","notify");
				notifications.removeByTypeSubType("tsc","update");
				notifications.removeByTypeSubType("tsc","firmware");
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("tscupdate");
				commandFile.close
				checkUpdateButton.enabled=false;
				disableButtonTimer.start();
			}
		}

		StandardButton {
			id: flushFirewallButton

			text: qsTr("Flush firewall rules")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: checkUpdateButton.right
				top: checkUpdateButton.top
				leftMargin: 20
			}

			topClickMargin: 2
			onClicked: {
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("flushfirewall");
				commandFile.close
			}
		}

		StandardButton {
			id: restartGuiButton

			text: qsTr("Restart GUI")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: parent.left
				top: lockButton.bottom
				topMargin: Math.round(15 * app.nxtScale)
			}

			topClickMargin: 2
			onClicked: {
				Qt.quit();	
			}
		}

		StandardButton {
			id: restorePasswordButton

			text: qsTr("Restore password")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: restartGuiButton.right
				top: restartGuiButton.top
				leftMargin: 20
			}

			topClickMargin: 2
			onClicked: {
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("restorerootpassword");
				commandFile.close
			}
		}



	}
	Text {
		id: versionText
		text: "Versie: " + app.tscVersion
		anchors {
			baseline: parent.bottom
			baselineOffset: -5
			horizontalCenter: parent.horizontalCenter
		}
		font {
			pixelSize: isNxt ? 18 : 15
			family: qfont.italic.name
		}
		color: colors.taTrafficSource
	}

	IconButton {
		id: betaButton

		width: isNxt ? 48 : 38
		height: isNxt ? 63 : 50
		iconSource: ""

		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		colorUp : "transparent"
		colorDown : "transparent"
		onClicked: { 
			if (!app.localSettings.locked) {
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("togglebeta");
				commandFile.close
			}
		}
	}


	Timer {
		id: disableButtonTimer

		interval: 5000 
		onTriggered: {
			checkUpdateButton.enabled=true;
			disableButtonTimer.stop();
		}
	}

}
