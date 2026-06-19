import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/kelas_kuliah.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'khs__page.dart';
import 'krs_page.dart';
import 'profile_page.dart';
import 'presensi_page.dart';
import 'mahasiswa_materi_page.dart';

// ─── Enum halaman ──────────────────────────────────────────────────────────────
enum _MhsPage { beranda, krs, khs, profil, jadwal, presensi, materi }

class MahasiswaDashboardPage extends StatefulWidget {
  const MahasiswaDashboardPage({super.key});

  @override
  State<MahasiswaDashboardPage> createState() => _MahasiswaDashboardPageState();
}

class _MahasiswaDashboardPageState extends State<MahasiswaDashboardPage> {
  _MhsPage _activePage = _MhsPage.beranda;
  DateTime _selectedDate = DateTime.now();

  void _goTo(_MhsPage page) => setState(() => _activePage = page);

  List<String> get _breadcrumbs {
    switch (_activePage) {
      case _MhsPage.krs: return ['Beranda', 'Akademik', 'KRS'];
      case _MhsPage.khs: return ['Beranda', 'Hasil Studi', 'KHS'];
      case _MhsPage.profil: return ['Beranda', 'Profil'];
      case _MhsPage.jadwal: return ['Beranda', 'Jadwal Kuliah'];
      case _MhsPage.presensi: return ['Beranda', 'Akademik', 'Presensi Kuliah'];
      case _MhsPage.materi: return ['Beranda', 'Akademik', 'Silabus & Materi'];
      default: return ['Beranda', 'Dashboard'];
    }
  }

  Widget _buildContent() {
    switch (_activePage) {
      case _MhsPage.krs: return const KrsPage();
      case _MhsPage.khs: return const KhsPage();
      case _MhsPage.profil: return const ProfilePage();
      case _MhsPage.presensi: return const PresensiPage(role: 'mahasiswa');
      case _MhsPage.materi: return const MahasiswaMateriPage();
      default:
        return _BerandaContent(
          selectedDate: _selectedDate,
          onDateChanged: (d) => setState(() => _selectedDate = d),
          onNavigate: _goTo,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mahasiswa = const AkademikService().mahasiswaAktif();
    return CyberScaffold(
      userName: mahasiswa.namaLengkap,
      userRole: 'mahasiswa',
      breadcrumbs: _breadcrumbs,
      child: Column(
        children: [
          _MahasiswaNavBar(active: _activePage, onSelect: _goTo),
          const SizedBox(height: 4),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

// ─── Topbar Nav Bar ────────────────────────────────────────────────────────────
class _MahasiswaNavBar extends StatefulWidget {
  final _MhsPage active;
  final void Function(_MhsPage) onSelect;
  const _MahasiswaNavBar({required this.active, required this.onSelect});
  @override
  State<_MahasiswaNavBar> createState() => _MahasiswaNavBarState();
}

class _MahasiswaNavBarState extends State<_MahasiswaNavBar> {
  String? _openDropdown;

  void _toggle(String key) => setState(() => _openDropdown = _openDropdown == key ? null : key);
  void _close() => setState(() => _openDropdown = null);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          Row(
            children: [
              _NavItem(label: 'Beranda', isActive: widget.active == _MhsPage.beranda,
                  onTap: () { _close(); widget.onSelect(_MhsPage.beranda); }),
              _NavDropdownItem(
                label: 'Jadwal',
                isOpen: _openDropdown == 'jadwal',
                isActive: widget.active == _MhsPage.jadwal,
                onTap: () => _toggle('jadwal'),
                items: [
                  _DropdownOption(icon: Icons.calendar_month, title: 'Jadwal Kuliah', subtitle: 'Lihat jadwal perkuliahan', onTap: () { _close(); widget.onSelect(_MhsPage.jadwal); }),
                ],
              ),
              _NavDropdownItem(
                label: 'Akademik',
                isOpen: _openDropdown == 'akademik',
                isActive: widget.active == _MhsPage.krs || widget.active == _MhsPage.presensi || widget.active == _MhsPage.materi,
                onTap: () => _toggle('akademik'),
                items: [
                  _DropdownOption(icon: Icons.edit_note, title: 'Pengisian KRS', subtitle: 'Tentukan rencana kuliah', onTap: () { _close(); widget.onSelect(_MhsPage.krs); }),
                  _DropdownOption(icon: Icons.fingerprint_rounded, title: 'Presensi Kuliah', subtitle: 'Isi kehadiran kelas hari ini', onTap: () { _close(); widget.onSelect(_MhsPage.presensi); }),
                  _DropdownOption(icon: Icons.library_books, title: 'Silabus & Materi', subtitle: 'Lihat materi perkuliahan', onTap: () { _close(); widget.onSelect(_MhsPage.materi); }),
                  _DropdownOption(icon: Icons.book, title: 'Nilai Mahasiswa', subtitle: 'Kualitas perkuliahan Anda', onTap: () { _close(); widget.onSelect(_MhsPage.khs); }),
                  _DropdownOption(icon: Icons.person, title: 'Profil', subtitle: 'Data diri mahasiswa', onTap: () { _close(); widget.onSelect(_MhsPage.profil); }),
                ],
              ),
              _NavDropdownItem(
                label: 'Tingkat Akhir',
                isOpen: _openDropdown == 'ta',
                isActive: false,
                onTap: () => _toggle('ta'),
                items: [
                  _DropdownOption(icon: Icons.school, title: 'Skripsi / TA', subtitle: 'Manajemen tugas akhir', onTap: () { _close(); }),
                ],
              ),
              _NavDropdownItem(
                label: 'Hasil Studi',
                isOpen: _openDropdown == 'hs',
                isActive: widget.active == _MhsPage.khs,
                onTap: () => _toggle('hs'),
                items: [
                  _DropdownOption(icon: Icons.bar_chart, title: 'KHS', subtitle: 'Kartu Hasil Studi', onTap: () { _close(); widget.onSelect(_MhsPage.khs); }),
                ],
              ),
            ],
          ),
          // Dropdown panel
          if (_openDropdown != null)
            _buildDropdownPanel(),
        ],
      ),
    );
  }

  Widget _buildDropdownPanel() {
    List<_DropdownOption> items = [];
    if (_openDropdown == 'jadwal') {
      items = [_DropdownOption(icon: Icons.calendar_month, title: 'Jadwal Kuliah', subtitle: 'Lihat jadwal perkuliahan', onTap: () { _close(); widget.onSelect(_MhsPage.jadwal); })];
    } else if (_openDropdown == 'akademik') {
      items = [
        _DropdownOption(icon: Icons.edit_note, title: 'Pengisian KRS', subtitle: 'Tentukan rencana kuliah', onTap: () { _close(); widget.onSelect(_MhsPage.krs); }),
        _DropdownOption(icon: Icons.fingerprint_rounded, title: 'Presensi Kuliah', subtitle: 'Isi kehadiran kelas hari ini', onTap: () { _close(); widget.onSelect(_MhsPage.presensi); }),
        _DropdownOption(icon: Icons.library_books, title: 'Silabus & Materi', subtitle: 'Lihat materi perkuliahan', onTap: () { _close(); widget.onSelect(_MhsPage.materi); }),
        _DropdownOption(icon: Icons.book, title: 'Nilai Mahasiswa', subtitle: 'Kualitas perkuliahan Anda', onTap: () { _close(); widget.onSelect(_MhsPage.khs); }),
        _DropdownOption(icon: Icons.person, title: 'Profil', subtitle: 'Data diri mahasiswa', onTap: () { _close(); widget.onSelect(_MhsPage.profil); }),
      ];
    } else if (_openDropdown == 'ta') {
      items = [_DropdownOption(icon: Icons.school, title: 'Skripsi / TA', subtitle: 'Manajemen tugas akhir', onTap: () { _close(); })];
    } else if (_openDropdown == 'hs') {
      items = [_DropdownOption(icon: Icons.bar_chart, title: 'KHS', subtitle: 'Kartu Hasil Studi', onTap: () { _close(); widget.onSelect(_MhsPage.khs); })];
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A6B),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(_openDropdown!.toUpperCase(), style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ),
          ...items.map((item) => _buildDropdownItemTile(item)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDropdownItemTile(_DropdownOption item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(item.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              Text(item.subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _DropdownOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _DropdownOption({required this.icon, required this.title, required this.subtitle, required this.onTap});
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? AppColors.primary : Colors.transparent, width: 3)),
        ),
        child: Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textSecondary, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}

class _NavDropdownItem extends StatelessWidget {
  final String label;
  final bool isOpen;
  final bool isActive;
  final VoidCallback onTap;
  final List<_DropdownOption> items;
  const _NavDropdownItem({required this.label, required this.isOpen, required this.isActive, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF1A3A6B) : Colors.transparent,
          border: Border(bottom: BorderSide(color: isActive && !isOpen ? AppColors.primary : Colors.transparent, width: 3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: isOpen ? Colors.white : (isActive ? AppColors.primary : AppColors.textSecondary), fontWeight: isActive || isOpen ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
            const SizedBox(width: 4),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: isOpen ? Colors.white : (isActive ? AppColors.primary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Beranda Content ───────────────────────────────────────────────────────────
class _BerandaContent extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;
  final void Function(_MhsPage) onNavigate;

  const _BerandaContent({required this.selectedDate, required this.onDateChanged, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final mahasiswa = akademik.mahasiswaAktif();
    final ipk = akademik.ipkMahasiswaAktif();
    final krsValid = akademik.krsValidMahasiswaAktif();
    final krsPending = akademik.krsPendingMahasiswaAktif();
    final krsDraft = akademik.krsDraftMahasiswaAktif();

    String krsStatus = 'Belum Mengisi KRS';
    Color krsColor = AppColors.warning;
    if (krsValid.isNotEmpty) { krsStatus = 'KRS Divalidasi ✓'; krsColor = AppColors.success; }
    else if (krsPending.isNotEmpty) { krsStatus = 'Menunggu Validasi...'; krsColor = AppColors.primary; }
    else if (krsDraft.isNotEmpty) { krsStatus = 'Draft KRS (${krsDraft.length} MK)'; krsColor = AppColors.warning; }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mahasiswa.isAktif)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red, width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS MAHASISWA: TIDAK AKTIF',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Status Anda saat ini tidak aktif. Silakan hubungi admin prodi atau pimpinan universitas untuk melakukan aktivasi.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // ── Kiri 65%: Jadwal ──
          Expanded(
            flex: 65,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _JadwalCard(selectedDate: selectedDate, onDateChanged: onDateChanged),
            ]),
          ),
          const SizedBox(width: 20),
          // ── Kanan 35%: Info ──
          Expanded(
            flex: 35,
            child: Column(children: [
              // Sapaan
              CyberPanel(
                isGlass: false,
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.school, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Hai, ${mahasiswa.namaLengkap.split(' ').first}!', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                    Text('Semester aktif • IPK ${ipk.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),
              // Status KRS
              CyberPanel(
                isGlass: false,
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: krsColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.assignment_turned_in_rounded, color: krsColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Status KRS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text(krsStatus, style: TextStyle(color: krsColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  ])),
                  if (krsValid.isEmpty)
                    TextButton(onPressed: () => onNavigate(_MhsPage.krs), child: const Text('Isi')),
                ]),
              ),
              const SizedBox(height: 12),
              // Stat Cards
              Row(children: [
                Expanded(child: _MiniStatCard(label: 'IPK', value: ipk.toStringAsFixed(2), icon: Icons.workspace_premium_rounded, color: AppColors.primary, progress: (ipk / 4.0).clamp(0.0, 1.0))),
                const SizedBox(width: 10),
                Expanded(child: _MiniStatCard(label: 'SKS Valid', value: '${krsValid.fold(0, (s, n) => s + n.sksMataKuliah)}', icon: Icons.menu_book_rounded, color: AppColors.success, progress: krsValid.isEmpty ? 0 : (krsValid.fold(0, (s, n) => s + n.sksMataKuliah) / 24).clamp(0.0, 1.0))),
              ]),
              const SizedBox(height: 12),
              // Tagihan
              CyberPanel(
                isGlass: false,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total Tagihan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Center(child: Column(children: [
                    Icon(Icons.check_circle_outline, color: AppColors.success, size: 40),
                    const SizedBox(height: 8),
                    const Text('Belum Ada Tagihan', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const Text('Terima kasih telah melunasi tagihan akademik.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11), textAlign: TextAlign.center),
                  ])),
                ]),
              ),
            ]),
          ),
        ],
      ),
    ],
  ),
);
  }
}

// ─── Jadwal Card ───────────────────────────────────────────────────────────────
class _JadwalCard extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;
  const _JadwalCard({required this.selectedDate, required this.onDateChanged});

  @override
  State<_JadwalCard> createState() => _JadwalCardState();
}

class _JadwalCardState extends State<_JadwalCard> {
  late DateTime _pendingDate;

  @override
  void initState() {
    super.initState();
    _pendingDate = widget.selectedDate;
  }

  static const _namaHari = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _namaBulan = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

  String _formatTanggal(DateTime d) => '${_namaHari[d.weekday]}, ${d.day} ${_namaBulan[d.month]} ${d.year}';
  String _namaHariDari(DateTime d) => _namaHari[d.weekday];

  void _showCalendar() {
    _pendingDate = widget.selectedDate;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Header
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                const Divider(height: 1),
                // Kalender mini
                Theme(
                  data: Theme.of(ctx).copyWith(
                    textTheme: Theme.of(ctx).textTheme.copyWith(
                      bodyMedium: const TextStyle(fontSize: 11),
                      titleSmall: const TextStyle(fontSize: 11),
                    ),
                  ),
                  child: SizedBox(
                    height: 260,
                    child: CalendarDatePicker(
                      initialDate: _pendingDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                      onDateChanged: (d) => setDlg(() => _pendingDate = d),
                    ),
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 10),
                // Tombol
                Row(children: [
                  Expanded(child: SizedBox(height: 36, child: OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, textStyle: const TextStyle(fontSize: 12)),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  ))),
                  const SizedBox(width: 8),
                  Expanded(child: SizedBox(height: 36, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, textStyle: const TextStyle(fontSize: 12)),
                    onPressed: () { Navigator.pop(ctx); widget.onDateChanged(_pendingDate); },
                    child: const Text('Terapkan'),
                  ))),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final hari = _namaHariDari(widget.selectedDate);
    final jadwal = akademik.jadwalPadaHari(hari);
    final isWeekend = widget.selectedDate.weekday >= 6;
    final isToday = _formatTanggal(widget.selectedDate) == _formatTanggal(DateTime.now());

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(children: [
            const Text('Jadwal Kuliah', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: _showCalendar,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(_formatTanggal(widget.selectedDate), style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                ]),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        if (isWeekend || jadwal.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(child: Column(children: [
              Icon(isWeekend ? Icons.weekend_outlined : Icons.event_busy_outlined, size: 52, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(isWeekend ? 'Hari Libur' : 'Tidak ada jadwal kuliah hari ini', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              if (!isToday) ...[const SizedBox(height: 8), TextButton(onPressed: () => widget.onDateChanged(DateTime.now()), child: const Text('Kembali ke hari ini'))],
            ])),
          )
        else
          ...jadwal.map((kelas) => _JadwalTile(kelas: kelas)),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ─── Jadwal Tile ───────────────────────────────────────────────────────────────
class _JadwalTile extends StatelessWidget {
  final KelasKuliah kelas;
  const _JadwalTile({required this.kelas});

  @override
  Widget build(BuildContext context) {
    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
    final colors = [AppColors.primary, AppColors.success, const Color(0xFFE67E22), const Color(0xFF8E44AD)];
    final color = colors[kelas.id.hashCode % colors.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: color, width: 4))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.menu_book_rounded, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mk.namaMataKuliah, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('${kelas.dosenPengampu} • Kelas ${kelas.namaKelas}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${kelas.jamMulai} – ${kelas.jamSelesai}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(kelas.ruangan, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('${mk.jumlahSks} SKS', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ]),
      ),
    );
  }
}

// ─── Mini Stat Card ────────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final double progress;
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900, height: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
