import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_lines.dart';
import '../models/user.dart';
import '../data/app_data.dart';
import 'admin_prodi_page.dart';
import 'admin_univ_page.dart';
import 'dosen_page.dart';
import 'mahasiswa_dashboard_page.dart';
import 'pimpinan_univ_page.dart';
import 'pimpinan_prodi_page.dart';
import 'package:postgres/postgres.dart';

// ─── Data akun test terkelompok per role ────────────────────────────────────
const _testCredentials = [
  _RoleGroup(
    role: 'Mahasiswa',
    icon: Icons.school_rounded,
    color: Color(0xFF3B82F6),
    accounts: [
      _Account('2024010001', '123', 'David Purnomo', 'ILKOM'),
      _Account('2024010002', '123', 'Vidi Lapa', 'Kedokteran'),
      _Account('2024010003', '123', 'Zhao Yufan', 'Biologi'),
      _Account('2024010010', '123', 'Keisha Putri', 'DKV'),
    ],
  ),
  _RoleGroup(
    role: 'Dosen',
    icon: Icons.person_4_rounded,
    color: Color(0xFF10B981),
    accounts: [
      _Account('D001', '123', 'Ir. Arfan', 'ILKOM'),
      _Account('D004', '123', 'dr. yuji', 'Kedokteran'),
      _Account('D007', '123', 'Dr. Raynata Bien', 'Biologi'),
    ],
  ),
  _RoleGroup(
    role: 'Admin Prodi',
    icon: Icons.manage_accounts_rounded,
    color: Color(0xFFF59E0B),
    accounts: [
      _Account('AP001', '789', 'Admin ILKOM', 'ILKOM-01'),
      _Account('AP002', '789', 'Admin Biologi', 'BIO-03'),
      _Account('AP003', '789', 'Admin Kedokteran', 'FK-02'),
    ],
  ),
  _RoleGroup(
    role: 'Admin Universitas',
    icon: Icons.admin_panel_settings_rounded,
    color: Color(0xFFEF4444),
    accounts: [
      _Account('A001', '456', 'Administrator Universitas', 'Universitas'),
    ],
  ),
  _RoleGroup(
    role: 'Pimpinan Universitas',
    icon: Icons.admin_panel_settings_rounded,
    color: Color(0xFF9333EA),
    accounts: [
      _Account('rektor', '123', 'Prof. Dr. Ir. Rektor, M.Si.', 'Rektorat'),
    ],
  ),
  _RoleGroup(
    role: 'Pimpinan Prodi',
    icon: Icons.supervised_user_circle_rounded,
    color: Color(0xFFEC4899),
    accounts: [
      _Account('kaprodiilkom', '123', 'Kaprodi Ilmu Komputer', 'ILKOM-01'),
      _Account('kaprodibio', '123', 'Kaprodi Biologi', 'BIO-03'),
      _Account('kaprodifk', '123', 'Kaprodi Kedokteran', 'FK-02'),
      _Account('kaprodidkv', '123', 'Kaprodi DKV', 'DKV-04'),
    ],
  ),
];

class _Account {
  final String username, password, nama, prodi;
  const _Account(this.username, this.password, this.nama, this.prodi);
}

class _RoleGroup {
  final String role;
  final IconData icon;
  final Color color;
  final List<_Account> accounts;
  const _RoleGroup({required this.role, required this.icon, required this.color, required this.accounts});
}

// ─── Login Page ─────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _authService = const AuthService();

  // Autocomplete
  List<User> _loadedUsers = [];
  List<_SuggestionItem> _suggestions = [];
  bool _showSuggestions = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _authService.getAllUsers();
    setState(() => _loadedUsers = users);
  }

  // Semua username valid dari database
  List<_SuggestionItem> get _allSuggestions {
    return _loadedUsers.map((u) {
      String role = '';
      String nama = u.nama;
      Color color = AppColors.primary;
      IconData icon = Icons.person;

      if (u.role == 'mahasiswa') { role = 'Mahasiswa'; color = const Color(0xFF3B82F6); icon = Icons.school_rounded; }
      else if (u.role == 'dosen') { role = 'Dosen'; color = const Color(0xFF10B981); icon = Icons.person_4_rounded; }
      else if (u.role == 'admin_prodi') { role = 'Admin Prodi'; color = const Color(0xFFF59E0B); icon = Icons.manage_accounts_rounded; }
      else if (u.role == 'admin_univ') { role = 'Admin Univ'; color = const Color(0xFFEF4444); icon = Icons.admin_panel_settings_rounded; }
      else if (u.role == 'pimpinan_univ') { role = 'Pimpinan Univ'; color = const Color(0xFF9333EA); icon = Icons.admin_panel_settings_rounded; }
      else if (u.role == 'pimpinan_prodi') { role = 'Pimpinan Prodi'; color = const Color(0xFFEC4899); icon = Icons.supervised_user_circle_rounded; }

      return _SuggestionItem(username: u.username, nama: nama, role: role, color: color, icon: icon, identifier: u.identifier);
    }).toList();
  }

  void _onUsernameChanged(String val) {
    if (val.isEmpty) {
      setState(() { _suggestions = []; _showSuggestions = false; });
      return;
    }
    final q = val.toLowerCase();
    final filtered = _allSuggestions.where((s) =>
      s.username.toLowerCase().contains(q) || 
      s.nama.toLowerCase().contains(q) ||
      s.identifier.toLowerCase().contains(q)
    ).take(6).toList();
    setState(() { _suggestions = filtered; _showSuggestions = filtered.isNotEmpty; });
  }

  void _selectSuggestion(_SuggestionItem item) {
    _usernameController.text = item.username;
    // Auto-fill password from _loadedUsers
    if (_loadedUsers.isNotEmpty) {
      final user = _loadedUsers.firstWhere((u) => u.username == item.username, orElse: () => _loadedUsers.first);
      _passwordController.text = user.password;
    }
    setState(() { _suggestions = []; _showSuggestions = false; });
    _passwordFocus.requestFocus();
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();
    final user = await _authService.login(_usernameController.text.trim(), _passwordController.text.trim());

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah'), backgroundColor: Colors.red),
      );
      return;
    }

    // Load all data from PostgreSQL database
    await AppData.loadFromDatabase();

    if (user.role == 'admin_univ') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminUnivPage()));
    } else if (user.role == 'admin_prodi') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminProdiPage()));
    } else if (user.role == 'dosen') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DosenPage()));
    } else if (user.role == 'mahasiswa') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MahasiswaDashboardPage()));
    } else if (user.role == 'pimpinan_univ') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PimpinanUnivPage()));
    } else if (user.role == 'pimpinan_prodi') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PimpinanProdiPage()));
    }
  }

  void _fillCredentials(_Account acc) {
    setState(() {
      _usernameController.text = acc.username;
      _passwordController.text = acc.password;
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _showTestCredentials() {
    showDialog(context: context, builder: (_) => _TestCredentialsDialog(onSelect: (acc) {
      Navigator.pop(context);
      _fillCredentials(acc);
    }));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          login();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                ),
              ),
            ),
            // FloatingLines animated background
            Positioned.fill(
              child: FloatingLines(
                enabledWaves: const ['top', 'middle', 'bottom'],
                lineCount: const [8, 14, 10],
                lineDistance: const [6, 5, 4],
                linesGradient: const [
                  '#5C7AEA',
                  '#7C3AED',
                  '#A78BFA',
                  '#3B82F6',
                  '#2F4BA2',
                ],
                animationSpeed: 0.6,
                bendRadius: 4.0,
                bendStrength: -0.4,
                mouseDamping: 0.04,
                parallax: true,
                parallaxStrength: 0.08,
                opacity: 0.55,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.gradStart, AppColors.gradEnd]),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              _waveBar(15), _waveBar(25), _waveBar(35), _waveBar(20), _waveBar(10),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          const Text('SIAKAD', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 4),
                          const Text('Universitas Nusa Cendana', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, 10))],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          const Text('Selamat Datang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                          const SizedBox(height: 6),
                          const Text('Log in ke Sistem Akademik Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 28),

                          // ── Username + Autocomplete ──
                          _UsernameField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            suggestions: _suggestions,
                            showSuggestions: _showSuggestions,
                            onChanged: _onUsernameChanged,
                            onSuggestionSelected: _selectSuggestion,
                            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                            onTapOutside: () => setState(() => _showSuggestions = false),
                          ),
                          const SizedBox(height: 20),

                          // ── Password ──
                          _PasswordField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            showPassword: _showPassword,
                            onToggle: () => setState(() => _showPassword = !_showPassword),
                            onSubmitted: (_) => login(),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: () {}, child: const Text('Lupa Password?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(height: 16),

                          // ── Tombol Masuk ──
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C7AEA),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.login_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Tombol Test Credentials ──
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _showTestCredentials,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.key_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Akun Testing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('atau', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ]),
                          const SizedBox(height: 20),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            _socialButton(Icons.g_mobiledata),
                            const SizedBox(width: 20),
                            _socialButton(Icons.apple),
                          ]),
                          const SizedBox(height: 20),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('Belum punya akun? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            GestureDetector(onTap: () {}, child: const Text('Daftar Sekarang', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))),
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tekan Enter untuk masuk', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waveBar(double h) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: 4, height: h,
    decoration: BoxDecoration(color: AppColors.gradStart, borderRadius: BorderRadius.circular(2)),
  );

  Widget _socialButton(IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, size: 28, color: const Color(0xFF1F2937)),
  );
}

// ─── Suggestion Item ────────────────────────────────────────────────────────
class _SuggestionItem {
  final String username, nama, role, identifier;
  final Color color;
  final IconData icon;
  const _SuggestionItem({required this.username, required this.nama, required this.role, required this.color, required this.icon, required this.identifier});
}

// ─── Username Field dengan Autocomplete ────────────────────────────────────
class _UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<_SuggestionItem> suggestions;
  final bool showSuggestions;
  final void Function(String) onChanged;
  final void Function(_SuggestionItem) onSuggestionSelected;
  final void Function(String) onFieldSubmitted;
  final VoidCallback onTapOutside;

  const _UsernameField({
    required this.controller, required this.focusNode,
    required this.suggestions, required this.showSuggestions,
    required this.onChanged, required this.onSuggestionSelected,
    required this.onFieldSubmitted, required this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Username / ID', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151), fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onFieldSubmitted,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: 'Ketik username atau nama...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey[400], size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(icon: Icon(Icons.close, color: Colors.grey[400], size: 18), onPressed: () { controller.clear(); onChanged(''); })
              : null,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        ),
      ),
      // Suggestion dropdown
      if (showSuggestions)
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(children: suggestions.map((s) => InkWell(
            onTap: () => onSuggestionSelected(s),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: s.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(s.icon, color: s.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.nama} (${s.username})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1F2937))),
                  Text('${s.identifier} · ${s.role}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ])),
                Icon(Icons.north_west_rounded, size: 14, color: Colors.grey[400]),
              ]),
            ),
          )).toList()),
        ),
    ]);
  }
}

// ─── Password Field ──────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showPassword;
  final VoidCallback onToggle;
  final void Function(String) onSubmitted;

  const _PasswordField({required this.controller, required this.focusNode, required this.showPassword, required this.onToggle, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151), fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !showPassword,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Masukkan password',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400], size: 20),
          suffixIcon: IconButton(
            icon: Icon(showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[400], size: 20),
            onPressed: onToggle,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        ),
      ),
    ]);
  }
}

// ─── Dialog Test Credentials ────────────────────────────────────────────────
class _TestCredentialsDialog extends StatelessWidget {
  final void Function(_Account) onSelect;
  const _TestCredentialsDialog({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 580),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.gradStart, AppColors.gradEnd]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(children: [
              const Icon(Icons.key_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Akun Testing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                Text('Pilih akun untuk login otomatis', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white, size: 20)),
            ]),
          ),
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _testCredentials.map((group) => _buildGroup(context, group)).toList(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, _RoleGroup group) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: group.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(group.icon, color: group.color, size: 16),
          ),
          const SizedBox(width: 8),
          Text(group.role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: group.color, letterSpacing: 0.8)),
        ]),
      ),
      ...group.accounts.map((acc) => InkWell(
        onTap: () => onSelect(acc),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: group.color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: group.color.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(acc.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1F2937))),
              const SizedBox(height: 2),
              Text(acc.prodi, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey[200]!)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.person_outline, size: 10, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(acc.username, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
                Row(children: [
                  Icon(Icons.lock_outline, size: 10, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(acc.password, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.login_rounded, size: 16, color: group.color),
          ]),
        ),
      )),
      const SizedBox(height: 6),
    ]);
  }
}

