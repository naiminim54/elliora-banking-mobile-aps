import 'package:flutter/material.dart';
import '../utils/format.dart';

/// Modal de confirmation de virement
class TransferConfirmDialog extends StatelessWidget {
  final Map<String, dynamic> fromAccount;
  final String toAccountNumber;
  final double amount;
  final VoidCallback onConfirm;

  const TransferConfirmDialog({
    super.key,
    required this.fromAccount,
    required this.toAccountNumber,
    required this.amount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Confirmation de virement'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Veuillez vérifier les détails de votre virement :',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Compte source
          _buildDetailRow(
            'Compte source',
            '${fromAccount['type']} (${fromAccount['id']})',
          ),
          const SizedBox(height: 8),

          // Compte bénéficiaire
          _buildDetailRow('Compte bénéficiaire', toAccountNumber),
          const SizedBox(height: 8),

          // Montant
          _buildDetailRow(
            'Montant',
            FormatUtils.formatCurrency(amount),
            highlight: true,
          ),
          const SizedBox(height: 8),

          // Solde après opération
          _buildDetailRow(
            'Solde après opération',
            FormatUtils.formatCurrency(
              (fromAccount['balance'] as num).toDouble() - amount,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Cette opération est irréversible.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.green.shade700 : Colors.black,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Méthode statique pour afficher la modal
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> fromAccount,
    required String toAccountNumber,
    required double amount,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => TransferConfirmDialog(
        fromAccount: fromAccount,
        toAccountNumber: toAccountNumber,
        amount: amount,
        onConfirm: onConfirm,
      ),
    );
  }
}
