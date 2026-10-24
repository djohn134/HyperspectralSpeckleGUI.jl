import jlqml
import Makie
import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

ApplicationWindow {
    id: mainGui
    title: "HyperspectralSpeckleGUI"
    width: 1650
    height: 1075
    minimumWidth: 1650
    minimumHeight: 1075
    visible: true

    property int textFieldWidth: 125
    property int textWidth: 175

    SystemPalette { 
        id: sysPalette
        colorGroup: SystemPalette.Active
    }
    color: sysPalette.window

    Component.onCompleted: {
        observables.windowColor = sysPalette.mid.toString();
        observables.windowText = sysPalette.windowText.toString();
        observables.windowDarkColor = sysPalette.dark.toString();

        var tableRows = []
        for (var ix = 0; ix < observables.layerHeights.length; ix++) {
            tableRows[ix] = {
                "layer": ix+1,
                "height": observables.layerHeights[ix] * 1e-3,
                "windSpeed": observables.windSpeed[ix],
                "windDirection": observables.windDirection[ix],
                "seed": observables.randomSeed[ix]
            }
        }
        layersModel.rows = tableRows
    }

    header: Rectangle{
        id: headerBar
        height: 40
        width: parent.width
        color: sysPalette.mid
        anchors.margins: 5

        Text {
            id: headerTitle
            text: qsTr("HyperspectralSpeckle.jl: ")
            font.pixelSize: 24
            font.bold: true
            color: sysPalette.windowText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.topMargin: 5
        }

        Text {
            text: qsTr("Generate full-aperture and WFS images through atmospheric turbulence.")
            font.pixelSize: 18
            font.bold: false
            color: sysPalette.windowText
            anchors.baseline: headerTitle.baseline
            anchors.left: headerTitle.right
            anchors.leftMargin: 5
            anchors.topMargin: 5
        }

        Text {
            text: qsTr("Default Datatype: ")
            color: sysPalette.windowText
            anchors.rightMargin: 5
            anchors.right: defaultDatatypeComboBox.left
            anchors.verticalCenter: parent.verticalCenter
        }
        
        ComboBox {
            id: defaultDatatypeComboBox
            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
            model: [ "Float32", "Float64" ]
            currentValue: observables.defaultDatatype
            anchors.rightMargin: 5
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onActivated: {
                observables.defaultDatatype = currentValue;
            }
        }

    }

    RowLayout {
        id: mainRowLayout
        anchors.margins: 5
        anchors.fill: parent
        spacing: 5
        
        ColumnLayout {
            id: columnLayoutLeft
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.bottomMargin: 5
            Layout.topMargin: 5
            Layout.fillHeight: true
            spacing: 5

            Rectangle{
                Layout.preferredWidth: 475
                Layout.preferredHeight: columnLayoutOptics.childrenRect.height + 10
                Layout.alignment: Qt.AlignTop
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutOptics
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 2.5

                    GridLayout {
                        rows: 18
                        columns: 3
                        rowSpacing: 2.5
                        columnSpacing: 5
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            text: qsTr("Optical System Parameters")
                            font.pixelSize: 20
                            font.bold: true
                            color: sysPalette.windowText
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignTop
                            Layout.columnSpan: 3
                        }

                        Text {
                            id: apertureDiameterText
                            text: qsTr("Aperture Diameter")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            id: apertureDiameterTextField
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.apertureDiameter
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.apertureDiameter = parseFloat(text)
                            }
                        }

                        Text {
                            id: apertureDiameterUnitText
                            text: qsTr("m")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Obscuration Fraction")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.obscurationFraction
                            validator: DoubleValidator {
                                bottom: 0
                                top: 1
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.obscurationFraction = parseFloat(text)
                            }
                        }

                        Text {
                            text: qsTr("(0-1)")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Field of view")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.fieldOfView
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.fieldOfView = parseFloat(text)
                            }
                        }

                        Text {
                            text: qsTr("arcsec")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        RowLayout {
                            Layout.columnSpan: 3

                            Text {
                                font.pixelSize: 14
                                font.bold: true
                                color: sysPalette.windowText
                                Layout.alignment: Qt.AlignBaseline
                                text: qsTr("Detectors")
                            }

                            Rectangle {
                                color: sysPalette.windowText
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.alignment: Qt.AlignBaseline
                            }
                        }

                        Text {
                            text: qsTr("Image Datatype")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        ComboBox {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            model: [ "Default", "Float32", "Float64", "UInt64", "UInt32", "UInt16", "UInt14", "UInt13", "UInt12", "UInt8" ]
                            currentValue: observables.imageDatatype
                            onActivated: {
                                observables.imageDatatype = currentValue;
                            }
                        }

                        Text {
                            text: qsTr("Read Noise")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.readNoise
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.readNoise = parseFloat(text)
                            }
                        }

                        Text {
                            text: qsTr("e\u207B")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Well depth")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: qsTr(observables.wellDepth.toString())
                            validator: DoubleValidator {
                                bottom: 0
                                decimals: 0
                                // notation: DoubleValidator.StandardNotation
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.wellDepth = parseFloat(text);
                            }
                        }

                        Text {
                            text: qsTr("e\u207B")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Gain")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            readOnly: true
                            text: Math.round(observables.gain * 100) / 100
                            enabled: false
                        }

                        Text {
                            text: qsTr("e\u207B/ADU")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Exposure Time")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.exposureTime * 1e3
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.exposureTime = parseFloat(text) * 1e-3
                            }
                        }

                        Text {
                            text: qsTr("ms")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Quantum Efficiency")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        Loader {
                            id: qeLoader
                            Layout.preferredWidth: textFieldWidth
                            sourceComponent: qeComboBox.currentValue == "Uniform" ? qeUniformTextField : qeFromFileButton
                        }

                        Component {
                            id: qeUniformTextField
                            TextField {
                                id: qeUniformTextField
                                Layout.preferredWidth: textFieldWidth
                                color: sysPalette.windowText
                                text: observables.quantumEfficiency
                                validator: DoubleValidator {
                                    bottom: 0
                                    top: 1
                                }
                                onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                                onEditingFinished: {
                                    observables.quantumEfficiency = parseFloat(text)
                                }
                            }
                        }

                        Component {
                            id: qeFromFileButton
                            Button {
                                Layout.preferredWidth: textFieldWidth
                                text: qsTr("Open")
                            }
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            id: qeComboBox
                            model: ["Uniform", "From File"]
                        }

                        RowLayout {
                            Layout.columnSpan: 3

                            Text {
                                font.pixelSize: 14
                                font.bold: true
                                color: (fullApCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                                Layout.alignment: Qt.AlignBaseline
                                text: qsTr("Full Aperture Channel")
                            }

                            Rectangle {
                                color: (fullApCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.alignment: Qt.AlignBaseline
                            }

                            CheckBox {
                                id: fullApCheckBox
                                checked: observables.enableFullAp
                                Layout.alignment: Qt.AlignRight
                                text: qsTr("Enable")

                                indicator: Rectangle {
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    x: fullApCheckBox.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 3
                                    border.color: sysPalette.windowText
                                    border.width: 1
                                    color: sysPalette.midlight

                                    Rectangle {
                                        width: 12
                                        height: 12
                                        x: parent.width/2 - width/2
                                        y: parent.height/2 - height/2
                                        radius: 3
                                        color: sysPalette.windowText
                                        visible: fullApCheckBox.checked
                                    }
                                }

                                onCheckedChanged: {
                                    observables.enableFullAp = checked;
                                }
                            }
                        }
                        
                        Text {
                            text: qsTr("Response")
                            Layout.preferredWidth: textWidth
                            Layout.minimumWidth: implicitWidth
                            color: (fullApCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        Loader {
                            id: responseFullApLoader
                            Layout.preferredWidth: textFieldWidth
                            sourceComponent: responseFullApComboBox.currentValue == "Uniform" ? responseFullApUniformTextField : responseFullApFromFileButton
                        }

                        Component {
                            id: responseFullApUniformTextField
                            TextField {
                                Layout.preferredWidth: textFieldWidth
                                color: (fullApCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                                enabled: fullApCheckBox.checked
                                text: (observables.responseFullAp.length == 1) ? observables.responseFullAp[0] : ""
                                validator: DoubleValidator {
                                    bottom: 0
                                    top: 1
                                }
                                onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                                onEditingFinished: {
                                    observables.responseFullAp = parseFloat(text)
                                }
                            }
                        }

                        FileDialog {
                            id: responseFullApFileDialog
                            onAccepted: {
                                var pathToFile = selectedFile.toString().replace("file://", "");
                                Julia.loadFullApResponseData(pathToFile);
                                imagesTabBar.currentIndex = 3;
                            }
                        }

                        Component {
                            id: responseFullApFromFileButton
                            Button {
                                enabled: fullApCheckBox.checked
                                Layout.preferredWidth: textFieldWidth
                                text: qsTr("Open")
                                onClicked: {
                                    responseFullApFileDialog.open();
                                }
                            }
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            enabled: fullApCheckBox.checked
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            id: responseFullApComboBox
                            model: ["Uniform", "From File"]
                        }

                        Text {
                            text: qsTr("Static Phase (FITS)")
                            Layout.preferredWidth: textWidth
                            Layout.minimumWidth: implicitWidth
                            color: (fullApCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        TextField {
                            id: staticPhaseFullApTextField
                            enabled: fullApCheckBox.checked
                            Layout.preferredWidth: textFieldWidth
                            color: (fullApCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            placeholderText: qsTr("(Optional)")
                        }

                        Button {
                            Layout.fillWidth: true
                            enabled: fullApCheckBox.checked
                            text: qsTr("Open")
                            onClicked: {
                                staticPhaseFullApFileDialog.open();
                            }
                        }

                        FileDialog {
                            id: staticPhaseFullApFileDialog
                            onAccepted: {
                                var pathToFile = selectedFile.toString().replace("file://", "");
                                staticPhaseFullApTextField.text = pathToFile;
                                imagesTabBar.currentIndex = 2;
                            }
                        }
                
                        RowLayout {
                            Layout.columnSpan: 3

                            Text {
                                font.pixelSize: 14
                                font.bold: true
                                color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                                Layout.alignment: Qt.AlignBaseline
                                text: qsTr("Wavefront Sensor Channel")
                            }

                            Rectangle {
                                color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.alignment: Qt.AlignBaseline
                            }

                            CheckBox {
                                id: wfsCheckBox
                                checked: observables.enableWfs
                                Layout.alignment: Qt.AlignRight
                                text: qsTr("Enable")

                                indicator: Rectangle {
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    x: wfsCheckBox.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 3
                                    border.color: sysPalette.windowText
                                    border.width: 1
                                    color: sysPalette.midlight

                                    Rectangle {
                                        width: 12
                                        height: 12
                                        x: parent.width/2 - width/2
                                        y: parent.height/2 - height/2
                                        radius: 3
                                        color: sysPalette.windowText
                                        visible: wfsCheckBox.checked
                                    }
                                }

                                onCheckedChanged: {
                                    observables.enableWfs = checked;
                                }
                            }
                        }

                        Text {
                            text: qsTr("Wavefront Sensor Type")
                            Layout.preferredWidth: textWidth
                            color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        ComboBox {
                            id: wfsTypeComboBox
                            enabled: wfsCheckBox.checked
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            model: [ "Shack-Hartmann", "Pyramid" ]
                            currentValue: observables.wfsType
                            onActivated: {
                                observables.wfsType = currentValue;
                            }
                        }

                        Text {
                            text: (wfsTypeComboBox.currentValue == "Shack-Hartmann") ? qsTr("Microlens Array Size") : qsTr("Pyramid Facets")
                            Layout.preferredWidth: textWidth
                            color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        TextField {
                            enabled: wfsCheckBox.checked
                            Layout.preferredWidth: textFieldWidth
                            color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            text: observables.microlensArrayLength
                            validator: IntValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.microlensArrayLength = parseInt(text)
                            }
                        }

                        Text {
                            text: (wfsTypeComboBox.currentValue == "Shack-Hartmann") ? qsTr("lenslets") : qsTr("")
                            Layout.fillWidth: true
                            color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        Text {
                            text: qsTr("Response")
                            Layout.preferredWidth: textWidth
                            Layout.minimumWidth: implicitWidth
                            color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        Loader {
                            id: responseWfsLoader
                            Layout.preferredWidth: textFieldWidth
                            sourceComponent: responseWfsComboBox.currentValue == "Uniform" ? responseWfsUniformTextField : responseWfsFromFileButton
                        }

                        Component {
                            id: responseWfsUniformTextField
                            TextField {
                                enabled: wfsCheckBox.checked
                                Layout.preferredWidth: textFieldWidth
                                color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                                text: (observables.responseWfs.length == 1) ? observables.responseWfs[0] : ""
                                validator: DoubleValidator {
                                    bottom: 0
                                    top: 1
                                }
                                onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                                onEditingFinished: {
                                    observables.responseWfs = parseFloat(text)
                                }
                            }
                        }

                        Component {
                            id: responseWfsFromFileButton
                            Button {
                                enabled: wfsCheckBox.checked
                                Layout.preferredWidth: textFieldWidth
                                text: qsTr("Open")
                                onClicked: {
                                    responseWfsFileDialog.open();
                                }
                            }
                        }

                        FileDialog {
                            id: responseWfsFileDialog
                            onAccepted: {
                                var pathToFile = selectedFile.toString().replace("file://", "");
                                Julia.loadWfsResponseData(pathToFile);
                                imagesTabBar.currentIndex = 3;
                            }
                        }

                        ComboBox {
                            enabled: wfsCheckBox.checked
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            id: responseWfsComboBox
                            model: ["Uniform", "From File"]
                        }

                        Text {
                            text: qsTr("Static Phase (FITS)")
                            Layout.preferredWidth: textWidth
                            Layout.minimumWidth: implicitWidth
                            color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        TextField {
                            enabled: wfsCheckBox.checked
                            id: staticPhaseWfsTextField
                            color: (wfsCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            Layout.preferredWidth: textFieldWidth
                            placeholderText: qsTr("(Optional)")
                        }

                        Button {
                            enabled: wfsCheckBox.checked
                            Layout.fillWidth: true
                            text: qsTr("Open")
                            onClicked: {
                                staticPhaseWfsFileDialog.open();
                            }
                        }

                        FileDialog {
                            id: staticPhaseWfsFileDialog
                            onAccepted: {
                                var pathToFile = selectedFile.toString().replace("file://", "");
                                staticPhaseWfsTextField.text = pathToFile;
                                imagesTabBar.currentIndex = 2;
                            }
                        }

                        CheckBox {
                            id: adcCheckBox
                            checked: observables.includeAdc
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 3
                            text: qsTr("Include Atmospheric Dispersion Corrector")

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: adcCheckBox.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: sysPalette.windowText
                                border.width: 1
                                color: sysPalette.midlight

                                Rectangle {
                                    width: 12
                                    height: 12
                                    x: parent.width/2 - width/2
                                    y: parent.height/2 - height/2
                                    radius: 3
                                    color: sysPalette.windowText
                                    visible: adcCheckBox.checked
                                }
                            }

                            contentItem: Text {
                                text: adcCheckBox.text
                                font: adcCheckBox.font
                                color: sysPalette.windowText
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: adcCheckBox.indicator.width + adcCheckBox.spacing
                            }
                        }
                    
                    }

                }

            }

            Rectangle{
                Layout.preferredWidth: 475
                Layout.preferredHeight: columnLayoutAtmosphere.childrenRect.height + 10
                Layout.alignment: Qt.AlignTop
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutAtmosphere
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 2.5

                    Text {
                        text: qsTr("Atmosphere Parameters")
                        font.pixelSize: 20
                        font.bold: true
                        color: sysPalette.windowText
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                    }

                    GridLayout {
                        rows: 3
                        columns: 3
                        rowSpacing: 2.5
                        columnSpacing: 5
                        Layout.fillWidth: true

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Reference wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: qsTr((observables.refWavelength * 1e9).toFixed(1))
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.refWavelength = parseFloat(text) * 1e-9
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("D/r0")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.Dr0
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.Dr0 = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("(vertical)")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Zenith Angle")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.zenithAngle
                            validator: DoubleValidator {
                                bottom: 0
                                top: 90
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.zenithAngle = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("deg")
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Transmission")
                            Layout.preferredWidth: textWidth
                            Layout.minimumWidth: implicitWidth
                            color: sysPalette.windowText
                        }

                        Loader {
                            id: atmosphericTransmissionLoader
                            Layout.preferredWidth: textFieldWidth
                            sourceComponent: atmosphericTransmissionComboBox.currentValue == "Uniform" ? atmosphericTransmissionUniformTextField : atmosphericTransmissionFromFileButton
                        }

                        Component {
                            id: atmosphericTransmissionUniformTextField
                            TextField {
                                Layout.preferredWidth: textFieldWidth
                                color: sysPalette.windowText
                                text: (observables.atmosphericTransmission.length == 1) ? observables.atmosphericTransmission[0] : "" 
                                validator: DoubleValidator {
                                    bottom: 0
                                    top: 1
                                }
                                onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                                onEditingFinished: {
                                    observables.atmosphericTransmission = parseFloat(text)
                                }
                            }
                        }

                        FileDialog {
                            id: atmosphericTransmissionFileDialog
                            onAccepted: {
                                var pathToFile = selectedFile.toString().replace("file://", "");
                                Julia.loadAtmosphericTransmissionData(pathToFile);
                                imagesTabBar.currentIndex = 3;
                            }
                        }

                        Component {
                            id: atmosphericTransmissionFromFileButton
                            Button {
                                Layout.preferredWidth: textFieldWidth
                                text: qsTr("Open")
                                onClicked: {
                                    atmosphericTransmissionFileDialog.open();
                                }
                            }
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            id: atmosphericTransmissionComboBox
                            model: ["Uniform", "From File"]
                        }

                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                    }

                    Rectangle {
                        color: sysPalette.light
                        Layout.preferredHeight: childrenRect.height
                        Layout.preferredWidth: childrenRect.width
                        Layout.alignment: Qt.AlignHCenter

                        ColumnLayout{
                            anchors.centerIn: parent
                            spacing: 0

                            HorizontalHeaderView {
                                id: horizontalHeader
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                
                                // Link it directly to your TableView
                                syncView: layersTableView
                                model: [ 
                                    "Layer",
                                    "Height (km)", 
                                    "Wind Speed (m/s)", 
                                    "Wind Direction (deg)",
                                    "Random Seed"
                                ]

                                // Optional: Customize how the header cells look
                                delegate: Rectangle {
                                    implicitHeight: 20
                                    implicitWidth: cellText.implicitWidth + 5
                                    color: sysPalette.dark

                                    Text {
                                        id: cellText
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData  // 'display' fetches data from the model's headerData()
                                        color: sysPalette.windowText
                                        font.bold: true
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            ScrollView {
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                ScrollBar.vertical.interactive: true
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredHeight: 20 + (3 * 20)

                                TableView {
                                    id: layersTableView
                                    columnSpacing: 0
                                    rowSpacing: 0
                                    clip: true
                                    anchors.centerIn: parent
                                    model: TableModel {
                                        id: layersModel
                                        TableModelColumn { display: "layer" }
                                        TableModelColumn { display: "height" }
                                        TableModelColumn { display: "windSpeed" }
                                        TableModelColumn { display: "windDirection" }
                                        TableModelColumn { display: "seed" }
                                        
                                        rows: [{"layer": "", "height": "", "windSpeed": "", "windDirection": "", "seed": ""}]
                                    }

                                    // Dynamically distribute width across your columns
                                    property var columnWidths: [40, 80, 120, 130, 90]
                                    columnWidthProvider: function (column) {
                                        return columnWidths[column] || 100
                                    }

                                    delegate: Rectangle {
                                        implicitHeight: 20
                                        // border.width: 1
                                        color: sysPalette.base

                                        Text {
                                            id: cellText
                                            color: sysPalette.windowText
                                            text: {
                                                if (model.column == 0 || model.column == 4) return display;
                                                else return display.toFixed(1);
                                                
                                            }
                                            anchors.centerIn: parent
                                        }

                                        TableView.editDelegate: TextField {
                                            anchors.fill: parent
                                            text: display
                                            horizontalAlignment: TextInput.AlignHCenter
                                            Component.onCompleted: selectAll()
                                            validator: {
                                                if (model.column == 0) return layerVal;
                                                if (model.column == 1) return heightVal;
                                                if (model.column == 2) return windSpeedVal;
                                                if (model.column == 3) return windDirectionVal;
                                                if (model.column == 4) return seedVal;
                                            }
                                            IntValidator { id: layerVal; bottom: 1 }
                                            DoubleValidator { id: heightVal; bottom: 0; decimals: 2 }
                                            DoubleValidator { id: windSpeedVal; bottom: 0.0; decimals: 2 }
                                            DoubleValidator { id: windDirectionVal; bottom: -180.0; top: 180.0; decimals: 2 }
                                            IntValidator { id: seedVal; bottom: 0 }

                                            TableView.onCommit: {
                                                display = text
                                            }
                                        }

                                        Rectangle {
                                            height: 1 // Border thickness
                                            color: sysPalette.dark // Border color
                                            
                                            // Anchor to the bottom, matching the parent's width
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                        }
                            
                                    }
                            
                                }
                            
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignRight
                                layoutDirection: Qt.RightToLeft
                                Layout.preferredHeight: 25
                                spacing: 0

                                Button {
                                    text: "–"
                                    Layout.preferredHeight: 25
                                    font.pixelSize: 18
                                    font.bold: true
                                    palette.buttonText: "red"
                                    Layout.preferredWidth: layersTableView.width / layersTableView.model.columnCount / 2
                                    onClicked: {
                                        if (layersModel.rowCount > 1) {
                                            layersModel.removeRow(layersModel.rowCount-1);
                                        }
                                    }
                                }

                                Button {
                                    text: "+"
                                    Layout.preferredHeight: 25
                                    font.pixelSize: 18
                                    font.bold: true
                                    palette.buttonText: "green"
                                    Layout.preferredWidth: layersTableView.width / layersTableView.model.columnCount / 2
                                    onClicked: {
                                        layersModel.insertRow(layersModel.rowCount, {"layer": layersTableView.model.rowCount+1, "height": "", "windSpeed": "", "windDirection": "", "seed": Math.floor(Math.random() * (999999 - 1 + 1)) + 1});
                                    }
                                }

                                Button {
                                    Layout.preferredHeight: 25
                                    Layout.preferredWidth: layersTableView.width / layersTableView.model.columnCount / 2
                                    icon.source: "assets/dice.png"
                                    onClicked: {
                                        for (let ix=0; ix<layersModel.rowCount; ix++) {
                                            var seed = Math.floor(Math.random() * (999999 - 1 + 1)) + 1;
                                            layersTableView.model.setData(layersTableView.model.index(ix, 4), seed)
                                        }
                                    }

                                }

                            }

                        }

                    }

                }
            
            }

            Rectangle{
                Layout.preferredWidth: 475
                Layout.preferredHeight: columnLayoutDiversity.childrenRect.height + 10
                Layout.alignment: Qt.AlignTop
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutDiversity
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 2.5

                    RowLayout{
                        Layout.fillWidth: true

                        Text {
                            text: qsTr("Diversity Phase")
                            font.pixelSize: 20
                            font.bold: true
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CheckBox {
                            id: diversityCheckBox
                            checked: observables.enableDiversity
                            Layout.alignment: Qt.AlignRight
                            text: qsTr("Enable")

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: diversityCheckBox.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: sysPalette.windowText
                                border.width: 1
                                color: sysPalette.midlight

                                Rectangle {
                                    width: 12
                                    height: 12
                                    x: parent.width/2 - width/2
                                    y: parent.height/2 - height/2
                                    radius: 3
                                    color: sysPalette.windowText
                                    visible: diversityCheckBox.checked
                                }
                            }

                            onCheckedChanged: {
                                observables.enableDiversity = checked;
                            }
                        }
                        
                    }

                    GridLayout {
                        rows: 3
                        columns: 3
                        rowSpacing: 2.5
                        columnSpacing: 5
                        Layout.fillWidth: true

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Zernike Index")
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            text: observables.zernikeIndex
                            enabled: diversityCheckBox.checked
                            validator: IntValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.zernikeIndex = parseInt(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("(Noll)")
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Num. of waves")
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            text: observables.numWaves
                            enabled: diversityCheckBox.checked
                            validator: DoubleValidator {}
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.numWaves = parseFloat(text)
                            }
                        }

                        Item {}

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Period")
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            text: observables.diversityPeriod * 1e3
                            enabled: diversityCheckBox.checked
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.diversityPeriod = parseFloat(text) * 1e-3
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("ms")
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Reference time")
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: (diversityCheckBox.checked == true) ? sysPalette.windowText : Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.5)
                            text: observables.referenceTime
                            enabled: diversityCheckBox.checked
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.referenceTime = parseFloat(text)
                            }
                        }

                        Item {}

                    }
            
                }
            
            }

        }

        ColumnLayout {
            id: columnLayoutCenter
            Layout.preferredWidth: 450
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.bottomMargin: 5
            Layout.topMargin: 5
            spacing: 5

            Rectangle{
                id: targetParametersRectangle
                Layout.preferredWidth: 475
                Layout.fillHeight: true
                // Layout.preferredHeight: columnLayoutObject.childrenRect.height + 10
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutObject
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 2.5

                    Text {
                        text: qsTr("Target Parameters")
                        font.pixelSize: 20
                        font.bold: true
                        color: sysPalette.windowText
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                    }

                    GridLayout {
                        rows: 7
                        columns: 3
                        rowSpacing: 2.5
                        columnSpacing: 5
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Target Brightness")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.targetBrightness
                            validator: DoubleValidator {}
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.targetBrightness = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("mag")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Background Brightness")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.backgroundBrightness
                            validator: DoubleValidator {}
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.backgroundBrightness = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("mag/arcsec²")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Range")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.targetRange * 1e-3
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onAcceptableInputChanged: color = acceptableInput ? sysPalette.windowText : "red";
                            onEditingFinished: {
                                observables.targetRange = parseFloat(text) * 1e3
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("km")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Truth Image (FITS)")
                            color: sysPalette.windowText
                        }

                        TextField {
                            id: truthImageTextField
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            placeholderText: qsTr("(Required)")
                        }

                        Button {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("Open")
                            onClicked: {
                                targetFileDialog.open();
                            }
                        }

                        FileDialog {
                            id: targetFileDialog
                            onAccepted: {
                                var pathToFile = selectedFile.toString().replace("file://", "");
                                truthImageTextField.text = pathToFile;
                                Julia.loadTruthImage(pathToFile);
                            }
                        }

                    }

                    Item{
                        Layout.preferredHeight: 5
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: sysPalette.dark
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 5

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Button {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    icon.source: "assets/rotCCW.png"
                                    onClicked: {
                                        Julia.rotTargetCCW90()
                                    }
                                }

                                Button {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    icon.source: "assets/rotCW.png"
                                    onClicked: {
                                        Julia.rotTargetCW90()
                                    }
                                }

                                Text {
                                    font.pixelSize: 14
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                    text: qsTr("Colormap:")
                                    color: sysPalette.windowText
                                }

                                ComboBox {
                                    font.pixelSize: 14
                                    implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                                    model: observables.availableColormaps
                                    currentValue: observables.currentTargetColormap
                                    onActivated: {
                                        observables.currentTargetColormap = currentValue;
                                    }
                                }
                            }

                            MakieArea {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                scene: observables.targetFigureObs
                            }
                        
                            GridLayout {                                        
                                rows: 3
                                columns: 3
                                Layout.fillWidth: true
                            
                                Button {
                                    Layout.rowSpan: 2
                                    Layout.fillWidth: false
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth / 2
                                    flat: true
                                    icon.source: "assets/left-icon.svg"
                                    icon.color: sysPalette.light

                                    onClicked: {
                                        targetWavelengthSlider.value -= 1
                                    }
                                }
                                
                                Text {
                                    text: qsTr("Wavelength")
                                    color: sysPalette.windowText
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                Button {
                                    Layout.rowSpan: 2
                                    Layout.fillWidth: false
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth / 2
                                    flat: true
                                    icon.source: "assets/right-icon.svg"
                                    icon.color: sysPalette.light

                                    onClicked: {
                                        targetWavelengthSlider.value += 1
                                    }
                                }

                                Text {
                                    text: observables.truthTargetWavelengths[targetWavelengthSlider.value-1].toFixed(1) + qsTr("nm")
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    color: sysPalette.windowText
                                    font.pixelSize: 12
                                }

                                Slider {
                                    id: targetWavelengthSlider
                                    Layout.fillWidth: true
                                    Layout.columnSpan: 3
                                    from: 1
                                    to: observables.numWavelengthsTarget
                                    value: observables.currentTargetWavelength
                                    stepSize: 1  
                                    onValueChanged: {
                                        observables.currentTargetWavelength = value;
                                    }
                                }

                            }

                        }
                    
                    }

                    Item{
                        Layout.preferredHeight: 5
                    }

                }
            
            }

            Rectangle{
                Layout.preferredWidth: 475
                Layout.preferredHeight: childrenRect.height + 10
                // Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutSimulation
                    anchors.centerIn: parent
                    anchors.margins: 5
                    spacing: 2.5

                    Text {
                        text: qsTr("Simulation Parameters")
                        font.pixelSize: 20
                        font.bold: true
                        color: sysPalette.windowText
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                    }

                    GridLayout {
                        rows: 7
                        columns: 3
                        rowSpacing: 2.5
                        columnSpacing: 5
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        CheckBox {
                            id: noiseCheckBox
                            checked: observables.includeNoise
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 3
                            text: qsTr("Include photon & detector noise")

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: noiseCheckBox.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: sysPalette.windowText
                                border.width: 1
                                color: sysPalette.midlight

                                Rectangle {
                                    width: 12
                                    height: 12
                                    x: parent.width/2 - width/2
                                    y: parent.height/2 - height/2
                                    radius: 3
                                    color: sysPalette.windowText
                                    visible: noiseCheckBox.checked
                                }
                            }

                            contentItem: Text {
                                text: noiseCheckBox.text
                                font: noiseCheckBox.font
                                color: sysPalette.windowText
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: noiseCheckBox.indicator.width + noiseCheckBox.spacing
                            }
                        }

                        CheckBox {
                            id: propagateCheckBox
                            checked: observables.propagateLayers
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 3
                            text: qsTr("Propagate layers")

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: propagateCheckBox.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: sysPalette.windowText
                                border.width: 1
                                color: sysPalette.midlight

                                Rectangle {
                                    width: 12
                                    height: 12
                                    x: parent.width/2 - width/2
                                    y: parent.height/2 - height/2
                                    radius: 3
                                    color: sysPalette.windowText
                                    visible: propagateCheckBox.checked
                                }
                            }

                            contentItem: Text {
                                text: propagateCheckBox.text
                                font: propagateCheckBox.font
                                color: sysPalette.windowText
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: propagateCheckBox.indicator.width + propagateCheckBox.spacing
                            }

                            onCheckedChanged: {
                                observables.propagateLayers = checked;
                            }
                        }

                        CheckBox {
                            id: anisoCheckBox
                            checked: observables.simulateAnisoplanatic
                            Layout.alignment: Qt.AlignLeft
                            text: qsTr("Simulate Anisoplanatic")
                            onCheckedChanged: {
                                anisoPatchesTextField.enabled = checked;
                                observables.simulateAnisoplanatic = checked;
                            }

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: anisoCheckBox.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: sysPalette.windowText
                                border.width: 1
                                color: sysPalette.midlight

                                Rectangle {
                                    width: 12
                                    height: 12
                                    x: parent.width/2 - width/2
                                    y: parent.height/2 - height/2
                                    radius: 3
                                    color: sysPalette.windowText
                                    visible: anisoCheckBox.checked
                                }
                            }

                            contentItem: Text {
                                text: anisoCheckBox.text
                                font: anisoCheckBox.font
                                color: sysPalette.windowText
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: anisoCheckBox.indicator.width + anisoCheckBox.spacing
                            }
                        }


                        TextField {
                            id: anisoPatchesTextField
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.patchSize
                            validator: IntValidator {
                                bottom: 1
                            }
                            onEditingFinished: {
                                observables.patchSize = parseInt(text)
                            }
                        }

                        Text {
                            enabled: anisoCheckBox.checked
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("Pix. per patch")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Num. of timesteps")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.numTimesteps
                            validator: IntValidator {
                                bottom: 1
                            }
                            onEditingFinished: {
                                observables.numTimesteps = parseInt(text)
                            }
                        }

                        Item {}

                        RowLayout {
                            Layout.columnSpan: 3

                            Text {
                                font.pixelSize: 14
                                font.bold: true
                                color: sysPalette.windowText
                                Layout.alignment: Qt.AlignBaseline
                                text: qsTr("Wavelength")
                            }

                            Rectangle {
                                color: sysPalette.windowText
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.alignment: Qt.AlignBaseline
                            }
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Lower wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            id: lowerWavelengthTextField
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: qsTr((observables.lowerWavelength * 1e9).toFixed(1))
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onEditingFinished: {
                                observables.lowerWavelength = parseFloat(text) * 1e-9
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Upper wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            id: upperWavelengthTextField
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: qsTr((observables.upperWavelength * 1e9).toFixed(1))
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onEditingFinished: {
                                observables.upperWavelength = parseFloat(text) * 1e-9
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            text: qsTr("Nyquist wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: qsTr((observables.nyquistWavelength * 1e9).toFixed(1))
                            validator: DoubleValidator {
                                bottom: 0
                            }
                            onEditingFinished: {
                                observables.nyquistWavelength = parseFloat(text) * 1e-9
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: textWidth
                            Layout.alignment: Qt.AlignTop

                            text: qsTr("Num. of wavelengths")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.numWavelengths
                            validator: IntValidator {
                                bottom: 1
                            }
                            onEditingFinished: {
                                observables.numWavelengths = parseInt(text);
                            }
                        }

                        Text {
                            id: numWavelengthsUnitsTextField
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            color: sysPalette.windowText
                            text: (parseInt(observables.numWavelengths) == 1) ? qsTr("") : qsTr("(") + Math.round(observables.spacingWavelength * 10) / 10 + qsTr("nm spacing; λ/Δλ=") + Math.round(observables.spectralResolution).toLocaleString() + (")");
                        }

                        RowLayout {
                            Layout.columnSpan: 3

                            Text {
                                font.pixelSize: 14
                                font.bold: true
                                color: sysPalette.windowText
                                Layout.alignment: Qt.AlignBaseline
                                text: qsTr("Image Sizes")
                            }

                            Rectangle {
                                color: sysPalette.windowText
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.alignment: Qt.AlignBaseline
                            }
                        }

                        Text {
                            text: qsTr("Image Size (Full Aperture)")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.imageSizeFullAp
                            validator: IntValidator {
                                bottom: 0
                            }
                            onEditingFinished: {
                                observables.imageSizeFullAp = parseInt(text)
                            }
                        }

                        Text {
                            text: qsTr("pixels")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Image Size (Wavefront Sensor)")
                            Layout.preferredWidth: textWidth
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: textFieldWidth
                            color: sysPalette.windowText
                            text: observables.imageSizeWfs
                            validator: IntValidator {
                                bottom: 0
                            }
                            onEditingFinished: {
                                observables.imageSizeWfs = parseInt(text)
                            }
                        }

                        Text {
                            text: qsTr("pixels")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                    }

                    Button {
                        Layout.preferredHeight: 50
                        Layout.fillWidth: true
                        text: qsTr("Simulate Images")
                        font.bold: true
                        font.pixelSize: 18
                        onClicked: {
                            Julia.runHyperspectralSpeckle();
                        }
                    }

                }
        
            }
        
        }

        ColumnLayout {
            id: columnLayoutRight
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.bottomMargin: 5
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            Rectangle{
                id: rightBackgroundRectangle
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutImagery
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 2.5                    

                    Text {
                        text: qsTr("Outputs & Diagnostics")
                        font.pixelSize: 20
                        font.bold: true
                        color: sysPalette.windowText
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                    }

                    TabBar {
                        id: imagesTabBar
                        Layout.fillWidth: true
                        contentHeight: 40
                        font.pixelSize: 14
                        currentIndex: imagesStackLayout.currentIndex

                        TabButton {text: qsTr("Images")}
                        TabButton {text: qsTr("Atmosphere")}
                        TabButton {text: qsTr("Pupil")}
                        TabButton {text: qsTr("Optical Response")}
                    }

                    StackLayout {
                        id: imagesStackLayout
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        anchors.margins: 2.5
                        currentIndex: imagesTabBar.currentIndex

                        Item {
                            id: imagesTabBarView
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 5

                                Rectangle {
                                    id: imageryBackgroundRectangle
                                    // Layout.preferredWidth: columnLayoutImagery.width * 3/5
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersColumnLayout
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 2.5

                                        MakieArea {
                                            id: imageryMakieView
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            scene: observables.imagesFigureObs
                                        }

                                        RowLayout {
                                            spacing: 5

                                            ComboBox {
                                                model: ["Full Aperture", "Wavefront Sensor"]
                                                currentIndex: 0
                                                font.pixelSize: 14
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignRight
                                                text: qsTr("Colormap:")
                                                color: sysPalette.windowText
                                            }

                                            ComboBox {
                                                font.pixelSize: 14
                                                implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                                                model: observables.availableColormaps
                                                currentValue: observables.currentImagesColormap
                                                onActivated: {
                                                    observables.currentImagesColormap = currentValue;
                                                }
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text{
                                                text: "Scale:"
                                                color: sysPalette.windowText
                                                font.pixelSize: 14
                                            }

                                            ComboBox {
                                                model: ["Linear", "Log", "Sqrt"]
                                                currentIndex: 0
                                                font.pixelSize: 14
                                            }

                                        }

                                        GridLayout {                                        
                                            rows: 3
                                            columns: 3
                                            Layout.fillWidth: true
                                        
                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/left-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    timestepSlider.value -= 1
                                                }
                                            }
                                            
                                            Text {
                                                text: qsTr("Timestep")
                                                color: sysPalette.windowText
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/right-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    timestepSlider.value += 1
                                                }
                                            }

                                            Text {
                                                text: timestepSlider.value + qsTr("/") + timestepSlider.to
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                color: sysPalette.windowText
                                                font.pixelSize: 12
                                            }

                                            Slider {
                                                id: timestepSlider
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                                from: 1
                                                to: observables.numTimesteps
                                                value: observables.currentImageTimestep
                                                stepSize: 1   
                                                onValueChanged: {
                                                    observables.currentImageTimestep = value;
                                                }                         
                                            }

                                        }

                                        GridLayout {                                        
                                            rows: 3
                                            columns: 3
                                            Layout.fillWidth: true
                                        
                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/left-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    subapSlider.value -= 1
                                                }
                                            }

                                            Text {
                                                text: qsTr("Sub-Aperture Index")
                                                color: sysPalette.windowText
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/right-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    subapSlider.value += 1
                                                }
                                            }

                                            Text {
                                                text: subapSlider.value + qsTr("/") + subapSlider.to
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                color: sysPalette.windowText
                                                font.pixelSize: 12
                                            }

                                            Slider {
                                                id: subapSlider
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                                from: 1
                                                to: observables.numSubaps
                                                value: observables.currentImageSubap
                                                stepSize: 1  
                                                onValueChanged: {
                                                    observables.currentImageSubap = value;
                                                }                   
                                            }
                                        
                                        }

                                        GridLayout {                                        
                                            rows: 3
                                            columns: 3
                                            Layout.fillWidth: true
                                        
                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/left-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    wavelengthSlider.value -= 1
                                                }
                                            }

                                            Text {
                                                text: qsTr("Wavelength")
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                color: sysPalette.windowText
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/right-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    wavelengthSlider.value += 1
                                                }
                                            }

                                            Text {
                                                text: wavelengthSlider.value + qsTr("nm")
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                color: sysPalette.windowText
                                                font.pixelSize: 12
                                            }

                                            Slider {
                                                id: wavelengthSlider
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                                from: 1
                                                to: observables.numWavelengthsSet
                                                value: observables.currentImageWavelength.toFixed(1)
                                                stepSize: 1
                                                onValueChanged: {
                                                    observables.currentImageWavelength = value;
                                                }                        
                                            }

                                        }
                                    }
                                }

                                // Rectangle {
                                //     id: imageryStatsRectangle
                                //     Layout.preferredWidth: columnLayoutImagery.width * 2/5 - 5
                                //     Layout.preferredHeight: childrenRect.height + 10
                                //     Layout.alignment: Qt.AlignTop
                                //     color: sysPalette.dark
                                //     radius: 5

                                //     GridLayout {
                                //         anchors.top: parent.top
                                //         anchors.left: parent.left
                                //         anchors.right: parent.right
                                //         anchors.margins: 5
                                //         rowSpacing: 5
                                //         columns: 2
                                //         rows: 10

                                //         Text {
                                //             text: qsTr("Image Stats")
                                //             font.pixelSize: 18
                                //             font.bold: true
                                //             color: sysPalette.windowText
                                //             Layout.columnSpan: 2
                                //         }

                                //         Text {
                                //             text: qsTr("Plate Scale: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("##### arcsec/pix")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Mean: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Median: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Std: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Min: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Max: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }
                                    
                                //     }
                                
                                // }

                            }

                        }

                        Item {
                            id: atmosphereTabBarView
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 5

                                Rectangle {
                                    id: atmosphereBackgroundRectangle
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersAtmosphereColumnLayout
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 2.5

                                        MakieArea {
                                            id: atmosphereMakieView
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            scene: observables.atmosphereFigureObs
                                        }

                                        RowLayout {
                                            spacing: 5

                                            ComboBox {
                                                model: ["Phase", "OPD", "Mask"]
                                                currentIndex: 0
                                                font.pixelSize: 14
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignRight
                                                text: qsTr("Colormap:")
                                                color: sysPalette.windowText
                                            }

                                            ComboBox {
                                                font.pixelSize: 14
                                                implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                                                model: observables.availableColormaps
                                                currentValue: observables.currentAtmosphereColormap
                                                onActivated: {
                                                    observables.currentAtmosphereColormap = currentValue;
                                                }
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text{
                                                text: "Scale:"
                                                color: sysPalette.windowText
                                                font.pixelSize: 14
                                            }

                                            ComboBox {
                                                model: ["Linear", "Log", "Sqrt"]
                                                currentIndex: 0
                                                font.pixelSize: 14
                                            }

                                        }

                                        GridLayout {                                        
                                            rows: 3
                                            columns: 3
                                            Layout.fillWidth: true
                                        
                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/left-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    timestepSlider.value -= 1
                                                }
                                            }
                                            
                                            Text {
                                                text: qsTr("Layer")
                                                color: sysPalette.windowText
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/right-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    timestepSlider.value += 1
                                                }
                                            }

                                            Text {
                                                text: layerSlider.value + qsTr("/") + layerSlider.to
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                color: sysPalette.windowText
                                                font.pixelSize: 12
                                            }

                                            Slider {
                                                id: layerSlider
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                                from: 1
                                                to: observables.numLayers
                                                value: observables.currentAtmosphereLayer
                                                stepSize: 1   
                                                onValueChanged: {
                                                    observables.currentAtmosphereLayer = value;
                                                }                         
                                            }

                                        }

                                        GridLayout {                                        
                                            rows: 3
                                            columns: 3
                                            Layout.fillWidth: true
                                        
                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/left-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    wavelengthAtmosphereSlider.value -= 1
                                                }
                                            }

                                            Text {
                                                text: qsTr("Wavelength")
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                color: sysPalette.windowText
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Button {
                                                Layout.rowSpan: 2
                                                Layout.fillWidth: false
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: implicitWidth / 2
                                                flat: true
                                                icon.source: "assets/right-icon.svg"
                                                icon.color: sysPalette.light

                                                onClicked: {
                                                    wavelengthAtmosphereSlider.value += 1
                                                }
                                            }

                                            Text {
                                                text: wavelengthAtmosphereSlider.value + qsTr("nm")
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                color: sysPalette.windowText
                                                font.pixelSize: 12
                                            }

                                            Slider {
                                                id: wavelengthAtmosphereSlider
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                                from: 1
                                                to: observables.numWavelengthsSet
                                                value: observables.currentAtmosphereWavelength
                                                stepSize: 1  
                                                onValueChanged: {
                                                    observables.currentAtmosphereWavelength = value;
                                                }                          
                                            }

                                        }
                                    }
                                }

                                // Rectangle {
                                //     id: atmosphereStatsRectangle
                                //     Layout.preferredWidth: columnLayoutImagery.width * 2/5 - 5
                                //     Layout.preferredHeight: childrenRect.height + 10
                                //     Layout.alignment: Qt.AlignTop
                                //     color: sysPalette.dark
                                //     radius: 5

                                //     GridLayout {
                                //         anchors.top: parent.top
                                //         anchors.left: parent.left
                                //         anchors.right: parent.right
                                //         anchors.margins: 5
                                //         rowSpacing: 5
                                //         columns: 2
                                //         rows: 10

                                //         Text {
                                //             text: qsTr("Image Stats")
                                //             font.pixelSize: 18
                                //             font.bold: true
                                //             color: sysPalette.windowText
                                //             Layout.columnSpan: 2
                                //         }

                                //         Text {
                                //             text: qsTr("Plate Scale: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("##### arcsec/pix")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Mean: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Median: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Std: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Min: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("Max: ")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }

                                //         Text {
                                //             text: qsTr("#####")
                                //             font.pixelSize: 16
                                //             color: sysPalette.windowText
                                //         }
                                    
                                //     }
                                
                                // }

                            }
                        }

                        Item {
                            id: pupilMasksTabBarView
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                anchors.fill: parent
                                spacing: 5

                                Rectangle {
                                    id: masksBackgroundRectangle
                                    // Layout.preferredWidth: columnLayoutImagery.width * 3/5
                                    // Layout.preferredHeight: childrenRect.height + 10
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignTop
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersMasksColumnLayout
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 2.5

                                        MakieArea {
                                            id: masksMakieView
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            scene: observables.pupilFigureObs
                                        }

                                        ColumnLayout {
                                            spacing: 5

                                            RowLayout {
                                                ComboBox {
                                                    model: ["Masks", "Static Phase"]
                                                    currentIndex: 0
                                                    font.pixelSize: 14
                                                }
                                                ComboBox {
                                                    model: ["Full Aperture", "Wavefront Sensor"]
                                                    currentIndex: 0
                                                    font.pixelSize: 14
                                                }

                                                Item {
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    horizontalAlignment: Text.AlignRight
                                                    text: qsTr("Colormap:")
                                                    color: sysPalette.windowText
                                                    font.pixelSize: 14
                                                }

                                                ComboBox {
                                                    font.pixelSize: 14
                                                    implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                                                    model: observables.availableColormaps
                                                    currentValue: observables.currentPupilColormap
                                                    onActivated: {
                                                        observables.currentPupilColormap = currentValue;
                                                    }
                                                }
                                            }

                                            GridLayout {                                        
                                                rows: 3
                                                columns: 3
                                                Layout.fillWidth: true
                                            
                                                Button {
                                                    Layout.rowSpan: 2
                                                    Layout.fillWidth: false
                                                    Layout.fillHeight: true
                                                    Layout.preferredWidth: implicitWidth / 2
                                                    flat: true
                                                    icon.source: "assets/left-icon.svg"
                                                    icon.color: sysPalette.light

                                                    onClicked: {
                                                        maskWavelengthSlider.value -= 1
                                                    }
                                                }
                                                
                                                Text {
                                                    text: qsTr("Wavelength")
                                                    color: sysPalette.windowText
                                                    Layout.fillWidth: true
                                                    horizontalAlignment: Text.AlignHCenter
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                }

                                                Button {
                                                    Layout.rowSpan: 2
                                                    Layout.fillWidth: false
                                                    Layout.fillHeight: true
                                                    Layout.preferredWidth: implicitWidth / 2
                                                    flat: true
                                                    icon.source: "assets/right-icon.svg"
                                                    icon.color: sysPalette.light

                                                    onClicked: {
                                                        maskWavelengthSlider.value += 1
                                                    }
                                                }

                                                Text {
                                                    text: maskWavelengthSlider.value + qsTr("nm")
                                                    Layout.fillWidth: true
                                                    horizontalAlignment: Text.AlignHCenter
                                                    color: sysPalette.windowText
                                                    font.pixelSize: 12
                                                }

                                                Slider {
                                                    id: maskWavelengthSlider
                                                    Layout.fillWidth: true
                                                    Layout.columnSpan: 3
                                                    from: 1
                                                    to: observables.numWavelengthsSet
                                                    value: observables.currentPupilWavelength
                                                    stepSize: 1  
                                                    onValueChanged: {
                                                        observables.currentPupilWavelength = value;
                                                    }
                                                }

                                            }

                                        }
                                    
                                    }
                                
                                }
                                
                            }

                        }

                        Item {
                            id: responseTabBarView
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                anchors.fill: parent
                                spacing: 5

                                Rectangle {
                                    id: responseBackgroundRectangle
                                    // Layout.preferredWidth: columnLayoutImagery.width
                                    // Layout.preferredHeight: childrenRect.height + 10
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignTop
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersResponseColumnLayout
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 2.5

                                        MakieArea {
                                            id: responseMakieView
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            scene: observables.responseFigureObs
                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

            Rectangle{
                id: saveOutputsRectangle
                Layout.fillWidth: true
                Layout.preferredHeight: columnLayoutOutputs.height + 10
                Layout.alignment: Qt.AlignTop
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutOutputs
                    // anchors.centerIn: parent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 5
                    spacing: 2.5                    

                    Text {
                        text: qsTr("Save Outputs")
                        font.pixelSize: 20
                        font.bold: true
                        color: sysPalette.windowText
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                    }

                    Text {
                        text: qsTr("Outputs will be saved to:")
                        color: sysPalette.windowText
                        font.pixelSize: 14
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        TextField {
                            Layout.fillWidth: true
                            text: observables.saveDirectory
                        }

                        Button {
                            icon.source: "assets/folder.png"
                            icon.color: sysPalette.windowText
                        }
                    }

                    Text {
                        text: qsTr("Run Id / Filename Tag")
                        color: sysPalette.windowText
                        font.pixelSize: 14
                    }

                    TextField {
                        Layout.preferredWidth: 200
                        text: observables.runId
                        onEditingFinished: {
                            observables.runId = text.toString()
                        }
                    }

                    Button {
                        text: qsTr("Save")
                        font.pixelSize: 18
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 50
                        Layout.preferredWidth: 150
                    }

                }

            }
        
        }

    }

}

