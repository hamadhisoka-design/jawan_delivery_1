class TopupRequest {
  final String id;
  final String driverEmail;
  final double amount;
  final String method;
  final DateTime time;

  String status; // pending | approved | rejected

  TopupRequest({
    required this.id,
    required this.driverEmail,
    required this.amount,
    required this.method,
    required this.time,
    this.status = "pending",
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'driverEmail': driverEmail,
        'amount': amount,
        'method': method,
        'time': time.toIso8601String(),
        'status': status,
      };

  factory TopupRequest.fromJson(Map<String, dynamic> json) => TopupRequest(
        id: json['id'] as String,
        driverEmail: json['driverEmail'] as String,
        amount: (json['amount'] as num).toDouble(),
        method: json['method'] as String,
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
        status: json['status'] as String? ?? 'pending',
      );
}
