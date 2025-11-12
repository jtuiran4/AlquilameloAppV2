import 'package:shared_preferences/shared_preferences.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/datasources/datasources.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  static const String _userIdKey = 'current_user_id';
  static const String _userProfileKey = 'user_profile';

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<String?> getCachedUserId() async {
    return _prefs.getString(_userIdKey);
  }

  @override
  Future<void> cacheUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  @override
  Future<UserProfile?> getCachedUserProfile() async {
    final profileJson = _prefs.getString(_userProfileKey);
    if (profileJson != null) {
      try {
        final data = Map<String, dynamic>.from(
          profileJson.split(',').fold<Map<String, dynamic>>({}, (map, pair) {
            final parts = pair.split(':');
            if (parts.length == 2) {
              map[parts[0]] = parts[1];
            }
            return map;
          })
        );
        return _jsonToUserProfile(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> cacheUserProfile(UserProfile user) async {
    final profileData = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'profileImage': user.profileImage,
      'createdAt': user.createdAt?.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
    };

    final profileString = profileData.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');

    await _prefs.setString(_userProfileKey, profileString);
  }

  @override
  Future<void> clearAuthCache() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userProfileKey);
  }

  UserProfile _jsonToUserProfile(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }
}