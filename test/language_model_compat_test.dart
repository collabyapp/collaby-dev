import 'package:collaby_app/models/profile_model.dart' as setup_model;
import 'package:collaby_app/models/profile_model/profile_model.dart'
    as profile_model;
import 'package:collaby_app/models/profile_model/user_model.dart' as user_model;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Language model compatibility', () {
    test(
      'Profile language model accepts language/name/code and exposes aliases',
      () {
        final fromLanguage = profile_model.LanguageModel.fromJson({
          'language': 'Spanish',
          'level': 'Native',
        });
        expect(fromLanguage.language, 'Spanish');
        expect(fromLanguage.name, 'Spanish');
        expect(fromLanguage.code, 'Spanish');
        expect(fromLanguage.level, 'Native');

        final fromName = profile_model.LanguageModel.fromJson({
          'name': 'English',
          'level': 'Fluent',
        });
        expect(fromName.language, 'English');
        expect(fromName.name, 'English');
        expect(fromName.code, 'English');

        final fromCode = profile_model.LanguageModel.fromJson({
          'code': 'pt',
          'level': 'Beginner',
        });
        expect(fromCode.language, 'pt');
        expect(fromCode.name, 'pt');
        expect(fromCode.code, 'pt');
      },
    );

    test('Setup language model exposes language alias from name', () {
      final language = setup_model.LanguageModel(
        code: 'es',
        name: 'Spanish',
        level: 'Native',
      );
      expect(language.language, 'Spanish');
      expect(language.name, 'Spanish');
      expect(language.code, 'es');
      expect(language.level, 'Native');
    });

    test(
      'User language model accepts legacy name field and exposes aliases',
      () {
        final fromLanguage = user_model.LanguageModel.fromJson({
          '_id': '1',
          'language': 'Arabic',
          'level': 'Conversational',
        });
        expect(fromLanguage.language, 'Arabic');
        expect(fromLanguage.name, 'Arabic');
        expect(fromLanguage.code, 'Arabic');
        expect(fromLanguage.level, 'Conversational');

        final fromLegacyName = user_model.LanguageModel.fromJson({
          '_id': '2',
          'name': 'German',
          'level': 'Beginner',
        });
        expect(fromLegacyName.language, 'German');
        expect(fromLegacyName.name, 'German');
        expect(fromLegacyName.code, 'German');
        expect(fromLegacyName.level, 'Beginner');
      },
    );
  });
}
