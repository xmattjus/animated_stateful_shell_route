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
    super.builder,
    super.pageBuilder,
    super.notifyRootObserver,
    super.parentNavigatorKey,
    super.restorationScopeId,
    super.key,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Easing.standard,
    required this.transitionBuilder,
  }) : assert(branches.isNotEmpty),
       assert(
         (pageBuilder != null) || (builder != null),
         'One of builder or pageBuilder must be provided',
       ),
       assert(
         _debugUniqueNavigatorKeys(branches).length == branches.length,
         'Navigator keys must be unique',
       ),
       assert(_debugValidateParentNavigatorKeys(branches)),
       assert(_debugValidateRestorationScopeIds(restorationScopeId, branches)),
       super(navigatorContainerBuilder: _buildAnimatedContainer);

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

  static Set<GlobalKey<NavigatorState>> _debugUniqueNavigatorKeys(
    List<StatefulShellBranch> branches,
  ) => Set<GlobalKey<NavigatorState>>.from(
    branches.map((StatefulShellBranch e) => e.navigatorKey),
  );

  static bool _debugValidateParentNavigatorKeys(
    List<StatefulShellBranch> branches,
  ) {
    for (final branch in branches) {
      for (final RouteBase route in branch.routes) {
        if (route is GoRoute) {
          assert(
            route.parentNavigatorKey == null ||
                route.parentNavigatorKey == branch.navigatorKey,
          );
        }
      }
    }
    return true;
  }

  static bool _debugValidateRestorationScopeIds(
    String? restorationScopeId,
    List<StatefulShellBranch> branches,
  ) {
    if (branches
        .map((StatefulShellBranch e) => e.restorationScopeId)
        .nonNulls
        .isNotEmpty) {
      assert(
        restorationScopeId != null,
        'A restorationScopeId must be set for '
        'the StatefulShellRoute when using restorationScopeIds on one or more '
        'of the branches',
      );
    }
    return true;
  }
}
