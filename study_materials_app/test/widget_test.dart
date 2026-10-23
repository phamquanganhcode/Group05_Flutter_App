import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kiểm thử giao diện Widget Test (Tag Chip & Responsive Layout)
/// Phụ trách: Nguyễn Phúc Bình An (MSSV: 2051063858)
void main() {
  group('Kiểm thử Giao diện Widget (Nguyễn Phúc Bình An)', () {
    testWidgets('Kiểm thử hiển thị và tương tác với FilterChip Tag', (WidgetTester tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: FilterChip(
                    label: const Text('#Flutter'),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        isSelected = selected;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Kiểm tra nhãn hiển thị đúng
      expect(find.text('#Flutter'), findsOneWidget);

      // Thao tác bấm chọn chip tag
      await tester.tap(find.byType(FilterChip));
      await tester.pump();

      // Kiểm tra trạng thái đã được chọn
      expect(isSelected, true);
    });

    testWidgets('Kiểm thử Responsive LayoutBuilder điều chỉnh giao diện', (WidgetTester tester) async {
      // Thiết lập kích thước màn hình nhỏ (Mobile < 600px)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return const Text('Layout Mobile (1 cột)');
                } else {
                  return const Text('Layout Web/Desktop (đa cột)');
                }
              },
            ),
          ),
        ),
      );

      expect(find.text('Layout Mobile (1 cột)'), findsOneWidget);
      expect(find.text('Layout Web/Desktop (đa cột)'), findsNothing);

      // Đổi kích thước màn hình sang Web/Desktop (>= 850px)
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return const Text('Layout Mobile (1 cột)');
                } else {
                  return const Text('Layout Web/Desktop (đa cột)');
                }
              },
            ),
          ),
        ),
      );

      expect(find.text('Layout Web/Desktop (đa cột)'), findsOneWidget);
      expect(find.text('Layout Mobile (1 cột)'), findsNothing);

      // Reset kích thước
      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
