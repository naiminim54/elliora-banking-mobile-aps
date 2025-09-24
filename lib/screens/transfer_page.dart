import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../utils/format.dart';
import '../utils/validate.dart';

/// Page de virement reproduisant le design Next.js
class TransferPage extends StatefulWidget {
  final List<dynamic> accounts;
  final String? selectedAccountId;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const TransferPage({
    super.key,
    required this.accounts,
    this.selectedAccountId,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _fromAccountId;
  bool _isLoading = false;
  String _step = 'form'; // 'form', 'confirmation', 'success'
  String? _transferId;

  @override
  void initState() {
    super.initState();
    _fromAccountId =
        widget.selectedAccountId ??
        (widget.accounts.isNotEmpty ? widget.accounts[0]['id'] : null);
  }

  @override
  void dispose() {
    _toAccountController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _fromAccount {
    return widget.accounts.firstWhere(
      (account) => account['id'] == _fromAccountId,
      orElse: () => null,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final balance = _fromAccount?['balance']?.toDouble() ?? 0;

    final validation = ValidationUtils.validateTransfer(
      amount,
      balance,
      _toAccountController.text.trim(),
    );

    if (!validation.isValid) {
      for (final error in validation.errors) {
        Fluttertoast.showToast(
          msg: error,
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      }
      return;
    }

    setState(() => _step = 'confirmation');
  }

  Future<void> _confirmTransfer() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.transfer(
        fromAccountId: _fromAccountId!,
        toAccountNumber: _toAccountController.text.trim(),
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      _transferId = response['transferId'];
      setState(() {
        _step = 'success';
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: 'Virement initié avec succès !',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() => _isLoading = false);

      Fluttertoast.showToast(
        msg: e is ApiException ? e.message : 'Erreur lors du virement',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  void _handleSuccess() {
    widget.onSuccess();
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              if (_step != 'success')
                IconButton(
                  onPressed: _step == 'form'
                      ? widget.onBack
                      : () => setState(() => _step = 'form'),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (_step != 'success') const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.send,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nouveau virement',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Transférez des fonds entre vos comptes ou vers un bénéficiaire',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildStepContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 'confirmation':
        return _buildConfirmationStep();
      case 'success':
        return _buildSuccessStep();
      default:
        return _buildFormStep();
    }
  }

  Widget _buildFormStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection du compte source
          Text(
            'Compte source',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _fromAccountId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            items: widget.accounts.map<DropdownMenuItem<String>>((account) {
              return DropdownMenuItem<String>(
                value: account['id'],
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatAccountType(account['type'] ?? ''),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            FormatUtils.formatCurrency(
                              account['balance']?.toDouble() ?? 0,
                              account['currency'] ?? 'FCFA',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _fromAccountId = value),
            validator: (value) =>
                value == null ? 'Sélectionnez un compte' : null,
          ),

          const SizedBox(height: 24),

          // Compte bénéficiaire
          Text(
            'Compte bénéficiaire',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _toAccountController,
            decoration: InputDecoration(
              hintText: 'Numéro de compte du bénéficiaire',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Entrez le numéro de compte bénéficiaire';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Montant
          Text(
            'Montant à transférer',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixText: _fromAccount?['currency'] ?? 'FCFA',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Entrez le montant';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Montant invalide';
              }
              return null;
            },
          ),

          if (_fromAccount != null) ...[
            const SizedBox(height: 8),
            Text(
              'Maximum disponible: ${FormatUtils.formatCurrency(_fromAccount!['balance']?.toDouble() ?? 0, _fromAccount!['currency'] ?? 'FCFA')}',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
            ),
          ],

          const SizedBox(height: 24),

          // Description
          Text(
            'Motif du virement (optionnel)',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Remboursement, cadeau, facture...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 32),

          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Continuer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final currency = _fromAccount?['currency'] ?? 'FCFA';

    return Column(
      children: [
        // Icône d'avertissement
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning, color: AppColors.warning, size: 40),
        ),

        const SizedBox(height: 24),

        Text(
          'Confirmer le virement',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Vérifiez attentivement les informations ci-dessous',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 32),

        // Résumé
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildConfirmationRow(
                'Compte source',
                _formatAccountType(_fromAccount?['type'] ?? ''),
              ),
              const Divider(),
              _buildConfirmationRow('Bénéficiaire', _toAccountController.text),
              const Divider(),
              _buildConfirmationRow(
                'Montant',
                FormatUtils.formatCurrency(amount, currency),
              ),
              if (_descriptionController.text.trim().isNotEmpty) ...[
                const Divider(),
                _buildConfirmationRow(
                  'Motif',
                  _descriptionController.text.trim(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Boutons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 'form'),
                child: const Text('Retour'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmTransfer,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Confirmer le virement'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final currency = _fromAccount?['currency'] ?? 'FCFA';

    return Column(
      children: [
        // Icône de succès
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, color: AppColors.success, size: 60),
        ),

        const SizedBox(height: 24),

        Text(
          'Virement initié !',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Votre demande de virement a été transmise avec succès',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Détails du transfert
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildConfirmationRow('ID de transaction', _transferId ?? 'N/A'),
              const Divider(),
              _buildConfirmationRow('Statut', 'En cours de traitement'),
              const Divider(),
              _buildConfirmationRow(
                'Montant',
                FormatUtils.formatCurrency(amount, currency),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleSuccess,
            child: const Text('Retour au dashboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAccountType(String type) {
    switch (type.toLowerCase()) {
      case 'current':
        return 'Compte Courant';
      case 'savings':
        return 'Compte Épargne';
      default:
        return type;
    }
  }
}
