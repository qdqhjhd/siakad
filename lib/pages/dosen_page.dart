import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../utils/logout.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'input_nilai_page.dart';
import 'validasi_krs_page.dart';
import 'presensi_page.dart';
import 'mulai_kuliah_page.dart';

enum _DosenPage { beranda, krs, presensi, nilai }

class DosenPage extends StatefulWidget {
  const DosenPage({super.key});

  @override
  State<DosenPage> createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  _DosenPage _activePage = _DosenPage.beranda;
  DateTime _selectedDate = DateTime.now();

  void _goTo(_DosenPage page) => setState(() => _activePage = page);

  List<String> get _breadcrumbs {
    switch (_activePage) {
      case _DosenPage.krs:
        return ['Beranda', 'Akademik', 'Validasi KRS'];
      case _DosenPage.presensi:
        return ['Beranda', 'Akademik', 'Presensi Kelas'];
      case _DosenPage.nilai:
        return ['Beranda', 'Akademik', 'Input Nilai'];
      default:
        return ['Beranda', 'Dashboard Dosen'];
    }
  }

  Widget _buildContent() {
    switch (_activePage) {
      case _DosenPage.krs:
        return const ValidasiKrsPage();
      case _DosenPage.presensi:
        return const PresensiPage(role: 'dosen');
      case _DosenPage.nilai:
        return const InputNilaiPage();
      default:
        return _BerandaContent(
          selectedDate: _selectedDate,
          onDateChanged: (d) => setState(() => _selectedDate = d),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaDosen = AppData.currentDosenNama;
    final prodiDosen = AppData.currentDosenProdi;

    return CyberScaffold(
      userName: namaDosen,
      userRole: 'dosen',
      breadcrumbs: _breadcrumbs,
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      child: Column(
        children: [
          _DosenNavBar(active: _activePage, onSelect: _goTo),
          const SizedBox(height: 4),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

// ─── Topbar Nav Bar ────────────────────────────────────────────────────────────
class _DosenNavBar extends StatefulWidget {
  final _DosenPage active;
  final void Function(_DosenPage) onSelect;
  const _DosenNavBar({required this.active, required this.onSelect});

  @override
  State<_DosenNavBar> createState() => _DosenNavBarState();
}

class _DosenNavBarState extends State<_DosenNavBar> {
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
              _NavItem(
                label: 'Beranda',
                isActive: widget.active == _DosenPage.beranda,
                onTap: () {
                  _close();
                  widget.onSelect(_DosenPage.beranda);
                },
              ),
              _NavDropdownItem(
                label: 'Akademik',
                isOpen: _openDropdown == 'akademik',
                isActive: widget.active == _DosenPage.krs ||
                    widget.active == _DosenPage.presensi ||
                    widget.active == _DosenPage.nilai,
                onTap: () => _toggle('akademik'),
                items: [
                  _DropdownOption(
                    icon: Icons.fact_check,
                    title: 'Validasi KRS Mahasiswa',
                    subtitle: 'Setujui KRS mahasiswa bimbingan',
                    onTap: () {
                      _close();
                      widget.onSelect(_DosenPage.krs);
                    },
                  ),
                  _DropdownOption(
                    icon: Icons.fingerprint_rounded,
                    title: 'Presensi Kelas (Pertemuan)',
                    subtitle: 'Kelola sesi presensi kelas',
                    onTap: () {
                      _close();
                      widget.onSelect(_DosenPage.presensi);
                    },
                  ),
                  _DropdownOption(
                    icon: Icons.edit_note,
                    title: 'Input Nilai Mahasiswa',
                    subtitle: 'Kelola nilai mata kuliah kelas',
                    onTap: () {
                      _close();
                      widget.onSelect(_DosenPage.nilai);
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_openDropdown != null) _buildDropdownPanel(),
        ],
      ),
    );
  }

  Widget _buildDropdownPanel() {
    List<_DropdownOption> items = [];
    if (_openDropdown == 'akademik') {
      items = [
        _DropdownOption(
          icon: Icons.fact_check,
          title: 'Validasi KRS Mahasiswa',
          subtitle: 'Setujui KRS mahasiswa bimbingan',
          onTap: () {
            _close();
            widget.onSelect(_DosenPage.krs);
          },
        ),
        _DropdownOption(
          icon: Icons.fingerprint_rounded,
          title: 'Presensi Kelas (Pertemuan)',
          subtitle: 'Kelola sesi presensi kelas',
          onTap: () {
            _close();
            widget.onSelect(_DosenPage.presensi);
          },
        ),
        _DropdownOption(
          icon: Icons.edit_note,
          title: 'Input Nilai Mahasiswa',
          subtitle: 'Kelola nilai mata kuliah kelas',
          onTap: () {
            _close();
            widget.onSelect(_DosenPage.nilai);
          },
        ),
      ];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A6B),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              _openDropdown!.toUpperCase(),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  item.subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
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
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
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
            Text(
              label,
              style: TextStyle(
                color: isOpen ? Colors.white : (isActive ? AppColors.primary : AppColors.textSecondary),
                fontWeight: isActive || isOpen ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: isOpen ? Colors.white : (isActive ? AppColors.primary : AppColors.textSecondary),
            ),
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

  const _BerandaContent({required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final namaDosen = AppData.currentDosenNama;
    final prodiDosen = AppData.currentDosenProdi;
    final kelasDosen = akademik.kelasDosenAktif();
    final semuaNilai = akademik.nilaiDosenAktif();
    final belumInput = akademik.nilaiBelumInputDosenAktif();
    final progressInput = akademik.progresInputNilaiDosenAktif();
    final rataRata = akademik.rataRataNilaiDosenAktif();
    final pendingKrs = akademik.pengajuanKrsDosenAktif().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Kiri 65%: Jadwal ──
              Expanded(
                flex: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _JadwalDosenCard(
                      selectedDate: selectedDate,
                      onDateChanged: onDateChanged,
                      kelasDosen: kelasDosen,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // ── Kanan 35%: Info ──
              Expanded(
                flex: 35,
                child: Column(
                  children: [
                    // Sapaan
                    CyberPanel(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hai, ${namaDosen.split(' ').first}!',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'NIDN ${AppData.currentDosenNidn} • $prodiDosen',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            label: 'Jumlah Kelas',
                            value: '${kelasDosen.length}',
                            icon: Icons.class_rounded,
                            color: AppColors.primary,
                            progress: kelasDosen.isEmpty ? 0 : 1.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStatCard(
                            label: 'Belum Input Nilai',
                            value: '$belumInput',
                            icon: Icons.edit_off_rounded,
                            color: belumInput == 0 ? AppColors.success : const Color(0xFFE67E22),
                            progress: semuaNilai.isEmpty ? 0 : (belumInput / semuaNilai.length).clamp(0.0, 1.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            label: 'Validasi KRS',
                            value: '$pendingKrs',
                            icon: Icons.fact_check_rounded,
                            color: pendingKrs == 0 ? AppColors.success : const Color(0xFFF59E0B),
                            progress: pendingKrs == 0 ? 1.0 : 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStatCard(
                            label: 'Rata Nilai',
                            value: rataRata == 0 ? '-' : rataRata.toStringAsFixed(1),
                            icon: Icons.workspace_premium_rounded,
                            color: AppColors.primary,
                            progress: rataRata == 0 ? 0 : (rataRata / 100).clamp(0.0, 1.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Panel
                    CyberPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProgressMetric(
                            label: 'Progress Input Nilai',
                            value: '${(progressInput * 100).round()}%',
                            progress: progressInput,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Jadwal Dosen Card ────────────────────────────────────────────────────────
class _JadwalDosenCard extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;
  final List<dynamic> kelasDosen;

  const _JadwalDosenCard({required this.selectedDate, required this.onDateChanged, required this.kelasDosen});

  @override
  State<_JadwalDosenCard> createState() => _JadwalDosenCardState();
}

class _JadwalDosenCardState extends State<_JadwalDosenCard> {
  late DateTime _pendingDate;

  @override
  void initState() {
    super.initState();
    _pendingDate = widget.selectedDate;
  }

  static const _namaHari = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Tanggal',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
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
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, textStyle: const TextStyle(fontSize: 12)),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, textStyle: const TextStyle(fontSize: 12)),
                            onPressed: () {
                              Navigator.pop(ctx);
                              widget.onDateChanged(_pendingDate);
                            },
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hari = _namaHariDari(widget.selectedDate);
    final jadwal = widget.kelasDosen.where((k) => k.hari == hari).toList();
    final isWeekend = widget.selectedDate.weekday >= 6;
    final isToday = _formatTanggal(widget.selectedDate) == _formatTanggal(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Text(
                  'Jadwal Mengajar Anda',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showCalendar,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          _formatTanggal(widget.selectedDate),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (isWeekend || jadwal.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      isWeekend ? Icons.weekend_outlined : Icons.event_busy_outlined,
                      size: 52,
                      color: AppColors.textSecondary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isWeekend ? 'Hari Libur Akhir Pekan' : 'Tidak ada jadwal mengajar pada hari ini',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                    ),
                    if (!isToday) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => widget.onDateChanged(DateTime.now()),
                        child: const Text('Kembali ke hari ini'),
                      )
                    ],
                  ],
                ),
              ),
            )
          else
            ...jadwal.map((kelas) => _JadwalDosenTile(kelas: kelas)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Jadwal Dosen Tile ────────────────────────────────────────────────────────
class _JadwalDosenTile extends StatelessWidget {
  final dynamic kelas;
  const _JadwalDosenTile({required this.kelas});

  @override
  Widget build(BuildContext context) {
    final mk = AppData.daftarMataKuliah.firstWhere((m) => m.kodeMataKuliah == kelas.kodeMataKuliah);
    final colors = [AppColors.primary, AppColors.success, const Color(0xFFE67E22), const Color(0xFF8E44AD)];
    final color = colors[kelas.id.hashCode % colors.length];
    final totalMhs = AppData.daftarNilai.where((n) => n.idKelasKuliah == kelas.id && n.statusKrs == 'valid').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mk.namaMataKuliah,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelas ${kelas.namaKelas} • $totalMhs Mahasiswa Terdaftar',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${kelas.jamMulai} – ${kelas.jamSelesai}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(kelas.ruangan, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${mk.jumlahSks} SKS', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MulaiKuliahPage(kelas: kelas),
                      ),
                    );
                  },
                  icon: const Icon(Icons.school, size: 16),
                  label: const Text('Mulai Kuliah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900, height: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
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
