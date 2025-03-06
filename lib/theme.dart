import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    colorSchemeSeed: Colors.amber,
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: [lightCustomColors],
  );

  static final dark = ThemeData(
    colorSchemeSeed: Color(0x415f91),
    useMaterial3: true,
    brightness: Brightness.dark,
    extensions: [darkCustomColors],
  );
}

// the code below was generated using Material Theme Builder,
// see https://m3.material.io/theme-builder

const success = Color(0xFF4E7D4D);

CustomColors lightCustomColors = const CustomColors(
  sourceSuccess: Color(0xFF4E7D4D),
  success: Color(0xFF246C2C),
  onSuccess: Color(0xFFFFFFFF),
  successContainer: Color(0xFFA9F5A5),
  onSuccessContainer: Color(0xFF002105),
);

CustomColors darkCustomColors = const CustomColors(
  sourceSuccess: Color(0xFF4E7D4D),
  success: Color(0xFF8DD88B),
  onSuccess: Color(0xFF00390D),
  successContainer: Color(0xFF015317),
  onSuccessContainer: Color(0xFFA9F5A5),
);

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.sourceSuccess,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  final Color? sourceSuccess;
  final Color? success;
  final Color? onSuccess;
  final Color? successContainer;
  final Color? onSuccessContainer;

  @override
  CustomColors copyWith({
    Color? sourceSuccess,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return CustomColors(
      sourceSuccess: sourceSuccess ?? this.sourceSuccess,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      sourceSuccess: Color.lerp(sourceSuccess, other.sourceSuccess, t),
      success: Color.lerp(success, other.success, t),
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t),
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t),
    );
  }
}

// Standardized gap sizes
const SMALL_GAP = 8.0;
const MEDIUM_GAP = 16.0;
const LARGE_GAP = 24.0;
const XLARGE_GAP = 32.0;

// Standardized border radiuses
const SMALL_BORDER_RADIUS = 8.0;
const MEDIUM_BORDER_RADIUS = 16.0;
const LARGE_BORDER_RADIUS = 32.0;

// Standardized padding
const double SMALL_PADDING = 8.0;
const double MEDIUM_PADDING = 16.0;
const double LARGE_PADDING = 24.0;
const double XLARGE_PADDING = 32.0;
