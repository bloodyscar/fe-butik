import 'package:flutter/material.dart';

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to fetch reports
    await Future.delayed(const Duration(seconds: 2));

    // Mock data for demonstration
    final mockReports = [
      {
        'id': 1,
        'tanggal': '2024-07-25',
        'judul_kegiatan': 'Rapat Koordinasi Tim Dewan',
        'lokasi_kegiatan': 'Gedung DPR RI, Jakarta',
        'deskripsi_kegiatan':
            'Rapat koordinasi membahas agenda program kerja semester kedua tahun 2024 dan evaluasi kinerja tim dewan.',
        'lokasi_sekarang': 'Jakarta Pusat, DKI Jakarta, Indonesia',
        'created_at': '2024-07-25T10:30:00Z',
      },
      {
        'id': 2,
        'tanggal': '2024-07-20',
        'judul_kegiatan': 'Kunjungan Kerja ke Daerah',
        'lokasi_kegiatan': 'Kantor Gubernur Jawa Barat, Bandung',
        'deskripsi_kegiatan':
            'Melakukan kunjungan kerja untuk membahas program pembangunan infrastruktur di wilayah Jawa Barat dan koordinasi dengan pemerintah daerah.',
        'lokasi_sekarang': 'Bandung, Jawa Barat, Indonesia',
        'created_at': '2024-07-20T14:15:00Z',
      },
      {
        'id': 3,
        'tanggal': '2024-07-18',
        'judul_kegiatan': 'Sidang Paripurna DPR',
        'lokasi_kegiatan': 'Ruang Sidang Utama DPR RI',
        'deskripsi_kegiatan':
            'Mengikuti sidang paripurna DPR RI membahas RUU tentang perubahan UU Kesehatan dan pembahasan anggaran kesehatan nasional.',
        'lokasi_sekarang': 'Jakarta Pusat, DKI Jakarta, Indonesia',
        'created_at': '2024-07-18T09:00:00Z',
      },
      {
        'id': 4,
        'tanggal': '2024-07-15',
        'judul_kegiatan': 'Dialog dengan Konstituen',
        'lokasi_kegiatan': 'Balai Kota Surabaya',
        'deskripsi_kegiatan':
            'Melakukan dialog dengan konstituen di Surabaya untuk mendengar aspirasi masyarakat terkait kebijakan ekonomi dan sosial.',
        'lokasi_sekarang': 'Surabaya, Jawa Timur, Indonesia',
        'created_at': '2024-07-15T16:20:00Z',
      },
    ];

    setState(() {
      _reports = mockReports;
      _isLoading = false;
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      List<String> months = [
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
        'Desember',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      List<String> months = [
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
        'Desember',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat riwayat laporan...'),
                ],
              ),
            )
          : _reports.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return _buildReportCard(report);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada laporan',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Laporan yang Anda kirim akan muncul di sini',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/report');
            },
            icon: const Icon(Icons.add),
            label: const Text('Buat Laporan Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetail(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report['judul_kegiatan'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(height: 12),

              // Date and location
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(report['tanggal']),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report['lokasi_kegiatan'] ?? '',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description preview
              Text(
                report['deskripsi_kegiatan'] ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer with created date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dibuat: ${_formatDateTime(report['created_at'])}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetail(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.assignment, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Expanded(child: Text('Detail Laporan')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status
                const SizedBox(height: 16),

                _buildDetailRow('Tanggal', _formatDate(report['tanggal'])),
                _buildDetailRow('Judul Kegiatan', report['judul_kegiatan']),
                _buildDetailRow('Lokasi Kegiatan', report['lokasi_kegiatan']),
                _buildDetailRow('Lokasi Sekarang', report['lokasi_sekarang']),

                const SizedBox(height: 8),
                const Text(
                  'Deskripsi Kegiatan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(report['deskripsi_kegiatan']),

                const SizedBox(height: 16),
                Text(
                  'Dibuat: ${_formatDateTime(report['created_at'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
