import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';

class WebCam extends StatefulWidget {
  @override
  _WebCamState createState() => _WebCamState();
}

class _WebCamState extends State<WebCam> {
  static html.VideoElement _webcamVideoElement = html.VideoElement();

  @override
  void initState() {
    super.initState();

    // Register a webcam
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('webcamVideoElement',
        (int viewId) {
      getMedia();
      return _webcamVideoElement;
    });
  }

  getMedia() {
    html.window.navigator.mediaDevices?.getUserMedia({
      "video": {"facingMode": 'environment'}
    }).then((streamHandle) {
      _webcamVideoElement
        ..srcObject = streamHandle
        ..autoplay = true;
    }).catchError((onError) {
      print(onError);
    });
  }

  switchCameraOff() {
    if (_webcamVideoElement.srcObject != null) {
      var tracks = _webcamVideoElement.srcObject?.getTracks();

      //stopping tracks and setting srcObject to null to switch camera off
      _webcamVideoElement.srcObject = null;

      tracks?.forEach((track) {
        track.stop();
      });
    }
  }

  @override
  void dispose() {
    switchCameraOff();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              child: new HtmlElementView(
            key: UniqueKey(),
            viewType: 'webcamVideoElement',
          )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          html.CanvasElement canvas =
              html.CanvasElement(width: 750, height: 750);
          html.CanvasRenderingContext2D ctx = canvas.context2D;
          ctx.drawImage(_webcamVideoElement, 0, 0);
          print(dataFromBase64String(canvas.toDataUrl('image/jpeg')));
        },
        child: Icon(Icons.camera_alt_rounded),
      ),
    );
  }
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}
