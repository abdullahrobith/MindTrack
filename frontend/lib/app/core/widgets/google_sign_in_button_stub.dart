import 'package:flutter/material.dart';

Widget buildGoogleSignInButton({required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/google_logo.png", width: 24, height: 24),
          const SizedBox(width: 8),
          const Text("Google"),
        ],
      ),
    ),
  );
}
