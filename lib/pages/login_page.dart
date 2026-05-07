import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'admin_prodi_page.dart';
import 'admin_univ_page.dart';
import 'dosen_page.dart';
import 'mahasiswa_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = const AuthService();

  void login() {
    final user = authService.login(
      usernameController.text,
      passwordController.text,
    );

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah')),
      );
      return;
    }

    if (user.role == 'admin_univ') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminUnivPage()),
      );
    } else if (user.role == 'admin_prodi') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminProdiPage()),
      );
    } else if (user.role == 'dosen') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DosenPage()),
      );
    } else if (user.role == 'mahasiswa') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MahasiswaDashboardPage()),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/login pic.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.bg.withValues(alpha: 0.72),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.bg.withValues(alpha: 0.9),
                    AppColors.deep.withValues(alpha: 0.72),
                    AppColors.bg.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: wide
                      ? Row(
                          children: [
                            const Expanded(child: _LoginIntro()),
                            const SizedBox(width: 36),
                            SizedBox(
                              width: 390,
                              child: _LoginForm(
                                usernameController: usernameController,
                                passwordController: passwordController,
                                onLogin: login,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _LoginIntro(),
                            const SizedBox(height: 24),
                            _LoginForm(
                              usernameController: usernameController,
                              passwordController: passwordController,
                              onLogin: login,
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoginIntro extends StatelessWidget {
  const _LoginIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIAKAD sederhana',
          style: TextStyle(
            fontSize: 42,
            color: AppColors.text,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Sistem informasi akademik.',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 16,
            height: 1.5,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CyberPanel(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Masuk Portal',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gunakan akun sesuai role akademik.',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: usernameController,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person, color: AppColors.cyan),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock, color: AppColors.cyan),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: onLogin, child: const Text('LOGIN')),
            ),
            const SizedBox(height: 16),
            const Text(
              'Demo: admin / 456, adminilkom / 789, megumi / 123, vidi / 123',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
