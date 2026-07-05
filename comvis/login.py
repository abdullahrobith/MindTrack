from deepface import DeepFace
import cv2
import os
import time

# ============================================
# CONFIG
# ============================================

DATABASE_PATH = "database"

MODEL_NAME = "Facenet512"
DETECTOR = "opencv"

THRESHOLD = 0.30
CHECK_INTERVAL = 2

# ============================================
# LOAD DATABASE
# ============================================

known_faces = []

for file in os.listdir(DATABASE_PATH):

    if file.endswith(".jpg") or file.endswith(".png"):

        known_faces.append(file)

if len(known_faces) == 0:

    print("Database wajah kosong!")
    exit()

print("Database loaded:", known_faces)

# ============================================
# LOAD FACE DETECTOR
# ============================================

face_detector = cv2.CascadeClassifier(
    cv2.data.haarcascades +
    "haarcascade_frontalface_default.xml"
)

# ============================================
# OPEN CAMERA
# ============================================

cam = cv2.VideoCapture(0, cv2.CAP_DSHOW)

if not cam.isOpened():

    print("Kamera gagal dibuka")
    exit()

print("Tekan ESC untuk keluar")

# ============================================
# VARIABLE
# ============================================

last_check = 0

text = "Mendeteksi..."
color = (255, 255, 0)

# ============================================
# MAIN LOOP
# ============================================

while True:

    ret, frame = cam.read()

    if not ret:

        print("Gagal membaca kamera")
        break

    # Resize supaya ringan
    frame = cv2.resize(frame, (640, 480))

    # Convert grayscale untuk detector
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Detect wajah
    faces = face_detector.detectMultiScale(
        gray,
        scaleFactor=1.1,
        minNeighbors=5,
        minSize=(100, 100)
    )

    current_time = time.time()

    # ========================================
    # JIKA ADA WAJAH
    # ========================================

    if len(faces) > 0:

        # Ambil wajah terbesar
        largest_face = max(faces, key=lambda rect: rect[2] * rect[3])

        x, y, w, h = largest_face

        # Bounding box
        cv2.rectangle(
            frame,
            (x, y),
            (x + w, y + h),
            color,
            2
        )

        # Crop wajah
        face_crop = frame[y:y+h, x:x+w]

        # Verifikasi tiap interval
        if current_time - last_check > CHECK_INTERVAL:

            temp_face = "temp_face.jpg"

            cv2.imwrite(temp_face, face_crop)

            found = False

            try:

                best_match = None
                best_distance = 999

                for face_file in known_faces:

                    db_path = os.path.join(
                        DATABASE_PATH,
                        face_file
                    )

                    result = DeepFace.verify(
                        img1_path=temp_face,
                        img2_path=db_path,
                        model_name=MODEL_NAME,
                        detector_backend=DETECTOR,
                        enforce_detection=True
                    )

                    distance = result["distance"]

                    print(
                        f"{face_file} -> Distance: {distance}"
                    )

                    # Cari distance terbaik
                    if distance < best_distance:

                        best_distance = distance
                        best_match = face_file

                # Jika cocok
                if best_distance < THRESHOLD:

                    username = os.path.splitext(
                        best_match
                    )[0]

                    text = (
                        f"Login Berhasil: "
                        f"{username}"
                    )

                    color = (0, 255, 0)

                    found = True

                else:

                    text = "Login Gagal"
                    color = (0, 0, 255)

            except Exception as e:

                print("Error:", e)

                text = "Wajah Tidak Terdeteksi"
                color = (0, 255, 255)

            # Hapus temp
            if os.path.exists(temp_face):

                os.remove(temp_face)

            last_check = current_time

    else:

        text = "Tidak Ada Wajah"
        color = (0, 255, 255)

    # ========================================
    # UI TEXT
    # ========================================

    cv2.putText(
        frame,
        text,
        (20, 40),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.9,
        color,
        2
    )

    cv2.putText(
        frame,
        "ESC = Keluar",
        (20, 80),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        (255, 255, 255),
        2
    )

    # ========================================
    # SHOW CAMERA
    # ========================================

    cv2.imshow(
        "Face Recognition Login",
        frame
    )

    key = cv2.waitKey(1)

    if key == 27:

        break

# ============================================
# CLOSE
# ============================================

cam.release()
cv2.destroyAllWindows()