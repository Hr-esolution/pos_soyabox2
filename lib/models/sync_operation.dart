class SyncOperation {
  final int? id;
  final String operationType; // create, update, delete
  final String entityType; // User, Order, Product
  final String data; // JSON string
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? errorMessage;
  final int retryCount;
  final DateTime? nextRetryAt;
  final bool isCompleted;

  SyncOperation({
    this.id,
    required this.operationType,
    required this.entityType,
    required this.data,
    this.metadata,
    required this.createdAt,
    this.syncedAt,
    this.errorMessage,
    this.retryCount = 0,
    this.nextRetryAt,
    this.isCompleted = false,
  });

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      operationType: json['operation_type'],
      entityType: json['entity_type'],
      data: json['data'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at']) : null,
      errorMessage: json['error_message'],
      retryCount: json['retry_count'] ?? 0,
      nextRetryAt: json['next_retry_at'] != null ? DateTime.parse(json['next_retry_at']) : null,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation_type': operationType,
      'entity_type': entityType,
      'data': data,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'error_message': errorMessage,
      'retry_count': retryCount,
      'next_retry_at': nextRetryAt?.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}