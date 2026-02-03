import 'package:get/get.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToHome() => changeTab(0);
  void goToNewPatient() => changeTab(1);
  void goToHistory() => changeTab(2);
  void goToInventory() => changeTab(3);
  void goToSettings() => changeTab(4);
}
