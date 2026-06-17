class Plan {
  String id;
  String title;
  String description;
  DateTime? date;  // Date the plan is scheduled for

  Plan({
    required this.id,
    required this.title,
    required this.description,
    this.date,
  });

  // Convert Plan to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),  // Send date as ISO string
    };
  }

  // Create Plan from JSON response
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}
