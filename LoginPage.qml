import QtQuick 2.4
import Material 0.2
import com.evercloud.http 0.1
import com.evercloud.conn 0.1
import com.evercloud.sys 0.1
import "./settingPage"

Page {
    actionBar.hidden: true

    Settingstore {
        id: settings
    }

    View {
        // 背景卡片
        radius: 3
        width: 400
        height: 500
        elevation: 3
        backgroundColor: "white"
        anchors.centerIn: parent

        View {
            // 标题板
            id: caption

            width: parent.width
            height: 150
            radius: 3
            backgroundColor: Theme.primaryColor
            elevation: 1

            Icon {
                id: caption_icon
                name: "action/account_circle"
                color: "white"
                size: 48

                anchors {
                    bottom: parent.bottom
                    bottomMargin: 32
                    left: parent.left
                    leftMargin: 50
                }
            }

            Text {
                text: "登录"

                color: "white"
                font.pointSize: 32

                anchors {
                    verticalCenter: caption_icon.verticalCenter
                    left: caption_icon.right
                    leftMargin: 16
                }
            }
        }

        TextField {
            // 用户名输入框
            id: username

            placeholderText: "用户名"
            floatingLabel: true
            font.pointSize: 20

            onTextChanged: {
                username.hasError = false;
                if (username.text === "") {
                    keep_username.checked = false
                }
            }

            width: 300
            anchors {
                top: caption.bottom
                topMargin: 64
                horizontalCenter: parent.horizontalCenter
            }
        }

        TextField {
            // 密码输入框
            id: password

            placeholderText: "密码"
            floatingLabel: true
            echoMode: TextInput.Password
            font.pointSize: 24

            onTextChanged: {
                password.hasError = false;
                password.helperText = "";
                if (password.text === "") {
                    keep_password.checked = false
                }
            }

            width: 300
            anchors {
                top: username.bottom
                topMargin: 32
                horizontalCenter: parent.horizontalCenter
            }
        }

        Row {
            // 开关栏
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: password.bottom
                topMargin: 32
            }

            spacing: 16

            Switch {
                id: keep_username
                enabled: username.text !== ""
                checked: true
                onCheckedChanged: function () {
                    if (keep_username.checked == false) {
                        keep_password.checked = false
                    }
                }
            }

            Label {
                text: "记住用户名"
                anchors.verticalCenter: keep_username.verticalCenter
            }

            Rectangle {
                color: "white"
                width: 1
                height: 24
                anchors.verticalCenter: parent.verticalCenter
            }

            Switch {
                id: keep_password
                enabled: password.text !== "" && keep_username.checked
                checked: true
            }

            Label {
                text: "记住密码"
                anchors.verticalCenter: keep_password.verticalCenter
            }
            Component.onCompleted: {
                if (settings.user !== '') {
                    username.text = settings.user
                    keep_username.checked = true
                } else {
                    keep_username.checked = false
                }

                if (settings.passwd !== '') {
                    password.text = settings.passwd
                    keep_password.checked = true
                } else {
                    keep_password.checked = false
                }
            }
        }

        ProgressCircle {
            // 登录过程中显示进度圈
            id: login_progress
            anchors.centerIn: login_button
            visible: false
        }

        Button {
            // 登录按钮
            id: login_button
            anchors {
                bottom: parent.bottom
                bottomMargin: 32
                horizontalCenter: parent.horizontalCenter
            }

            elevation: 1
            backgroundColor: Theme.accentColor

            enabled: input_is_valid()
            onClicked: {
                if (username.text !== "test" || password.text !== "123456") {
                    username.hasError = true;
                    password.hasError = true;
                    password.helperText = "用户名或密码错误";
                } else {
                    UserConnection.username = username.text;
                    UserConnection.password = password.text;
                    pageStack.push(Qt.resolvedUrl("DesktopPage.qml"));
                }
            }

            function input_is_valid() {
                return username.text !== "" && password.text !== "";
            }

            Icon {
                name: "action/done"
                size: 32
                color: "white"

                anchors.centerIn: parent
            }
        }
    }

    Dialog {
        id: shutDownDialog
        property string powerAction: "shutdown"
        width: Units.dp(300)
        text: "确定要关机吗？"
        hasActions: true
        positiveButtonText: "确定"
        negativeButtonText: "取消"

        onAccepted: {
            //保存当前用户名或密码逻辑
            if ((keep_username.checked == true)
                    && (keep_password.checked == false)) {
                settings.storeUser(username.text, '')
            } else if ((keep_username.checked == true)
                       && (keep_password.checked == true)
                       && (username.text !== '')) {
                settings.storeUser(username.text, password.text)
            } else if (keep_username.checked == false) {
                settings.storeUser('', '')
            }

            if (powerAction === "shutdown") {
                sys.shutdown();
            } else if (powerAction === "reboot") {
                sys.reboot();
            } else {
                console.log("unknown power action");
            }

        }
    }

    Row {
        // 右下按钮栏
        anchors {
            bottom: parent.bottom
            bottomMargin: 32
            right: parent.right
            rightMargin: 32
        }

        spacing: 32

        Action {
            id: rebootAction
            iconName: "navigation/refresh"
            text: "重启"
        }

        Action {
            id: shutDownAction
            iconName: "action/power_settings_new"
            text: "关机"
        }

        IconButton {
            action: rebootAction
            size: 32
            hoverAnimation: true
            color: Theme.light.iconColor
            onClicked: {
                shutDownDialog.powerAction = "reboot";
                shutDownDialog.text = "确定要重启吗？"
                shutDownDialog.show()
            }
        }

        IconButton {
            action: shutDownAction
            size: 32
            color: Theme.light.iconColor
            hoverAnimation: true
            onClicked: {
                shutDownDialog.powerAction = "shutdown";
                shutDownDialog.text = "确定要关机吗？"
                shutDownDialog.show()
            }
        }
    }

    Row {
        // 左下按钮栏
        anchors {
            bottom: parent.bottom
            bottomMargin: 32
            left: parent.left
            leftMargin: 32
        }

        spacing: 32

        Action {
            id: settingAction
            iconName: "action/settings"
            text: "系统设置"
        }

        IconButton {
            action: settingAction
            size: 32
            hoverAnimation: true
            color: Theme.light.iconColor
            onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"))
        }
    }

    Snackbar {
        // 通知栏
        id: prompt
    }

    SystemPower {
        id: sys
    }
}
