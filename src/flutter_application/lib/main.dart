// Importing necessary packages.
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

// Importing screens.
import 'home_screen.dart';
import 'profile_screen.dart';

List<CameraDescription> cameras = [];

// Main function.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(MyApp());
}

// Main App widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => BaseScreen(),
        '/result': (context) => HomeScreen(),
      },
    );
  }
}

// Base Screen widget.
class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

// State for Base Screen widget.
class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [HomeScreen(), CameraPage(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.blueGrey,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.videocam, size: 30),
          Icon(Icons.person, size: 30),
        ],
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Camera Page widget.
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

// State for Camera Page widget.
class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  int _countdownSeconds = 5;
  bool _recording = false;
  num _heartRate = 72;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.low,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Building widget.
  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Record Video Button
            ElevatedButton(
              onPressed: _recording ? null : _startRecording,
              child: Text(
                'Record Video',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            if (_recording)
              Text(
                '$_countdownSeconds',
                style: TextStyle(
                  fontSize: 48.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Function to start recording.
  void _startRecording() async {
    try {
      setState(() {
        _recording = true;
      });
      // Setting up the camera.
      await _controller.setFlashMode(FlashMode.torch);
      await _controller.setExposureOffset(-2.0);
      await _controller.setZoomLevel(1);
      await _controller.setExposureMode(ExposureMode.locked);
      await _controller.startVideoRecording();
      await _startCountdown();

      // Stopping and saving the video.
      final xFile = await _controller.stopVideoRecording();
      await _controller.setFlashMode(FlashMode.off);
      await uploadVideoToFirebase(xFile);
      _getHeartRate();
      _showCompletedMessage(context);
    } catch (e) {
      print('Failed to record video: $e');
    } finally {
      setState(() {
        _recording = false;
        _countdownSeconds = 5;
      });
    }
  }

  // Function to start countdown.
  Future<void> _startCountdown() async {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _countdownSeconds--;
      });
    }
  }

  // Function to show a dialog on recording completion.
  void _showCompletedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Video Recording Complete',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
        content: Container(
          height: 111,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                '$_heartRate BPM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BaseScreen()),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to save video.
  Future<void> _saveVideo(String path) async {
    GallerySaver.saveVideo(path);
  }

  // Function to upload video to Firebase.
  Future<void> uploadVideoToFirebase(XFile videoFile) async {
    final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('videos/${DateTime.now()}.mp4');
    final task = firebaseStorageRef.putFile(File(videoFile.path));

    await task.whenComplete(() async {
      print('Video uploaded to Firebase storage');
    });
  }

  // Function to get random heart rate.
  void _getHeartRate() {
    final random = Random();
    final minHeartRate = 68;
    final maxHeartRate = 98;
    final heartRate = minHeartRate + random.nextInt(maxHeartRate - minHeartRate + 1);
    setState(() {
      _heartRate = heartRate;
    });
  }

  // void processVideoOnCloudFunction(String videoUrl) async {
  //   try {
  //     final FirebaseApp app = Firebase.app();
  //     final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
  //       app: app,
  //       region: 'us-central1',
  //     );

  //     final HttpsCallable processVideo = functions.httpsCallable('processVideo',
  //         options: HttpsCallableOptions());

  //     final result = await processVideo.call({
  //       'videoUrl': videoUrl,
  //     });

  //     final heartRate = result.data['heartRate'];
  //     Navigator.pushNamed(context, '/result', arguments: heartRate);
  //   } catch (error) {
  //     print('Error processing video: $error');
  //   }
  // }

  // void processVideoOnCloudFunction(String videoUrl) {
  //   final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  //   final processVideo = functions.httpsCallable('processVideo');

  //   processVideo.call({
  //     'videoUrl': videoUrl,
  //   }).then((result) {
  //     final heartRate = result.data['heartRate'];
  //     Navigator.pushNamed(context, '/result', arguments: heartRate);
  //   }).catchError((error) {
  //     print('Error processing video: $error');
  //   });
  // }
}
