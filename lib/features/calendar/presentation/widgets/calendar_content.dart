import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_tabs.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/social_platform_visuals.dart';
import '../../domain/entities/calendar_entry.dart';
import '../controllers/calendar_controller.dart';

class CalendarContent extends StatelessWidget {
  const CalendarContent({
    required this.state,
    required this.controller,
    required this.onCreate,
    required this.onEntry,
    super.key,
  });

  final CalendarState state;
  final CalendarController controller;
  final VoidCallback onCreate;
  final VoidCallback onEntry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Calendrier éditorial Social Flow AI',
      child: ListView(
        key: const Key('calendar-scroll'),
        padding: AppSpacing.screenInsets,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(onCreate: onCreate),
                  const SizedBox(height: AppSpacing.lg),
                  DefaultTabController(
                    length: CalendarViewMode.values.length,
                    initialIndex: state.viewMode.index,
                    child: AppTabs(
                      tabs: const ['Mois', 'Semaine', 'Liste'],
                      isScrollable: false,
                      onTap:
                          (index) => controller.setViewMode(
                            CalendarViewMode.values[index],
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PeriodControls(state: state, controller: controller),
                  const SizedBox(height: AppSpacing.md),
                  _PlatformFilters(state: state, controller: controller),
                  const SizedBox(height: AppSpacing.md),
                  switch (state.viewMode) {
                    CalendarViewMode.month => _MonthView(
                      state: state,
                      onSelect: controller.selectDate,
                    ),
                    CalendarViewMode.week => _WeekView(
                      state: state,
                      onSelect: controller.selectDate,
                    ),
                    CalendarViewMode.list => _ListView(
                      state: state,
                      onEntry: onEntry,
                    ),
                  },
                  if (state.viewMode != CalendarViewMode.list) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    _SelectedDay(
                      state: state,
                      onCreate: onCreate,
                      onEntry: onEntry,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendrier éditorial',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Planifiez vos contenus sur tous vos réseaux.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      AppIconButton(
        icon: Icons.add,
        tooltip: 'Ajouter une publication',
        onPressed: onCreate,
      ),
    ],
  );
}

class _PeriodControls extends StatelessWidget {
  const _PeriodControls({required this.state, required this.controller});

  final CalendarState state;
  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;
    final label = switch (state.viewMode) {
      CalendarViewMode.month || CalendarViewMode.list =>
        '${_monthNames[state.focusedDate.month - 1]} ${state.focusedDate.year}',
      CalendarViewMode.week => _weekPeriodLabel(state.focusedDate),
    };

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            key: const Key('calendar-period'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        AppIconButton(
          icon: Icons.chevron_left,
          tooltip: 'Période précédente',
          onPressed: controller.previousPeriod,
        ),
        AppIconButton(
          icon: Icons.chevron_right,
          tooltip: 'Période suivante',
          onPressed: controller.nextPeriod,
        ),
        if (!compact)
          AppTertiaryButton(
            label: 'Aujourd’hui',
            onPressed: controller.goToToday,
          )
        else
          AppIconButton(
            icon: Icons.today_outlined,
            tooltip: 'Aujourd’hui',
            onPressed: controller.goToToday,
          ),
      ],
    );
  }
}

class _PlatformFilters extends StatelessWidget {
  const _PlatformFilters({required this.state, required this.controller});

  final CalendarState state;
  final CalendarController controller;

  static const platforms = [
    SocialPlatform.instagram,
    SocialPlatform.facebook,
    SocialPlatform.tiktok,
    SocialPlatform.youtube,
    SocialPlatform.linkedin,
  ];

  @override
  Widget build(BuildContext context) {
    final showLabels = MediaQuery.sizeOf(context).width >= 360;
    return SingleChildScrollView(
      key: const Key('calendar-filters'),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppChip(
            label: 'Tous',
            selected: state.platform == null,
            onSelected: (_) => controller.setPlatform(null),
          ),
          for (final platform in platforms) ...[
            const SizedBox(width: AppSpacing.sm),
            SocialPlatformChip(
              platform: platform,
              selected: state.platform == platform,
              showLabel: showLabels,
              onSelected: (_) => controller.setPlatform(platform),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({required this.state, required this.onSelect});

  final CalendarState state;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(state.focusedDate.year, state.focusedDate.month);
    final leading = first.weekday - DateTime.monday;
    final days = DateTime(first.year, first.month + 1, 0).day;
    final cellCount = ((leading + days + 6) ~/ 7) * 7;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Row(
            children: [
              for (final label in _weekdayInitials)
                Expanded(child: _WeekdayLabel(label)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          GridView.builder(
            key: const Key('calendar-month-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DateTime.daysPerWeek,
              childAspectRatio: 0.70,
              crossAxisSpacing: AppSpacing.xs,
              mainAxisSpacing: AppSpacing.xs,
            ),
            itemCount: cellCount,
            itemBuilder: (context, index) {
              final day = index - leading + 1;
              if (day < 1 || day > days) return const SizedBox.shrink();
              final date = DateTime(first.year, first.month, day);
              return _DayCell(
                date: date,
                entryCount: state.entriesFor(date).length,
                isToday: CalendarState.isSameDay(date, state.today),
                selected: CalendarState.isSameDay(date, state.selectedDate),
                onTap: () => onSelect(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.entryCount,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final int entryCount;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${_fullDate(date)}, $entryCount publication${entryCount > 1 ? 's' : ''}',
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          key: Key('calendar-day-${date.year}-${date.month}-${date.day}'),
          onTap: onTap,
          borderRadius: AppRadius.control,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: AppSizes.iconLarge,
                  height: AppSizes.iconLarge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? scheme.primary : AppColors.transparent,
                    shape: BoxShape.circle,
                    border:
                        isToday && !selected
                            ? Border.all(color: scheme.primary, width: 1.25)
                            : null,
                  ),
                  child: Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? scheme.onPrimary : scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                if (entryCount > 0)
                  Text(
                    '$entryCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  const SizedBox(height: AppSizes.iconExtraSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.state, required this.onSelect});

  final CalendarState state;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final start = state.focusedDate.subtract(
      Duration(days: state.focusedDate.weekday - DateTime.monday),
    );
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: SingleChildScrollView(
        key: const Key('calendar-week-strip'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            for (var index = 0; index < DateTime.daysPerWeek; index++) ...[
              if (index > 0) const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 58,
                child: _DayCell(
                  date: start.add(Duration(days: index)),
                  entryCount:
                      state.entriesFor(start.add(Duration(days: index))).length,
                  isToday: CalendarState.isSameDay(
                    start.add(Duration(days: index)),
                    state.today,
                  ),
                  selected: CalendarState.isSameDay(
                    start.add(Duration(days: index)),
                    state.selectedDate,
                  ),
                  onTap: () => onSelect(start.add(Duration(days: index))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.state, required this.onEntry});

  final CalendarState state;
  final VoidCallback onEntry;

  @override
  Widget build(BuildContext context) {
    final entries =
        state.filteredEntries.where((entry) {
            return entry.scheduledAt.year == state.focusedDate.year &&
                entry.scheduledAt.month == state.focusedDate.month;
          }).toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (entries.isEmpty) {
      return const _CompactEmpty(
        title: 'Aucune publication ce mois-ci',
        message: 'Changez de période ou retirez le filtre actif.',
      );
    }

    return Column(
      key: const Key('calendar-list-view'),
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index == 0 ||
              !CalendarState.isSameDay(
                entries[index - 1].scheduledAt,
                entries[index].scheduledAt,
              )) ...[
            if (index > 0) const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _fullDate(entries[index].scheduledAt),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _EntryCard(entry: entries[index], onTap: onEntry),
          if (index < entries.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SelectedDay extends StatelessWidget {
  const _SelectedDay({
    required this.state,
    required this.onCreate,
    required this.onEntry,
  });

  final CalendarState state;
  final VoidCallback onCreate;
  final VoidCallback onEntry;

  @override
  Widget build(BuildContext context) {
    final entries = state.entriesFor(state.selectedDate);
    return Column(
      key: const Key('calendar-selected-day'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: _fullDate(state.selectedDate),
          subtitle:
              '${entries.length} publication${entries.length > 1 ? 's' : ''}',
        ),
        const SizedBox(height: AppSpacing.md),
        if (entries.isEmpty)
          _CompactEmpty(
            title: 'Aucune publication prévue',
            message: 'Ce créneau est libre dans votre planning éditorial.',
            actionLabel: 'Ajouter une publication',
            onAction: onCreate,
          )
        else ...[
          for (var index = 0; index < entries.length; index++) ...[
            _EntryCard(entry: entries[index], onTap: onEntry),
            if (index < entries.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Ajouter une publication',
            icon: Icons.add,
            onPressed: onCreate,
          ),
        ],
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.onTap});

  final CalendarEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(entry.status);
    final contentType = _contentTypeLabel(entry.contentType);
    return AppCard(
      semanticLabel:
          '${entry.platform.label}, ${entry.title}, ${status.$1}, ${_time(entry.scheduledAt)}',
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (entry.mediaUrl case final url?)
            AppNetworkImage(
              url: url,
              semanticLabel: 'Aperçu de ${entry.title}',
              width: AppSizes.avatarLarge,
              height: AppSizes.avatarLarge,
            )
          else
            SocialPlatformIcon(
              platform: entry.platform,
              containerSize: AppSizes.avatarLarge,
              size: AppSizes.iconLarge,
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppBadge(label: status.$1, tone: status.$2),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${entry.platform.label} · ${_time(entry.scheduledAt)} · $contentType',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (entry.summary case final summary?) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        const Icon(
          Icons.event_available_outlined,
          color: AppColors.brandPrimary,
          size: AppSizes.iconHero,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppTertiaryButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    ),
  );
}

const _weekdayInitials = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _weekdayNames = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];
const _monthNames = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

String _fullDate(DateTime date) =>
    '${_weekdayNames[date.weekday - 1]} ${date.day} ${_monthNames[date.month - 1].toLowerCase()}';

String _weekPeriodLabel(DateTime date) {
  final start = date.subtract(Duration(days: date.weekday - DateTime.monday));
  final end = start.add(const Duration(days: 6));
  return '${start.day}–${end.day} ${_monthNames[end.month - 1]} ${end.year}';
}

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _contentTypeLabel(CalendarContentType type) => switch (type) {
  CalendarContentType.image => 'Image',
  CalendarContentType.reel => 'Reel',
  CalendarContentType.video => 'Vidéo',
  CalendarContentType.carousel => 'Carrousel',
  CalendarContentType.text => 'Post',
};

(String, AppBadgeTone) _statusPresentation(CalendarEntryStatus status) =>
    switch (status) {
      CalendarEntryStatus.draft => ('Brouillon', AppBadgeTone.neutral),
      CalendarEntryStatus.scheduled => ('Programmé', AppBadgeTone.info),
      CalendarEntryStatus.pending => ('À valider', AppBadgeTone.warning),
      CalendarEntryStatus.published => ('Publié', AppBadgeTone.success),
      CalendarEntryStatus.failed => ('Échec', AppBadgeTone.danger),
    };
