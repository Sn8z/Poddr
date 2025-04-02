class Breakpoints {
  static const int mobileScreen = 600;
  static const int tabletScreen = 1000;
  static const int mediumScreen = 1400;
  static const int largeScreen = 2000;

  static bool isMobile(double width) {
    return width < mobileScreen;
  }

  static bool isTablet(double width) {
    return width >= mobileScreen && width < tabletScreen;
  }

  static bool isMedium(double width) {
    return width >= tabletScreen && width < mediumScreen;
  }

  static bool isLarge(double width) {
    return width >= mediumScreen && width < largeScreen;
  }

  static bool isExtraLarge(double width) {
    return width >= largeScreen;
  }

  static bool isDesktop(double width) {
    return width >= mediumScreen;
  }
}
