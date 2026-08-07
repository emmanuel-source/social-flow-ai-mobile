import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/deep_links/deep_link_parser.dart';

void main() {
  test('ouvre les statistiques d’une publication', () {
    final target = DeepLinkParser.parse(Uri.parse('socialflow://app/post/post-42'));
    expect(target?.route, AppRoutes.postAnalytics);
    expect(target?.arguments, 'post-42');
  });
}
