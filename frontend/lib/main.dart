import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'app/routes/app_pages.dart';
import 'app/controllers/navigation_controller.dart';
import 'app/core/controllers/global_auth_controller.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Get.put(
    NavigationController(),
    permanent: true,
  );

  final auth = Get.put(
    GlobalAuthController(),
    permanent: true,
  );

  await auth.getCurrentUser();

  runApp(
    MyApp(auth),
  );
}

class MyApp extends StatelessWidget {

  final GlobalAuthController auth;

  const MyApp(
    this.auth, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Obx(
      () => GetMaterialApp(

        title: "MindTrack",

        debugShowCheckedModeBanner: false,

        initialRoute: AppPages.INITIAL,

        getPages: AppPages.routes,

        themeMode: auth.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,

        theme: ThemeData.light().copyWith(
          primaryColor: const Color(0xFF2E66E7),
          scaffoldBackgroundColor: const Color(0xFFF6F8FC),
          canvasColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2E66E7),
            secondary: Color(0xFF4B8DFF),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E66E7),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),

        darkTheme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFF2E66E7),
          scaffoldBackgroundColor: const Color(0xFF121212),
          canvasColor: const Color(0xFF1E1E1E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2E66E7),
            secondary: Color(0xFF4B8DFF),
            surface: Color(0xFF1E1E1E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            foregroundColor: Color(0xFF2E66E7),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF2E66E7)),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            selectedItemColor: Color(0xFF2E66E7),
            unselectedItemColor: Colors.grey,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.grey),
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: Color(0xFF2E66E7), width: 2),
            ),
          ),
        ),
      ),
    );
  }
}