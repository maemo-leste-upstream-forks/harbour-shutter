import QtQuick 2.0
import QtMultimedia 5.6
import "pages"
import uk.co.piggz.pinhole 1.0

import "./components/"
import "./components/platform"

ApplicationWindowPL {
    id: app
    property bool loadingComplete: false;
    Settings {
        id: settings
        property string cameraName
        property int cameraId: 0
        property string captureMode
        property int cameraCount
        property variant enabledCameras: [] //Calculated on startup and when disabledCameras changes
        property variant disabledCameras: [] //Calculated on startup and when disabledCameras changes

        function getCameraValue(s, d) {
            return get(cameraId, s, d);
        }
        function setCameraValue(s, v) {
            set(cameraId, s, v);
        }
        function getCameraModeValue(s, d) {
            return get(cameraId + "_" + captureMode, s, d);
        }
        function setCameraModeValue(s, v) {
            set(cameraId + "_" + captureMode, s, v);
        }
        function strToSize(siz) {
            var w = parseInt(siz.substring(0, siz.indexOf("x")))
            var h = parseInt(siz.substring(siz.indexOf("x") + 1))
            return Qt.size(w, h)
        }

        function sizeToStr(siz) {
            return siz.width + "x" + siz.height
        }
        //Return either the current mode resolution or default resolution for that mode
        function resolution(mode) {
            if (settings.captureMode === mode
                    && settings.mode.resolution !== "") {
                var res = strToSize(settings.mode.resolution)
                if (modelResolution.isValidResolution(res, mode)) {
                    return res
                }
            }
            return modelResolution.defaultResolution(mode)
        }

        function calculateEnabledCameras()
        {
            settings.enabledCameras = []
            for (var i = 0; i < settings.cameraCount; ++i) {
                if (settings.disabledCameras.indexOf("[" + modelCamera.get(i) + "]") == -1) {
                    settings.enabledCameras.push(modelCamera.get(i))
                }
            }
        }

        Component.onCompleted: {
            console.log("Setting up default settings");
            captureMode = get("global", "captureMode", "image");
            cameraName = get("global", "cameraName", "");
            cameraId = get("global", "cameraId", 0);

            set("global", "cameraId", cameraId);
            set("global", "cameraName", cameraName);
            set("global", "captureMode", captureMode);

            cameraCount = modelCamera.rowCount;
        }
    }

    StylerPL {
        id: styler
    }
    TruncationModes { id: truncModes }
    DockModes { id: dockModes }

    Rectangle {
        anchors.fill: parent
        z: -10
        color: "black"
    }

    initialPage: CameraUI {
            id: cameraUI
    }

    Component.onCompleted: {
        cameraUI.startup();
        loadingComplete = true;
    }

    /*
    onApplicationActiveChanged: {
        if (Qt.application.state == Qt.ApplicationActive) {
            cameraUI.camera.start();
        } else {
            cameraUI.camera.stop();
        }
    }
*/
}
