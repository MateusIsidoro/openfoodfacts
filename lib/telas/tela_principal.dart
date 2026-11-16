import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../servicos/servico_open_food_facts.dart';
import '../widgets/cartao_produto.dart';
import 'tela_comparador.dart';
import 'tela_detalhes_produto.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final TextEditingController _controladorPesquisa = TextEditingController();
  List<Product> _listaProdutosResultados = [];
  final List<Product> _listaProdutosFavoritos = [];
  final List<Product> _listaProdutosComparados = [];
  bool _estahCarregando = false;
  String? _mensagemErro;
  int _indiceAbaAtual = 0;
  String _termoAtual = 'cafe';

  final List<String> _categoriasRapidas = [
    'Café',
    'Leite',
    'Biscoito',
    'Chocolate',
    'Suco',
    'Iogurte',
    'Arroz',
    'Massa',
  ];

  final Map<String, String> _codigosExemplo = {
    '7891000100103': 'Leite Condensado Moça',
    '7891021006125': 'Café Melitta',
    '7894900011517': 'Coca-Cola',
    '3017620422003': 'Nutella Hazelnuts',
    '7891000000014': 'Achocolatado Nescau',
  };

  @override
  void initState() {
    super.initState();
    _realizarPesquisaTexto(_termoAtual);
  }

  @override
  void dispose() {
    _controladorPesquisa.dispose();
    super.dispose();
  }

  Future<void> _realizarPesquisaTexto(String termo) async {
    final String termoLimpo = termo.trim();
    if (termoLimpo.isEmpty) return;

    // Se o usuário digitou um código numérico EAN (ex: 7891000100103), redireciona automaticamente para busca por EAN
    if (RegExp(r'^\d{8,14}$').hasMatch(termoLimpo)) {
      return _realizarBuscaCodigoBarras(termoLimpo);
    }

    setState(() {
      _estahCarregando = true;
      _mensagemErro = null;
      _termoAtual = termoLimpo;
    });

    final List<Product> resultados = await ServicoOpenFoodFacts.buscarProdutosPorTexto(termoLimpo);

    setState(() {
      _estahCarregando = false;
      _listaProdutosResultados = resultados;
      if (resultados.isEmpty) {
        _mensagemErro = 'Nenhum produto encontrado para "$termo".';
      }
    });
  }

  Future<void> _realizarBuscaCodigoBarras(String codigoBarras) async {
    if (codigoBarras.trim().isEmpty) return;

    setState(() {
      _estahCarregando = true;
      _mensagemErro = null;
    });

    final Product? produtoEncontrado = await ServicoOpenFoodFacts.buscarProdutoPorCodigoBarras(codigoBarras);

    setState(() {
      _estahCarregando = false;
      if (produtoEncontrado != null) {
        _listaProdutosResultados = [produtoEncontrado];
      } else {
        _listaProdutosResultados = [];
        _mensagemErro = 'Nenhum produto encontrado com o código $codigoBarras.';
      }
    });
  }

  void _alternarFavorito(Product produto) {
    setState(() {
      final bool jaExiste = _listaProdutosFavoritos.any((p) => p.barcode == produto.barcode);
      if (jaExiste) {
        _listaProdutosFavoritos.removeWhere((p) => p.barcode == produto.barcode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${produto.productName ?? "Produto"} removido dos favoritos.'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _listaProdutosFavoritos.add(produto);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${produto.productName ?? "Produto"} adicionado aos favoritos!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  bool _verificarSeEhFavorito(Product produto) {
    return _listaProdutosFavoritos.any((p) => p.barcode == produto.barcode);
  }

  bool _verificarSeEstaNoComparador(Product produto) {
    return _listaProdutosComparados.any((p) => p.barcode == produto.barcode);
  }

  void _alternarComparador(Product produto) {
    setState(() {
      final bool jaExiste = _verificarSeEstaNoComparador(produto);
      if (jaExiste) {
        _listaProdutosComparados.removeWhere((p) => p.barcode == produto.barcode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${produto.productName ?? "Produto"} removido do comparador.'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (_listaProdutosComparados.length >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O comparador suporta no máximo 2 produtos. Remova um antes de adicionar outro.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        _listaProdutosComparados.add(produto);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _listaProdutosComparados.length == 2
                  ? 'Comparador pronto! Vá para a aba Comparar.'
                  : '${produto.productName ?? "Produto"} adicionado ao comparador. Adicione mais 1.',
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            action: _listaProdutosComparados.length == 2
                ? SnackBarAction(
                    label: 'Comparar',
                    textColor: Colors.white,
                    onPressed: () => setState(() => _indiceAbaAtual = 2),
                  )
                : null,
          ),
        );
      }
    });
  }

  void _abrirDialogoSimuladorLeitor() {
    final TextEditingController controladorCodigoCustomizado = TextEditingController();

    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.green),
              SizedBox(width: 8),
              Text('Simulador de Leitor EAN'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecione um código de barras de teste ou digite um EAN:'),
                const SizedBox(height: 12),
                ..._codigosExemplo.entries.map((par) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.barcode_reader, size: 20),
                    title: Text(par.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('EAN: ${par.key}'),
                    onTap: () {
                      Navigator.pop(contextDialog);
                      _controladorPesquisa.text = par.key;
                      _realizarBuscaCodigoBarras(par.key);
                    },
                  );
                }),
                const Divider(),
                TextField(
                  controller: controladorCodigoCustomizado,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Digite um código EAN customizado',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final String textoDigitado = controladorCodigoCustomizado.text.trim();
                Navigator.pop(contextDialog);
                if (textoDigitado.isNotEmpty) {
                  _controladorPesquisa.text = textoDigitado;
                  _realizarBuscaCodigoBarras(textoDigitado);
                }
              },
              child: const Text('Buscar EAN'),
            ),
          ],
        );
      },
    );
  }

  void _abrirTelaDetalhes(Product produto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesProduto(
          produto: produto,
          ehFavorito: _verificarSeEhFavorito(produto),
          aoAlternarFavorito: _alternarFavorito,
          estaNoComparador: _verificarSeEstaNoComparador(produto),
          aoAlternarComparador: _alternarComparador,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  Widget _construirAbaPesquisa() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.green.shade700,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controladorPesquisa,
                        onSubmitted: (termo) => _realizarPesquisaTexto(termo),
                        decoration: InputDecoration(
                          hintText: 'Buscar produto ou EAN...',
                          prefixIcon: const Icon(Icons.search, color: Colors.green),
                          suffixIcon: _controladorPesquisa.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _controladorPesquisa.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                    ),
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    onPressed: _abrirDialogoSimuladorLeitor,
                    tooltip: 'Simulador de Leitor de Código de Barras',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categoriasRapidas.length,
                  itemBuilder: (context, index) {
                    final String categoria = _categoriasRapidas[index];
                    final bool ehSelecionada = _termoAtual.toLowerCase() == categoria.toLowerCase();
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(categoria),
                        selected: ehSelecionada,
                        selectedColor: Colors.amber.shade600,
                        labelStyle: TextStyle(
                          color: ehSelecionada ? Colors.white : Colors.black87,
                          fontWeight: ehSelecionada ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selecionado) {
                          if (selecionado) {
                            _controladorPesquisa.text = categoria;
                            _realizarPesquisaTexto(categoria);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _estahCarregando
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 16),
                      Text('Consultando Open Food Facts...'),
                    ],
                  ),
                )
              : _mensagemErro != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _mensagemErro!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _listaProdutosResultados.length,
                      itemBuilder: (context, index) {
                        final Product produtoAtual = _listaProdutosResultados[index];
                        return CartaoProduto(
                          produto: produtoAtual,
                          ehFavorito: _verificarSeEhFavorito(produtoAtual),
                          aoClicar: () => _abrirTelaDetalhes(produtoAtual),
                          aoAlternarFavorito: () => _alternarFavorito(produtoAtual),
                          estaNoComparador: _verificarSeEstaNoComparador(produtoAtual),
                          aoAlternarComparador: () => _alternarComparador(produtoAtual),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _construirAbaFavoritos() {
    if (_listaProdutosFavoritos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum produto favoritado ainda.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Toque no ícone de coração nos produtos para salvá-los.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _listaProdutosFavoritos.length,
      itemBuilder: (context, index) {
        final Product produtoFavorito = _listaProdutosFavoritos[index];
        return CartaoProduto(
          produto: produtoFavorito,
          ehFavorito: true,
          aoClicar: () => _abrirTelaDetalhes(produtoFavorito),
          aoAlternarFavorito: () => _alternarFavorito(produtoFavorito),
          estaNoComparador: _verificarSeEstaNoComparador(produtoFavorito),
          aoAlternarComparador: () => _alternarComparador(produtoFavorito),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'NutriBusca',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'NutriBusca Open Food Facts',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.restaurant_menu, size: 40, color: Colors.green),
                children: [
                  const Text('Aplicativo desenvolvido para consulta nutricional e informações de alimentos utilizando a biblioteca openfoodfacts no Flutter.'),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _indiceAbaAtual,
        children: [
          _construirAbaPesquisa(),
          _construirAbaFavoritos(),
          TelaComparador(
            produtosComparados: _listaProdutosComparados,
            aoRemoverProduto: (produto) => _alternarComparador(produto),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAbaAtual,
        onDestinationSelected: (novoIndice) {
          setState(() {
            _indiceAbaAtual = novoIndice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: Colors.green),
            label: 'Pesquisar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: Colors.red),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows),
            selectedIcon: Icon(Icons.compare_arrows, color: Colors.blue),
            label: 'Comparar',
          ),
        ],
      ),
    );
  }
}
