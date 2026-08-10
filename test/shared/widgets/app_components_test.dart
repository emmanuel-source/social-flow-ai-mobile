import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';
import 'package:socialflow_ai/shared/widgets/app_avatar.dart';
import 'package:socialflow_ai/shared/widgets/app_badge.dart';
import 'package:socialflow_ai/shared/widgets/app_chip.dart';
import 'package:socialflow_ai/shared/widgets/app_list_tile.dart';
import 'package:socialflow_ai/shared/widgets/app_selection_controls.dart';
import 'package:socialflow_ai/shared/widgets/app_skeleton.dart';
import 'package:socialflow_ai/shared/widgets/section_header.dart';
import 'package:socialflow_ai/shared/widgets/social_network_card.dart';

import 'widget_test_harness.dart';

void main() {
  testWidgets('content primitives remain readable on compact screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        ListView(
          children: [
            const SectionHeader(
              title: 'Comptes sociaux',
              subtitle: 'Gérez les plateformes de votre espace de travail.',
            ),
            SocialNetworkCard(
              platform: SocialPlatform.instagram,
              accountLabel: '@socialflow',
              connected: true,
              selected: true,
              onTap: () {},
            ),
            const AppAvatar(label: 'Social Flow'),
            const Wrap(
              children: [
                AppChip(label: 'Instagram', selected: true),
                AppBadge(label: 'Programmé', tone: AppBadgeTone.success),
              ],
            ),
            AppListTile(
              title: 'Publication avec un titre suffisamment long',
              subtitle: 'Description sur plusieurs lignes.',
              onTap: () {},
            ),
            const AppSkeleton(height: 24),
          ],
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Instagram'), findsWidgets);
  });

  testWidgets('selection controls forward changes without business logic', (
    tester,
  ) async {
    bool? checked = false;
    var switched = false;
    String? selected = 'a';
    await tester.pumpWidget(
      buildTestApp(
        ListView(
          children: [
            AppSwitch(
              label: 'Notifications',
              value: switched,
              onChanged: (value) => switched = value,
            ),
            AppCheckbox(
              label: 'Accepter',
              value: checked,
              onChanged: (value) => checked = value,
            ),
            AppRadio<String>(
              label: 'Option B',
              value: 'b',
              groupValue: selected,
              onChanged: (value) => selected = value,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Notifications'));
    await tester.tap(find.text('Accepter'));
    await tester.tap(find.text('Option B'));
    expect(switched, isTrue);
    expect(checked, isTrue);
    expect(selected, 'b');
  });

  testWidgets('badge can expose a more descriptive semantic status', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      buildTestApp(
        const AppBadge(
          label: 'YouTube',
          semanticLabel: 'YouTube, attention requise',
          tone: AppBadgeTone.warning,
        ),
      ),
    );

    expect(find.text('YouTube'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('YouTube, attention requise')),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
