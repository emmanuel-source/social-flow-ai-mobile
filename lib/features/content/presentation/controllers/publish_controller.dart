import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/mock_publish_intent_submitter.dart';
import '../../domain/entities/publish_intent.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/services/publish_intent_submitter.dart';

typedef PublishClock = DateTime Function();

enum PublishSubmissionStatus { editing, submitting, success, error }

class PublishState {
  const PublishState({
    required this.mode,
    required this.timeZone,
    this.selectedDate,
    this.selectedHour,
    this.selectedMinute,
    this.status = PublishSubmissionStatus.editing,
    this.intent,
    this.errorMessage,
  });

  final PublishMode mode;
  final DateTime? selectedDate;
  final int? selectedHour;
  final int? selectedMinute;
  final String timeZone;
  final PublishSubmissionStatus status;
  final PublishIntent? intent;
  final String? errorMessage;

  DateTime? get scheduledAt {
    final date = selectedDate;
    final hour = selectedHour;
    final minute = selectedMinute;
    if (date == null || hour == null || minute == null) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool isValidAt(DateTime now) {
    if (mode == PublishMode.now) return timeZone.trim().isNotEmpty;
    final value = scheduledAt;
    return value != null && timeZone.trim().isNotEmpty && value.isAfter(now);
  }

  String? validationMessage(DateTime now) {
    if (mode == PublishMode.now) return null;
    if (selectedDate == null ||
        selectedHour == null ||
        selectedMinute == null) {
      return 'Sélectionnez une date et une heure.';
    }
    if (!(scheduledAt?.isAfter(now) ?? false)) {
      return 'Choisissez une date et une heure futures.';
    }
    if (timeZone.trim().isEmpty) return 'Le fuseau horaire est requis.';
    return null;
  }

  PublishState copyWith({
    PublishMode? mode,
    DateTime? selectedDate,
    int? selectedHour,
    int? selectedMinute,
    String? timeZone,
    PublishSubmissionStatus? status,
    PublishIntent? intent,
    String? errorMessage,
    bool clearIntent = false,
    bool clearError = false,
  }) => PublishState(
    mode: mode ?? this.mode,
    selectedDate: selectedDate ?? this.selectedDate,
    selectedHour: selectedHour ?? this.selectedHour,
    selectedMinute: selectedMinute ?? this.selectedMinute,
    timeZone: timeZone ?? this.timeZone,
    status: status ?? this.status,
    intent: clearIntent ? null : intent ?? this.intent,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final publishClockProvider = Provider<PublishClock>((ref) => DateTime.now);

final publishTimeZoneProvider = Provider<String>(
  (ref) => DateTime.now().timeZoneName,
);

final publishIntentSubmitterProvider = Provider<PublishIntentSubmitter>(
  (ref) => const MockPublishIntentSubmitter(),
);

final publishControllerProvider =
    NotifierProvider<PublishController, PublishState>(PublishController.new);

class PublishController extends Notifier<PublishState> {
  @override
  PublishState build() => _initialState();

  void selectMode(PublishMode mode) {
    if (state.status == PublishSubmissionStatus.submitting) return;
    state = state.copyWith(
      mode: mode,
      status: PublishSubmissionStatus.editing,
      clearIntent: true,
      clearError: true,
    );
  }

  void selectDate(DateTime date) {
    if (state.status == PublishSubmissionStatus.submitting) return;
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
      status: PublishSubmissionStatus.editing,
      clearIntent: true,
      clearError: true,
    );
  }

  void selectTime({required int hour, required int minute}) {
    if (state.status == PublishSubmissionStatus.submitting) return;
    state = state.copyWith(
      selectedHour: hour,
      selectedMinute: minute,
      status: PublishSubmissionStatus.editing,
      clearIntent: true,
      clearError: true,
    );
  }

  void setTimeZone(String timeZone) {
    if (state.status == PublishSubmissionStatus.submitting) return;
    state = state.copyWith(
      timeZone: timeZone,
      status: PublishSubmissionStatus.editing,
      clearIntent: true,
      clearError: true,
    );
  }

  PublishIntent? createIntent(SocialPost post) {
    final now = ref.read(publishClockProvider)();
    if (!post.hasValidPlatformVariants || !state.isValidAt(now)) return null;
    if (state.mode == PublishMode.now) {
      return PublishIntent.now(post: post, timeZone: state.timeZone);
    }
    return PublishIntent.scheduled(
      post: post,
      scheduledAt: state.scheduledAt!,
      timeZone: state.timeZone,
    );
  }

  Future<bool> submit(SocialPost post) async {
    if (state.status == PublishSubmissionStatus.submitting) return false;
    final intent = createIntent(post);
    if (intent == null) return false;

    state = state.copyWith(
      status: PublishSubmissionStatus.submitting,
      intent: intent,
      clearError: true,
    );
    try {
      await ref.read(publishIntentSubmitterProvider).submit(intent);
      state = state.copyWith(
        status: PublishSubmissionStatus.success,
        intent: intent,
        clearError: true,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        status: PublishSubmissionStatus.error,
        intent: intent,
        errorMessage:
            'La simulation n’a pas pu être terminée. Réessayez sans perdre votre contenu.',
      );
      return false;
    }
  }

  void reset() => state = _initialState();

  PublishState _initialState() => PublishState(
    mode: PublishMode.now,
    timeZone: ref.read(publishTimeZoneProvider),
  );
}
