import '../entities/publish_intent.dart';

/// Future integration point for submitting a prepared publishing intention.
abstract interface class PublishIntentSubmitter {
  Future<void> submit(PublishIntent intent);
}
