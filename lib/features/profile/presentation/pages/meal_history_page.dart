import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodbegood/config/routes.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';
import 'package:intl/intl.dart';

/// Meal history page with export functionality
class MealHistoryPage extends StatefulWidget {
  const MealHistoryPage({super.key});

  @override
  State<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage> {
  final MockDataService _mockDataService = MockDataService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _history = _mockDataService.getMealHistory('1');
        _isLoading = false;
      });
    });
  }

  double get _totalSavings {
    return _history.fold(0.0, (sum, item) => sum + (item['totalValue'] as double));
  }

  int get _totalMeals {
    return _history.length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goProfile();
            }
          },
        ),
        title: const Text('Meal History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isLoading ? null : _exportHistory,
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Cards
                _buildSummaryCards(colorScheme, textTheme),

                // History List
                Expanded(
                  child: _history.isEmpty
                      ? _buildEmptyState(colorScheme, textTheme)
                      : _buildHistoryList(colorScheme, textTheme),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCards(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.restaurant,
              value: '$_totalMeals',
              label: 'Total Meals',
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.savings,
              value: '€${_totalSavings.toStringAsFixed(2)}',
              label: 'Total Saved',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.calendar_month,
              value: '${_history.length}',
              label: 'This Month',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: colorScheme.onSurface.withAlpha(77),
          ),
          const SizedBox(height: 16),
          Text(
            'No meal history yet',
            style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start picking up meals to see your history',
            style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withAlpha(102),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ColorScheme colorScheme, TextTheme textTheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final date = DateTime.parse(item['date'] as String);
        final items = (item['items'] as List).cast<String>();
        final totalValue = item['totalValue'] as double;

        return _HistoryCard(
          date: date,
          items: items,
          totalValue: totalValue,
          index: index,
        );
      },
    );
  }

  void _exportHistory() {
    // Generate CSV content
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Date,Items,Total Value');
    
    for (final item in _history) {
      final date = DateTime.parse(item['date'] as String);
      final items = (item['items'] as List).cast<String>().join('; ');
      final totalValue = item['totalValue'] as double;
      
      csvBuffer.writeln(
        '${DateFormat('yyyy-MM-dd').format(date)},"$items",${totalValue.toStringAsFixed(2)}',
      );
    }

    // Add summary
    csvBuffer.writeln();
    csvBuffer.writeln('Summary,,,');
    csvBuffer.writeln('Total Meals,,$_totalMeals,');
    csvBuffer.writeln('Total Savings,,€${_totalSavings.toStringAsFixed(2)},');

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: csvBuffer.toString()));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('CSV data copied to clipboard!'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

/// Summary card widget
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// History card widget
class _HistoryCard extends StatelessWidget {
  final DateTime date;
  final List<String> items;
  final double totalValue;
  final int index;

  const _HistoryCard({
    required this.date,
    required this.items,
    required this.totalValue,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date column
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    DateFormat('dd').format(date),
                    style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                    'Meal #${index + 1}',
                    style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item,
                          style: textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, HH:mm').format(date),
                    style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                  ),
                ],
              ),
            ),

            // Value
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '€${totalValue.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


