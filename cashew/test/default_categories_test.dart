import 'dart:convert';
import 'dart:io';

import 'package:budget/database/tables.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Danh mục mặc định cho sinh viên', () {
    // Chưa khởi tạo EasyLocalization nên .tr() trả về chính khóa dịch
    List<TransactionCategory> categories = defaultCategories();

    // Khóa chính và thứ tự không bị trùng
    expect(categories.map((c) => c.categoryPk).toSet().length,
        categories.length);
    expect(categories.map((c) => c.order).toSet().length, categories.length);

    Map en = jsonDecode(
        File("assets/translations/generated/en.json").readAsStringSync());
    Map vi = jsonDecode(
        File("assets/translations/generated/vi.json").readAsStringSync());

    // Các danh mục mới: loại chi tiêu/thu nhập và bản dịch tiếng Việt
    Map<String, (bool, String)> expected = {
      "default-category-rent": (false, "Tiền trọ"),
      "default-category-tuition": (false, "Đóng học phí"),
      "default-category-milk-tea": (false, "Trà sữa"),
      "default-category-textbooks": (false, "Giáo trình"),
      "default-category-family-allowance": (true, "Tiền gia đình gửi"),
      "default-category-scholarship": (true, "Học bổng"),
    };
    expected.forEach((key, value) {
      TransactionCategory category =
          categories.firstWhere((c) => c.name == key);
      expect(category.income, value.$1);
      expect(vi[key], value.$2);
    });

    for (TransactionCategory category in categories) {
      // Mọi danh mục đều có bản dịch tiếng Anh (ngôn ngữ dự phòng)
      expect(en.containsKey(category.name), true, reason: category.name);
      // Biểu tượng có trong assets
      expect(File("assets/categories/${category.iconName}").existsSync(), true,
          reason: category.iconName);
    }
  });
}
