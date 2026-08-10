import '../entities/profile_overview.dart';

abstract interface class ProfileRepository {
  Future<ProfileOverview> fetchOverview();
}
