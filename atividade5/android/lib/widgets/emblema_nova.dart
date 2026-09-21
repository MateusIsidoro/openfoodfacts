import 'package:flutter/material.dart';

class EmblemaNova extends StatelessWidget {
  final int? grupoNova;

  const EmblemaNova({
    super.key,
    required this.grupoNova,
  });

  Color _obterCorNova(int? grupo) {
    switch (grupo) {
      case 1:
        return const Color(0xFF2E7D32);
      case 2:
        return const Color(0xFFF57F17);
      case 3:
        return const Color(0xFFE65100);
      case 4:
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  String _obterDescricaoNova(int? grupo) {
    switch (grupo) {
      case 1:
        return 'Alimentos in natura ou minimamente processados';
      case 2:
        return 'Ingredientes culinários processados';
      case 3:
        return 'Alimentos processados';
      case 4:
        return 'Alimentos ultraprocessados';
      default:
        return 'Classificação NOVA não informada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color corNova = _obterCorNova(grupoNova);
    final String textoGrupo = grupoNova != null ? 'NOVA $grupoNova' : 'NOVA ?';
    final String descricaoGrupo = _obterDescricaoNova(grupoNova);

    return Tooltip(
      message: descricaoGrupo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: corNova.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: corNova, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers, size: 14, color: corNova),
            const SizedBox(width: 4),
            Text(
              textoGrupo,
              style: TextStyle(
                color: corNova,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
