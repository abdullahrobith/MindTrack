import cv2
import os

# Buat folder database jika belum ada
if not os.path.exists("database"):
    os.makedirs("database")

# Input nama user
name = input("Masukkan nama user: ")

# Buka kamera
cam = cv2.VideoCapture(0, cv2.CAP_DSHOW)

print("Tekan SPACE untuk mengambil foto")
print("Tekan ESC untuk keluar")

while True:

    ret, frame = cam.read()

    if not ret:
        print("Kamera gagal dibuka")
        break

    cv2.imshow("Register Wajah", frame)

    key = cv2.waitKey(1)

    # SPACE untuk capture
    if key == 32:

        file_path = f"database/{name}.jpg"

        cv2.imwrite(file_path, frame)

        print(f"Wajah berhasil disimpan: {file_path}")

        break

    # ESC keluar
    elif key == 27:
        break

cam.release()
cv2.destroyAllWindows()