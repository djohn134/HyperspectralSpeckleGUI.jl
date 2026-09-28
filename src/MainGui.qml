import QtQuick
import QtQuick.Controls
import jlqml

ApplicationWindow {
  id: mainWin
  title: "My Application"
  width: 1600
  height: 900
  visible: true

  Rectangle {
    anchors.fill: parent
    // color: "red"

    Text {
      anchors.centerIn: parent
      text: "Hello world!"
    }
  }
}
