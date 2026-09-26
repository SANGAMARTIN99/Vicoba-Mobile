import 'package:flutter/material.dart';

/// VicobaPlus Layout and Dimension Constants
class AppDimensions {
  AppDimensions._();

  // Spacing Scale (4/8px rhythm)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double heroic = 48.0;

  // Radii matching Web tokens.css
  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 9999.0;

  static final BorderRadius roundedSm = BorderRadius.circular(radiusSm);
  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedLg = BorderRadius.circular(radiusLg);
  static final BorderRadius roundedXl = BorderRadius.circular(radiusXl);
  static final BorderRadius roundedFull = BorderRadius.circular(radiusFull);

  // Minimum Touch Target (WCAG accessibility standard)
  static const double minTouchTarget = 44.0;

  // Standard Elevations
  static const double elevationLow = 1.0;
  static const double elevationMed = 3.0;
  static const double elevationHigh = 8.0;
}
