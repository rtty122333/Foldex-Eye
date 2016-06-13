import QtQuick 2.4
import Material 0.2
import Material.ListItems 0.1 as ListItem
import QtQml 2.2

Page {
    id: settingpage
    title: "设置"

    backAction: Action {
        text: "返回"
        iconName: "navigation/arrow_back"
        onTriggered: settingpage.pop()
        visible: canGoBack
    }

    property int selectedComponent: 0
    property var settingName: [{
            name: "网络设置",
            url: "network.qml",
            icon: "notification/wifi"
        }, {
            name: "服务器配置",
            url: "server.qml",
            icon: "device/storage"
        }, {
            name: "协议配置",
            url: "protocol.qml",
            icon: "action/swap_horiz"
        }]

    Sidebar {
        id: settingside
        width: Units.dp(320)
        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: settingName
                delegate: ListItem.Standard {
                    text: settingName[index].name
                    selected: index == settingpage.selectedComponent
                    onClicked: {
                        settingpage.selectedComponent = index
                        console.log(settingName[index].url)
                    }
                    action: Icon {
                        anchors.centerIn: parent
                        name: settingName[index].icon
                        size: 24
                    }
                }
            }
        }
    }

    Item {
        id: flickable
        anchors {
            left: settingside.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        Loader {
            id: example
            anchors.fill: parent
            asynchronous: true
            visible: status == Loader.Ready
            source: {
                return Qt.resolvedUrl(("%1%2").arg("settingPage/").arg(settingName[settingpage.selectedComponent].url))
            }
        }
    }
}
