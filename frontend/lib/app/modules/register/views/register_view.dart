import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/google_sign_in_button.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF2E66E7),
        colorScheme: const ColorScheme.light(primary: Color(0xFF2E66E7)),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.9, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [

                    /// 🔷 LOGO
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7FB),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/images/logo.jpg",
                        width: 70,
                        height: 70,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 🔵 TITLE
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Mulai perjalananmu bersama MindTrack",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 👤 NAME
                    _inputField(
                      label: "Full Name",
                      hint: "Your name",
                      onChanged: (val) => controller.name.value = val,
                    ),

                    const SizedBox(height: 16),

                    /// 📧 EMAIL
                    _inputField(
                      label: "Email",
                      hint: "name@example.com",
                      onChanged: (val) => controller.email.value = val,
                    ),

                    const SizedBox(height: 16),

                    /// 🔒 PASSWORD
                    _inputField(
                      label: "Password",
                      hint: "********",
                      obscure: true,
                      onChanged: (val) => controller.password.value = val,
                    ),

                    const SizedBox(height: 16),

                    /// 🔒 CONFIRM PASSWORD
                    _inputField(
                      label: "Confirm Password",
                      hint: "********",
                      obscure: true,
                      onChanged: (val) => controller.confirmPassword.value = val,
                    ),

                    const SizedBox(height: 30),

                    /// 🔘 REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.register();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A66DB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ─── OR CONTINUE ───
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "or continue with",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// 🔘 GOOGLE BUTTON
                    CustomGoogleSignInButton(
                      onTap: () {
                        controller.loginWithGoogle();
                      },
                    ),

                    const SizedBox(height: 30),

                    /// 🔗 BACK TO LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.back(); // balik ke login
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xFF3A66DB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// 🔧 reusable input
  Widget _inputField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    bool obscure = false,
  }) {
    return TextField(
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}