import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../widgets/emblema_nutriscore.dart';
import '../widgets/emblema_nova.dart';

class TelaDetalhesProduto extends StatefulWidget {
  final Product produto;
  final bool ehFavorito;
  final Function(Product) aoAlternarFavorito;
  final bool estaNoComparador;
  final Function(Product)? aoAlternarComparador;

  const TelaDetalhesProduto({
    super.key,
    required this.produto,
    required this.ehFavorito,
    required this.aoAlternarFavorito,
    this.estaNoComparador = false,
    this.aoAlternarComparador,
  });

  @override
  State<TelaDetalhesProduto> createState() => _TelaDetalhesProdutoState();
}

class _TelaDetalhesProdutoState extends State<TelaDetalhesProduto> {
  late bool _estahFavoritado;
  late bool _estahNoComparador;

  @override
  void initState() {
    super.initState();
    _estahFavoritado = widget.ehFavorito;
    _estahNoComparador = widget.estaNoComparador;
  }

  Widget _criarLinhaNutricional(String titulo, String valor, String unidade, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '$valor $unidade',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatarValorNutriente(double? valor) {
    if (valor == null) return 'N/I';
    return valor.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final Product produtoItem = widget.produto;
    final String? urlImagem = produtoItem.imageFrontUrl ?? produtoItem.imageFrontSmallUrl;
    final String nomeProduto = produtoItem.productName ?? 'Produto Sem Nome';
    final String marcaProduto = produtoItem.brands ?? 'Marca Não Informada';
    final String codigoBarras = produtoItem.barcode ?? 'Não disponível';
    final String quantidade = produtoItem.quantity ?? 'Desconhecida';
    final String ingredientes = produtoItem.ingredientsText ?? 'Lista de ingredientes não informada.';
    final Nutriments? tabelaNutricional = produtoItem.nutriments;
    final String? ecoscoreGrade = produtoItem.ecoscoreGrade;

    final double? energiaKcal = tabelaNutricional?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams);
    final double? gorduras = tabelaNutricional?.getValue(Nutrient.fat, PerSize.oneHundredGrams);
    final double? gordurasSaturadas = tabelaNutricional?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams);
    final double? carboidratos = tabelaNutricional?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams);
    final double? acucares = tabelaNutricional?.getValue(Nutrient.sugars, PerSize.oneHundredGrams);
    final double? proteinas = tabelaNutricional?.getValue(Nutrient.proteins, PerSize.oneHundredGrams);
    final double? sal = tabelaNutricional?.getValue(Nutrient.salt, PerSize.oneHundredGrams);
    final double? sodio = tabelaNutricional?.getValue(Nutrient.sodium, PerSize.oneHundredGrams);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Produto'),
        actions: [
          if (widget.aoAlternarComparador != null)
            IconButton(
              icon: Icon(
                _estahNoComparador ? Icons.compare_arrows : Icons.add_chart,
                color: _estahNoComparador ? Colors.amber : null,
              ),
              tooltip: _estahNoComparador ? 'Remover da Comparação' : 'Adicionar à Comparação',
              onPressed: () {
                setState(() {
                  _estahNoComparador = !_estahNoComparador;
                });
                widget.aoAlternarComparador!(produtoItem);
              },
            ),
          IconButton(
            icon: Icon(
              _estahFavoritado ? Icons.favorite : Icons.favorite_border,
              color: _estahFavoritado ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _estahFavoritado = !_estahFavoritado;
              });
              widget.aoAlternarFavorito(produtoItem);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 240,
              color: Colors.grey.shade100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: urlImagem != null && urlImagem.isNotEmpty
                        ? Image.network(
                            urlImagem,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.fastfood, size: 80, color: Colors.grey),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(Icons.fastfood, size: 80, color: Colors.grey),
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomeProduto,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Marca: $marcaProduto',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.qr_code, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'EAN: $codigoBarras | Quantidade: $quantidade',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Classificações de Qualidade e Processamento',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              EmblemaNutriscore(
                                pontuacaoNutriscore: produtoItem.nutriscore,
                                tamanhoFonte: 14,
                              ),
                              EmblemaNova(
                                grupoNova: produtoItem.novaGroup,
                              ),
                              if (ecoscoreGrade != null && ecoscoreGrade.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.teal, width: 1.2),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.eco, size: 14, color: Colors.teal),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ECO-SCORE ${ecoscoreGrade.toUpperCase()}',
                                        style: const TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tabela Nutricional',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Por 100g / 100ml',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          _criarLinhaNutricional('Energia / Calorias', _formatarValorNutriente(energiaKcal), 'kcal', Colors.orange),
                          _criarLinhaNutricional('Gorduras Totais', _formatarValorNutriente(gorduras), 'g', Colors.redAccent),
                          _criarLinhaNutricional('Gorduras Saturadas', _formatarValorNutriente(gordurasSaturadas), 'g', Colors.deepOrange),
                          _criarLinhaNutricional('Carboidratos', _formatarValorNutriente(carboidratos), 'g', Colors.amber),
                          _criarLinhaNutricional('Açúcares', _formatarValorNutriente(acucares), 'g', Colors.purple),
                          _criarLinhaNutricional('Proteínas', _formatarValorNutriente(proteinas), 'g', Colors.blue),
                          _criarLinhaNutricional('Sal', _formatarValorNutriente(sal), 'g', Colors.teal),
                          _criarLinhaNutricional('Sódio', _formatarValorNutriente(sodio), 'g', Colors.cyan),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingredientes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ingredientes,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
