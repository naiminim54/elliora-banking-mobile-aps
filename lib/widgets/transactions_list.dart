import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../utils/format.dart';

/// Widget liste des transactions (recherche, tri, filtres)
class TransactionsList extends StatefulWidget {
  final String accountId;

  const TransactionsList({super.key, required this.accountId});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  static const int _pageSize = 10;

  // Filtres et recherche
  final TextEditingController _searchController = TextEditingController();
  String? _sortBy = 'date';
  String? _sortOrder = 'desc';
  String? _filterType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions({bool append = false}) async {
    try {
      if (!append) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final response = await ApiClient.getTransactions(
        widget.accountId,
        page: append ? _currentPage + 1 : 1,
        pageSize: _pageSize,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      if (mounted) {
        setState(() {
          if (append) {
            _transactions.addAll(response.items);
            _currentPage++;
          } else {
            _transactions = response.items;
            _currentPage = response.page;
          }
          _totalPages = (response.total / _pageSize).ceil();
          _totalItems = response.total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is ApiException ? e.message : 'Erreur lors du chargement';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
      _transactions.clear();
    });
    _loadTransactions();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _sortBy = 'date';
      _sortOrder = 'desc';
      _filterType = null;
      _startDate = null;
      _endDate = null;
    });
    _applyFilters();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche et filtres
        _buildFiltersSection(),

        // Liste des transactions
        Expanded(child: _buildTransactionsList()),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Barre de recherche
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filtres rapides
            Row(
              children: [
                // Tri
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Tri',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Date')),
                      DropdownMenuItem(value: 'amount', child: Text('Montant')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Ordre
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortOrder,
                    decoration: const InputDecoration(
                      labelText: 'Ordre',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'desc', child: Text('↓')),
                      DropdownMenuItem(value: 'asc', child: Text('↑')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                // Type
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tous')),
                      DropdownMenuItem(value: 'credit', child: Text('Crédit')),
                      DropdownMenuItem(value: 'debit', child: Text('Débit')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Période
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${FormatUtils.formatDate(_startDate!)} - ${FormatUtils.formatDate(_endDate!)}'
                          : 'Période',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Effacer'),
                ),
                ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Appliquer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_isLoading && _transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadTransactions(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64),
            SizedBox(height: 16),
            Text('Aucune transaction trouvée'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // En-tête avec informations
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_totalItems transactions'),
              Text('Page $_currentPage/$_totalPages'),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            itemCount:
                _transactions.length + (_currentPage < _totalPages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _transactions.length) {
                // Bouton charger plus
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => _loadTransactions(append: true),
                      child: const Text('Charger plus'),
                    ),
                  ),
                );
              }

              final transaction = _transactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final amount = (transaction['amount'] as num).toDouble();
    final date = DateTime.parse(transaction['date']);
    final description = transaction['description'] ?? '';
    final type = transaction['type'] ?? '';
    final isCredit = amount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            isCredit ? Icons.add : Icons.remove,
            color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(FormatUtils.formatDateTime(date)),
            if (type.isNotEmpty)
              Text(
                type.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Text(
          FormatUtils.formatCurrency(amount.abs()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        isThreeLine: type.isNotEmpty,
      ),
    );
  }
}
