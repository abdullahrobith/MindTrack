part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const BERANDA = _Paths.BERANDA;
  static const CHATBOT = _Paths.CHATBOT;
  static const RIWAYAT = _Paths.RIWAYAT;
  static const PROFIL = _Paths.PROFIL;
  static const KONSULTASI = _Paths.KONSULTASI;
  static const SELESAI = _Paths.SELESAI;
  static const HASIL = _Paths.HASIL;
  static const REGISTER = _Paths.REGISTER;
  static const VERIFICATION = _Paths.VERIFICATION;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const BERANDA = '/beranda';
  static const CHATBOT = '/chatbot';
  static const RIWAYAT = '/riwayat';
  static const PROFIL = '/profil';
  static const KONSULTASI = '/konsultasi';
  static const SELESAI = '/selesai';
  static const HASIL = '/hasil';
  static const REGISTER = '/register';
  static const VERIFICATION = '/verification';
}
