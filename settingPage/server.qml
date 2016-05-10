import QtQuick 2.4
import Material 0.2
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem

Item {
    Settingstore {
        id: serversetting
    }

    View {
        anchors.centerIn: parent

        width: Units.dp(350)
        height: column.implicitHeight + Units.dp(32)

        elevation: 1
        radius: Units.dp(2)

        ColumnLayout {
            id: column

            anchors {
                fill: parent
                topMargin: Units.dp(16)
                bottomMargin: Units.dp(16)
            }

            spacing: Units.dp(16)

            Label {
                id: titleLabel

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Units.dp(16)
                }

                style: "title"
                text: "服务器端配置"
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Units.dp(8)
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 16
                Label {
                    text: "服务器 IP 地址："
                }
                TextField {
                    id: serverfield
                    floatingLabel: true
                    characterLimit: 15
                    text: serversetting.server
                    validator: RegExpValidator {
                        regExp: /^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))$/
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Units.dp(8)
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: Units.dp(8)

                anchors {
                    right: parent.right
                    margins: Units.dp(16)
                }

                Button {
                    text: "确定"
                    textColor: Theme.primaryColor
                    onClicked: {
                        //TODO: Save settings
                        serversetting.storeServer(serverfield.text)
                        snackbar.open("保存成功")
                    }
                }
            }
        }
    }

    Snackbar {
        id: snackbar
    }
}
