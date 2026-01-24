import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_transitions.dart';
import 'shell_container.dart';

/// Stateful shell route that injects animations between branch switches.
/// Keeps navigation changes feeling intentional across nested navigators.
class AnimatedStatefulShellRoute extends StatefulShellRoute {
  /// Duration used for branch transition animations.
  final Duration transitionDuration;

  /// Curve applied to branch transition animations.
  final Curve transitionCurve;

  /// Builder that defines how branch content animates during switches.
  final CustomRouteTransitionBuilder transitionBuilder;

  /// Creates an animated shell route using a stack for transitions.
  /// Keeps branch state intact while animating between destinations.
  AnimatedStatefulShellRoute({
    required super.branches,
    super.redirect,
    required StatefulShellRouteBuilder super.builder,
    super.pageBuilder,
    super.notifyRootObserver,
    super.parentNavigatorKey,
    super.restorationScopeId,
    GlobalKey<StatefulNavigationShellState>? navigatorKey,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Easing.standard,
    required this.transitionBuilder,
  }) : super(
         navigatorContainerBuilder: _buildAnimatedContainer,
         key: navigatorKey,
       );

  static Widget _buildAnimatedContainer(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  ) {
    final AnimatedStatefulShellRoute route =
        navigationShell.route as AnimatedStatefulShellRoute;

    return AnimatedShellRouteContainer(
      navigationShell: navigationShell,
      transitionDuration: route.transitionDuration,
      transitionCurve: route.transitionCurve,
      transitionBuilder: route.transitionBuilder,
      children: children,
    );
  }
}
