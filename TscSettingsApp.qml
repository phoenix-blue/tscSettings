import QtQuick 1.1
import BxtClient 1.0
import FileIO 1.0

import qb.components 1.0
import qb.base 1.0

App {
	id: tscSettingsApp

	property url tscFrameUrl: "TscFrame.qml"
	property url rotateTilesScreenUrl: "RotateTilesScreen.qml"
	property url toggleFeaturesScreenUrl: "ToggleFeaturesScreen.qml"
	property url firmwareUpdateScreenUrl: "FirmwareUpdate.qml"
        property url softwareUpdateInProgressPopupUrl: "SoftwareUpdateInProgressPopup.qml"
        property Popup softwareUpdateInProgressPopup
	property url hideToonLogoScreenUrl: "HideToonLogoScreen.qml"
	property url customToonLogoScreenUrl: "CustomToonLogoScreen.qml"
        property url settingsScreenUrl: "qrc:/apps/settings/SettingsScreen.qml"

	property string tscVersion: "1.3.0 (BETA)"

	property real nxtScale: isNxt ? 1.25 : 1 
	property bool rebootNeeded: false
	
	FileIO { 
		id: startupFileIO
	}

        FileIO {
                id: downloadStatusFile
                source: "file:///tmp/update.status.vars"
                onError: console.log("Can't open /tmp/update.status.vars")
        }

	function init() {
		registry.registerWidget("settingsFrame", tscFrameUrl, this, "tscFrame", {categoryName: "TSC", categoryWeight: 310});
		registry.registerWidget("screen", rotateTilesScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", toggleFeaturesScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", firmwareUpdateScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", hideToonLogoScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", customToonLogoScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("popup", softwareUpdateInProgressPopupUrl, this,"softwareUpdateInProgressPopup");
                notifications.registerType("tsc", notifications.prio_HIGHEST, Qt.resolvedUrl("drawables/notification-update.svg"), settingsScreenUrl, {"categoryUrl": tscFrameUrl}, "Meerdere TSC notifications");
		notifications.registerSubtype("tsc", "update", settingsScreenUrl, {"categoryUrl": tscFrameUrl});
		notifications.registerSubtype("tsc", "firmware", firmwareUpdateScreenUrl, {});
	}

        QtObject {
                id: p

                property string configMsgUuid
	}


        Component.onCompleted: {
                // load the settings on completed is recommended instead of during init
		loadSettings();
		createStartupFile();
        }

        function loadSettings()  {
                var settingsFile = new XMLHttpRequest();
                settingsFile.onreadystatechange = function() {
                        if (settingsFile.readyState == XMLHttpRequest.DONE) {
                                if (settingsFile.responseText.length > 0)  {
                                        var temp = JSON.parse(settingsFile.responseText);
                                        for (var setting in globals.tsc) {
                                                if (!temp[setting])  { temp[setting] = globals.tsc[setting]; } // use default if no saved setting exists
                                        }
                                        globals.tsc = temp;
					if (stage.logo) stage.logo.visible = (globals.tsc["hideToonLogo"] !== 2 );
                                }
                        }
                }
                settingsFile.open("GET", "file:///HCBv2/qml/config/tsc.settings", true);
                settingsFile.send();
        }

	function saveGlobalsTsc() {
                // save the new settings into the json file
                var saveFile = new XMLHttpRequest();
                saveFile.open("PUT", "file:///HCBv2/qml/config/tsc.settings");
                saveFile.send(JSON.stringify(globals.tsc));
	}

	function createStartupFile() {
		// create a startup file which downloads the TSC control script and installs a inittab routine
  		var startupFileCheck = new XMLHttpRequest();
		console.log("TSC: checking tsc boot file"); 
                startupFileCheck.onreadystatechange = function() {
                        if (startupFileCheck.readyState == XMLHttpRequest.DONE) {
                                if (startupFileCheck.responseText.length === 0)  {
					console.log("TSC: missing tsc boot startup file, creating it")
	        			var startupFile = new XMLHttpRequest();
					startupFile.open("PUT", "file:///etc/rc5.d/S99tsc.sh");
					startupFile.send("if [ ! -s /usr/bin/tsc ] || grep -q no-check-certificate /usr/bin/tsc ; then /usr/bin/curl -Nks --retry 5 --connect-timeout 2 https://raw.githubusercontent.com/IgorYbema/tscSettings/master/tsc -o /usr/bin/tsc ; chmod +x /usr/bin/tsc ; fi ; if ! grep -q tscs /etc/inittab ; then sed -i '/qtqt/a\ tscs:245:respawn:/usr/bin/tsc >/var/log/tsc 2>&1' /etc/inittab ; if grep tscs /etc/inittab ; then reboot ; fi ; fi");
					startupFile.close;
					rebootNeeded = true;
				}
                                if (startupFileCheck.responseText.indexOf("curl") === -1)  {
					console.log("TSC: tsc boot startup file wrong, modifying it")
	        			var startupFile = new XMLHttpRequest();
					startupFile.open("PUT", "file:///etc/rc5.d/S99tsc.sh");
					startupFile.send("if [ ! -s /usr/bin/tsc ] || grep -q no-check-certificate /usr/bin/tsc ; then /usr/bin/curl -Nks --retry 5 --connect-timeout 2 https://raw.githubusercontent.com/IgorYbema/tscSettings/master/tsc -o /usr/bin/tsc ; chmod +x /usr/bin/tsc ; fi ; if ! grep -q tscs /etc/inittab ; then sed -i '/qtqt/a\ tscs:245:respawn:/usr/bin/tsc >/var/log/tsc 2>&1' /etc/inittab ; if grep tscs /etc/inittab ; then reboot ; fi ; fi");
					startupFile.close;
					rebootNeeded = true;
				}
			}
		}
                startupFileCheck.open("GET", "file:///etc/rc5.d/S99tsc.sh", true);
                startupFileCheck.send();
	}

        function getSoftwareUpdateStatus() {
                var downloadStatusText = downloadStatusFile.read();
                var keysAndValues = downloadStatusText.split('&');
                var retVal = {'action': '', 'item': 0}
                var keyvaluepair = ''

                for (var i = 0; i < keysAndValues.length; i++) {
                        keyvaluepair = keysAndValues[i].split('=');
                        retVal[keyvaluepair[0]] = keyvaluepair[1];
                }
                return retVal;
        }

        BxtDiscoveryHandler {
                id: configDiscoHandler
                deviceType: "hcb_config"

		onDiscoReceived: {
			if (rebootNeeded) {
				//rebooting the toon to let the startup script do some work
				var restartToonMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, deviceUuid, "specific1", "RequestReboot");
				bxtClient.sendMsg(restartToonMessage);
			}
                }
        }
}
