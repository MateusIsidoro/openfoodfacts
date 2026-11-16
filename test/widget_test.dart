import 'package:flutter_test/flutter_test.dart';
import 'package:atividade5/main.dart';

void main() {
  testWidgets('NutriBusca app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AplicativoNutriBusca());

    // Verify that the title 'NutriBusca' is rendered.
    expect(find.text('NutriBusca'), findsOneWidget);

    // Verify navigation tabs exist
    expect(find.text('Pesquisar'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Comparar'), findsOneWidget);

    // Switch to 'Comparar' tab
    await tester.tap(find.text('Comparar'));
    await tester.pump();

    // Verify empty state in comparator
    expect(find.textContaining('Nenhum produto adicionado'), findsOneWidget);
  });
}

