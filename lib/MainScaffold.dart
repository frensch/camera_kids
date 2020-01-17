import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_kids/CorrectRotation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:async';

import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class MainScaffold extends StatefulWidget {

  final CameraController cameraController;
  final Future<void> initializeControllerFuture;

  const MainScaffold(
      {Key key, this.cameraController, this.initializeControllerFuture})
      : super(key: key);

  StateMainScaffold createState()=> StateMainScaffold(cameraController, initializeControllerFuture);
}

class StateMainScaffold extends State<MainScaffold>{

  final CameraController cameraController;
  final Future<void> initializeControllerFuture;
  bool pressedButton = false;

  StateMainScaffold(this.cameraController, this.initializeControllerFuture);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            String urlImage = "assets/images/patinho.gif";
            return CorrectRotation(
                cameraController: cameraController, urlImage: urlImage);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: (pressedButton
            ? Icon(Icons.all_inclusive)
            : Icon(Icons.camera_alt)),
        backgroundColor: (pressedButton ? Colors.grey : Colors.cyan),
        onPressed: () async {
          setState(() {
            pressedButton = true;
          });

          Timer(Duration(milliseconds: 200), () {
            print("Yeah, this line is printed after 3 seconds");
            setState(() {
              pressedButton = false;
            });
          });

          try {

            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.jpg',
            );

            await initializeControllerFuture;
            await cameraController.takePicture(path);

            GallerySaver.saveImage(path);


          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}