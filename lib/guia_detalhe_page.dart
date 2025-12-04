import 'package:flutter/material.dart';
import 'guia_reciclagem.dart';

class _MaterialVisual {
  final IconData icon;
  final Color color;
  _MaterialVisual(this.icon, this.color);
}

class GuiaDetalhePage extends StatelessWidget {
  final GuiaReciclagem guia;

  const GuiaDetalhePage({super.key, required this.guia});

  _MaterialVisual _getVisualParaMaterial(String material) {
    switch (material.toLowerCase()) {
      case 'plástico':
        return _MaterialVisual(Icons.local_drink, Colors.red);
      case 'papel':
        return _MaterialVisual(Icons.article, Colors.blue);
      case 'vidro':
        return _MaterialVisual(Icons.wine_bar, Colors.green);
      case 'metal':
        return _MaterialVisual(Icons.set_meal, Colors.yellow.shade700);
      case 'orgânico':
        return _MaterialVisual(Icons.eco, Colors.brown);
      default:
        return _MaterialVisual(Icons.help_outline, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visual = _getVisualParaMaterial(guia.material);

    return Scaffold(
      appBar: AppBar(
        title: Text(guia.material),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (guia.imagemExemplo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  guia.imagemExemplo,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image_not_supported, size: 64));
                  },
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: visual.color,
                  foregroundColor: Colors.white,
                  child: Icon(visual.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    guia.material,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              guia.descricao,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}