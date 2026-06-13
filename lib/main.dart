import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'data/repositories/studio_repository.dart';
import 'data/services/ping_service.dart';
import 'data/services/session_service.dart';
import 'data/services/studio_api_service.dart';
import 'data/services/vpn_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/auth/view_models/auth_view.dart';
import 'ui/features/auth/views/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const VpnApp());
}

class VpnApp extends StatelessWidget {
  const VpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => StudioApiService()),
        Provider(create: (_) => SessionService()),
        Provider(create: (_) => PingService()),
        Provider(create: (_) => VpnService()),
        ProxyProvider3<StudioApiService, SessionService, PingService,
            StudioRepository>(
          update: (_, api, session, ping, __) => StudioRepository(
            apiService: api,
            sessionService: session,
            pingService: ping,
          ),
        ),
        ChangeNotifierProxyProvider<StudioRepository, AuthViewModel>(
          create: (ctx) => AuthViewModel(repository: ctx.read()),
          update: (_, repo, prev) => prev ?? AuthViewModel(repository: repo),
        ),
      ],
      child: MaterialApp(
        title: 'Studio VPN',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AuthScreen(),
      ),
    );
  }
}