class User {
  final String id;
  final String name;
  final String role;

  User({required this.id, required this.name, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], role: json['role']);
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class Account {
  final String id;
  final String type;
  final String currency;
  final int balance;

  Account({
    required this.id,
    required this.type,
    required this.currency,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      type: json['type'],
      currency: json['currency'],
      balance: json['balance'],
    );
  }
}

class Transaction {
  final String id;
  final DateTime date;
  final int amount;
  final String currency;
  final String description;
  final String status;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.currency,
    required this.description,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      currency: json['currency'],
      description: json['description'],
      status: json['status'],
    );
  }
}

class TransactionsResponse {
  final List<Transaction> items;
  final int page;
  final int pageSize;
  final int total;

  TransactionsResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      items: (json['items'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList(),
      page: json['page'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }
}

class TransferRequest {
  final String fromAccountId;
  final String toAccountNumber;
  final int amount;
  final String currency;
  final String note;

  TransferRequest({
    required this.fromAccountId,
    required this.toAccountNumber,
    required this.amount,
    required this.currency,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromAccountId': fromAccountId,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
      'currency': currency,
      'note': note,
    };
  }
}

class TransferResponse {
  final String transferId;
  final String status;
  final DateTime estimatedCompletion;

  TransferResponse({
    required this.transferId,
    required this.status,
    required this.estimatedCompletion,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      transferId: json['transferId'],
      status: json['status'],
      estimatedCompletion: DateTime.parse(json['estimatedCompletion']),
    );
  }
}
