import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_list_tile.dart';
import '../../../../shared/widgets/app_selection_controls.dart';
import '../../../../shared/widgets/app_state_view.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/publish_intent.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';
import '../controllers/publish_controller.dart';

class PostPublishScreen extends ConsumerWidget {
  const PostPublishScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publish = ref.watch(publishControllerProvider);
    final intent = publish.intent;
    if (publish.status == PublishSubmissionStatus.success && intent != null) {
      return _PublishSuccess(intent: intent);
    }

    final post = ref.watch(composerControllerProvider);
    final now = ref.read(publishClockProvider)();
    final valid = post.hasValidPlatformVariants && publish.isValidAt(now);
    final submitting = publish.status == PublishSubmissionStatus.submitting;

    return FeatureScaffold(
      title: 'Publier',
      subtitle: 'Étape 6 · Confirmation',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Choisissez quand diffuser votre contenu',
            subtitle:
                'Cette étape prépare une intention en mode démonstration. Aucun réseau social ne sera contacté.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          _PostSummary(post: post),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Quand publier ?'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                AppRadio<PublishMode>(
                  key: const Key('publish-mode-now'),
                  label: 'Publier maintenant',
                  subtitle: 'Préparer la diffusion dès validation.',
                  value: PublishMode.now,
                  groupValue: publish.mode,
                  onChanged:
                      submitting
                          ? null
                          : (value) {
                            if (value != null) {
                              ref
                                  .read(publishControllerProvider.notifier)
                                  .selectMode(value);
                            }
                          },
                ),
                AppRadio<PublishMode>(
                  key: const Key('publish-mode-scheduled'),
                  label: 'Programmer',
                  subtitle: 'Choisir une date et une heure.',
                  value: PublishMode.scheduled,
                  groupValue: publish.mode,
                  onChanged:
                      submitting
                          ? null
                          : (value) {
                            if (value != null) {
                              ref
                                  .read(publishControllerProvider.notifier)
                                  .selectMode(value);
                            }
                          },
                ),
              ],
            ),
          ),
          if (publish.mode == PublishMode.scheduled) ...[
            const SizedBox(height: AppSpacing.lg),
            _ScheduleControls(state: publish, enabled: !submitting),
          ],
          if (publish.validationMessage(now) case final message?) ...[
            const SizedBox(height: AppSpacing.md),
            Semantics(
              liveRegion: true,
              label: message,
              child: Text(
                message,
                key: const Key('publish-validation-message'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
          if (publish.status == PublishSubmissionStatus.error) ...[
            const SizedBox(height: AppSpacing.lg),
            AppErrorState(
              key: const Key('publish-error'),
              title: 'La préparation a échoué',
              message: publish.errorMessage!,
              onRetry: () => _submit(ref, post),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          if (submitting) ...[
            Semantics(
              liveRegion: true,
              label: 'Préparation de la publication en cours',
              child: const AppBadge(
                key: Key('publish-loading'),
                label: 'Préparation en cours',
                icon: Icons.hourglass_top,
                tone: AppBadgeTone.info,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppPrimaryButton(
            key: const Key('publish-submit'),
            label:
                publish.mode == PublishMode.now
                    ? 'Confirmer la publication'
                    : 'Confirmer la programmation',
            icon:
                publish.mode == PublishMode.now
                    ? Icons.send_outlined
                    : Icons.schedule_outlined,
            loading: submitting,
            onPressed: valid && !submitting ? () => _submit(ref, post) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _submit(WidgetRef ref, SocialPost post) async {
    final succeeded = await ref
        .read(publishControllerProvider.notifier)
        .submit(post);
    if (succeeded) ref.read(composerControllerProvider.notifier).reset();
  }
}

class _PostSummary extends StatelessWidget {
  const _PostSummary({required this.post});

  final SocialPost post;

  @override
  Widget build(BuildContext context) {
    final platforms = _orderedPlatforms(post.platforms);
    final customized =
        platforms.where((platform) {
          final variant = post.platformVariants[platform];
          return variant != null && !variant.matchesSource(post.caption);
        }).length;
    final mediaCount = post.mediaPaths.length;
    final caption = post.caption.trim();

    return AppCard(
      key: const Key('publish-summary'),
      semanticLabel:
          '${_typeLabel(post.type)}, ${platforms.length} réseaux, $mediaCount médias, $customized versions personnalisées',
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(
                label: _typeLabel(post.type),
                icon: _typeIcon(post.type),
                tone: AppBadgeTone.info,
              ),
              AppBadge(
                label:
                    '${platforms.length} réseau${platforms.length > 1 ? 'x' : ''}',
                icon: Icons.hub_outlined,
              ),
              AppBadge(
                label: '$mediaCount média${mediaCount > 1 ? 's' : ''}',
                icon: Icons.perm_media_outlined,
              ),
              AppBadge(
                label: '$customized personnalisée${customized > 1 ? 's' : ''}',
                icon: Icons.edit_outlined,
                tone:
                    customized == 0 ? AppBadgeTone.neutral : AppBadgeTone.info,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final platform in platforms) AppBadge(label: platform.label),
            ],
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const AppBadge(
            label: 'Prêt pour confirmation',
            icon: Icons.check_circle_outline,
            tone: AppBadgeTone.success,
          ),
        ],
      ),
    );
  }
}

class _ScheduleControls extends ConsumerWidget {
  const _ScheduleControls({required this.state, required this.enabled});

  final PublishState state;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledAt = state.scheduledAt;
    return AppCard(
      key: const Key('publish-schedule-controls'),
      child: Column(
        children: [
          Semantics(
            button: true,
            label:
                state.selectedDate == null
                    ? 'Date de programmation non sélectionnée'
                    : 'Date de programmation ${_formatDate(state.selectedDate!)}',
            child: AppListTile(
              key: const Key('publish-date'),
              title: 'Date',
              subtitle:
                  state.selectedDate == null
                      ? 'Sélectionner une date'
                      : _formatDate(state.selectedDate!),
              leading: const Icon(Icons.calendar_today_outlined),
              enabled: enabled,
              onTap: enabled ? () => _pickDate(context, ref) : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            button: true,
            label:
                scheduledAt == null
                    ? 'Heure de programmation non sélectionnée'
                    : 'Heure de programmation ${_formatTime(scheduledAt)}',
            child: AppListTile(
              key: const Key('publish-time'),
              title: 'Heure',
              subtitle:
                  state.selectedHour == null
                      ? 'Sélectionner une heure'
                      : _formatHour(state.selectedHour!, state.selectedMinute!),
              leading: const Icon(Icons.schedule_outlined),
              enabled: enabled,
              onTap: enabled ? () => _pickTime(context, ref) : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: 'Fuseau horaire ${state.timeZone}',
            child: AppListTile(
              key: const Key('publish-timezone'),
              title: 'Fuseau horaire',
              subtitle: state.timeZone,
              leading: const Icon(Icons.public_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = ref.read(publishClockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final selected = state.selectedDate;
    final initial =
        selected == null || selected.isBefore(today) ? today : selected;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(today.year + 5, today.month, today.day),
      helpText: 'Date de programmation',
    );
    if (date != null) {
      ref.read(publishControllerProvider.notifier).selectDate(date);
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final now = ref.read(publishClockProvider)();
    final initial = TimeOfDay(
      hour: state.selectedHour ?? now.add(const Duration(hours: 1)).hour,
      minute: state.selectedMinute ?? now.minute,
    );
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Heure de programmation',
    );
    if (time != null) {
      ref
          .read(publishControllerProvider.notifier)
          .selectTime(hour: time.hour, minute: time.minute);
    }
  }
}

class _PublishSuccess extends ConsumerWidget {
  const _PublishSuccess({required this.intent});

  final PublishIntent intent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = intent.selectedPlatforms.length;
    final scheduledAt = intent.scheduledAt;
    final scheduled = intent.mode == PublishMode.scheduled;
    return FeatureScaffold(
      title: scheduled ? 'Publication programmée' : 'Publication préparée',
      subtitle: 'Simulation terminée',
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: AppBadge(
              key: Key('publish-demo-badge'),
              label: 'Mode démonstration',
              icon: Icons.science_outlined,
              tone: AppBadgeTone.info,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSuccessState(
            key: const Key('publish-success'),
            title: scheduled ? 'Publication programmée' : 'Publication prête',
            message:
                scheduled
                    ? 'Votre intention de programmation a été préparée pour $count réseaux.'
                    : 'Votre contenu a été préparé pour $count réseaux. Aucun envoi réel n’a été effectué.',
          ),
          AppCard(
            semanticLabel:
                scheduled && scheduledAt != null
                    ? '${_formatDate(scheduledAt)}, ${_formatTime(scheduledAt)}, ${intent.timeZone}, $count réseaux'
                    : '$count réseaux, simulation terminée',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scheduled && scheduledAt != null) ...[
                  Text(
                    '${_formatDate(scheduledAt)} · ${_formatTime(scheduledAt)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(intent.timeZone),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text('$count réseau${count > 1 ? 'x' : ''}'),
                const SizedBox(height: AppSpacing.md),
                const AppBadge(
                  label: 'Simulation terminée',
                  icon: Icons.check_circle_outline,
                  tone: AppBadgeTone.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (scheduled) ...[
            AppSecondaryButton(
              key: const Key('publish-view-calendar'),
              label: 'Voir le calendrier',
              icon: Icons.calendar_month_outlined,
              onPressed: () => _leave(context, ref, AppRoutes.calendar),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppPrimaryButton(
            key: const Key('publish-home'),
            label: 'Retour à l’accueil',
            icon: Icons.home_outlined,
            onPressed: () => _leave(context, ref, AppRoutes.home),
          ),
        ],
      ),
    );
  }

  void _leave(BuildContext context, WidgetRef ref, String route) {
    ref.read(publishControllerProvider.notifier).reset();
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }
}

List<SocialPlatform> _orderedPlatforms(Set<SocialPlatform> selected) => [
  for (final platform in SocialPlatform.values)
    if (selected.contains(platform)) platform,
];

String _typeLabel(PostType type) => switch (type) {
  PostType.text => 'Texte',
  PostType.image => 'Photo',
  PostType.video => 'Vidéo',
  PostType.carousel => 'Carrousel',
};

IconData _typeIcon(PostType type) => switch (type) {
  PostType.text => Icons.notes_outlined,
  PostType.image => Icons.image_outlined,
  PostType.video => Icons.videocam_outlined,
  PostType.carousel => Icons.view_carousel_outlined,
};

const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

String _formatDate(DateTime value) =>
    '${value.day} ${_months[value.month - 1]} ${value.year}';

String _formatTime(DateTime value) => _formatHour(value.hour, value.minute);

String _formatHour(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
