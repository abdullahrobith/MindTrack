/// Konversi jawaban natural (Bahasa Indonesia bebas) menjadi skor resmi,
/// TANPA bergantung pada AI. AI hanya dipakai sebagai fallback saat
/// jawabannya benar-benar ambigu.
class RuleBasedScorer {
  // ── Skala klinis 0-3 (PHQ-9 / GAD-7 / DASS-21) ──────────────────
  static int? scoreClinical(String text) {
  final t = text.toLowerCase();

  const level3 = [
    'setiap hari', 'tiap hari', 'hampir setiap hari', 'selalu',
    'terus menerus', 'terus-terusan', 'tiap saat', 'sepanjang waktu',
    'nyaris tiap hari',
  ];
  const level0 = [
    'tidak pernah', 'tdk pernah', 'gak pernah', 'ga pernah',
    'nggak pernah', 'enggak pernah', 'tidak sama sekali',
    'engga sama sekali', 'nggak sama sekali',
  ];
  const level1 = [
    'kadang', 'kadang-kadang', 'sesekali', 'jarang',
    'beberapa hari', 'sekali-sekali', 'ga terlalu sering',
    'gak terlalu sering', 'tidak terlalu sering', 'dikit',
  ];
  const level2 = [
    'sering', 'lumayan sering', 'cukup sering',
    'lebih dari separuh', 'lebih dari setengah', 'banyak hari',
  ];

  if (level3.any(t.contains)) return 3;
  if (level0.any(t.contains)) return 0;
  if (level1.any(t.contains)) return 1;   // ✅ cek frasa negasi dulu
  if (level2.any(t.contains)) return 2;
  return null;
}

  // ── Skala lifestyle 0-4 (kualitas tidur, aktivitas, sosial, dll) ─
  static int? scoreFivePoint(String text) {
    final t = text.toLowerCase();

    const level4 = [
      'sangat baik', 'sangat aktif', 'sangat banyak', 'sangat tinggi',
      'luar biasa', 'maksimal', 'penuh banget',
    ];
    const level0 = [
      'sangat buruk', 'tidak ada', 'gak ada', 'nggak ada',
      'sangat rendah', 'tidak sama sekali', 'nol',
    ];
    const level3 = ['baik', 'aktif', 'banyak', 'tinggi'];
    const level1 = ['buruk', 'ringan', 'sedikit', 'rendah', 'dikit'];
    const level2 = ['cukup', 'sedang', 'lumayan', 'biasa aja', 'standar'];

    if (level4.any(t.contains)) return 4;
    if (level0.any(t.contains)) return 0;
    if (level3.any(t.contains)) return 3;
    if (level1.any(t.contains)) return 1;
    if (level2.any(t.contains)) return 2;
    return null;
  }

  // ── Durasi tidur (angka jam) ─────────────────────────────────────
  static double? scoreSleepHours(String text) {
    final t = text.toLowerCase();
    final match = RegExp(r'(\d{1,2}([.,]\d)?)\s*jam').firstMatch(t) ??
        RegExp(r'\b(\d{1,2}([.,]\d)?)\b').firstMatch(t);
    if (match == null) return null;
    final raw = match.group(1)?.replaceAll(',', '.');
    final val = double.tryParse(raw ?? '');
    if (val == null) return null;
    return val.clamp(0.0, 12.0);
  }
}