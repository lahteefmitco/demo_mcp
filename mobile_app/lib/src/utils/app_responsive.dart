import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Layout helpers for phone vs tablet/desktop. Requires [Sizer] above [MaterialApp].
abstract final class AppResponsive {
  /// Material guideline: ~600dp shortest side for “tablet” layouts.
  static const double tabletBreakpointShortestSide = 600;

  static double shortestSideOf(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide;

  static bool isCompactWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpointShortestSide;

  /// Uses [Sizer]’s [Device.screenType] (wrap [MaterialApp] with [Sizer]).
  static bool useWideShellLayout(BuildContext context) {
    return Device.screenType != ScreenType.mobile;
  }

  /// Max readable width for forms and primary content on large tablets.
  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return math.min(920, w);
  }

  /// Page padding using [Sizer] width/height percentages (requires [Sizer] above the tree).
  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h);
  }
}

/// Centers content and caps width on tablets so lines do not span edge-to-edge.
class ResponsiveContentWidth extends StatelessWidget {
  const ResponsiveContentWidth({
    required this.child,
    this.maxWidth,
    super.key,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cap = maxWidth ?? AppResponsive.contentMaxWidth(context);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: math.min(cap, constraints.maxWidth),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
