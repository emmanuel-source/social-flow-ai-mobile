import '../../../../shared/models/social_platform.dart';
import '../../../content/domain/entities/platform_post_variant.dart';
import '../../../content/domain/entities/social_post.dart';
import '../../domain/entities/draft.dart';

abstract final class DraftRecord {
  static const schemaVersion = 1;
  static const kind = 'socialflow_draft';

  static Map<String, Object> toMap(Draft draft) => {
    'schemaVersion': schemaVersion,
    'kind': kind,
    'id': draft.id,
    'postType': draft.postType.name,
    'sourceCaption': draft.sourceCaption,
    'mediaPaths': draft.mediaPaths,
    'selectedPlatforms': [
      for (final platform in draft.selectedPlatforms) platform.name,
    ],
    'platformVariants': {
      for (final entry in draft.platformVariants.entries)
        entry.key.name: {
          'caption': entry.value.caption,
          'sourceCaptionSnapshot': entry.value.sourceCaptionSnapshot,
        },
    },
    'createdAt': draft.createdAt.toUtc().toIso8601String(),
    'updatedAt': draft.updatedAt.toUtc().toIso8601String(),
  };

  static bool isDraftRecord(Object? value) {
    if (value is! Map) return false;
    return value['kind'] == kind;
  }

  static Draft fromMap(Map<dynamic, dynamic> map) {
    if (map['schemaVersion'] != schemaVersion || map['kind'] != kind) {
      throw const FormatException('Unsupported draft record');
    }

    final id = _requiredString(map, 'id');
    final postType = _enumByName(PostType.values, map['postType'], 'postType');
    final sourceCaption = _requiredString(
      map,
      'sourceCaption',
      allowEmpty: true,
    );
    final mediaPaths = _stringList(map['mediaPaths'], 'mediaPaths');
    final selectedPlatformNames = _stringList(
      map['selectedPlatforms'],
      'selectedPlatforms',
    );
    final selectedPlatforms = {
      for (final name in selectedPlatformNames)
        _enumByName(SocialPlatform.values, name, 'selectedPlatforms'),
    };
    final variantsValue = map['platformVariants'];
    if (variantsValue is! Map) {
      throw const FormatException('Invalid platformVariants');
    }
    final variants = <SocialPlatform, PlatformPostVariant>{};
    for (final entry in variantsValue.entries) {
      final platform = _enumByName(
        SocialPlatform.values,
        entry.key,
        'platformVariants',
      );
      final value = entry.value;
      if (value is! Map) {
        throw const FormatException('Invalid platform variant');
      }
      variants[platform] = PlatformPostVariant(
        platform: platform,
        caption: _requiredString(value, 'caption', allowEmpty: true),
        sourceCaptionSnapshot: _requiredString(
          value,
          'sourceCaptionSnapshot',
          allowEmpty: true,
        ),
      );
    }

    return Draft(
      id: id,
      postType: postType,
      sourceCaption: sourceCaption,
      mediaPaths: mediaPaths,
      selectedPlatforms: selectedPlatforms,
      platformVariants: variants,
      createdAt: _dateTime(map['createdAt'], 'createdAt'),
      updatedAt: _dateTime(map['updatedAt'], 'updatedAt'),
    );
  }

  static String _requiredString(
    Map<dynamic, dynamic> map,
    String key, {
    bool allowEmpty = false,
  }) {
    final value = map[key];
    if (value is! String || (!allowEmpty && value.isEmpty)) {
      throw FormatException('Invalid $key');
    }
    return value;
  }

  static List<String> _stringList(Object? value, String key) {
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Invalid $key');
    }
    return List<String>.from(value);
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    Object? value,
    String key,
  ) {
    if (value is! String) throw FormatException('Invalid $key');
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    throw FormatException('Unknown $key value: $value');
  }

  static DateTime _dateTime(Object? value, String key) {
    if (value is! String) throw FormatException('Invalid $key');
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('Invalid $key');
    return parsed;
  }
}
