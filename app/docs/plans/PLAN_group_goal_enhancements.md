# Feature Plan: Group Goal Enhancements

## 1. 개요
그룹 목표 관리 기능을 강화하여 사용자 경험을 개선합니다. 목표 숨기기/보기, 진행률 시각화, 최근 활동 내역 표시를 구현합니다.

## 2. 요구사항 분석
1.  **목표 숨기기**: 진행 중인 목표를 목록에서 숨김 처리 (상태: HIDDEN).
2.  **숨긴 목표 보기**: 숨겨진 목표를 다시 볼 수 있는 기능.
3.  **진행률 표시**: 목표 카드에 전체 진행률(%) 및 ProgressBar 표시.
4.  **최근 활동 내역**: 최근 7일간 읽은 구성원(최대 3명) 표시 (중복 제외).

## 3. 구현 상세

### 3.1 데이터 모델 및 저장소 (Repository)
- **`GroupGoalModel`**: `status` 필드 값으로 'HIDDEN' 사용.
- **`GroupGoalRepository`**:
    - `updateGoalStatus(goalId, status)`: 목표 상태 변경 메서드 추가.
    - `watchGoals(groupId, status)`: 특정 상태의 목표만 불러오도록 쿼리 메서드 개선.

### 3.2 UI: 목표 카드 (`GoalCard` Widget)
- 기존 `_buildGoalCard`를 별도 위젯 `GoalCard`로 분리.
- **데이터 로딩**: `bibleMapStateProvider(goalId)`를 구독하여 해당 목표의 통계(`stats`) 확보.
- **메뉴**: 카드 우측 상단 `PopupMenuButton` 추가 -> '숨기기' 옵션 제공. (숨긴 상태일 경우 '복구하기' 제공).
- **진행률**: `LinearProgressIndicator` 위젯 사용.
    - 계산: `clearedCount / totalChapters`.
- **최근 활동 (Recent History)**:
    - `state.stats.userStats` 활용.
    - 로직: `lastActiveAt`이 `DateTime.now().subtract(Duration(days: 7))` 이후인 유저 필터링 -> `lastActiveAt` 내림차순 정렬 -> 상위 3명 추출.
    - UI: `CircleAvatar` (이름 이니셜) + `Stack` 위젯으로 겹쳐서 표시하거나 나열.

### 3.3 UI: 목표 목록 (`GroupBibleMapTab`)
- **필터**: 리스트 상단에 `FilterChip` ("숨긴 목표 보기") 배치.
- **상태 관리**: `_showHidden` 상태 변수 추가.
- **로직**: `_showHidden` 값에 따라 Repository에 요청하는 `status` 파라미터 변경 ('ACTIVE' <-> 'HIDDEN').

## 4. 테스트 계획
- [ ] 숨기기 클릭 시 목록에서 사라지는지 확인.
- [ ] 숨긴 목표 보기 체크 시 숨겨진 목표가 나타나는지 확인.
- [ ] 진행률 바가 실제 데이터(완료 챕터 수)를 반영하는지 확인.
- [ ] 최근 7일 활동 유저가 최신순 3명만 나오는지 확인.
