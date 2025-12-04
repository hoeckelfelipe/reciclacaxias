// Define o modelo de dados para um ponto de coleta.
class PontoColeta {
  final int? id;
  final String nome;      // Ex: "Supermercado XYZ"
  final String endereco;  // Ex: "Rua das Flores, 123"
  final String materiais; // Ex: "Aceita pilhas, baterias e eletrônicos"
  final String? url;

  PontoColeta({
    this.id,
    required this.nome,
    required this.endereco,
    required this.materiais,
    this.url,
  });

  // Converte o objeto para um Map, para ser salvo no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'materiais': materiais,
      'url': url,
    };
  }

  // Converte um Map (vindo do banco) para um objeto PontoColeta.
  factory PontoColeta.fromMap(Map<String, dynamic> map) {
    return PontoColeta(
      id: map['id'],
      nome: map['nome'],
      endereco: map['endereco'],
      materiais: map['materiais'],
      url: map['url'],
    );
  }
}