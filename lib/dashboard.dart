import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_manipulator_app/camera_page.dart';

class Dashboard extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Dashboard({
    super.key,
    required this.title,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  XFile? photo;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
  }

  Future<void> findAvailableCameras() async {
    cameras = await availableCameras();
  }

  void openCameraPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          cameras: cameras,
        ),
      ),
    ).then((selectedPhoto) {
      setState(() {
        if (selectedPhoto != null) {
          photo = selectedPhoto;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: photo == null ? Colors.white : Colors.black,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: photo == null
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Tap the camera button to take a photo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.saturation,
                ),
                child: Image.file(
                  File(
                    photo!.path,
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await findAvailableCameras().then((_) {
            if (cameras!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No cameras available!'),
                ),
              );
            } else {
              openCameraPage();
            }
          });
        },
        tooltip: 'Open Camera',
        child: const Icon(Icons.photo_camera_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
