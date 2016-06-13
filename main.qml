import QtQuick 2.5
import QtQuick.Window 2.2
import Material 0.2

ApplicationWindow {
    id: main

    title: "Foldex-Eye"

    visible: true

    property bool closeKeysTriggered: false

    Component.onCompleted: {
        Units.pixelDensity = 4.46
    }

    theme {
        primaryColor: "blue"
        accentColor: "#2196f3"//Palette.colors["amber"]["700"]
        tabHighlightColor: "white"
    }

    initialPage: LoginPage {
        id: login_page
    }


    onClosing: {
        // 阻止 Alt+F4 等关闭方式
        if (!closeKeysTriggered)
            close.accepted = false
    }

    Shortcut {
        // 关闭程序快捷键，供调试用
        sequence: "Ctrl+P,Ctrl+Q"
        onActivated: {
            closeKeysTriggered = true;
            main.close();
        }
    }

}
