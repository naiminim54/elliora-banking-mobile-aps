import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

/// Widget de carte de crédit reproduisant exactement le design Next.js
class CreditCardWidget extends StatefulWidget {
  final Map<String, dynamic> account;
  final VoidCallback? onViewTransactions;
  final VoidCallback? onTransfer;

  const CreditCardWidget({
    super.key,
    required this.account,
    this.onViewTransactions,
    this.onTransfer,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget> {
  bool _isBalanceVisible = false;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  String _formatCardNumber(String accountId) {
    final cleaned = accountId.replaceAll(RegExp(r'\D'), '');
    final padded = cleaned.padRight(16, '0');
    return padded
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();
  }

  LinearGradient _getCardGradient(String type) {
    switch (type.toLowerCase()) {
      case 'current':
        return AppColors.cardCurrentGradient;
      case 'savings':
        return AppColors.cardSavingsGradient;
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B7280), Color(0xFF374151), Color(0xFF1F2937)],
        );
    }
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

  @override
  Widget build(BuildContext context) {
    final balance = widget.account['balance']?.toDouble() ?? 0.0;
    final currency = widget.account['currency'] ?? 'FCFA';
    final accountType = widget.account['type'] ?? 'current';
    final accountId = widget.account['id'] ?? '';

    final maskedBalance = _isBalanceVisible
        ? FormatUtils.formatCurrency(balance, currency)
        : '••• •••';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Carte de crédit principale
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: _getCardGradient(accountType),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Contenu de la carte
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header de la carte
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatAccountType(accountType).toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Elliora Banking',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          // Bouton pour masquer/afficher le solde
                          GestureDetector(
                            onTap: _toggleBalanceVisibility,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isBalanceVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Numéro de carte
                      Text(
                        _formatCardNumber(accountId),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 3.2,
                          fontFamily: 'monospace',
                        ),
                      ),

                      const Spacer(),

                      // Bottom section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solde disponible',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                maskedBalance,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currency,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Puce de la carte
                Positioned(
                  top: 24,
                  right: 24,
                  child: Container(
                    width: 32,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFACC15).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                // Overlay subtil
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onViewTransactions,
                  icon: const Icon(Icons.list_alt, size: 16),
                  label: Text(
                    'Transactions',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: balance > 0 ? widget.onTransfer : null,
                  icon: const Icon(Icons.send, size: 16),
                  label: Text(
                    'Virement',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Avertissement solde insuffisant
          if (balance <= 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Solde insuffisant pour effectuer un virement',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
