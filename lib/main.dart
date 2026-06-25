import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/connections_provider.dart';
import 'providers/subscription_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EasyStockApp());
}

class EasyStockApp extends StatelessWidget {
  const EasyStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
          update: (_, auth, sub) {
            sub!.update(auth.uid, auth.verificationStatus.name);
            return sub;
          },
        ),
        ChangeNotifierProvider(create: (_) => ConnectionsProvider()),
      ],
      child: MaterialApp.router(
        title: 'EasyStock',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
