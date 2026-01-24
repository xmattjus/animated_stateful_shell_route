import 'package:flutter/material.dart';

/// Animation styles available for shell route branch transitions.
enum AnimationType { fade, slideHorizontal, slideVertical, scale }

/// Signature for builders that animate shell route branch switches.
typedef CustomRouteTransitionBuilder =
    Widget Function({
      required int index,
      required Widget child,
      required int currentIndex,
      required int nextIndex,
      required Animation<double> animation,
    });

/// Built-in transition builders for animated shell routes.
///
/// Provides ready-to-use motion patterns for consistent branch changes.
class ShellRouteTransitions {
  /// Fades out the current branch while fading in the next branch.
  static CustomRouteTransitionBuilder get fade => _fadeTransition;

  /// Slides branches horizontally while adjusting opacity.
  static CustomRouteTransitionBuilder get slideHorizontal =>
      _slideHorizontalTransition;

  /// Slides branches vertically while adjusting opacity.
  static CustomRouteTransitionBuilder get slideVertical =>
      _slideVerticalTransition;

  /// Scales branches to emphasize the incoming destination.
  static CustomRouteTransitionBuilder get scale => _scaleTransition;

  static Widget _fadeTransition({
    required int index,
    required Widget child,
    required int currentIndex,
    required int nextIndex,
    required Animation<double> animation,
  }) {
    double opacity = 0.0;

    if (index == currentIndex && index != nextIndex) {
      opacity = 1.0 - animation.value;
    } else if (index == nextIndex) {
      opacity = animation.value;
    } else if (index == currentIndex && index == nextIndex) {
      opacity = 1.0;
    }

    return Opacity(opacity: opacity, child: child);
  }

  static Widget _slideHorizontalTransition({
    required int index,
    required Widget child,
    required int currentIndex,
    required int nextIndex,
    required Animation<double> animation,
  }) {
    double offsetX = 0.0;
    double opacity = 0.0;
    bool isMovingForward = nextIndex > currentIndex;

    if (index == currentIndex && index != nextIndex) {
      offsetX = isMovingForward ? -animation.value : animation.value;
      opacity = 1.0 - animation.value;
    } else if (index == nextIndex) {
      offsetX = isMovingForward
          ? 1.0 - animation.value
          : -1.0 + animation.value;
      opacity = animation.value;
    } else if (index == currentIndex && index == nextIndex) {
      offsetX = 0.0;
      opacity = 1.0;
    }

    return FractionalTranslation(
      translation: Offset(offsetX, 0.0),
      child: Opacity(opacity: opacity, child: child),
    );
  }

  static Widget _slideVerticalTransition({
    required int index,
    required Widget child,
    required int currentIndex,
    required int nextIndex,
    required Animation<double> animation,
  }) {
    double offsetY = 0.0;
    double opacity = 0.0;

    if (index == currentIndex && index != nextIndex) {
      offsetY = -animation.value;
      opacity = 1.0 - animation.value;
    } else if (index == nextIndex) {
      offsetY = 1.0 - animation.value;
      opacity = animation.value;
    } else if (index == currentIndex && index == nextIndex) {
      offsetY = 0.0;
      opacity = 1.0;
    }

    return FractionalTranslation(
      translation: Offset(0.0, offsetY),
      child: Opacity(opacity: opacity, child: child),
    );
  }

  static Widget _scaleTransition({
    required int index,
    required Widget child,
    required int currentIndex,
    required int nextIndex,
    required Animation<double> animation,
  }) {
    double scale = 1.0;
    double opacity = 0.0;

    if (index == currentIndex && index != nextIndex) {
      scale = 1.0 - (0.3 * animation.value);
      opacity = 1.0 - animation.value;
    } else if (index == nextIndex) {
      scale = 0.7 + (0.3 * animation.value);
      opacity = animation.value;
    } else if (index == currentIndex && index == nextIndex) {
      scale = 1.0;
      opacity = 1.0;
    }

    return Transform.scale(
      scale: scale,
      child: Opacity(opacity: opacity, child: child),
    );
  }

  /// Wraps a custom transition builder for clarity and type safety.
  /// Use this when providing your own animation without the presets.
  static CustomRouteTransitionBuilder createCustomTransition(
    CustomRouteTransitionBuilder builder,
  ) {
    return builder;
  }
}
