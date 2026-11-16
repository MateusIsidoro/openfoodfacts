import 'package:openfoodfacts/openfoodfacts.dart';

class ServicoOpenFoodFacts {
  static void inicializar() {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'NutriBusca - Aplicativo Escolar Flutter',
      url: 'https://pub.dev/packages/openfoodfacts',
    );
  }

  static Future<List<Product>> buscarProdutosPorTexto(String termo) async {
    inicializar();
    final String termoLimpo = termo.trim();
    if (termoLimpo.isEmpty) return [];

    final fields = [
      ProductField.BARCODE,
      ProductField.NAME,
      ProductField.BRANDS,
      ProductField.NUTRISCORE,
      ProductField.IMAGE_FRONT_URL,
      ProductField.IMAGE_FRONT_SMALL_URL,
      ProductField.NUTRITION,
      ProductField.NUTRIMENTS,
      ProductField.INGREDIENTS_TEXT,
      ProductField.NOVA_GROUP,
      ProductField.ECOSCORE_GRADE,
      ProductField.CATEGORIES_TAGS_IN_LANGUAGES,
      ProductField.QUANTITY,
    ];

    // Estratégia 1: Busca direta por palavras-chave
    try {
      final configuracaoBusca = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [termoLimpo]),
          const PageSize(size: 20),
        ],
        language: OpenFoodFactsLanguage.PORTUGUESE,
        fields: fields,
        version: ProductQueryVersion.latestVersion,
      );

      final resultadoBusca = await OpenFoodAPIClient.searchProducts(
        null,
        configuracaoBusca,
      );

      if (resultadoBusca.products != null && resultadoBusca.products!.isNotEmpty) {
        return resultadoBusca.products!;
      }
    } catch (_) {}

    // Estratégia 2: Fallback por filtro de categorias (caso a busca direta sofra oscilação 503 da API)
    try {
      final configuracaoCategoria = ProductSearchQueryConfiguration(
        parametersList: [
          TagFilter.fromType(
            tagFilterType: TagFilterType.CATEGORIES,
            contains: true,
            tagName: termoLimpo,
          ),
          const PageSize(size: 20),
        ],
        language: OpenFoodFactsLanguage.PORTUGUESE,
        fields: fields,
        version: ProductQueryVersion.latestVersion,
      );

      final resultadoCat = await OpenFoodAPIClient.searchProducts(
        null,
        configuracaoCategoria,
      );

      if (resultadoCat.products != null && resultadoCat.products!.isNotEmpty) {
        return resultadoCat.products!;
      }
    } catch (_) {}

    return [];
  }

  static Future<Product?> buscarProdutoPorCodigoBarras(String codigoBarras) async {
    inicializar();
    try {
      final configuracaoProduto = ProductQueryConfiguration(
        codigoBarras,
        language: OpenFoodFactsLanguage.PORTUGUESE,
        fields: [
          ProductField.BARCODE,
          ProductField.NAME,
          ProductField.BRANDS,
          ProductField.NUTRISCORE,
          ProductField.IMAGE_FRONT_URL,
          ProductField.IMAGE_FRONT_SMALL_URL,
          ProductField.NUTRITION,
          ProductField.NUTRIMENTS,
          ProductField.INGREDIENTS_TEXT,
          ProductField.NOVA_GROUP,
          ProductField.ECOSCORE_GRADE,
          ProductField.CATEGORIES_TAGS_IN_LANGUAGES,
          ProductField.QUANTITY,
        ],
        version: ProductQueryVersion.latestVersion,
      );

      final resultadoProduto = await OpenFoodAPIClient.getProductV3(
        configuracaoProduto,
      );

      if (resultadoProduto.status == ProductResultV3.statusSuccess) {
        return resultadoProduto.product;
      }
      return null;
    } catch (erro) {
      return null;
    }
  }
}
