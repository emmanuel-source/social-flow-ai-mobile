import '../../domain/entities/publish_intent.dart';
import '../../domain/services/publish_intent_submitter.dart';

class MockPublishIntentSubmitter implements PublishIntentSubmitter {
  const MockPublishIntentSubmitter({
    this.delay = const Duration(milliseconds: 650),
  });

  final Duration delay;

  @override
  Future<void> submit(PublishIntent intent) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }
}
