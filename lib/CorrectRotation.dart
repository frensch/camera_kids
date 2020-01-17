import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:camera/camera.dart';


class CorrectRotation extends StatelessWidget {

  final CameraController cameraController;
  final String urlImage;

  const CorrectRotation({Key key, this.cameraController, this.urlImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      builder: (context) {
        NativeDeviceOrientation orientation =
        NativeDeviceOrientationReader.orientation(context);
        print("Received new orientation: $orientation");
        if (orientation == NativeDeviceOrientation.landscapeLeft) {
          return Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(urlImage),
              Expanded(child: AspectRatio(
                  aspectRatio: 1 / cameraController.value.aspectRatio,
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: CameraPreview(cameraController)))),
            ],
          ));
        } else if (orientation == NativeDeviceOrientation.landscapeRight) {
          return Center( child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child:AspectRatio(
                  aspectRatio: 1/cameraController.value.aspectRatio,
                  child: RotatedBox(
                      quarterTurns: 1,
                      child: CameraPreview(cameraController)))),
              Image.asset(urlImage),
            ],
          ));
        } else {
          return Center( child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(urlImage),
              Expanded(
                  child: AspectRatio(
                      aspectRatio: cameraController.value.aspectRatio,
                      child: RotatedBox(
                          quarterTurns: (orientation ==
                              NativeDeviceOrientation.portraitUp
                              ? 0
                              : 2),
                          child: CameraPreview(cameraController)))),
            ],
          ));
        }
      },
    );
  }
}