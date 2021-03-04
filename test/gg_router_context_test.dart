// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:gg_router/gg_router.dart';

main() {
  group('context.router', () {
    // .........................................................................
    setUp(WidgetTester tester, {required Widget child}) async {
      final widget = MaterialApp.router(
        routeInformationParser: GgRouteInformationParser(),
        routerDelegate: GgRouterDelegate(child: child),
      );
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets(
      'should work correctly',
      (WidgetTester tester) async {
        BuildContext? context;

        late GgRouterContext rootRouter;
        late GgRouterContext router;
        late GgRouterContext childRouter;

        await setUp(tester, child: Builder(builder: (c0) {
          rootRouter = c0.router;

          final builder = (BuildContext c1, String x) {
            context = c1;
            router = c1.router;
            return GgRouterWidget({
              'childRoute$x': (c2) {
                childRouter = c2.router;
                return Container();
              }
            });
          };

          return GgRouterWidget({
            'routeA': (c) => builder(c, 'A'),
            'routeB': (c) => builder(c, 'B'),
            'routeC': (c) => builder(c, 'C'),
          });
        }));

        expect(context!, isNotNull);

        // .......................................................
        // context.router should give the current context's router
        expect(router, isInstanceOf<GgRouterContext>());
        expect(childRouter, isInstanceOf<GgRouterContext>());

        // .......................................................
        // context.router.node should give the route node assigned to the
        // current context, in our case this is the first route
        expect(router.node.name, 'routeA');
        expect(childRouter.node.name, 'childRouteA');

        // .......................................................
        // context.router.routeName should give the name of the
        // route segment
        expect(router.routeName, 'routeA');
        expect(childRouter.routeName, 'childRouteA');

        // .......................................................
        // context.router.routeNameOfActiveChild should give the name
        // of the active child route, or null if no child route is active.
        expect(router.routeNameOfActiveChild, 'childRouteA');
        expect(childRouter.routeNameOfActiveChild, null);

        // .......................................................
        // context.router.routePath should give the complete path
        // of the route
        expect(router.routePath, '/routeA');
        expect(childRouter.routePath, '/routeA/childRouteA');

        // .......................................................
        // context.router.indexOfActiveChild should give the index
        // of the active child route, or null if no child route is active.
        expect(rootRouter.indexOfActiveChild, 0);
        expect(childRouter.indexOfActiveChild, null);
        router.navigateTo('/routeC');
        await tester.pumpAndSettle();
        expect(rootRouter.indexOfActiveChild, 2);

        // .......................................................
        // context.router.onActiveChildChange should inform, when the
        // active child changes
        bool? onActiveChildChangeDidFire;
        final s = router.onActiveChildChange
            .listen((event) => onActiveChildChangeDidFire = true);

        await tester.pumpAndSettle();
        expect(onActiveChildChangeDidFire, isNull);

        // context.router.navigateTo() should allow to navigate relatively
        router.navigateTo('../routeB');
        await tester.pumpAndSettle();
        expect(onActiveChildChangeDidFire, true);

        expect(router.routePath, '/routeB');
        expect(childRouter.routePath, '/routeB/childRouteB');

        // context.router.navigateTo() should allow to navigate absolutely
        childRouter.navigateTo('/routeC');
        await tester.pumpAndSettle();
        expect(router.routePath, '/routeC');
        expect(childRouter.routePath, '/routeC/childRouteC');

        s.cancel();

        await tearDown(tester);
      },
    );
  });
}
