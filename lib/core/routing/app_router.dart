import 'package:go_router/go_router.dart';

import '../../features/dashboard/ui/views/dashboard_view.dart';
import '../../features/widgets/presentation/pages/widget_catalog_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/widgets',
      name: 'widgets',
      builder: (context, state) => const WidgetCatalogPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
