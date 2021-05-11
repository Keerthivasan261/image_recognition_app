import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_recognition_app/main.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tflite/tflite.dart';

class MainPage extends StatefulWidget {
  static const id = "MainPage";

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool showSpinner = false;
  bool isWorked = false;
  String result = "";
  CameraImage camImg;
  CameraController camController;

  loadModal() async {
    await Tflite.loadModel(
      model: "images/tflite_file.tflite",
      labels: "images/text_file.txt",
    );
  }

  // ignore: must_call_super
  initCamera() {
    camController = CameraController(cameras[0], ResolutionPreset.high);
    camController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      camController.startImageStream((image) => {
            setState(() {
              if (!isWorked) {
                showSpinner = false;
                camImg = image;
                isWorked = true;
                runModal();
              }
            }),
          });
    });
  }

  runModal() async {
    if (camImg != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: camImg.planes.map(
          (planes) {
            return planes.bytes;
          },
        ).toList(),
        imageHeight: camImg.height,
        imageWidth: camImg.width,
        numResults: 2,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 0,
        threshold: 0.1,
        asynch: true,
      );
      result = "";
      recognitions.forEach((response) {
        result = "\' " + response["label"].toString().toUpperCase() + " \'\n\n";
      });
      setState(() {
        result;
      });
      isWorked = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModal();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    camController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        color: Colors.red,
        inAsyncCall: showSpinner,
        child: Stack(
          children: [
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              bottom: 0,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black54,
                          )
                        ],
                        color: Colors.white,
                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: camImg == null
                          ? Center(
                              child: SizedBox(
                                height: 120,
                                child: Column(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        showSpinner = true;
                                        initCamera();
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: Colors.red,
                                        ),
                                        child: Icon(
                                          MdiIcons.camera,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Press here\n to open camera",
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : AspectRatio(
                              aspectRatio: camController.value.aspectRatio,
                              child: CameraPreview(camController),
                            ),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: 90,
                    child: SizedBox(
                      height: 160,
                      child: Center(
                        child: Text(
                          "$result",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
