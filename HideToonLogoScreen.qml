import QtQuick 1.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: hideToonLogoScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("Hide Toon Logo")

	onShown: radioButtonList.currentIndex = globals.tsc["hideToonLogo"] 
	onSaved: {
			var myTsc = globals.tsc
			myTsc["hideToonLogo"] = radioButtonList.currentIndex
			globals.tsc = myTsc
			app.saveSettingsTsc();
	}

	RadioButtonList {
		id: radioButtonList
		width: Math.round(220 * 1.28)
		height: Math.round(250 * app.nxtScale)

		anchors.centerIn: parent

		title: qsTr("Hide the Toon logo")

		Component.onCompleted: {
			addItem("Disabled");
			addItem("Only during dim");
			addItem("Always");
		}
	}

}
