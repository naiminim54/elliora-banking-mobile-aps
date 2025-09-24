/// Fonctions de validation (montant, etc.)
class ValidationUtils {
  /// Valide un montant de virement
  static String? validateTransferAmount(double? amount, double accountBalance) {
    if (amount == null || amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }

    if (amount > accountBalance) {
      return 'Solde insuffisant';
    }

    return null; // Pas d'erreur
  }

  /// Valide un numéro de compte bénéficiaire
  static String? validateAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.trim().isEmpty) {
      return 'Le numéro de compte est obligatoire';
    }

    // Validation simple : au moins 10 caractères alphanumériques
    if (accountNumber.trim().length < 10) {
      return 'Le numéro de compte doit contenir au moins 10 caractères';
    }

    return null; // Pas d'erreur
  }

  /// Valide les champs de login
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Le nom d\'utilisateur est obligatoire';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    return null;
  }

  /// Valide un montant saisi (format string)
  static String? validateAmountInput(String? amountStr) {
    if (amountStr == null || amountStr.trim().isEmpty) {
      return 'Le montant est obligatoire';
    }

    final amount = double.tryParse(
      amountStr.replaceAll(RegExp(r'[^\d.-]'), ''),
    );
    if (amount == null) {
      return 'Montant invalide';
    }

    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }

    return null;
  }

  /// Valide une transaction de virement complète
  static ValidationResult validateTransfer(
    double amount,
    double balance,
    String toAccountNumber,
  ) {
    final errors = <String>[];

    // Validation du montant
    if (amount <= 0) {
      errors.add('Le montant doit être supérieur à 0');
    }

    if (amount > balance) {
      errors.add('Solde insuffisant');
    }

    // Validation du compte bénéficiaire
    if (toAccountNumber.trim().isEmpty) {
      errors.add('Le numéro de compte bénéficiaire est obligatoire');
    } else if (toAccountNumber.trim().length < 10) {
      errors.add('Le numéro de compte doit contenir au moins 10 caractères');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}

/// Résultat de validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}
