import 'package:flutter/material.dart';
import '../../service/order_service.dart';
import '../../utils/price_formatter.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;
  String? _errorMessage;
  
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _searchQueryController = TextEditingController();

  // Simple date formatter helper
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  @override
  void initState() {
    super.initState();
    // Set default date range (current month)
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    _startDateController.text = _formatDate(firstDayOfMonth);
    _endDateController.text = _formatDate(lastDayOfMonth);
    
    // Load initial report
    _loadSalesReport();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _searchQueryController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesReport() async {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal mulai dan tanggal selesai'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await OrderService.getSalesReport(
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        query: _searchQueryController.text.isNotEmpty ? _searchQueryController.text : null,
      );

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _reportData = result['data'];
          _errorMessage = null;
        } else {
          _errorMessage = result['message'] ?? 'Gagal memuat laporan penjualan';
          _reportData = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error memuat laporan penjualan: $e';
        _reportData = null;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller, String title) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: title,
    );
    
    if (picked != null) {
      controller.text = _formatDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 32,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analitik Penjualan',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                'Laporan penjualan komprehensif dengan wawasan',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Universal Search Field
                    TextFormField(
                      controller: _searchQueryController,
                      decoration: const InputDecoration(
                        labelText: 'Pencarian Universal',
                        hintText: 'Cari berdasarkan produk, pelanggan, atau order...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        suffixIcon: Tooltip(
                          message: 'Kosongkan untuk melihat semua data',
                          child: Icon(Icons.info_outline, size: 20),
                        ),
                      ),
                      onChanged: (value) {
                        // Optional: Auto-search after typing stops
                        // You can implement debouncing here if needed
                      },
                      onFieldSubmitted: (value) {
                        // Trigger search when user presses enter
                        _loadSalesReport();
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Range Selection
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startDateController,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Mulai',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(_startDateController, 'Pilih Tanggal Mulai'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _endDateController,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Selesai',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(_endDateController, 'Pilih Tanggal Selesai'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _loadSalesReport,
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh),
                            label: Text(_isLoading ? 'Membuat Laporan...' : 'Buat Laporan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : () {
                              _searchQueryController.clear();
                              _loadSalesReport();
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Hapus Filter'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Report Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _reportData != null
                          ? _buildReportContent()
                          : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error Memuat Laporan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadSalesReport,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak Ada Data Laporan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih rentang tanggal dan klik "Buat Laporan" untuk melihat analitik penjualan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    final data = _reportData!['data'];
    final overallSummary = data['overall_summary'];
    final reportInfo = data['report_info'];
    final topProducts = data['top_products'] as List<dynamic>? ?? [];
    final topCustomers = data['top_customers'] as List<dynamic>? ?? [];
    final dailySales = data['daily_sales'];
    final weeklySales = data['weekly_sales'];
    final monthlySales = data['monthly_sales'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Sales Trends Section
          Text(
            'Rekap Penjualan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Daily Sales
          _buildSalesSection(
            'Penjualan Harian',
            dailySales['description'],
            dailySales['data'] as List<dynamic>,
            dailySales['total_records'],
            Icons.calendar_today,
            Colors.blue,
          ),

          const SizedBox(height: 16),

          // Weekly Sales
          _buildSalesSection(
            'Penjualan Mingguan',
            weeklySales['description'],
            weeklySales['data'] as List<dynamic>,
            weeklySales['total_records'],
            Icons.calendar_view_week,
            Colors.orange,
          ),

          const SizedBox(height: 16),

          // Monthly Sales
          _buildSalesSection(
            'Penjualan Bulanan',
            monthlySales['description'],
            monthlySales['data'] as List<dynamic>,
            monthlySales['total_records'],
            Icons.calendar_view_month,
            Colors.green,
          ),

        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Icon(icon, color: color, size: 28), // Slightly smaller icon
            const SizedBox(height: 6), // Reduced spacing
            Flexible( // Wrap with Flexible
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18, // Slightly smaller font
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit to 1 line
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible( // Wrap with Flexible
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11, // Slightly smaller font
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Allow 2 lines for title
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSection(
    String title,
    String description,
    List<dynamic> salesData,
    int totalRecords,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalRecords catatan',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            if (salesData.isNotEmpty) ...[
              SizedBox( // Wrap with SizedBox for better control
                height: 130, // Increased height to accommodate total products
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: salesData.length,
                  itemBuilder: (context, index) {
                    final item = salesData[index];
                    return Container(
                      width: 170, // Slightly reduced width
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10), // Reduced padding
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Added
                        children: [
                          Flexible( // Wrap with Flexible
                            child: Text(
                              item['period'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 13, // Slightly smaller
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                          Flexible(
                            child: Text(
                              'Pesanan: ${item['total_orders']}',
                              style: const TextStyle(fontSize: 11), // Smaller font
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Pendapatan: ${PriceFormatter.formatPrice(item['total_revenue'].toDouble())}',
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Produk: ${item['total_products'] ?? 0}',
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              SizedBox( // Changed from Container to SizedBox
                height: 60,
                child: Center(
                  child: Text(
                    'Tidak ada data tersedia untuk periode ini',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}