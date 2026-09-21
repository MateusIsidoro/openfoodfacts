import 'package:flutter/material.dart';

class EmblemaNutriscore extends StatelessWidget {
  final String? pontuacaoNutriscore;
  final double tamanhoFonte;

  const EmblemaNutriscore({
    super.key,
    required this.pontuacaoNutriscore,
    this.tamanhoFonte = 14,
  });

  Color _obterCorPorLetra(String letra) {
    switch (letra.toUpperCase()) {
      case 'A':
        return const Color(0xFF008B4C);
      case 'B':
        return const Color(0xFF85BB2F);
      case 'C':
        return const Color(0xFFFFC900);
      case 'D':
        return const Color(0xFFEE8100);
      case 'E':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String letraValor = pontuacaoNutriscore != null && pontuacaoNutriscore!.isNotEmpty
        ? pontuacaoNutriscore!.toUpperCase()
        : '?';
    final Color corFundo = _obterCorPorLetra(letraValor);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tamanhoFonte * 0.7,
        vertical: tamanhoFonte * 0.3,
      ),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: corFundo.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NUTRI-SCORE ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: tamanhoFonte * 0.75,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            letraValor,
            style: TextStyle(
              color: Colors.white,
              fontSize: tamanhoFonte,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
