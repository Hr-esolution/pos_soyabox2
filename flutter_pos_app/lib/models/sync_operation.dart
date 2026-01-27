import 'dart:convert';

class SyncOperation {
  final String? id;
  final String entityType;
  final String operationType; // create, update, delete
  final Map<String, dynamic> data;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? errorMessage;
  final int retryCount;
  final DateTime? nextRetryAt;
  final bool isCompleted;

  SyncOperation({
    this.id,
    required this.entityType,
    required this.operationType,
    required this.data,
    this.metadata,
    required this.createdAt,
    this.syncedAt,
    this.errorMessage,
    this.retryCount = 0,
    this.nextRetryAt,
    this.isCompleted = false,
  });

  SyncOperation copyWith({
    String? id,
    String? entityType,
    String? operationType,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? syncedAt,
    String? errorMessage,
    int? retryCount,
    DateTime? nextRetryAt,
    bool? isCompleted,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operationType: operationType ?? this.operationType,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'operation_type': operationType,
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

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'],
      entityType: map['entity_type'] ?? '',
      operationType: map['operation_type'] ?? '',
      data: map['data'] as Map<String, dynamic> ?? {},
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      syncedAt: map['synced_at'] != null 
          ? DateTime.parse(map['synced_at']) 
          : null,
      errorMessage: map['error_message'],
      retryCount: map['retry_count']?.toInt() ?? 0,
      nextRetryAt: map['next_retry_at'] != null 
          ? DateTime.parse(map['next_retry_at']) 
          : null,
      isCompleted: map['is_completed'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncOperation.fromJson(String source) => SyncOperation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SyncOperation(id: $id, entityType: $entityType, operationType: $operationType, data: $data, metadata: $metadata, createdAt: $createdAt, syncedAt: $syncedAt, errorMessage: $errorMessage, retryCount: $retryCount, nextRetryAt: $nextRetryAt, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SyncOperation &&
        other.id == id &&
        other.entityType == entityType &&
        other.operationType == operationType &&
        other.data.toString() == data.toString() &&
        other.metadata.toString() == metadata.toString() &&
        other.createdAt == createdAt &&
        other.syncedAt == syncedAt &&
        other.errorMessage == errorMessage &&
        other.retryCount == retryCount &&
        other.nextRetryAt == nextRetryAt &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      entityType,
      operationType,
      data.toString(),
      metadata?.toString(),
      createdAt,
      syncedAt,
      errorMessage,
      retryCount,
      nextRetryAt,
      isCompleted,
    );
  }
}