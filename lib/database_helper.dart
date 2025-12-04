import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'guia_reciclagem.dart';
import 'ponto_coleta.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'reciclagem.db');
    return await openDatabase(
      path,
      version: 5, // <-- MUDANÇA: Versão 5 para forçar a atualização
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE guias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material TEXT,
        descricao TEXT,
        icone TEXT,
        imagemExemplo TEXT 
      )
    ''');

    await db.execute('''
      CREATE TABLE pontos_coleta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        endereco TEXT,
        materiais TEXT,
        url TEXT 
      )
    ''');
    
    await _inserirDadosIniciais(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE guias ADD COLUMN imagemExemplo TEXT");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE pontos_coleta ADD COLUMN url TEXT");
    }
    if (oldVersion < 4) {
      await db.update(
        'pontos_coleta',
        {'url': 'https://www.instagram.com/codecacaxias/'},
        where: 'nome = ?',
        whereArgs: ['Troca Solidária'],
      );
    }
    // Versão 5: Força a reinserção dos guias para adicionar os novos
    if (oldVersion < 5) {
      await db.delete('guias'); // Limpa para refazer
      await _inserirGuias(db);
    }
  }

  Future<void> _inserirDadosIniciais(Database db) async {
    await _inserirGuias(db);
    await _inserirPontos(db);
  }

  // Separei a função de guias para organizar melhor
  Future<void> _inserirGuias(Database db) async {
    // 1. Categorias Básicas
    await db.insert('guias', GuiaReciclagem(material: 'Plástico', descricao: 'Garrafas PET, potes, embalagens de limpeza, sacolas e tubos.', icone: 'bottle', imagemExemplo: 'assets/images/plastico.png').toMap());
    await db.insert('guias', GuiaReciclagem(material: 'Papel', descricao: 'Jornais, revistas, papelão, folhas, envelopes.', icone: 'paper', imagemExemplo: 'assets/images/papel.png').toMap());
    await db.insert('guias', GuiaReciclagem(material: 'Vidro', descricao: 'Garrafas, potes de conserva, frascos. Cuidado ao manusear.', icone: 'glass', imagemExemplo: 'assets/images/vidro.png').toMap());
    await db.insert('guias', GuiaReciclagem(material: 'Metal', descricao: 'Latas de alumínio e aço, arames, pregos, tampas.', icone: 'metal', imagemExemplo: 'assets/images/metal.png').toMap());
    await db.insert('guias', GuiaReciclagem(material: 'Orgânico', descricao: 'Restos de comida, cascas, erva-mate, borra de café.', icone: 'organic', imagemExemplo: 'assets/images/organico.png').toMap());

    // 2. Itens Específicos (Novos!)
    await db.insert('guias', GuiaReciclagem(material: 'Isopor', descricao: 'SIM, é reciclável! Deve estar limpo e seco. Vai no contêiner AMARELO (Seletivo).', icone: 'isopor', imagemExemplo: 'assets/images/plastico.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Tetra Pak', descricao: 'Caixinhas de leite, suco e molhos. Lave bem e amasse. Vai no contêiner AMARELO.', icone: 'box', imagemExemplo: 'assets/images/papel.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Caixa de Pizza', descricao: 'Se tiver gordura: ORGÂNICO (Verde). Apenas a tampa limpa pode ir no Seletivo.', icone: 'pizza', imagemExemplo: 'assets/images/organico.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Espelhos e Louças', descricao: 'NÃO são recicláveis. Embrulhe bem para não ferir o coletor e coloque no ORGÂNICO.', icone: 'broken', imagemExemplo: 'assets/images/vidro.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Lâmpadas', descricao: 'NÃO coloque no lixo comum. Leve a pontos de descarte (mercados que vendem ou Ecoponto).', icone: 'light', imagemExemplo: 'assets/images/vidro.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Pilhas e Baterias', descricao: 'Lixo tóxico. Entregue em farmácias, mercados ou no Ecoponto da Codeca.', icone: 'battery', imagemExemplo: 'assets/images/metal.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Óleo de Cozinha', descricao: 'Guarde em garrafa PET bem fechada e entregue nas UBSs ou Ecoponto.', icone: 'oil', imagemExemplo: 'assets/images/organico.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Eletrônicos', descricao: 'Celulares, cabos e computadores velhos. Leve ao Ecoponto da Codeca.', icone: 'tech', imagemExemplo: 'assets/images/metal.png').toMap());
    
    await db.insert('guias', GuiaReciclagem(material: 'Remédios', descricao: 'Vencidos ou não usados: entregue em farmácias ou UBSs. Nunca jogue na pia.', icone: 'pill', imagemExemplo: 'assets/images/organico.png').toMap());
  }

  Future<void> _inserirPontos(Database db) async {
    final List<Map<String, dynamic>> pontosExistentes = await db.query('pontos_coleta');
    if (pontosExistentes.isEmpty) {
      await db.insert('pontos_coleta', PontoColeta(nome: 'Coleta Seletiva (Contêineres Amarelos)', endereco: 'Espalhados por toda a cidade', materiais: 'Principal método para descarte de Plástico, Papel, Vidro e Metal. Procure o contêiner amarelo mais próximo.').toMap());
      await db.insert('pontos_coleta', PontoColeta(nome: 'Ecoponto da CODECA', endereco: 'RSC-453, n° 31.382, Bairro Centenário', materiais: 'Móveis, pneus, eletrônicos e doações. Funciona de seg a sex (8h-17h) e sáb (7h-13h).').toMap());
      await db.insert('pontos_coleta', PontoColeta(nome: 'Eco Prata - Prataviera Shopping', endereco: 'Av. Júlio de Castilhos, 1914, Mezanino - Centro', materiais: 'Tampinhas plásticas, raio-x, pilhas, baterias, eletrônicos e lâmpadas.').toMap());
      await db.insert('pontos_coleta', PontoColeta(nome: 'Troca Solidária', endereco: 'Diversos bairros (ver no Instagram da Codeca)', materiais: 'Troca de recicláveis por alimentos. Programa com datas e locais específicos.', url: 'https://www.instagram.com/codecacaxias/').toMap());
    }
  }

  Future<List<GuiaReciclagem>> getGuias() async {
    final db = await database;
    final maps = await db.query('guias');
    return maps.map((map) => GuiaReciclagem.fromMap(map)).toList();
  }

  Future<List<PontoColeta>> getPontosColeta() async {
    final db = await database;
    final maps = await db.query('pontos_coleta');
    return maps.map((map) => PontoColeta.fromMap(map)).toList();
  }
}