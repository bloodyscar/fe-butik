import 'package:flutter/material.dart';

class ReportCouncilPage extends StatefulWidget {
  const ReportCouncilPage({super.key});

  @override
  State<ReportCouncilPage> createState() => _ReportCouncilPageState();
}

class _ReportCouncilPageState extends State<ReportCouncilPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulKegiatanController = TextEditingController();
  final _lokasiKegiatanController = TextEditingController();
  final _deskripsiKegiatanController = TextEditingController();
  final _lokasiSekarangController = TextEditingController();

  DateTime? _selectedDate;
  bool _isSubmitting = false;

  // Helper function to format date
  String _formatDate(DateTime date) {
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
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _judulKegiatanController.dispose();
    _lokasiKegiatanController.dispose();
    _deskripsiKegiatanController.dispose();
    _lokasiSekarangController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kegiatan Dewan'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.assignment, size: 48, color: Colors.blue[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Form Laporan Kegiatan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Silakan isi form di bawah untuk melaporkan kegiatan dewan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 1. Tanggal
                _buildSectionTitle('1. Tanggal Kegiatan'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : 'Pilih tanggal kegiatan',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate != null
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Judul Kegiatan (Text Area)
                _buildSectionTitle('2. Judul Kegiatan'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _judulKegiatanController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan judul kegiatan...',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 2,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul kegiatan harus diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // 3. Lokasi Kegiatan
                _buildSectionTitle('3. Lokasi Kegiatan'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lokasiKegiatanController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan lokasi kegiatan',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lokasi kegiatan harus diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // 4. Deskripsi Kegiatan
                _buildSectionTitle('4. Deskripsi Kegiatan'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deskripsiKegiatanController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan deskripsi detail kegiatan...',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 2,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi kegiatan harus diisi';
                    }
                    if (value.trim().length < 20) {
                      return 'Deskripsi minimal 20 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // 5. Lokasi Sekarang
                _buildSectionTitle('5. Lokasi Sekarang'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lokasiSekarangController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan lokasi Anda saat ini',
                    prefixIcon: const Icon(Icons.my_location),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.gps_fixed, color: Colors.blue[600]),
                      onPressed: _getCurrentLocation,
                      tooltip: 'Dapatkan lokasi saat ini',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 2,
                      ),
                    ),
                    helperText:
                        'Tekan ikon GPS untuk mendapatkan lokasi otomatis',
                    helperStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lokasi sekarang harus diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Mengirim Laporan...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send),
                              SizedBox(width: 8),
                              Text(
                                'Kirim Laporan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _getCurrentLocation() {
    // Simulate getting current location
    // In a real app, you would use location services here
    setState(() {
      _lokasiSekarangController.text = 'Jakarta Pusat, DKI Jakarta, Indonesia';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lokasi berhasil didapatkan'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitReport() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal kegiatan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Create report data
      final reportData = {
        'tanggal': _formatDateForAPI(_selectedDate!),
        'judul_kegiatan': _judulKegiatanController.text.trim(),
        'lokasi_kegiatan': _lokasiKegiatanController.text.trim(),
        'deskripsi_kegiatan': _deskripsiKegiatanController.text.trim(),
        'lokasi_sekarang': _lokasiSekarangController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      print('📋 Report Data: $reportData');

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Laporan Terkirim!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Laporan kegiatan dewan berhasil dikirim.'),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal: ${_formatDate(_selectedDate!)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Judul: ${_judulKegiatanController.text.trim()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Terima kasih atas laporan yang telah disampaikan.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
