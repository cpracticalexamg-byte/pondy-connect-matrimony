import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/core/widgets/app_button.dart';
import 'package:pondy_connect_matrimony/core/widgets/pill_chip.dart';
import 'package:pondy_connect_matrimony/core/widgets/pondy_logo.dart';

void main() {
  testWidgets('Pondy Connect Matrimony smoke test and core widgets test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PondyLogo(size: 80),
          ),
        ),
      ),
    );

    // Verify logo renders
    expect(find.byType(PondyLogo), findsOneWidget);
  });

  testWidgets('AppButton renders and responds to tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Continue',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('PillChip renders and toggles selection', (WidgetTester tester) async {
    bool selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PillChip(
                label: 'Myself',
                isSelected: selected,
                onTap: () {
                  setState(() {
                    selected = !selected;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Myself'), findsOneWidget);
    await tester.tap(find.text('Myself'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
  });
}
