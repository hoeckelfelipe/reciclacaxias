import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir links e email
import 'database_helper.dart';
import 'guia_detalhe_page.dart';
import 'guia_reciclagem.dart';
import 'ponto_coleta.dart';

void main() => runApp(const AppReciclagem());

class AppReciclagem extends StatelessWidget {
  const AppReciclagem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recicla-Caxias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green.shade600,
          brightness: Brightness.light,
          primary: Colors.green.shade700,
          secondary: Colors.teal.shade400,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class MaterialVisual {
  final IconData icon;
  final Color color;
  MaterialVisual(this.icon, this.color);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  
  List<GuiaReciclagem> _todosGuias = [];
  List<GuiaReciclagem> _guiasFiltrados = [];
  bool _isLoadingGuias = true;
  final TextEditingController _searchController = TextEditingController();

  // Lista das categorias que devem aparecer sempre
  final List<String> _categoriasPrincipais = [
    'Plástico', 
    'Papel', 
    'Vidro', 
    'Metal', 
    'Orgânico'
  ];

  late Future<List<PontoColeta>> pontosColeta;

  @override
  void initState() {
    super.initState();
    _carregarGuias();
    pontosColeta = dbHelper.getPontosColeta();
  }

  void _carregarGuias() async {
    final guias = await dbHelper.getGuias();
    setState(() {
      _todosGuias = guias;
      // MUDANÇA: Inicialmente mostra APENAS as categorias principais
      _guiasFiltrados = guias.where((g) => _categoriasPrincipais.contains(g.material)).toList();
      _isLoadingGuias = false;
    });
  }

  void _filtrarGuias(String query) {
    if (query.isEmpty) {
      // Se a busca estiver vazia, volta a mostrar apenas as principais
      setState(() {
        _guiasFiltrados = _todosGuias.where((g) => _categoriasPrincipais.contains(g.material)).toList();
      });
    } else {
      // Se tiver busca, procura em TUDO (incluindo isopor, lâmpada, etc.)
      setState(() {
        _guiasFiltrados = _todosGuias
            .where((guia) =>
                guia.material.toLowerCase().contains(query.toLowerCase()) ||
                guia.descricao.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _fazerDenuncia() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'alo@codeca.com.br',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Denúncia de Descarte Irregular - App Reciclagem',
        'body': 'Olá, gostaria de relatar um descarte irregular.\n\nEndereço do local:\n\nDescrição do problema:\n\n(Anexe fotos se possível)'
      }),
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      if (mounted) _mostrarAviso('Não foi possível abrir o app de e-mail.');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  MaterialVisual _getVisualParaMaterial(String material) {
    switch (material.toLowerCase()) {
      case 'plástico':
      case 'isopor': 
        return MaterialVisual(Icons.local_drink, Colors.red);
      
      case 'papel':
      case 'tetra pak': 
        return MaterialVisual(Icons.article, Colors.blue);
      
      case 'vidro':
        return MaterialVisual(Icons.wine_bar, Colors.green);
      
      case 'metal':
      case 'pilhas e baterias': 
      case 'eletrônicos':
        return MaterialVisual(Icons.set_meal, Colors.yellow.shade800);
      
      case 'orgânico':
      case 'caixa de pizza': 
      case 'espelhos e louças': 
        return MaterialVisual(Icons.eco, Colors.brown);
      
      case 'lâmpadas':
      case 'óleo de cozinha':
      case 'remédios':
        return MaterialVisual(Icons.warning_amber_rounded, Colors.orange);
        
      default:
        return MaterialVisual(Icons.help_outline, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guia de Reciclagem'),
          actions: [
            IconButton(
              icon: const Icon(Icons.report_problem, color: Colors.amberAccent),
              tooltip: 'Denunciar Descarte Irregular',
              onPressed: _fazerDenuncia,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.list_alt_rounded), text: 'Guia de Materiais'),
              Tab(icon: Icon(Icons.location_on_rounded), text: 'Pontos de Coleta'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGuiaTab(),
            _buildPontoColetaList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuiaTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filtrarGuias,
            decoration: InputDecoration(
              labelText: 'Buscar material...',
              hintText: 'Ex: Isopor, Pizza, Lâmpada...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: _isLoadingGuias
              ? const Center(child: CircularProgressIndicator())
              : _guiasFiltrados.isEmpty
                  ? const Center(child: Text("Nenhum material encontrado."))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      itemCount: _guiasFiltrados.length,
                      itemBuilder: (context, index) {
                        final guia = _guiasFiltrados[index];
                        final visual = _getVisualParaMaterial(guia.material);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GuiaDetalhePage(guia: guia),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: visual.color,
                                    foregroundColor: Colors.white,
                                    child: Icon(visual.icon, size: 28),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          guia.material,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          guia.descricao,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPontoColetaList() {
    return FutureBuilder<List<PontoColeta>>(
      future: pontosColeta,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Nenhum ponto de coleta encontrado"));
        }

        final pontosData = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: pontosData.length,
          itemBuilder: (context, index) {
            final ponto = pontosData[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: InkWell(
                onTap: () => _abrirLink(ponto),
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ponto.nome,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_pin, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ponto.endereco)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.recycling, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ponto.materiais, style: const TextStyle(fontStyle: FontStyle.italic))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _abrirLink(PontoColeta ponto) async {
    Uri? uri;
    if (ponto.url != null && ponto.url!.isNotEmpty) {
      uri = Uri.tryParse(ponto.url!);
    } else if (ponto.endereco.toLowerCase() != 'espalhados por toda a cidade') {
      final query = Uri.encodeComponent('${ponto.nome}, ${ponto.endereco}, Caxias do Sul, RS');
      uri = Uri.parse('geo:0,0?q=$query');
    }

    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível abrir o link para "${ponto.nome}"')),
          );
        }
      }
    }
  }
}