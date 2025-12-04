// Define o modelo de dados para um item do guia de reciclagem.
class GuiaReciclagem {
  final int? id;
  final String material; // Ex: "Plástico", "Vidro", "Papel"
  final String descricao;  // Ex: "Garrafas PET, embalagens de shampoo..."
  final String icone;      // Nome de um ícone para exibir (ex: 'plastic_bottle_icon')
  final String imagemExemplo;

  GuiaReciclagem({
    this.id,
    required this.material,
    required this.descricao,
    required this.icone,
    required this.imagemExemplo,
  });

  // Converte o objeto para um Map, para ser salvo no banco de dados.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'material': material,
      'descricao': descricao,
      'icone': icone,
      'imagemExemplo': imagemExemplo,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Converte um Map (vindo do banco) para um objeto GuiaReciclagem.
  factory GuiaReciclagem.fromMap(Map<String, dynamic> map) {
    return GuiaReciclagem(
      id: map['id'] is int ? map['id'] as int : (map['id'] is int? map['id'] as int : null),
      material: (map['material'] ?? '') as String,
      descricao: (map['descricao'] ?? '') as String,
      icone: (map['icone'] ?? '') as String,
      imagemExemplo: (map['imagemExemplo'] ?? '') as String,
    );
  }
}