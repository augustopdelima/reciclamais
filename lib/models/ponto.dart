class PontoColeta {
  final String id;
  final String nome;
  final String endereco;
  final double latitude;
  final double longitude;
  final String? telefone;
  final String? horario;
  final List<String> materiais; // Lista de materiais coletados

  PontoColeta({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    this.telefone,
    this.horario,
    required this.materiais,
  });

  factory PontoColeta.fromFirestore(Map<String, dynamic> data, String id) {
    return PontoColeta(
      id: id,
      nome: data['nome'] ?? '',
      endereco: data['endereco'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      telefone: data['telefone'],
      horario: data['horario'],
      materiais: List<String>.from(data['materiais'] ?? []),
    );
  }
}
