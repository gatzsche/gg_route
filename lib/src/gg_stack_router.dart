// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';

import 'gg_router.dart';

/// Use [GgStackRouter] to show a selected route infront of an backgroundWidget.
class GgStackRouter extends StatelessWidget {
  // ...........................................................................

  /// Constructor.
  /// - [key] The widget's key.
  /// - [backgroundWidget] The background widget.
  /// - [foregroundRoutes] A list of routes which are shown infront of
  ///   [backgroundWidget]. Only the route is shown which matches the currently
  ///   active path segment.
  const GgStackRouter({
    Key? key,
    required this.backgroundWidget,
    required this.foregroundRoutes,
  }) : super(key: key);

  // ...........................................................................
  /// The background widget.
  final Widget backgroundWidget;

  // ...........................................................................
  /// The list of routes which are shown infront of the [backgroundWidget].
  /// Only the route belonging to the active child route is shown.
  final Map<String, Widget Function(BuildContext)> foregroundRoutes;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: GgRouter.of(context).onActiveChildChange,
      builder: (context, snapshot) {
        final node = GgRouter.of(context).node;
        if (node.activeChild == null) {
          return backgroundWidget;
        } else {
          return Stack(
            children: [
              backgroundWidget,
              GgRouter(foregroundRoutes),
            ],
          );
        }
      },
    );
  }
}
