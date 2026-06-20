import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/register/register_pending_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/orders/order_tracking_screen.dart';
import '../screens/orders/payment_details_screen.dart';
import '../screens/distributors/distributor_connections_screen.dart';
import '../screens/distributors/distributor_detail_screen.dart';
import '../screens/stock/stock_browse_screen.dart';
import '../screens/stock/product_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/shop_details_screen.dart';
import '../screens/profile/personal_info_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/subscription_screen.dart';
import '../screens/profile/subscription_payment_screen.dart';
import '../screens/profile/language_screen.dart';
import '../screens/profile/faq_screen.dart';
import '../screens/profile/support_screen.dart';
import '../screens/profile/terms_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/notifications/notifications_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/register/pending',
      builder: (_, state) {
        final ref = (state.extra as String?) ?? 'SK-0000';
        return RegisterPendingScreen(referenceNumber: ref);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (_, state) => OrderHistoryScreen(
        initialTab: (state.extra as int?) ?? 0,
      ),
    ),
    GoRoute(
      path: '/orders/:orderId/tracking',
      builder: (_, state) => OrderTrackingScreen(
        orderId: state.pathParameters['orderId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/distributors',
      builder: (_, __) => const DistributorConnectionsScreen(),
    ),
    GoRoute(
      path: '/distributors/:name',
      builder: (_, state) {
        final arg = state.extra as DistributorArg;
        return DistributorDetailScreen(dist: arg);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (_, __) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/shop',
      builder: (_, __) => const ShopDetailsScreen(),
    ),
    GoRoute(
      path: '/profile/personal',
      builder: (_, __) => const PersonalInfoScreen(),
    ),
    GoRoute(
      path: '/profile/password',
      builder: (_, __) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/profile/subscription',
      builder: (_, __) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/subscription/payment',
      builder: (_, state) => SubscriptionPaymentScreen(
        arg: state.extra as SubscriptionPaymentArg,
      ),
    ),
    GoRoute(
      path: '/profile/language',
      builder: (_, __) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/profile/faq',
      builder: (_, __) => const FaqScreen(),
    ),
    GoRoute(
      path: '/profile/support',
      builder: (_, __) => const SupportScreen(),
    ),
    GoRoute(
      path: '/profile/terms',
      builder: (_, __) => const TermsScreen(),
    ),
    GoRoute(
      path: '/stock/:distributorName',
      builder: (_, state) => StockBrowseScreen(
        distributorName: state.extra as String? ??
            Uri.decodeComponent(state.pathParameters['distributorName'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/product/:productId',
      builder: (_, state) {
        final arg = state.extra as ProductDetailArg;
        return ProductDetailScreen(arg: arg);
      },
    ),
    GoRoute(
      path: '/payment/:orderId',
      builder: (_, state) {
        final arg = state.extra as PaymentArg;
        return PaymentDetailsScreen(arg: arg);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (_, __) => const SearchScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),
  ],
);
