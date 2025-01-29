import 'package:flutter/foundation.dart';

final bool isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

final bool isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.linux;

final bool isMobileWeb = isMobile && kIsWeb;
final bool isDesktopWeb = isDesktop && kIsWeb;
const bool isWeb = kIsWeb;
