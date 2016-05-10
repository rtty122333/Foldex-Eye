import QtQuick 2.4
import QtQml.Models 2.2
import Material 0.2
import com.evercloud.rdp 0.1
import com.evercloud.conn 0.1
import com.evercloud.http 0.1
import "./settingPage"

Page {
    id: desktop_selection

    backAction: Action {
        text: "返回"
        iconName: "navigation/arrow_back"
        onTriggered: desktop_selection.pop()
        visible: canGoBack
    }

    ListModel {
        id: hosts
    }

    Row {
        anchors.centerIn: parent
        spacing: 20

        Button {
            text: "test-VM1";
            onClicked: {
                rdp.username = UserConnection.username;
                rdp.password = UserConnection.password;
                rdp.host = serversetting.server;
                rdp.start();
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
            if (code !== 0) {
                prompt.open("连接错误：" + rdp.status())
            }
        }
    }

    Settingstore {
        id: serversetting
    }

    Snackbar {
        id: prompt
    }
}
