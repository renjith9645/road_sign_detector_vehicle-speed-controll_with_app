<<<<<<< HEAD
# road_sign_detector

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# 🚗 AI-Based Road Sign Detection and Autonomous Vehicle Control System

## Overview

This project presents an AI-powered autonomous vehicle capable of detecting traffic signs in real time and automatically controlling vehicle movement based on the detected signs. The system combines Deep Learning, Computer Vision, Embedded Systems, and Mobile Application Development to create an intelligent transportation prototype. The vehicle uses a Raspberry Pi, Pi Camera, YOLO object detection model, Flask server, and Flutter mobile application to provide autonomous navigation and remote monitoring capabilities.

## Features

* Real-time traffic sign detection using YOLO
* Autonomous vehicle control based on detected signs
* Live camera streaming from Raspberry Pi
* Remote control through Flutter mobile application
* Real-time vehicle status monitoring
* Automatic speed adjustment according to speed limit signs
* Stop and No Entry sign recognition
* Wireless communication over Wi-Fi
* Modern futuristic dashboard interface
* GPIO-based motor control using Raspberry Pi

## Technologies Used

### Hardware

* Raspberry Pi 4
* Raspberry Pi Camera Module
* L298N Motor Driver
* DC Motors
* Robot Chassis
* Battery Pack

### Software

* Python
* Flask
* OpenCV
* YOLO (Ultralytics)
* Picamera2
* Flutter
* Dart
* HTTP REST API
* Raspberry Pi OS

## System Architecture

The Raspberry Pi captures live video through the Pi Camera and processes each frame using a custom-trained YOLO model. Detected traffic signs are classified and used to generate control decisions. Based on the detection results, the Raspberry Pi adjusts motor speed and direction through GPIO-controlled motor drivers.

A Flask web server streams live video and provides APIs for vehicle control and status monitoring. The Flutter mobile application communicates with the Flask server to display the live camera feed, detected traffic signs, vehicle speed, and movement direction while also providing manual control options.

## Traffic Sign Logic

| Detected Sign  | Vehicle Action    |
| -------------- | ----------------- |
| Stop           | Vehicle Stops     |
| No Entry       | Vehicle Stops     |
| Speed Limit 30 | Speed Set to 40%  |
| Speed Limit 60 | Speed Set to 80%  |
| Speed Limit 80 | Speed Set to 100% |

## API Endpoints

### Live Video Stream

```http
/video_feed
```

### Vehicle Status

```http
/status
```

### Traffic Sign Information

```http
/traffic_signs
```

### Vehicle Controls

```http
/control/F
/control/B
/control/L
/control/R
/control/STOP
```

## Mobile Application Features

* Connect to Raspberry Pi using IP Address
* Live camera monitoring
* Real-time traffic sign display
* Speed monitoring
* Direction monitoring
* Vehicle control buttons
* Connection status indicator
* Dashboard refresh functionality
* Futuristic dark theme UI

## Working Principle

1. Camera captures live video.
2. YOLO model detects traffic signs.
3. Raspberry Pi processes detection results.
4. Motor speed and direction are adjusted automatically.
5. Flask server streams live data.
6. Flutter application displays video and vehicle status.
7. User can manually override controls through the mobile application.

## Project Structure

```text
road-sign-detector/
│
├── best.pt
├── app.py
├── requirements.txt
│
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── services/
│
├── models/
├── images/
└── README.md
```

## Applications

* Autonomous Vehicles
* Smart Transportation Systems
* Driver Assistance Systems
* Robotics Research
* Traffic Monitoring
* Educational Projects
* AI and Computer Vision Learning

## Future Enhancements

* Lane Detection
* Obstacle Avoidance
* GPS Navigation
* Voice Commands
* Cloud-Based Monitoring
* Multi-Sign Recognition
* Vehicle-to-Vehicle Communication
* Real-Time Analytics Dashboard

## Conclusion

This project demonstrates the successful integration of Artificial Intelligence, Computer Vision, Robotics, and Mobile Technologies to create a smart autonomous vehicle system. By combining YOLO-based traffic sign detection with Raspberry Pi motor control and a Flutter-based monitoring application, the system provides an efficient and cost-effective solution for autonomous navigation research and intelligent transportation applications.
>>>>>>> 76b612a28f1607239d90c54358e261fa2cc8c62a
