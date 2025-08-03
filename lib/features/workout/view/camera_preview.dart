import 'package:flutter/material.dart';
import 'package:camera/camera.dart';


class CameraPrev extends StatefulWidget {
  const CameraPrev({super.key});

  @override
  State<CameraPrev> createState() => _CameraPrevState();
}

class _CameraPrevState extends State<CameraPrev> {
  CameraController? _cameraController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initCamera();
  }
  Future<void> _initCamera()async{
    final cameras = await availableCameras();
    final frontCamera = cameras[1];
    _cameraController = CameraController(
    frontCamera,
    ResolutionPreset.medium,
    enableAudio: false);
    await _cameraController!.initialize();
    setState(() {

    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_cameraController==null || !_cameraController!.value.isInitialized){
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(title: const Text("Live Pose Detection")),
    body: CameraPreview(_cameraController!),);
  }
}
