part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const BERANDA = _Paths.BERANDA;
  static const CHATBOT = _Paths.CHATBOT;
  static const RIWAYAT = _Paths.RIWAYAT;
  static const PENGATURAN = _Paths.PENGATURAN;
  static const KONSULTASI = _Paths.KONSULTASI;
  static const SELESAI = _Paths.SELESAI;
  static const HASIL = _Paths.HASIL;
  static const REGISTER = _Paths.REGISTER;
  static const VERIFICATION = _Paths.VERIFICATION;
  static const RELAXATION_MUSIC = _Paths.RELAXATION_MUSIC;
  static const JOURNAL = _Paths.JOURNAL;
  static const BREATHING = _Paths.BREATHING;
  static const AFFIRMATION = _Paths.AFFIRMATION;
  static const FACE_REGISTER = _Paths.FACE_REGISTER;
  static const FACE_LOGIN = _Paths.FACE_LOGIN;
  static const MAIN = _Paths.MAIN;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const BERANDA = '/beranda';
  static const MAIN = '/main';
  static const CHATBOT = '/chatbot';
  static const RIWAYAT = '/riwayat';
  static const PENGATURAN = '/pengaturan';
  static const KONSULTASI = '/konsultasi';
  static const SELESAI = '/selesai';
  static const HASIL = '/hasil';
  static const REGISTER = '/register';
  static const VERIFICATION = '/verification';
  static const RELAXATION_MUSIC = '/relaxation-music';
  static const JOURNAL = '/journal';
  static const BREATHING = '/breathing';
  static const AFFIRMATION = '/affirmation';
  static const FACE_REGISTER = '/face-register';
  static const FACE_LOGIN = '/face-login';
}
