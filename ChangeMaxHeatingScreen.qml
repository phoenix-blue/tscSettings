import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import BxtClient 1.0

Screen {
	id: tscChangeMaxHeatingScreen

	isSaveCancelDialog: true
	screenTitle: "Change max heating setpoint"

	property bool firstShown: true;  // we need this because exiting a keyboard will load onShown again. Without this the input will be overwritten with the app settings again


	onSaved: {
		app.setMaxHeat(maxHeating.inputText);
	}

	onShown: {
		if (firstShown) {
                        maxHeating.inputText = globals.tsc["maxHeatingTemp"]
			firstShown = false;
		}
	}

        Text {
                id: bodyText

                width: Math.round(650 * app.nxtScale)
                wrapMode: Text.WordWrap

                text: "Set maximum heating temp, after setting the toon will restart for changes to take effect"
                color: "#000000"

                font.pixelSize: qfont.bodyText
                font.family: qfont.regular.name

                anchors {
                        top: parent.top
                        topMargin: isNxt ? Math.round(10 * 1.28) : 10
                        horizontalCenter: parent.horizontalCenter
                }
        }

	EditTextLabel {
		id: maxHeating
		width: isNxt ? 300 : 250
		leftText: "Max temp.:"
		inputHints: Qt.ImhDigitsOnly
		anchors {
			top: bodyText.bottom
			topMargin : 10
			left: parent.left
			leftMargin: isNxt ? 60 : 50
		}
	}

	
}

