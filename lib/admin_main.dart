import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/gara_provider.dart';
import 'config/firebase_config.dart';
import 'screens/login_screen.dart';
import 'admin/admin_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseConfig.initialize();
  } catch (_) {}
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GaraProvider()),
      ],
      child: MaterialApp(
        title: 'Gara Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667EEA),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const _AdminWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _AdminWrapper extends StatelessWidget {
  const _AdminWrapper();

  @override
  Widget build(BuildContext context) {
    // Demo admin mode nếu Firebase chưa được cấu hình trên Web
    if (!FirebaseConfig.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gara Admin (DEMO)')),
        body: Column(
          children: const [
            MaterialBanner(
              content: Text('Demo mode: Firebase chưa cấu hình cho Web. Một số chức năng chỉ xem thử.'),
              actions: [SizedBox()],
            ),
            Expanded(child: AdminDashboard()),
          ],
        ),
      );
    }

    return Consumer<AuthProvider>(builder: (context, auth, _) {
      if (auth.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!auth.isLoggedIn) {
        return const LoginScreen();
      }
      // cập nhật quyền admin cho GaraProvider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GaraProvider>().setAdminStatus(auth.isAdmin);
      });
      if (!auth.isAdmin) {
        return Scaffold(
          appBar: AppBar(title: const Text('Gara Admin')),
          body: const Center(child: Text('Bạn không có quyền truy cập trang quản trị.')),
        );
      }
      return const AdminDashboard();
    });
  }
}
