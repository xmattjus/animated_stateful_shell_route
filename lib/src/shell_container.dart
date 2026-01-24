import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'extensions.dart';
import 'route_transitions.dart';

/// Container that wires shell route animations to branch widgets.
///
/// Keeps navigation shell state synchronized while applying transitions.
class AnimatedShellRouteContainer extends StatefulWidget {
  /// Navigation shell that controls the active branch.
  final StatefulNavigationShell navigationShell;

  /// Duration for branch transition animations.
  final Duration transitionDuration;

  /// Curve applied to branch transition animations.
  final Curve transitionCurve;

  /// Builder that customizes how branches animate during switches.
  final CustomRouteTransitionBuilder transitionBuilder;

  /// Whether branches render inside an indexed stack.
  final bool isIndexedStack;

  /// Widgets for each branch of the shell route.
  final List<Widget> children;

  /// Creates an animated container for shell routes.
  const AnimatedShellRouteContainer({
    super.key,
    required this.navigationShell,
    required this.transitionDuration,
    required this.transitionCurve,
    required this.transitionBuilder,
    this.isIndexedStack = false,
    required this.children,
  });

  @override
  /// Creates the mutable state for this animated container.
  State<AnimatedShellRouteContainer> createState() =>
      _AnimatedShellRouteContainerState();
}

class _AnimatedShellRouteContainerState
    extends State<AnimatedShellRouteContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;
  int _nextIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navigationShell.currentIndex;
    _nextIndex = _currentIndex;

    _animationController = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    )..value = 1.0;

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.transitionCurve,
    );
  }

  @override
  void didUpdateWidget(AnimatedShellRouteContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _onBranchChanged(widget.navigationShell.currentIndex);
    }
  }

  // Handles branch changes with animation and guards rapid switching.
  void _onBranchChanged(int newIndex) {
    if (_currentIndex == newIndex) return;

    // Store the new index as the target destination
    _nextIndex = newIndex;

    // Handle interruption of animations when rapidly switching tabs
    if (_animationController.isAnimating) {
      _animationController.stop();

      // If animation was more than halfway through, consider the previous animation
      // as effectively completed for better visual feedback during rapid switching
      if (_animationController.value > 0.5) {
        _currentIndex = _nextIndex;
        _nextIndex = newIndex;
      }
    }

    _animationController.reset();

    // Begin the animation to the new tab
    _animationController.forward().then((_) {
      // Only update state if this completion callback is for the most recent animation
      // and if the widget is still mounted - prevents stale animation callbacks
      if (mounted && _nextIndex == newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safety mechanism: ensure UI state remains synchronized with the navigation shell
    // This prevents the desynchronization when rapidly switching tabs
    if (!_animationController.isAnimating &&
        widget.navigationShell.currentIndex != _currentIndex) {
      // Force synchronization if we detect a mismatch between UI and logical state
      _currentIndex = widget.navigationShell.currentIndex;
      _nextIndex = _currentIndex;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final children = UnmodifiableListView<Widget>(
          widget.children.mapIndexed<Widget>((index, child) {
            final bool isVisible =
                index == _currentIndex || index == _nextIndex;

            Widget animatedChild = _createAnimatedChild(
              child,
              index,
              isVisible,
            );

            // Apply transition animation
            Widget transitionedChild = widget.transitionBuilder(
              index: index,
              child: animatedChild,
              currentIndex: _currentIndex,
              nextIndex: _nextIndex,
              animation: _animation,
            );

            // Wrap with Positioned.fill to make it a direct Stack child
            return Positioned.fill(child: transitionedChild);
          }),
        );

        final stack = () {
          if (widget.isIndexedStack) {
            return IndexedStack(index: _nextIndex, children: children);
          } else {
            return Stack(children: children);
          }
        }();

        return SizedBox(child: stack);
      },
    );
  }

  Widget _createAnimatedChild(Widget child, int index, bool isVisible) {
    // Determine if this child should be interactive based on animation state
    bool shouldIgnorePointer;

    if (_animationController.isAnimating) {
      // During animation, only the target tab should be interactive
      shouldIgnorePointer = index != _nextIndex;
    } else {
      // When no animation is happening, only the current tab should be interactive
      shouldIgnorePointer = index != _currentIndex;
    }

    return TickerMode(
      enabled: isVisible,
      child: IgnorePointer(ignoring: shouldIgnorePointer, child: child),
    );
  }
}
