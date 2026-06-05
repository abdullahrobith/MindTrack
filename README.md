```markdown
# MindTrack Project

Proyek MindTrack telah diperbarui dengan arsitektur baru yang memisahkan antara Backend (FastAPI) dan Frontend (Flutter).

## 📂 Struktur Proyek
MindTrack/
├── backend/    # FastAPI server
└── frontend/   # Flutter web application

```

## 🚀 Cara Menjalankan Proyek

Pastikan kamu sudah menginstal **Python** dan **Flutter SDK** di komputer masing-masing.

### 1. Backend (FastAPI)

Langkah-langkah untuk menjalankan server backend:

1. Masuk ke folder backend:
```bash
cd backend

```


2. Buat dan aktifkan virtual environment:
```bash
# Windows
python -m venv venv
venv\Scripts\activate

```


3. Install library yang dibutuhkan:
```bash
pip install -r requirements.txt

```


4. Jalankan server:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 5000

```
4. Open server:
```bash
http://127.0.0.1:5000

```



### 2. Frontend (Flutter)

Langkah-langkah untuk menjalankan aplikasi frontend:

1. Masuk ke folder frontend:
```bash
cd frontend

```


2. Install dependencies:
```bash
flutter pub get

```


3. Jalankan aplikasi di browser:
```bash
flutter run

```
