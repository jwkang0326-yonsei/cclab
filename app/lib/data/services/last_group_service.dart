import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마지막으로 접속한 그룹 ID를 로컬에 저장/조회하는 서비스
class LastGroupService {
  static const String _lastGroupIdKey = 'last_group_id';

  final SharedPreferences _prefs;

  LastGroupService(this._prefs);

  /// 마지막 접속 그룹 ID 조회
  String? getLastGroupId() {
    return _prefs.getString(_lastGroupIdKey);
  }

  /// 마지막 접속 그룹 ID 저장
  Future<void> setLastGroupId(String groupId) async {
    await _prefs.setString(_lastGroupIdKey, groupId);
  }

  /// 마지막 접속 그룹 ID 삭제 (로그아웃 시 등)
  Future<void> clearLastGroupId() async {
    await _prefs.remove(_lastGroupIdKey);
  }
}

/// LastGroupService Provider
/// SharedPreferences는 비동기 초기화가 필요하므로 main.dart에서 override 해야 함
final lastGroupServiceProvider = Provider<LastGroupService>((ref) {
  throw UnimplementedError('lastGroupServiceProvider must be overridden in main.dart');
});

/// 현재 선택된 그룹 ID를 관리하는 Notifier
class CurrentGroupIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    // 초기값은 lastGroupService에서 가져옴
    try {
      final lastGroupService = ref.read(lastGroupServiceProvider);
      return lastGroupService.getLastGroupId();
    } catch (e) {
      return null;
    }
  }

  void setGroupId(String? groupId) {
    state = groupId;
  }
}

final currentGroupIdProvider = NotifierProvider<CurrentGroupIdNotifier, String?>(
  CurrentGroupIdNotifier.new,
);

