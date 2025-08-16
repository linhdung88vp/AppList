import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/gara_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'config/firebase_config.dart';
import 'services/admin_helper.dart';

void main() async {
  print('🚗 Gara Management App đang khởi động...');
  
  // Khởi tạo Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Khởi tạo Firebase
    await FirebaseConfig.initialize();
    print('🔥 Firebase đã được khởi tạo thành công!');
    
    // Tạo tài khoản demo nếu cần
    await AdminHelper.createDemoAccountsIfNeeded();
    
  } catch (e) {
    print('⚠️ Lỗi khởi tạo Firebase: $e');
    print('📱 Ứng dụng sẽ chạy với demo data');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️ Đang build MyApp...');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => GaraProvider()),
      ],
      child: MaterialApp(
        title: 'Quản lý Gara Ô tô',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang khởi tạo...'),
                ],
              ),
            ),
          );
        }
        
        if (authProvider.isLoggedIn) {
          // Cập nhật admin status cho GaraProvider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GaraProvider>().setAdminStatus(authProvider.isAdmin);
          });
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
