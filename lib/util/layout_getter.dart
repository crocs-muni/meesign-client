import '../enums/screen_layout.dart';
import '../ui_constants.dart';

class LayoutGetter {
  static ScreenLayout getCurLayout(double width) {
    if (width > minLaptopLayoutWidth) {
      return ScreenLayout.desktop;
    } else if (width > minTabletLayoutWidth) {
      return ScreenLayout.tablet;
    } else {
      return ScreenLayout.mobile;
    }
  }
}
