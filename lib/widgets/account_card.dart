import 'package:flutter/material.dart';
import '../widgets/credit_card_widget.dart';

/// Widget carte de compte - Wrapper vers CreditCardWidget
class AccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final VoidCallback? onViewTransactions;
  final VoidCallback? onTransfer;

  const AccountCard({
    super.key,
    required this.account,
    this.onViewTransactions,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return CreditCardWidget(
      account: account,
      onViewTransactions: onViewTransactions,
      onTransfer: onTransfer,
    );
  }
}
