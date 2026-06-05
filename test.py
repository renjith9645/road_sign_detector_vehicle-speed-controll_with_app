from flask import Flask, jsonify, Response
import cv2
import time

app = Flask(__name__)

direction = "STOP"
speed = 0
detected_signs = ["speed60"]

camera = cv2.VideoCapture(0)

@app.route("/")
def home():
    return jsonify({
        "status": "running"
    })

@app.route("/status")
def status():
    return jsonify({
        "direction": direction,
        "speed": speed,
        "detected_signs": detected_signs
    })

@app.route("/control/F")
def forward():
    global direction, speed
    direction = "FORWARD"
    speed = 100
    return status()

@app.route("/control/B")
def backward():
    global direction, speed
    direction = "BACKWARD"
    speed = 100
    return status()

@app.route("/control/L")
def left():
    global direction, speed
    direction = "LEFT"
    speed = 100
    return status()

@app.route("/control/R")
def right():
    global direction, speed
    direction = "RIGHT"
    speed = 100
    return status()

@app.route("/control/STOP")
def stop():
    global direction, speed
    direction = "STOP"
    speed = 0
    return status()

def generate_frames():
    while True:
        success, frame = camera.read()

        if not success:
            continue

        cv2.putText(
            frame,
            f"Direction: {direction}",
            (20, 40),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 255, 0),
            2
        )

        cv2.putText(
            frame,
            f"Speed: {speed}",
            (20, 80),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (255, 0, 0),
            2
        )

        cv2.putText(
            frame,
            f"Sign: {detected_signs[0]}",
            (20, 120),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 0, 255),
            2
        )

        ret, buffer = cv2.imencode(".jpg", frame)
        frame = buffer.tobytes()

        yield (
            b"--frame\r\n"
            b"Content-Type: image/jpeg\r\n\r\n" +
            frame +
            b"\r\n"
        )

@app.route("/video_feed")
def video_feed():
    return Response(
        generate_frames(),
        mimetype="multipart/x-mixed-replace; boundary=frame"
    )

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        threaded=True
    )