
from flask import Flask, Response, jsonify
from ultralytics import YOLO
from picamera2 import Picamera2
import cv2
import threading
import RPi.GPIO as GPIO

app = Flask(__name__)

# =====================================
# MOTOR PINS
# =====================================

ENA = 18
IN1 = 23
IN2 = 24

ENB = 19
IN3 = 27
IN4 = 22

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(ENA, GPIO.OUT)
GPIO.setup(IN1, GPIO.OUT)
GPIO.setup(IN2, GPIO.OUT)

GPIO.setup(ENB, GPIO.OUT)
GPIO.setup(IN3, GPIO.OUT)
GPIO.setup(IN4, GPIO.OUT)

pwmA = GPIO.PWM(ENA, 1000)
pwmB = GPIO.PWM(ENB, 1000)

pwmA.start(0)
pwmB.start(0)

# =====================================
# GLOBAL VARIABLES
# =====================================

direction = "STOP"
current_speed = 0

detected_signs = []
frame_global = None

# =====================================
# YOLO MODEL
# =====================================

model = YOLO("best.pt")

# =====================================
# CAMERA
# =====================================

picam2 = Picamera2()

config = picam2.create_preview_configuration(
    main={"size": (640, 480)}
)

picam2.configure(config)
picam2.start()

# =====================================
# MOTOR FUNCTIONS
# =====================================

def apply_motor(direction, speed):

    if direction == "FORWARD":

        GPIO.output(IN1, 1)
        GPIO.output(IN2, 0)

        GPIO.output(IN3, 1)
        GPIO.output(IN4, 0)

    elif direction == "BACKWARD":

        GPIO.output(IN1, 0)
        GPIO.output(IN2, 1)

        GPIO.output(IN3, 0)
        GPIO.output(IN4, 1)

    elif direction == "LEFT":

        GPIO.output(IN1, 0)
        GPIO.output(IN2, 1)

        GPIO.output(IN3, 1)
        GPIO.output(IN4, 0)

    elif direction == "RIGHT":

        GPIO.output(IN1, 1)
        GPIO.output(IN2, 0)

        GPIO.output(IN3, 0)
        GPIO.output(IN4, 1)

    elif direction == "STOP":

        speed = 0

    pwmA.ChangeDutyCycle(speed)
    pwmB.ChangeDutyCycle(speed)

# =====================================
# CAMERA + YOLO THREAD
# =====================================

def camera_loop():

    global frame_global
    global detected_signs
    global current_speed

    while True:

        frame = picam2.capture_array()

        frame = cv2.cvtColor(
            frame,
            cv2.COLOR_RGB2BGR
        )

        results = model(
            frame,
            imgsz=320,
            conf=0.25,
            verbose=False
        )

        boxes = results[0].boxes

        labels = []
        detected_signs = []

        if len(boxes) > 0:

            for box in boxes:

                label = model.names[
                    int(box.cls[0])
                ]

                label = label.lower().strip()

                labels.append(label)
                detected_signs.append(label)

            print(
                "Detected Signs:",
                ", ".join(labels)
            )

            # =====================
            # SIGN LOGIC
            # =====================

            if "stop" in labels \
            or "noentry" in labels \
            or "no_entry_for_vehicular_traffic" in labels \
            or "no entry" in labels:

                current_speed = 0

            elif "speed30" in labels \
            or "speed_limit_30" in labels \
            or "speed_limit_15" in labels \
            or "speed_limit_5" in labels \
            or "30" in labels:

                current_speed = 40

            elif "speed60" in labels \
            or "speed 60" in labels \
            or "speed_limit_60" in labels \
            or "60" in labels:
                current_speed = 80

            elif "speed80" in labels \
            or "speed 80" in labels \
            or "80" in labels:

                current_speed = 100

            apply_motor(
                direction,
                current_speed
            )

        else:

            detected_signs = []

        annotated = results[0].plot()

        sign_text = "Signs: "

        if len(detected_signs) > 0:
            sign_text += ", ".join(detected_signs)
        else:
            sign_text += "None"

        cv2.putText(
            annotated,
            sign_text,
            (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.7,
            (0, 255, 0),
            2
        )

        cv2.putText(
            annotated,
            f"Speed: {current_speed}",
            (10, 60),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.7,
            (255, 0, 0),
            2
        )

        cv2.putText(
            annotated,
            f"Direction: {direction}",
            (10, 90),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.7,
            (0, 0, 255),
            2
        )

        frame_global = annotated

        cv2.imshow(
            "Traffic Sign Detection",
            annotated
        )

        cv2.waitKey(1)

# =====================================
# VIDEO STREAM
# =====================================

def generate_frames():

    global frame_global

    while True:

        if frame_global is None:
            continue

        ret, buffer = cv2.imencode(
            '.jpg',
            frame_global
        )

        frame = buffer.tobytes()

        yield (
            b'--frame\r\n'
            b'Content-Type: image/jpeg\r\n\r\n'
            + frame +
            b'\r\n'
        )

@app.route('/video_feed')
def video_feed():

    return Response(
        generate_frames(),
        mimetype='multipart/x-mixed-replace; boundary=frame'
    )

# =====================================
# CONTROL ROUTES
# =====================================

@app.route('/control/F')
def forward():

    global direction
    global current_speed

    direction = "FORWARD"
    current_speed = 100

    apply_motor(direction, current_speed)

    return jsonify({
        "direction": direction,
        "speed": current_speed,
        "detected_signs": detected_signs
    })

@app.route('/control/B')
def backward():

    global direction
    global current_speed

    direction = "BACKWARD"
    current_speed = 100

    apply_motor(direction, current_speed)

    return jsonify({
        "direction": direction,
        "speed": current_speed,
        "detected_signs": detected_signs
    })

@app.route('/control/L')
def left():

    global direction
    global current_speed

    direction = "LEFT"
    current_speed = 100

    apply_motor(direction, current_speed)

    return jsonify({
        "direction": direction,
        "speed": current_speed,
        "detected_signs": detected_signs
    })

@app.route('/control/R')
def right():

    global direction
    global current_speed

    direction = "RIGHT"
    current_speed = 100

    apply_motor(direction, current_speed)

    return jsonify({
        "direction": direction,
        "speed": current_speed,
        "detected_signs": detected_signs
    })

@app.route('/control/STOP')
def stop():

    global direction
    global current_speed

    direction = "STOP"
    current_speed = 0

    apply_motor(direction, current_speed)

    return jsonify({
        "direction": direction,
        "speed": current_speed,
        "detected_signs": detected_signs
    })

# =====================================
# STATUS API
# =====================================

@app.route('/status')
def status():

    return jsonify({

        "direction": direction,
        "speed": current_speed,
        "detected_signs": detected_signs

    })

# =====================================
# TRAFFIC SIGN API
# =====================================

@app.route('/traffic_signs')
def traffic_signs():

    return jsonify({

        "direction": direction,
        "speed": current_speed,
        "count": len(detected_signs),
        "detected_signs": detected_signs

    })

# =====================================
# HOME
# =====================================

@app.route('/')
def home():

    return jsonify({

        "video_feed":
        "/video_feed",

        "status":
        "/status",

        "traffic_signs":
        "/traffic_signs",

        "forward":
        "/control/F",

        "backward":
        "/control/B",

        "left":
        "/control/L",

        "right":
        "/control/R",

        "stop":
        "/control/STOP"

    })

# =====================================
# START THREAD
# =====================================

threading.Thread(
    target=camera_loop,
    daemon=True
).start()

# =====================================
# START FLASK
# =====================================

app.run(
    host="0.0.0.0",
    port=5000,
    threaded=True
)
