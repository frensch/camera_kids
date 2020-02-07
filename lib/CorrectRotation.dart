import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:camera/camera.dart';


class CorrectRotation extends StatefulWidget {

  final CameraController cameraController;
  final String urlImage;
  final Function takePicture;
  static bool pressedButton = false;

  const CorrectRotation({Key key, this.cameraController, this.urlImage, this.takePicture}) : super(key: key);


  StateCorrectRotation createState()=> StateCorrectRotation(this.cameraController, this.urlImage, this.takePicture);
}

class StateCorrectRotation extends State<CorrectRotation>{

  final CameraController cameraController;
  final String urlImage;
  final Function takePicture;

  StateCorrectRotation(this.cameraController, this.urlImage, this.takePicture);

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
              FloatingActionButton(
                child: (CorrectRotation.pressedButton
                    ? Icon(Icons.all_inclusive)
                    : Icon(Icons.camera_alt)),
                backgroundColor: (CorrectRotation.pressedButton ? Colors.grey : Colors.cyan),
                onPressed: takePicture,
              )
            ],
          ));
        } else if (orientation == NativeDeviceOrientation.landscapeRight) {
          return Center( child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                child: (CorrectRotation.pressedButton
                    ? Icon(Icons.all_inclusive)
                    : Icon(Icons.camera_alt)),
                backgroundColor: (CorrectRotation.pressedButton ? Colors.grey : Colors.cyan),
                onPressed: takePicture,
              ),
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
              FloatingActionButton(
                child: (CorrectRotation.pressedButton
                    ? Icon(Icons.all_inclusive)
                    : Icon(Icons.camera_alt)),
                backgroundColor: (CorrectRotation.pressedButton ? Colors.grey : Colors.cyan),
                onPressed: takePicture,
              )
            ],
          ));
        }
      },
    );
  }
}