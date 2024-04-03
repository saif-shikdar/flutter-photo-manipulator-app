import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
      await _cameraController.lockCaptureOrientation();
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.auto);
      XFile picture = await _cameraController.takePicture();
      closeCamera(picture);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  void closeCamera(XFile picture) {
    Navigator.pop(
      context,
      picture,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              iconSize: 35,
              icon: Icon(
                  _isRearCameraSelected
                      ? CupertinoIcons.switch_camera
                      : CupertinoIcons.switch_camera_solid,
                  color: Colors.white),
              onPressed: () {
                setState(
                  () => _isRearCameraSelected = !_isRearCameraSelected,
                );
                initCamera(
                  widget.cameras![_isRearCameraSelected ? 0 : 1],
                );
              },
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Icon(
                  Icons.panorama_fish_eye_rounded,
                  color: Colors.white,
                  size: 90,
                ),
                IconButton(
                  onPressed: takePicture,
                  iconSize: 65,
                  icon: const Icon(
                    Icons.circle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 50,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: _cameraController.value.isInitialized
          ? SafeArea(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: CameraPreview(
                      _cameraController,
                      child: Icon(
                        Icons.crop_free_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Material(
                        color: Colors.black54,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
