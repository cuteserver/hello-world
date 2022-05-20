import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

ApplicationWindow
{
    id: mainWindow
    width: Qt.platform.os === "ios" ? Screen.desktopAvailableWidth : 600
    height: Qt.platform.os === "ios" ? Screen.desktopAvailableHeight : 400
    flags: Qt.platform.os === "ios" ? Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint : Qt.Window
    visible: true
    title: qsTr("Hello World")
    Rectangle
    {
        id: page
        parent: mainWindow.contentItem
        anchors.fill: parent
        color: "white"
        Text
        {
            objectName: "appTextItem"
            text: Qt.platform.os === "wasm" ? "Hello Cute World (WebAssembly)." : ""
            anchors.verticalCenter: page.verticalCenter
            anchors.horizontalCenter: page.horizontalCenter
            font.family: "Arial"
            font.pointSize: 18
            color: "black"
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferDefaultHinting
        }
    }
}

