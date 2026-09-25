import 'dart:io';

import 'package:budget/database/tables.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Danh mục mặc định cho sinh viên', () {
    List<TransactionCategory> categories = defaultCategories();

    // Khóa chính và thứ tự không bị trùng
    expect(categories.map((c) => c.categoryPk).toSet().length,
        categories.length);
    expect(categories.map((c) => c.order).toSet().length, categories.length);

    // Các danh mục mới tồn tại với đúng loại chi tiêu/thu nhập
    Map<String, bool> expected = {
      "Tiền trọ": false,
      "Đóng học phí": false,
      "Trà sữa": false,
      "Giáo trình": false,
      "Tiền gia đình gửi": true,
      "Học bổng": true,
    };
    expected.forEach((name, income) {
      TransactionCategory category =
          categories.firstWhere((c) => c.name == name);
      expect(category.income, income);
    });

    // Biểu tượng của mọi danh mục đều có trong assets
    for (TransactionCategory category in categories) {
      expect(File("assets/categories/${category.iconName}").existsSync(), true,
          reason: category.iconName);
    }
  });
}
