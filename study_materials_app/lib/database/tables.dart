import 'package:drift/drift.dart';

@DataClassName('StudyMaterial')
class StudyMaterials extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 250)();
  TextColumn get description => text().nullable()();
  TextColumn get type => text().withLength(min: 1, max: 50)(); // 'Bài giảng', 'Bài tập', 'Tài liệu tham khảo'
  TextColumn get url => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
}
