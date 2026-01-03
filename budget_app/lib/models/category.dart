class Category {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' or 'expense'
  final String icon;
  final String color;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Catégories par défaut pour les dépenses
  static List<Map<String, String>> get defaultExpenseCategories => [
    {'name': 'Nourriture', 'icon': 'restaurant', 'color': '#FF6B6B'},
    {'name': 'Transport', 'icon': 'directions_car', 'color': '#4ECDC4'},
    {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '#A855F7'},
    {'name': 'Factures', 'icon': 'receipt', 'color': '#FFA726'},
    {'name': 'Santé', 'icon': 'medical_services', 'color': '#EF4444'},
    {'name': 'Loisirs', 'icon': 'sports_esports', 'color': '#8B5CF6'},
    {'name': 'Éducation', 'icon': 'school', 'color': '#3B82F6'},
    {'name': 'Autres', 'icon': 'more_horiz', 'color': '#6B7280'},
  ];

  // Catégories par défaut pour les revenus
  static List<Map<String, String>> get defaultIncomeCategories => [
    {'name': 'Salaire', 'icon': 'work', 'color': '#00D09C'},
    {'name': 'Freelance', 'icon': 'laptop', 'color': '#4ECDC4'},
    {'name': 'Investissement', 'icon': 'trending_up', 'color': '#A855F7'},
    {'name': 'Cadeau', 'icon': 'card_giftcard', 'color': '#FFA726'},
    {'name': 'Remboursement', 'icon': 'replay', 'color': '#3B82F6'},
    {'name': 'Autres', 'icon': 'more_horiz', 'color': '#6B7280'},
  ];
}

