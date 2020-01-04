import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
      .requestPermissions([PermissionGroup.storage, PermissionGroup.camera]);

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final selfieCamera = cameras.last;

  //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  //   .then((_) {
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: selfieCamera,
      ),
    ),
  );
  //});
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool pressedButton = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.ultraHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            //return CameraPreview(_controller);

            String url_image = "assets/images/patinho.gif";
            //    "https://frensch.s3.amazonaws.com/tenor.gif";

            return NativeDeviceOrientationReader(
              builder: (context) {
                NativeDeviceOrientation orientation =
                    NativeDeviceOrientationReader.orientation(context);
                print("Received new orientation: $orientation");
                if (orientation == NativeDeviceOrientation.landscapeLeft ||
                    orientation == NativeDeviceOrientation.landscapeRight) {
                  return Center( child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(url_image),
                      Expanded(child:AspectRatio(
                      aspectRatio: 1/_controller.value.aspectRatio,

                          child: RotatedBox(
                              quarterTurns: (orientation ==
                                      NativeDeviceOrientation.landscapeLeft
                                  ? 3
                                  : 1),
                              child: CameraPreview(_controller)))),
                    ],
                  ));
                } else {
                  return Center( child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(url_image),
                      Expanded(
                          child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,

                child: RotatedBox(
                              quarterTurns: (orientation ==
                                      NativeDeviceOrientation.portraitUp
                                  ? 0
                                  : 2),
                              child: CameraPreview(_controller)))),
                    ],
                  ));
                }
              },
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: (pressedButton
            ? Icon(Icons.all_inclusive)
            : Icon(Icons.camera_alt)),
        backgroundColor: (pressedButton ? Colors.grey : Colors.cyan),
        // Provide an onPressed callback.
        onPressed: () async {
          setState(() {
            pressedButton = true;
          });

          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.jpg',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            GallerySaver.saveImage(path);

            setState(() {
              pressedButton = false;
            });

            // If the picture was taken, display it on a new screen.
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path),
              ),
            );*/

          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
