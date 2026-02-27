import 'package:hive/hive.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
part 'approvedfield.g.dart';

@HiveType(typeId: 1)
class ApprovedField {
  @HiveField(0)
  final List<String> fields;

  ApprovedField({
    required this.fields,
  });

  static Future<void> approvedFields() async {
    try {
      var localDb = await Hive.openBox<ApprovedField>('approved_fields');

      await localDb.clear();

      final List<ApprovedField> fields = [
        ApprovedField(
          fields: ['Hasan Özaydın Halı Saha','Şampiyon Halı Saha']
        )
      ];

      for (var field in fields) {
        await localDb.add(field);
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'approvedfield approvedFields error',
      );
    }
  }
}