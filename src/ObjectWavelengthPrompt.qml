import jlqml
import Makie
import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels


ApplicationWindow {
    id: objectWavelengthWindow
    title: "Set object wavelengths"
    width: 400
    height: 600
    // minimumWidth: 400
    // minimumHeight: 600
    // maximumWidth: 400
    // maximumHeight: 600
    visible: true

    property int textFieldWidth: 125
    property int textWidth: 175

    SystemPalette { 
        id: sysPalette
        colorGroup: SystemPalette.Active
    }
    color: sysPalette.window

    Rectangle {
        anchors.fill: parent
        anchors.margins: 5
        color: sysPalette.dark
        radius: 5

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5

            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Button {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    icon.source: "assets/rotCCW.png"
                    onClicked: {
                        Julia.rotSetTargetCCW90()
                    }
                }

                Button {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    icon.source: "assets/rotCW.png"
                    onClicked: {
                        Julia.rotSetTargetCW90()
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
                    currentValue: observables.currentSetTargetColormap
                    onActivated: {
                        observables.currentSetTargetColormap = currentValue;
                    }
                }
            }

            MakieArea {
                Layout.fillHeight: true
                Layout.fillWidth: true
                scene: observables.targetSetWavelengthFigureObs
            }
            // Rectangle {
            //     Layout.fillHeight: true
            //     Layout.fillWidth: true
            // }
        
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
                        targetSetWavelengthSlider.value -= 1
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
                        targetSetWavelengthSlider.value += 1
                    }
                }

                Text {
                    text: targetSetWavelengthSlider.value+"/"+targetSetWavelengthSlider.to
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: sysPalette.windowText
                    font.pixelSize: 12
                }

                Slider {
                    id: targetSetWavelengthSlider
                    Layout.fillWidth: true
                    Layout.columnSpan: 3
                    from: 1
                    to: observables.numWavelengthsTarget
                    value: observables.currentTargetSetWavelengthIx
                    stepSize: 1
                    onValueChanged: {
                        observables.currentTargetSetWavelengthIx = value;
                    }  
                }

            }

            GridLayout {                                        
                rows: 3
                columns: 3
                Layout.fillWidth: true

                CheckBox {
                    id: greybodyCheckBox
                    Layout.alignment: Qt.AlignLeft
                    Layout.columnSpan: 3
                    checked: observables.objectIsGreybody
                    text: qsTr("Greybody object")

                    indicator: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        x: parent.leftPadding
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
                            visible: greybodyCheckBox.checked
                        }
                    }

                    contentItem: Text {
                        text: greybodyCheckBox.text
                        font: greybodyCheckBox.font
                        color: sysPalette.windowText
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: parent.indicator.width + parent.spacing
                    }
                }

                Text {
                    enabled: !greybodyCheckBox.checked
                    Layout.preferredWidth: textWidth
                    text: qsTr("Lower wavelength")
                    color: sysPalette.windowText
                }

                TextField {
                    id: setLowerWavelengthTextField
                    enabled: !greybodyCheckBox.checked
                    Layout.preferredWidth: textFieldWidth
                    color: sysPalette.windowText
                    validator: DoubleValidator {
                        bottom: 0
                    }
                    onEditingFinished: {
                    }
                }

                Text {
                    enabled: !greybodyCheckBox.checked
                    text: qsTr("nm")
                    color: sysPalette.windowText
                }

                Text {
                    enabled: !greybodyCheckBox.checked
                    Layout.preferredWidth: textWidth
                    text: qsTr("Upper wavelength")
                    color: sysPalette.windowText
                }

                TextField {
                    id: setUpperWavelengthTextField
                    enabled: !greybodyCheckBox.checked
                    Layout.preferredWidth: textFieldWidth
                    color: sysPalette.windowText
                    validator: DoubleValidator {
                        bottom: 0
                    }
                    onEditingFinished: {
                    }
                }

                Text {
                    enabled: !greybodyCheckBox.checked
                    text: qsTr("nm")
                    color: sysPalette.windowText
                }

            }

            Button {
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                text: qsTr("Apply")
                font.bold: true
                font.pixelSize: 16
                onClicked: {
                    Julia.applyObjectWavelengths(greybodyCheckBox.checked, parseFloat(setLowerWavelengthTextField)*1e-9, parseFloat(setUpperWavelengthTextField)*1e-9);
                    objectWavelengthWindow.destroy()
                }
            }
        }
    }
}