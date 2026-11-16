import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../widgets/emblema_nutriscore.dart';
import '../widgets/emblema_nova.dart';

class TelaComparador extends StatelessWidget {
  final List<Product> produtosComparados;
  final Function(Product) aoRemoverProduto;

  const TelaComparador({
    super.key,
    required this.produtosComparados,
    required this.aoRemoverProduto,
  });

  String _fmt(double? valor, {int casas = 1}) {
    if (valor == null) return 'N/I';
    return valor.toStringAsFixed(casas);
  }

  Color _corComparacao(double? a, double? b, bool menorEMelhor) {
    if (a == null || b == null) return Colors.grey.shade300;
    if (a == b) return Colors.grey.shade300;
    final bool aEhMelhor = menorEMelhor ? a < b : a > b;
    return aEhMelhor ? Colors.green.shade100 : Colors.red.shade100;
  }

  Widget _cabecalhoProduto(Product produto, VoidCallback aoRemover) {
    final String? urlImagem =
        produto.imageFrontSmallUrl ?? produto.imageFrontUrl;
    final String nome = produto.productName ?? 'Produto Sem Nome';
    final String marca = produto.brands ?? '';

    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade100,
                child: urlImagem != null && urlImagem.isNotEmpty
                    ? Image.network(
                        urlImagem,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fastfood,
                          size: 36,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.fastfood, size: 36, color: Colors.grey),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: aoRemover,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          nome,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        if (marca.isNotEmpty)
          Text(
            marca,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        const SizedBox(height: 4),
        EmblemaNutriscore(
          pontuacaoNutriscore: produto.nutriscore,
          tamanhoFonte: 10,
        ),
        const SizedBox(height: 2),
        EmblemaNova(grupoNova: produto.novaGroup),
      ],
    );
  }

  Widget _linhaComparacao({
    required String rotulo,
    required String valorA,
    required String valorB,
    required Color corA,
    required Color corB,
    required Color corIndicador,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: corA,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                alignment: Alignment.centerRight,
                child: Text(
                  valorA,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.grey.shade200,
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: corIndicador,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        rotulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: corB,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                alignment: Alignment.centerLeft,
                child: Text(
                  valorB,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (produtosComparados.isEmpty) {
      return _construirEstadoVazio(0);
    }
    if (produtosComparados.length == 1) {
      return _construirEstadoVazio(1);
    }

    final Product a = produtosComparados[0];
    final Product b = produtosComparados[1];
    final Nutriments? nutA = a.nutriments;
    final Nutriments? nutB = b.nutriments;

    double? get(Nutriments? n, Nutrient nutrient) =>
        n?.getValue(nutrient, PerSize.oneHundredGrams);

    final energiaA = get(nutA, Nutrient.energyKCal);
    final energiaB = get(nutB, Nutrient.energyKCal);
    final gordA = get(nutA, Nutrient.fat);
    final gordB = get(nutB, Nutrient.fat);
    final satA = get(nutA, Nutrient.saturatedFat);
    final satB = get(nutB, Nutrient.saturatedFat);
    final carbA = get(nutA, Nutrient.carbohydrates);
    final carbB = get(nutB, Nutrient.carbohydrates);
    final acuA = get(nutA, Nutrient.sugars);
    final acuB = get(nutB, Nutrient.sugars);
    final proA = get(nutA, Nutrient.proteins);
    final proB = get(nutB, Nutrient.proteins);
    final salA = get(nutA, Nutrient.salt);
    final salB = get(nutB, Nutrient.salt);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com os dois produtos
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _cabecalhoProduto(a, () => aoRemoverProduto(a))),
                const SizedBox(width: 8),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _cabecalhoProduto(b, () => aoRemoverProduto(b))),
              ],
            ),
            const SizedBox(height: 20),

            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendaItem(Colors.green.shade100, 'Melhor'),
                const SizedBox(width: 16),
                _legendaItem(Colors.red.shade100, 'Pior'),
                const SizedBox(width: 16),
                _legendaItem(Colors.grey.shade300, 'Igual / N/I'),
              ],
            ),
            const SizedBox(height: 12),

            // Tabela de comparação
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    color: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: Text(
                        'Comparação por 100g / 100ml',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  _linhaComparacao(
                    rotulo: 'Calorias (kcal)',
                    valorA: '${_fmt(energiaA)} kcal',
                    valorB: '${_fmt(energiaB)} kcal',
                    corA: _corComparacao(energiaA, energiaB, true),
                    corB: _corComparacao(energiaB, energiaA, true),
                    corIndicador: Colors.orange,
                  ),
                  _linhaComparacao(
                    rotulo: 'Gorduras Totais (g)',
                    valorA: _fmt(gordA),
                    valorB: _fmt(gordB),
                    corA: _corComparacao(gordA, gordB, true),
                    corB: _corComparacao(gordB, gordA, true),
                    corIndicador: Colors.redAccent,
                  ),
                  _linhaComparacao(
                    rotulo: 'Gord. Saturadas (g)',
                    valorA: _fmt(satA),
                    valorB: _fmt(satB),
                    corA: _corComparacao(satA, satB, true),
                    corB: _corComparacao(satB, satA, true),
                    corIndicador: Colors.deepOrange,
                  ),
                  _linhaComparacao(
                    rotulo: 'Carboidratos (g)',
                    valorA: _fmt(carbA),
                    valorB: _fmt(carbB),
                    corA: _corComparacao(carbA, carbB, true),
                    corB: _corComparacao(carbB, carbA, true),
                    corIndicador: Colors.amber,
                  ),
                  _linhaComparacao(
                    rotulo: 'Açúcares (g)',
                    valorA: _fmt(acuA),
                    valorB: _fmt(acuB),
                    corA: _corComparacao(acuA, acuB, true),
                    corB: _corComparacao(acuB, acuA, true),
                    corIndicador: Colors.purple,
                  ),
                  _linhaComparacao(
                    rotulo: 'Proteínas (g)',
                    valorA: _fmt(proA),
                    valorB: _fmt(proB),
                    corA: _corComparacao(proA, proB, false),
                    corB: _corComparacao(proB, proA, false),
                    corIndicador: Colors.blue,
                  ),
                  _linhaComparacao(
                    rotulo: 'Sal (g)',
                    valorA: _fmt(salA),
                    valorB: _fmt(salB),
                    corA: _corComparacao(salA, salB, true),
                    corB: _corComparacao(salB, salA, true),
                    corIndicador: Colors.teal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text(
              '🟢 Verde = valor mais saudável  •  🔴 Vermelho = valor menos saudável\n(exceto Proteínas: maior é melhor)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendaItem(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _construirEstadoVazio(int quantidadeAtual) {
    final String mensagem = quantidadeAtual == 0
        ? 'Nenhum produto adicionado.\nPesquise e toque em ⊕ para adicionar até 2 produtos.'
        : 'Falta 1 produto.\nPesquise e toque em ⊕ para adicionar o segundo.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              quantidadeAtual == 0
                  ? Icons.compare_arrows
                  : Icons.add_circle_outline,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            if (quantidadeAtual > 0) ...[
              const SizedBox(height: 20),
              ...List.generate(
                quantidadeAtual,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Chip(
                    avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    label: Text(
                      produtosComparados[i].productName ?? 'Produto ${i + 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => aoRemoverProduto(produtosComparados[i]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
