class Registro {
  final String id;
  final String userId;
  final String titulo;
  final String artista;
  final String local;
  final String descricao;
  final DateTime dataEvento;
  final DateTime dataCriacao;
  final double? latitude;
  final double? longitude;
  final String? imagemPath;
  final bool synced;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Registro({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.artista,
    required this.local,
    required this.descricao,
    required this.dataEvento,
    required this.dataCriacao,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.imagemPath,
    this.synced = false,
    this.deletedAt,
  });

  bool get temLocalizacao => latitude != null && longitude != null;

  bool get excluido => deletedAt != null;

  static String chaveDia(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';

  String get chaveDoEvento => chaveDia(dataEvento);

  Registro copyWith({
    String? titulo,
    String? artista,
    String? local,
    String? descricao,
    DateTime? dataEvento,
    double? latitude,
    double? longitude,
    String? imagemPath,
    bool? synced,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Registro(
      id: id,
      userId: userId,
      titulo: titulo ?? this.titulo,
      artista: artista ?? this.artista,
      local: local ?? this.local,
      descricao: descricao ?? this.descricao,
      dataEvento: dataEvento ?? this.dataEvento,
      dataCriacao: dataCriacao,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagemPath: imagemPath ?? this.imagemPath,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'titulo': titulo,
      'artista': artista,
      'local': local,
      'descricao': descricao,
      'dataEvento': dataEvento.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'imagemPath': imagemPath,
      'synced': synced ? 1 : 0,
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'] as String,
      userId: map['userId'] as String,
      titulo: (map['titulo'] as String?) ?? '',
      artista: (map['artista'] as String?) ?? '',
      local: (map['local'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      dataEvento: DateTime.parse(map['dataEvento'] as String),
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      imagemPath: map['imagemPath'] as String?,
      synced: (map['synced'] as int? ?? 0) == 1,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      deletedAt: map['deletedAt'] == null ? null : DateTime.parse(map['deletedAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'titulo': titulo,
      'artista': artista,
      'local': local,
      'descricao': descricao,
      'dataEvento': dataEvento.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'imagemPath': imagemPath,
      'synced': true,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Registro.fromFirestore(String id, String userId, Map<String, dynamic> map) {
    final agora = DateTime.now();
    return Registro(
      id: id,
      userId: userId,
      titulo: (map['titulo'] as String?) ?? '',
      artista: (map['artista'] as String?) ?? '',
      local: (map['local'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      dataEvento: DateTime.tryParse((map['dataEvento'] as String?) ?? '') ?? agora,
      dataCriacao: DateTime.tryParse((map['dataCriacao'] as String?) ?? '') ?? agora,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      imagemPath: map['imagemPath'] as String?,
      synced: true,
      updatedAt: DateTime.tryParse((map['updatedAt'] as String?) ?? '') ?? agora,
    );
  }
}
