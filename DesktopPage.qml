import QtQuick 2.4
import QtQml.Models 2.2
import Material 0.2
import com.evercloud.rdp 0.1
import com.evercloud.conn 0.1
import com.evercloud.http 0.1
import "./settingPage"

Page {
    id: desktop_selection

    actionBar.hidden: true

    Image {
        fillMode: Image.PreserveAspectFit
        source: "image/1920.png"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    Row {
        // 左上按钮栏
        anchors {
            top: parent.top
            topMargin: 24
            left: parent.left
            leftMargin: 24
        }

        spacing: 18

        Action {
            id: backAction
            iconName: "navigation/arrow_back"
            text: "返回"
        }

        IconButton {
            action: backAction
            size: 24
            color: Theme.dark.iconColor
            onClicked: desktop_selection.pop()
            visible: canGoBack
        }
    }

    property bool heartbeat_error: false
    property date session_start: new Date()
    property int rdp_retry: 0

    Component.onCompleted: {
        parse_info();
        heartbeat.startSending(UserConnection.token);
    }

    Component.onDestruction: {
        heartbeat.stop();
    }

    function parse_info() {
        console.log(UserConnection.info);
        var info = JSON.parse(UserConnection.info);
        UserConnection.token = info["token"];
        var vms = info["vms"];
        for (var vm_id in vms) {
            var detail = vms[vm_id];
            hosts.append({
                token: info["token"],
                vm_id: vm_id,
                name: detail["name"],
                host: detail["floating_ips"][0]});
        }
    }

    ProgressCircle {
        // 连接过程中显示进度圈
        id: conn_progress
        anchors.centerIn: vm_buttons

        visible: false
    }

    ListModel {
        id: hosts
    }

    Row {
        id: vm_buttons
        anchors {
            bottom: parent.bottom
            bottomMargin: 100
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 25

        Repeater {
            model: hosts

            delegate: Button {
                text: name;
                width: Units.dp(200)
                height: Units.dp(48)
                backgroundColor: Theme.accentColor
                activeFocusOnPress: true
                onClicked: {
                    UserConnection.currentVm = vm_id;
                    request.url = "http://" + serversetting.server + ":8893/v1/conn";
                    request.jsonData = JSON.stringify({ 'token': token, 'vm_id': vm_id });
                    request.sendJson();
                    vm_buttons.visible = false;
                    conn_progress.visible = true;
                }
            }

        }
    }

    RDPProcess {
        id: rdp
        smoothFont: true
        dragFullWindow: true

        onErrorOccurred: {
            var err = rdp.errorCode();
            prompt.open("无法连接到桌面：" + err)
        }

        onFinished: {
            var code = rdp.status();
            if (desktop_selection.heartbeat_error) { // 心跳异常，需要重新登录
                desktop_selection.pop();
            }
            if (code !== 0) {
                prompt.open("连接错误：" + rdp.status())
            } else if (new Date() - desktop_selection.session_start < 500) {
                // 0.5秒内断开，可能是vm未完全启动，或其他异常情况，重试
                if (desktop_selection.rdp_retry == 10) {
                    // 重试次数超过阈值
                    prompt.open("无法连接到桌面");
                } else {
                    desktop_selection.rdp_retry++;
                    rdp_repeater.start();
                    return;
                }
            }
            conn_progress.visible = false;
            vm_buttons.visible = true;
            desktop_selection.rdp_retry = 0;

            heartbeat.startSending(UserConnection.token);
            // 断开连接
            disconn_request.url = "http://" + serversetting.server + ":8893/v1/disconn";
            disconn_request.jsonData = JSON.stringify({ "token": UserConnection.token, "vm_id": UserConnection.currentVm });
            disconn_request.sendJson();
        }
    }

    Request {
        id: request
        onResponseChanged: {
            var code = request.code;
            var response = JSON.parse(request.response);

            if (code === 200) {
                rdp.username = UserConnection.username;
                rdp.password = UserConnection.password;
                rdp.host = response[UserConnection.currentVm]["rdp_ip"];
                rdp.port = response[UserConnection.currentVm]["rdp_port"];
                rdp.policy = response[UserConnection.currentVm]["policy"];
                desktop_selection.session_start = new Date();
                rdp.start();
                heartbeat.startSending(UserConnection.token, UserConnection.currentVm);
            } else {
                prompt.open("无法启动虚拟机：" + response["err"])
            }

        }
    }

    Request {
        id: disconn_request
    }

    HeartBeat {
        id: heartbeat
        url: "http://" + serversetting.server + ":8893/v1/heartbeat"
        onError: { // 心跳异常
            heartbeat.stop();
            desktop_selection.heartbeat_error = true;
        }
    }

    Settingstore {
        id: serversetting
    }

    Snackbar {
        id: prompt
    }

    Timer {
        id: rdp_repeater
        interval: 1000
        repeat: false
        onTriggered: {
            desktop_selection.session_start = new Date();
            rdp.start();
        }
    }
}
