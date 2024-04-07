import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/region.dropdown.dart';

void main() {
  group(RegionDropdown, () {
    const regions = [
      Region(id: 1, name: 'Region 1'),
      Region(id: 2, name: 'Region 2'),
      Region(id: 3, name: 'Region 3'),
    ];

    testWidgets('displays correct label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionDropdown(
              regions: regions,
            ),
          ),
        ),
      );

      final labelFinder = find.text('Region');
      expect(labelFinder, findsOneWidget);
    });

    testWidgets('displays correct dropdown menu entries',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionDropdown(
              regions: regions,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownMenu<Region>));
      await tester.pump();

      final dropdownMenuEntry1Finder = find.text(regions[0].name!);
      final dropdownMenuEntry2Finder = find.text(regions[1].name!);
      final dropdownMenuEntry3Finder = find.text(regions[2].name!);

      expect(dropdownMenuEntry1Finder, findsAny);
      expect(dropdownMenuEntry2Finder, findsAny);
      expect(dropdownMenuEntry3Finder, findsAny);
    });

    testWidgets('calls onSelected', (WidgetTester tester) async {
      Region? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegionDropdown(
              regions: regions,
              onSelected: (region) {
                selectedValue = region;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownMenu<Region>));
      await tester.pump();

      await tester.tap(find.text(regions[1].name!).last);
      await tester.pump();

      expect(selectedValue, regions[1]);
    });
  });
}
