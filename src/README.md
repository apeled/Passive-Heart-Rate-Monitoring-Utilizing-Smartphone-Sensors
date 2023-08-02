# The `\src` Directory

This directory is the root source directory of our application, consisting of two main subdirectories: `backend` and `flutter_application`.

## Backend

The backend of our application is a Google Cloud Function designed to process video data and extract the heart rate. The function is triggered by a change in a Google Cloud Storage bucket.

### Files

- **main.py**: This is the main file that contains the Google Cloud Function, which processes the video data and calculates the heart rate.

- **requirements.txt**: This file lists the Python packages required to run the function. To install these dependencies, run: `pip install -r requirements.txt`


# Flutter Application

This directory contains all the code required to launch our Flutter Application on either a physical or a virtual device.

The Flutter application serves as the user interface for our project. It provides interactive screens to upload video files, view processed results, and other functionalities. It is designed to work seamlessly with the backend cloud function and presents the extracted heart rate data in a user-friendly manner.

Make sure you have the Flutter SDK installed on your machine. Follow the [instructions](https://flutter.dev/docs/get-started/install) if you haven't installed it yet.

Once you have Flutter installed, navigate to the `flutter_application` directory, and to fetch the project dependencies, run: `flutter pub get`

## Flutter Application Code Structure

The Flutter application is composed of the following main files:

### `lib/main.dart`

This is the entry point of the Flutter application. The `main()` function resides in this file. It initializes the Firebase app, gets the list of available cameras, and starts the Flutter app. The `MyApp` widget is a `MaterialApp` and sets up routes for the app.

It contains definitions for several widgets:

- `MyApp`: The root widget of the application.
- `BaseScreen`: A `StatefulWidget` that manages the navigation bar and switching between different screens.
- `CameraPage`: A `StatefulWidget` that handles the camera functionality, including starting/stopping the video recording, managing the countdown, and handling the completion of the recording.

### `lib/home_screen.dart`

This file contains the `HomeScreen` widget.

### `lib/profile_screen.dart`

This file contains the `ProfileScreen` widget.
