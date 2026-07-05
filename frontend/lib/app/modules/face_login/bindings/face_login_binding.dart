import 'package:get/get.dart';
import '../controllers/face_login_controller.dart';

class FaceLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaceLoginController>(() => FaceLoginController());
  }
}
