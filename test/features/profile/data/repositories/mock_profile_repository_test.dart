import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:socialflow_ai/features/profile/domain/entities/profile_overview.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  const repository = MockProfileRepository(delay: Duration.zero);

  test('returns the expected demo identity and plan', () async {
    final overview = await repository.fetchOverview();

    expect(overview.identity.name, 'Rami');
    expect(overview.identity.email, 'rami@socialflow.ai');
    expect(overview.identity.planName, 'Pro');
    expect(overview.isDemo, isTrue);
  });

  test('returns the active Social Flow AI workspace', () async {
    final overview = await repository.fetchOverview();

    expect(overview.workspace.name, 'Social Flow AI');
    expect(overview.workspace.role, 'Owner');
    expect(overview.workspace.membersCount, 4);
  });

  test(
    'returns three connected accounts and one disconnected account',
    () async {
      final overview = await repository.fetchOverview();

      expect(overview.connectedAccountsCount, 3);
      expect(overview.socialAccounts, hasLength(4));
      expect(
        overview.socialAccounts
            .singleWhere(
              (account) => account.platform == SocialPlatform.youtube,
            )
            .status,
        ProfileAccountStatus.disconnected,
      );
    },
  );

  test('can expose injected data for deterministic states', () async {
    const custom = ProfileOverview(
      identity: ProfileIdentity(
        name: 'Long User',
        email: 'long@example.com',
        planName: 'Demo',
      ),
      workspace: ProfileWorkspaceSummary(
        name: 'Workspace',
        role: 'Member',
        membersCount: 1,
      ),
      socialAccounts: [],
      isDemo: false,
    );

    final result =
        await const MockProfileRepository(
          delay: Duration.zero,
          overview: custom,
        ).fetchOverview();

    expect(result, same(custom));
  });
}
