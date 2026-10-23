import 'package:drift/drift.dart';
import 'tables.dart';
import 'connection.dart'
    if (dart.library.io) 'connection_io.dart'
    if (dart.library.html) 'connection_web.dart';

part 'database.g.dart';

@DriftDatabase(tables: [StudyMaterials])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
