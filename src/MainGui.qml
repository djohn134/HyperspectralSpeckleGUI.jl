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
    width: 1600
    height: 950
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    visible: true

    SystemPalette { 
        id: sysPalette
        colorGroup: SystemPalette.Active
    }
    color: sysPalette.window

    Component.onCompleted: {
        observables.windowColor = sysPalette.mid.toString();
        observables.windowText = sysPalette.windowText.toString();

        var tableRows = []
        for (var ix = 0; ix < observables.layerHeights.length; ix++) {
            tableRows[ix] = {
                "layer": ix+1,
                "height": observables.layerHeights[ix],
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
                Layout.preferredWidth: 450
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
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            id: apertureDiameterTextField
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.apertureDiameter
                            onAccepted: {
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
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.obscurationFraction
                            onAccepted: {
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
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.fieldOfView
                            onAccepted: {
                                observables.fieldOfView = parseFloat(text)
                            }
                        }

                        Text {
                            text: qsTr("arcsec")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Rectangle {
                            color: sysPalette.dark
                            Layout.preferredWidth: parent.width - 5
                            Layout.preferredHeight: 2
                            Layout.columnSpan: 3
                        }

                        Text {
                            text: qsTr("Image Datatype")
                            Layout.fillWidth: true
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
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: 75
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.readNoise
                            onAccepted: {
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
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.wellDepth
                            onAccepted: {
                                observables.wellDepth = parseInt(text);
                            }
                        }

                        Text {
                            text: qsTr("e\u207B")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Gain")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            readOnly: true
                            text: observables.gain
                            enabled: false
                        }

                        Text {
                            text: qsTr("e\u207B/ADU")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Exposure Time")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.exposureTime
                            onAccepted: {
                                observables.exposureTime = parseFloat(text)
                            }
                        }

                        Text {
                            text: qsTr("ms")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Text {
                            text: qsTr("Quantum Efficiency")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Loader {
                            id: qeLoader
                            Layout.fillWidth: true
                            sourceComponent: qeComboBox.currentValue == "Uniform" ? qeUniformTextField : qeFromFileButton
                        }

                        Component {
                            id: qeUniformTextField
                            TextField {
                                id: qeUniformTextField
                                Layout.fillWidth: true
                                color: sysPalette.windowText
                                text: observables.quantumEfficiency
                                onAccepted: {
                                    observables.quantumEfficiency = parseFloat(text)
                                }
                            }
                        }

                        Component {
                            id: qeFromFileButton
                            Button {
                                Layout.fillWidth: true
                                text: qsTr("Open")
                            }
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            id: qeComboBox
                            model: ["Uniform", "From File"]
                        }

                        Rectangle {
                            color: sysPalette.dark
                            Layout.preferredWidth: parent.width - 5
                            Layout.preferredHeight: 2
                            Layout.columnSpan: 3
                        }

                        Text {
                            text: qsTr("Wavefront Sensor Type")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        ComboBox {
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
                            text: qsTr("Microlens Array Length")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.microlensArrayLength
                            onAccepted: {
                                observables.microlensArrayLength = parseInt(text)
                            }
                        }

                        Text {
                            text: qsTr("lenslets")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        Rectangle {
                            color: sysPalette.dark
                            Layout.preferredWidth: parent.width - 5
                            Layout.preferredHeight: 2
                            Layout.columnSpan: 3
                        }
                        
                        Text {
                            text: qsTr("Transmission (Full Aperture)")
                            Layout.fillWidth: true
                            Layout.minimumWidth: implicitWidth
                            color: sysPalette.windowText
                        }

                        Loader {
                            id: responseFullApLoader
                            Layout.fillWidth: true
                            sourceComponent: responseFullApComboBox.currentValue == "Uniform" ? responseFullApUniformTextField : responseFullApFromFileButton
                        }

                        Component {
                            id: responseFullApUniformTextField
                            TextField {
                                Layout.fillWidth: true
                                color: sysPalette.windowText
                                text: observables.transmissionFullAp
                                onAccepted: {
                                    observables.transmissionFullAp = parseFloat(text)
                                }
                            }
                        }

                        Component {
                            id: responseFullApFromFileButton
                            Button {
                                Layout.fillWidth: true
                                text: qsTr("Open")
                            }
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            id: responseFullApComboBox
                            model: ["Uniform", "From File"]
                        }

                        Text {
                            text: qsTr("Transmission (Wavefront Sensor)")
                            Layout.fillWidth: true
                            Layout.minimumWidth: implicitWidth
                            color: sysPalette.windowText
                        }

                        Loader {
                            id: responseWfsLoader
                            Layout.fillWidth: true
                            sourceComponent: responseWfsComboBox.currentValue == "Uniform" ? responseWfsUniformTextField : responseWfsFromFileButton
                        }

                        Component {
                            id: responseWfsUniformTextField
                            TextField {
                                Layout.fillWidth: true
                                color: sysPalette.windowText
                                text: observables.transmissionWfs
                                onAccepted: {
                                    observables.transmissionWfs = parseFloat(text)
                                }
                            }
                        }

                        Component {
                            id: responseWfsFromFileButton
                            Button {
                                Layout.fillWidth: true
                                text: qsTr("Open")
                            }
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                            id: responseWfsComboBox
                            model: ["Uniform", "From File"]
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
                Layout.preferredWidth: 450
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
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Reference wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.refWavelength
                            onAccepted: {
                                observables.refWavelength = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("D/r0")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.Dr0
                            onAccepted: {
                                observables.Dr0 = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("(vertical)")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Zenith Angle")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 75
                            color: sysPalette.windowText
                            text: observables.zenithAngle
                            onAccepted: {
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
                            Layout.fillWidth: true
                            Layout.minimumWidth: implicitWidth
                            color: sysPalette.windowText
                        }

                        Loader {
                            id: atmosphericTransmissionLoader
                            Layout.fillWidth: true
                            sourceComponent: atmosphericTransmissionComboBox.currentValue == "Uniform" ? atmosphericTransmissionUniformTextField : atmosphericTransmissionFromFileButton
                        }

                        Component {
                            id: atmosphericTransmissionUniformTextField
                            TextField {
                                Layout.fillWidth: true
                                color: sysPalette.windowText
                                text: observables.atmosphericTransmission
                                onAccepted: {
                                    observables.atmosphericTransmission = parseFloat(text)
                                }
                            }
                        }

                        Component {
                            id: atmosphericTransmissionFromFileButton
                            Button {
                                Layout.fillWidth: true
                                text: qsTr("Open")
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
                        // border.width: 1
                        // border.color: sysPalette.dark

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
                                    // border.width: 1.5
                                    // border.color: sysPalette.mid

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
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    // anchors.fill: parent
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
                                    property var columnWidths: [40, 75, 110, 125, 90]
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
                                            text: display
                                            anchors.centerIn: parent
                                        }

                                        TableView.editDelegate: TextField {
                                            anchors.fill: parent
                                            text: display
                                            horizontalAlignment: TextInput.AlignHCenter
                                            Component.onCompleted: selectAll()

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
                Layout.preferredWidth: 450
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
                            color: sysPalette.windowText
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CheckBox {
                            id: diversityCheckBox
                            checked: false
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
                        }
                        
                    }

                    GridLayout {
                        rows: 3
                        columns: 3
                        rowSpacing: 2.5
                        columnSpacing: 5
                        Layout.fillWidth: true

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Zernike Index")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.zernikeIndex
                            enabled: diversityCheckBox.checked
                            onAccepted: {
                                observables.zernikeIndex = parseInt(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("(Noll)")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Num. of waves")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.numWaves
                            enabled: diversityCheckBox.checked
                            onAccepted: {
                                observables.numWaves = parseFloat(text)
                            }
                        }

                        Item {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Period")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.diversityPeriod
                            enabled: diversityCheckBox.checked
                            onAccepted: {
                                observables.diversityPeriod = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("ms")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Reference time")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.referenceTime
                            enabled: diversityCheckBox.checked
                            onAccepted: {
                                observables.referenceTime = parseFloat(text)
                            }
                        }

                        Item {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                        }

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
                Layout.preferredWidth: 450
                Layout.preferredHeight: columnLayoutObject.childrenRect.height + 10
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    id: columnLayoutObject
                    anchors.centerIn: parent
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
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Target Brightness")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.targetBrightness
                            onAccepted: {
                                observables.targetBrightness = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("mag")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Background Brightness")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.backgroundBrightness
                            onAccepted: {
                                observables.backgroundBrightness = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("mag/arcsec²")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Range")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.targetRange
                            onAccepted: {
                                observables.targetRange = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("km")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Truth Image File (FITS)")
                            color: sysPalette.windowText
                        }

                        TextField {
                            id: truthImageTextField
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
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
                                truthImageTextField.text = selectedFile.toString();
                                Julia.loadTruthImage(selectedFile.toString());
                            }
                        }

                    }

                    Item{
                        Layout.preferredHeight: 5
                    }

                    Rectangle {
                        Layout.preferredHeight: 300
                        Layout.preferredWidth: 400
                        Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                        color: sysPalette.dark
                        radius: 5

                        MakieArea {
                            anchors.fill: parent
                            scene: observables.targetFigureObs
                        }
                    }

                    Item{
                        Layout.preferredHeight: 5
                    }

                }
            
            }

            Rectangle{
                Layout.preferredWidth: 450
                Layout.preferredHeight: columnLayoutLeft.height - targetParametersRectangle.height - 5
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
                        }

                        CheckBox {
                            id: anisoCheckBox
                            checked: observables.simulateAnisoplanatic
                            Layout.alignment: Qt.AlignLeft
                            text: qsTr("Simulate Anisoplanatic")

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

                            onCheckedChanged: {
                                anisoPatchesTextField.enabled = anisoCheckBox.checked
                            }
                        }


                        TextField {
                            id: anisoPatchesTextField
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.patchSize
                            onAccepted: {
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
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Num. of timesteps")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.numTimesteps
                            onAccepted: {
                                observables.numTimesteps = parseInt(text)
                            }
                        }

                        Item {}

                        Rectangle {
                            color: sysPalette.dark
                            Layout.preferredWidth: parent.width - 5
                            Layout.preferredHeight: 2
                            Layout.columnSpan: 3
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Lower wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.lowerWavelength
                            onAccepted: {
                                observables.lowerWavelength = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Upper wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.upperWavelength
                            onAccepted: {
                                observables.upperWavelength = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Nyquist wavelength")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.nyquistWavelength
                            onAccepted: {
                                observables.nyquistWavelength = parseFloat(text)
                            }
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterUnitText.width
                            text: qsTr("nm")
                            color: sysPalette.windowText
                        }

                        Text {
                            Layout.preferredWidth: apertureDiameterText.width
                            text: qsTr("Num. of wavelengths")
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.preferredWidth: apertureDiameterTextField.width
                            color: sysPalette.windowText
                            text: observables.numWavelengths
                            onAccepted: {
                                observables.numWavelengths = parseInt(text)
                            }
                        }

                        Item {}

                        Rectangle {
                            color: sysPalette.dark
                            Layout.preferredWidth: parent.width - 5
                            Layout.preferredHeight: 2
                            Layout.columnSpan: 3
                        }

                        Text {
                            text: qsTr("Image Size (Full Aperture)")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.imageSizeFullAp
                            onAccepted: {
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
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                        TextField {
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                            text: observables.imageSizeWfs
                            onAccepted: {
                                observables.imageSizeWfs = parseInt(text)
                            }
                        }

                        Text {
                            text: qsTr("pixels")
                            Layout.fillWidth: true
                            color: sysPalette.windowText
                        }

                    }


                    Item{
                        Layout.preferredHeight: 14
                    }

                    Button {
                        Layout.preferredHeight: 50
                        Layout.fillWidth: true
                        text: qsTr("Simulate Images")
                        font.bold: true
                        font.pixelSize: 18
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
            spacing: 5

            Rectangle{
                id: rightBackgroundRectangle
                Layout.fillWidth: true
                // Layout.fillHeight: true
                Layout.preferredHeight: 700
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
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 5

                                Rectangle {
                                    id: imageryBackgroundRectangle
                                    Layout.preferredWidth: columnLayoutImagery.width * 3/5
                                    Layout.preferredHeight: childrenRect.height + 10
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersColumnLayout
                                        anchors.top: imageryBackgroundRectangle.top
                                        anchors.left: imageryBackgroundRectangle.left
                                        anchors.right: imageryBackgroundRectangle.right
                                        anchors.margins: 5
                                        spacing: 2.5

                                        Rectangle {
                                            id: imageryMakieView
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: width
                                            color: sysPalette.light
                                            radius: 5
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
                                                to: 100
                                                value: 1
                                                stepSize: 1                            
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
                                                to: 32
                                                value: 1
                                                stepSize: 1                          
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
                                                to: 5
                                                value: 1
                                                stepSize: 1                            
                                            }

                                        }
                                    }
                                }

                                Rectangle {
                                    id: imageryStatsRectangle
                                    Layout.preferredWidth: columnLayoutImagery.width * 2/5 - 5
                                    Layout.preferredHeight: childrenRect.height + 10
                                    Layout.alignment: Qt.AlignTop
                                    color: sysPalette.dark
                                    radius: 5

                                    GridLayout {
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.margins: 5
                                        rowSpacing: 5
                                        columns: 2
                                        rows: 10

                                        Text {
                                            text: qsTr("Image Stats")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: sysPalette.windowText
                                            Layout.columnSpan: 2
                                        }

                                        Text {
                                            text: qsTr("Plate Scale: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("##### arcsec/pix")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Mean: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Median: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Std: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Min: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Max: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }
                                    
                                    }
                                
                                }

                            }

                        }

                        Item {
                            id: atmosphereTabBarView
                            Layout.fillWidth: false
                            Layout.fillHeight: false

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 5

                                Rectangle {
                                    id: atmosphereBackgroundRectangle
                                    Layout.preferredWidth: columnLayoutImagery.width * 3/5
                                    Layout.preferredHeight: childrenRect.height + 10
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersAtmosphereColumnLayout
                                        anchors.top: atmosphereBackgroundRectangle.top
                                        anchors.left: atmosphereBackgroundRectangle.left
                                        anchors.right: atmosphereBackgroundRectangle.right
                                        anchors.margins: 5
                                        spacing: 2.5

                                        Rectangle {
                                            id: atmosphereMakieView
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: width
                                            color: sysPalette.light
                                            radius: 5
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
                                                to: layersModel.rowCount
                                                value: 1
                                                stepSize: 1                            
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
                                                to: 5
                                                value: 1
                                                stepSize: 1                            
                                            }

                                        }
                                    }
                                }

                                Rectangle {
                                    id: atmosphereStatsRectangle
                                    Layout.preferredWidth: columnLayoutImagery.width * 2/5 - 5
                                    Layout.preferredHeight: childrenRect.height + 10
                                    Layout.alignment: Qt.AlignTop
                                    color: sysPalette.dark
                                    radius: 5

                                    GridLayout {
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.margins: 5
                                        rowSpacing: 5
                                        columns: 2
                                        rows: 10

                                        Text {
                                            text: qsTr("Image Stats")
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: sysPalette.windowText
                                            Layout.columnSpan: 2
                                        }

                                        Text {
                                            text: qsTr("Plate Scale: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("##### arcsec/pix")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Mean: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Median: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Std: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Min: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("Max: ")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }

                                        Text {
                                            text: qsTr("#####")
                                            font.pixelSize: 16
                                            color: sysPalette.windowText
                                        }
                                    
                                    }
                                
                                }

                            }
                        }

                        Item {
                            id: pupilMasksTabBarView
                            Layout.fillWidth: false
                            Layout.fillHeight: false

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 5

                                Rectangle {
                                    id: masksBackgroundRectangle
                                    Layout.preferredWidth: columnLayoutImagery.width * 3/5
                                    Layout.preferredHeight: childrenRect.height + 10
                                    Layout.alignment: Qt.AlignTop
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersMasksColumnLayout
                                        anchors.top: masksBackgroundRectangle.top
                                        anchors.left: masksBackgroundRectangle.left
                                        anchors.right: masksBackgroundRectangle.right
                                        anchors.margins: 5
                                        spacing: 2.5

                                        Rectangle {
                                            id: masksMakieView
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: width
                                            color: sysPalette.light
                                            radius: 5
                                        }

                                        ColumnLayout {
                                            spacing: 5

                                            RowLayout {
                                                ComboBox {
                                                    model: ["Masks", "Static Aberrations"]
                                                    currentIndex: 0
                                                    font.pixelSize: 14
                                                }
                                                ComboBox {
                                                    model: ["Full Aperture", "Wavefront Sensor"]
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
                                                    to: 5
                                                    value: 1
                                                    stepSize: 1                            
                                                }

                                            }

                                        }
                                    
                                    }
                                
                                }
                                
                            }

                        }

                        Item {
                            id: responseTabBarView
                            Layout.fillWidth: false
                            Layout.fillHeight: false

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 5

                                Rectangle {
                                    id: responseBackgroundRectangle
                                    Layout.preferredWidth: columnLayoutImagery.width
                                    Layout.preferredHeight: childrenRect.height + 10
                                    Layout.alignment: Qt.AlignTop
                                    color: sysPalette.dark
                                    radius: 5

                                    ColumnLayout {
                                        id: slidersResponseColumnLayout
                                        anchors.top: responseBackgroundRectangle.top
                                        anchors.left: responseBackgroundRectangle.left
                                        anchors.right: responseBackgroundRectangle.right
                                        anchors.margins: 5
                                        spacing: 2.5

                                        Rectangle {
                                            id: responseMakieView
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: rightBackgroundRectangle.height * 1/2
                                            color: sysPalette.light
                                            radius: 5
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
                Layout.preferredHeight: columnLayoutLeft.height - rightBackgroundRectangle.height - 5
                Layout.alignment: Qt.AlignTop
                color: sysPalette.mid
                radius: 5
                border.width: 1.5
                border.color: sysPalette.dark

                ColumnLayout {
                    anchors.top: parent.top
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
                        onAccepted: {
                            observables.runId = text.toString()
                        }
                    }

                    Button {
                        text: qsTr("Save")
                        font.pixelSize: 18
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 35
                        Layout.preferredWidth: 150
                    }

                }

            }
        
        }

    }

}

