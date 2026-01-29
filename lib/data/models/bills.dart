import 'package:dorm_of_decents/data/models/expense_response.dart';

class BillsResponse {
  final ExpenseMonth month;
  final List<Bill> bills;
  final List<Profile> profiles;
  final UserProfile userProfile;

  const BillsResponse({
    required this.month,
    required this.bills,
    required this.profiles,
    required this.userProfile,
  });

  factory BillsResponse.fromJson(Map<String, dynamic> json) {
    return BillsResponse(
      month: json['month'],
      bills: json['bills'],
      profiles: json['profiles'],
      userProfile: json['userProfile'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "month": month,
      "bills": bills,
      "profiles": profiles,
      "userProfile": userProfile,
    };
  }

  double totalBills() {
    double total = 0.0;
    for (var bill in bills) {
      total += bill.amount;
    }
    return total;
  }

  double electricityBills() {
    double total = 0.0;
    for (var bill in bills) {
      if (bill.billType == "electricity") {
        total += bill.amount;
      }
    }
    return total;
  }

  double internetBills() {
    double total = 0.0;
    for (var bill in bills) {
      if (bill.billType == "internet") {
        total += bill.amount;
      }
    }
    return total;
  }

  double gasBills() {
    double total = 0.0;
    for (var bill in bills) {
      if (bill.billType == "gas") {
        total += bill.amount;
      }
    }
    return total;
  }
}

class UserProfile {
  final String name;
  final String role;

  UserProfile({required this.name, required this.role});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(name: json['name'], role: json['role']);
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "role": role};
  }
}

class Profile {
  final String id;
  final String name;

  const Profile({required this.id, required this.name});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name};
  }
}

class Bill {
  final String id;
  final String billType;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final Map<String, dynamic> profiles;

  const Bill({
    required this.id,
    required this.billType,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.profiles,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      billType: json['bill_type'],
      amount: json['amount'] ?? 0.0,
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime(json['created_at']),
      profiles: Map<String, dynamic>.from(json['profiles']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "bill_type": billType,
      "amount": amount,
      "description": description,
      "date": date.toIso8601String(),
      "created_at": createdAt.toIso8601String(),
      "profiles": profiles,
    };
  }
}
