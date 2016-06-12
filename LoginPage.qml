import QtQuick 2.4
import QtQuick.Controls 1.4 as QmlControls
import Material 0.2
import com.evercloud.http 0.1
import com.evercloud.conn 0.1
import com.evercloud.sys 0.1
import "./settingPage"

Page {
    actionBar.hidden: true

    Image {
        fillMode: Image.PreserveAspectCrop
        source: "image/bg_1366x768.png"
        anchors.fill: parent
    }

    Image {
        anchors {
            top: parent.top
            topMargin: 20
            left: parent.left
            leftMargin: 24
        }

        source: "image/logo.png"
        sourceSize.width: 197
        sourceSize.height: 39
    }

    Settingstore {
        id: settings
    }

    View {
        // 背景卡片
        radius: 3
        width: 490
        height: 363
        elevation: 3
        backgroundColor: "white"
        anchors.centerIn: parent

        Image {
            id: logo
            anchors {
                top: parent.top
                topMargin: 45
                horizontalCenter: parent.horizontalCenter
            }

            source: "image/logo.png"
            sourceSize.width: 197
            sourceSize.height: 39
        }

        TextField {
            // 用户名输入框
            id: username

            placeholderText: "用户名"
            font.pixelSize: 14
            showBorder: false
            showBox: true
            boxColor: "#d6d6d6"

            onTextChanged: {
                username.hasError = false;
                if (username.text === "") {
                    keep_username.checked = false
                }
            }

            width: 280
            height: 30
            anchors {
                top: logo.bottom
                topMargin: 95
                horizontalCenter: parent.horizontalCenter
            }
        }

        TextField {
            // 密码输入框
            id: password

            placeholderText: "密码"
            echoMode: TextInput.Password
            font.pixelSize: 14
            showBorder: false
            showBox: true
            boxColor: "#d6d6d6"

            onTextChanged: {
                password.hasError = false;
                password.helperText = "";
                if (password.text === "") {
                    keep_password.checked = false
                }
            }

            width: 280
            height: 30
            anchors {
                top: username.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
        }

        CheckBox {
            id: keep_username
            anchors {
                top: password.bottom
                topMargin: -6
                left: password.left
                leftMargin: -15
            }
            text: "记住用户名"
            textSize: 10
            enabled: username.text !== ""
            onCheckedChanged: function () {
                if (keep_username.checked == false) {
                    keep_password.checked = false
                }
            }
        }

        CheckBox {
            id: keep_password
            anchors {
                top: password.bottom
                topMargin: -6
                right: password.right
            }
            text: "记住密码"
            textSize: 10
            enabled: password.text !== "" && keep_username.checked
            checked: true
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
                top: keep_username.bottom
                topMargin: -1
                horizontalCenter: parent.horizontalCenter
            }

            width: 280
            height: 32

            text: "登录"
            elevation: 1
            backgroundColor: Theme.accentColor

            enabled: input_is_valid()
            onClicked: {
                login_button.visible = false;
                login_progress.visible = true;
                request.url = "http://" + settings.server + ":8893/v1/login";
                request.jsonData = JSON.stringify({
                                                      username: username.text,
                                                      password: password.text
                                                  });
                request.sendJson();
            }

            function input_is_valid() {
                return username.text !== "" && password.text !== "";
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
        // 右上按钮栏
        anchors {
            top: parent.top
            topMargin: 24
            right: parent.right
            rightMargin: 24
        }

        spacing: 18

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

        Action {
            id: settingAction
            iconName: "action/settings"
            text: "系统设置"
        }

        IconButton {
            action: settingAction
            size: 24
            hoverAnimation: true
            color: Theme.dark.iconColor
            onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"))
        }

        IconButton {
            action: rebootAction
            size: 24
            hoverAnimation: true
            color: Theme.dark.iconColor
            onClicked: {
                shutDownDialog.powerAction = "reboot";
                shutDownDialog.text = "确定要重启吗？"
                shutDownDialog.show()
            }
        }

        IconButton {
            action: shutDownAction
            size: 24
            color: Theme.dark.iconColor
            hoverAnimation: true
            onClicked: {
                shutDownDialog.powerAction = "shutdown";
                shutDownDialog.text = "确定要关机吗？"
                shutDownDialog.show()
            }
        }
    }

    Snackbar {
        // 通知栏
        id: prompt
    }

    Request {
        id: request
        onResponseChanged: {
            var code = request.code;
            var response = request.response;

            login_progress.visible = false;
            login_button.visible = true;

            if (code === 401) {
                username.hasError = true;
                password.hasError = true;
                //password.helperText = "用户名或密码错误";
                prompt.open("用户名或密码错误");
            } else if (code === 500) {
                prompt.open("服务暂时不可用");
            } else if (code === 200) {
                UserConnection.username = username.text;
                UserConnection.password = password.text;
                UserConnection.info = response;
                if (!keep_username.checked) {
                    username.text = "";
                }
                if (!keep_password.checked) {
                    password.text = "";
                }

                pageStack.push(Qt.resolvedUrl("DesktopPage.qml"));
            } else {
                prompt.open("连接服务器失败");
            }
        }
    }

    SystemPower {
        id: sys
    }
}
