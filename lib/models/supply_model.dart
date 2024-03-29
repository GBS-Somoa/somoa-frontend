class Supply {
  final String id;
  final String type;
  final String name;
  final Map<String, dynamic> details;
  final Map<String, dynamic> limit;
  final int? supplyAmountTmp;

  Supply({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    required this.limit,
    this.supplyAmountTmp,
  });

  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
        id: json['id'],
        type: json['type'],
        name: json['name'],
        details: json['details'],
        limit: json['limit'],
        supplyAmountTmp: json['supplyAmountTmp']);
  }
}
