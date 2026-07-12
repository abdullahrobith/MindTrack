enum InstrumentType { phq, gad, stress }

class AssessmentQuestion {
  final String text;
  final InstrumentType type;
  final int indexInType; // index di dalam instrumennya sendiri (untuk cek suicide risk dll)

  const AssessmentQuestion({
    required this.text,
    required this.type,
    required this.indexInType,
  });
}

// Skala jawaban resmi PHQ-9 / GAD-7 / DASS-21 (0-3, BUKAN 0-4)
const answerOptions = [
  "Tidak Sama Sekali",
  "Beberapa Hari",
  "Lebih dari Separuh Hari",
  "Hampir Setiap Hari",
];

// PHQ-9 (9 soal, wording resmi versi Indonesia)
final List<AssessmentQuestion> phqQuestions = [
  const AssessmentQuestion(text: "Kurang berminat atau bergairah dalam melakukan sesuatu", type: InstrumentType.phq, indexInType: 0),
  const AssessmentQuestion(text: "Merasa murung, sedih, atau putus asa", type: InstrumentType.phq, indexInType: 1),
  const AssessmentQuestion(text: "Sulit tidur, mudah terbangun, atau tidur berlebihan", type: InstrumentType.phq, indexInType: 2),
  const AssessmentQuestion(text: "Merasa lelah atau kurang bertenaga", type: InstrumentType.phq, indexInType: 3),
  const AssessmentQuestion(text: "Nafsu makan berkurang atau berlebihan", type: InstrumentType.phq, indexInType: 4),
  const AssessmentQuestion(text: "Merasa buruk tentang diri sendiri, merasa gagal, atau mengecewakan diri sendiri/keluarga", type: InstrumentType.phq, indexInType: 5),
  const AssessmentQuestion(text: "Sulit berkonsentrasi pada suatu hal, misalnya membaca atau menonton TV", type: InstrumentType.phq, indexInType: 6),
  const AssessmentQuestion(text: "Bergerak/berbicara sangat lambat, atau sebaliknya gelisah sehingga sering bergerak lebih banyak dari biasanya", type: InstrumentType.phq, indexInType: 7),
  const AssessmentQuestion(text: "Merasa lebih baik mati, atau berpikir untuk menyakiti diri sendiri", type: InstrumentType.phq, indexInType: 8),
];

// GAD-7 (7 soal)
final List<AssessmentQuestion> gadQuestions = [
  const AssessmentQuestion(text: "Merasa gugup, cemas, atau tegang", type: InstrumentType.gad, indexInType: 0),
  const AssessmentQuestion(text: "Tidak dapat menghentikan atau mengendalikan rasa khawatir", type: InstrumentType.gad, indexInType: 1),
  const AssessmentQuestion(text: "Terlalu khawatir tentang berbagai hal", type: InstrumentType.gad, indexInType: 2),
  const AssessmentQuestion(text: "Sulit untuk merasa rileks", type: InstrumentType.gad, indexInType: 3),
  const AssessmentQuestion(text: "Menjadi sangat gelisah sehingga sulit untuk duduk diam", type: InstrumentType.gad, indexInType: 4),
  const AssessmentQuestion(text: "Menjadi mudah kesal atau tersinggung", type: InstrumentType.gad, indexInType: 5),
  const AssessmentQuestion(text: "Merasa takut seolah-olah sesuatu yang buruk akan terjadi", type: InstrumentType.gad, indexInType: 6),
];

// DASS-21 subskala Stress (7 soal)
final List<AssessmentQuestion> stressQuestions = [
  const AssessmentQuestion(text: "Saya merasa sulit untuk beristirahat/tenang", type: InstrumentType.stress, indexInType: 0),
  const AssessmentQuestion(text: "Saya cenderung bereaksi berlebihan terhadap suatu keadaan", type: InstrumentType.stress, indexInType: 1),
  const AssessmentQuestion(text: "Saya merasa banyak menghabiskan energi karena cemas", type: InstrumentType.stress, indexInType: 2),
  const AssessmentQuestion(text: "Saya merasa gelisah", type: InstrumentType.stress, indexInType: 3),
  const AssessmentQuestion(text: "Saya merasa sulit untuk bersabar dalam menghadapi gangguan terhadap hal yang sedang saya lakukan", type: InstrumentType.stress, indexInType: 4),
  const AssessmentQuestion(text: "Saya merasa mudah tersinggung/marah", type: InstrumentType.stress, indexInType: 5),
  const AssessmentQuestion(text: "Saya merasa sulit untuk tenang setelah sesuatu yang mengganggu saya", type: InstrumentType.stress, indexInType: 6),
];

// Gabungan flat list untuk alur one-question-per-screen (9+7+7 = 23)
final List<AssessmentQuestion> allClinicalQuestions = [
  ...phqQuestions,
  ...gadQuestions,
  ...stressQuestions,
];

// Tambahkan di bagian bawah file, setelah allClinicalQuestions

class LifestyleQuestion {
  final String title;
  final String text;      // kalimat pertanyaan resmi
  final List<String> options;
  const LifestyleQuestion({
    required this.title,
    required this.text,
    required this.options,
  });
}

final List<LifestyleQuestion> lifestyleQuestions = [
  const LifestyleQuestion(
    title: 'Durasi Tidur',
    text: 'Kira-kira berapa jam Anda tidur semalam?',
    options: ['0 jam', '3 jam', '6 jam', '8 jam', '10 jam+'],
  ),
  const LifestyleQuestion(
    title: 'Kualitas Tidur',
    text: 'Bagaimana kualitas tidur Anda semalam?',
    options: ['Sangat Buruk', 'Buruk', 'Cukup', 'Baik', 'Sangat Baik'],
  ),
  const LifestyleQuestion(
    title: 'Aktivitas Fisik',
    text: 'Seberapa aktif Anda bergerak atau berolahraga hari ini?',
    options: ['Tidak Ada', 'Ringan', 'Sedang', 'Aktif', 'Sangat Aktif'],
  ),
  const LifestyleQuestion(
    title: 'Interaksi Sosial',
    text: 'Seberapa banyak Anda berinteraksi dengan orang lain hari ini?',
    options: ['Tidak Ada', 'Sedikit', 'Cukup', 'Banyak', 'Sangat Banyak'],
  ),
  const LifestyleQuestion(
    title: 'Produktivitas',
    text: 'Bagaimana tingkat produktivitas Anda hari ini?',
    options: ['Sangat Rendah', 'Rendah', 'Sedang', 'Tinggi', 'Sangat Tinggi'],
  ),
];