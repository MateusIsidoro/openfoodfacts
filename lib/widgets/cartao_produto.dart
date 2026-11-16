import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'emblema_nutriscore.dart';
import 'emblema_nova.dart';

class CartaoProduto extends StatelessWidget {
  final Product produto;
  final VoidCallback aoClicar;
  final VoidCallback aoAlternarFavorito;
  final bool ehFavorito;
  final bool estaNoComparador;
  final VoidCallback? aoAlternarComparador;

  const CartaoProduto({
    super.key,
    required this.produto,
    required this.aoClicar,
    required this.aoAlternarFavorito,
    required this.ehFavorito,
    this.estaNoComparador = false,
    this.aoAlternarComparador,
  });

  @override
  Widget build(BuildContext context) {
    final String? urlImagem = produto.imageFrontSmallUrl ?? produto.imageFrontUrl;
    final String nomeProduto = produto.productName ?? 'Produto Sem Nome';
    final String marcaProduto = produto.brands ?? 'Marca Desconhecida';
    final String codigoBarras = produto.barcode ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
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
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.fastfood,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeProduto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      codigoBarras.isNotEmpty ? '$marcaProduto • EAN: $codigoBarras' : marcaProduto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        EmblemaNutriscore(
                          pontuacaoNutriscore: produto.nutriscore,
                          tamanhoFonte: 10,
                        ),
                        EmblemaNova(
                          grupoNova: produto.novaGroup,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  ehFavorito ? Icons.favorite : Icons.favorite_border,
                  color: ehFavorito ? Colors.red : Colors.grey,
                ),
                onPressed: aoAlternarFavorito,
                tooltip: ehFavorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
              ),
              if (aoAlternarComparador != null)
                IconButton(
                  icon: Icon(
                    estaNoComparador ? Icons.compare_arrows : Icons.add_chart,
                    color: estaNoComparador ? Colors.blue : Colors.grey,
                  ),
                  onPressed: aoAlternarComparador,
                  tooltip: estaNoComparador ? 'Remover do comparador' : 'Adicionar ao comparador',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
