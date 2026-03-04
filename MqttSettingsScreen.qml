import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

Screen {
	id: mqttSettingsScreen

	isSaveCancelDialog: true
	screenTitle: "MQTT settings"

	property bool firstShown: true
	property variant mqttConfig: ({})

	function loadMqttConfig() {
		var readFile = new XMLHttpRequest();
		readFile.onreadystatechange = function() {
			if (readFile.readyState == XMLHttpRequest.DONE) {
				if (readFile.responseText.length > 0) {
					try {
						mqttConfig = JSON.parse(readFile.responseText)
					} catch(e) {
						mqttConfig = ({})
					}
				}

			brokerLabel.inputText = mqttConfig["broker"] ? mqttConfig["broker"] : "192.168.1.100"
			portLabel.inputText = mqttConfig["port"] ? mqttConfig["port"].toString() : "1883"
			usernameLabel.inputText = mqttConfig["username"] ? mqttConfig["username"] : ""
			passwordLabel.inputText = mqttConfig["password"] ? mqttConfig["password"] : ""
			topicLabel.inputText = mqttConfig["topic"] ? mqttConfig["topic"] : "toon/woonkamer"
			intervalLabel.inputText = mqttConfig["interval"] ? mqttConfig["interval"].toString() : "30"
		}
	}
		readFile.open("GET", "file:///mnt/data/tsc/mqtt-config.json", true)
		readFile.send()
	}

	onShown: {
		if (firstShown) {
			firstShown = false
		}
		loadMqttConfig()
	}

	onSaved: {
		var parsedPort = parseInt(portLabel.inputText)
		var parsedInterval = parseInt(intervalLabel.inputText)

		if (isNaN(parsedPort)) parsedPort = 1883
		if (isNaN(parsedInterval)) parsedInterval = 30

		var saveData = {
			"broker": brokerLabel.inputText,
			"port": parsedPort,
			"username": usernameLabel.inputText,
			"password": passwordLabel.inputText,
			"topic": topicLabel.inputText,
			"interval": parsedInterval,
			"enabled_sensors": ["temperature", "humidity", "setpoint", "burner", "modulation", "program_state", "active_state", "power_usage", "power_production", "gas_usage"]
		}

		var saveFile = new XMLHttpRequest();
		saveFile.open("PUT", "file:///mnt/data/tsc/mqtt-config.json");
		saveFile.send(JSON.stringify(saveData));

		var commandFile = new XMLHttpRequest();
		commandFile.open("PUT", "file:///tmp/tsc.command");
		commandFile.send("mqttrestart");
		commandFile.close
	}

	Text {
		id: bodyText

		width: Math.round(650 * app.nxtScale)
		wrapMode: Text.WordWrap

		text: "Configureer MQTT broker gegevens. Opslaan herstart de MQTT service."
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
		id: brokerLabel
		width: isNxt ? 600 : 500
		leftText: "Broker IP:"
		anchors {
			top: bodyText.bottom
			topMargin: 10
			left: parent.left
			leftMargin: isNxt ? 60 : 50
		}
	}

	EditTextLabel {
		id: portLabel
		width: isNxt ? 300 : 250
		leftText: "Poort:"
		inputHints: Qt.ImhDigitsOnly
		anchors {
			top: brokerLabel.bottom
			topMargin: 10
			left: brokerLabel.left
		}
	}

	EditTextLabel {
		id: usernameLabel
		width: isNxt ? 600 : 500
		leftText: "Gebruiker:"
		anchors {
			top: portLabel.bottom
			topMargin: 10
			left: brokerLabel.left
		}
	}

	EditTextLabel {
		id: passwordLabel
		width: isNxt ? 600 : 500
		leftText: "Wachtwoord:"
		anchors {
			top: usernameLabel.bottom
			topMargin: 10
			left: brokerLabel.left
		}
	}

	EditTextLabel {
		id: topicLabel
		width: isNxt ? 600 : 500
		leftText: "Topic basis:"
		anchors {
			top: passwordLabel.bottom
			topMargin: 10
			left: brokerLabel.left
		}
	}

	EditTextLabel {
		id: intervalLabel
		width: isNxt ? 300 : 250
		leftText: "Interval (sec):"
		inputHints: Qt.ImhDigitsOnly
		anchors {
			top: topicLabel.bottom
			topMargin: 10
			left: brokerLabel.left
		}
	}
}
