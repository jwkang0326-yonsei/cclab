# Feature Plan: Firestore 통계 필드 실시간 업데이트 구현

성경 읽기 앱의 Admin Web 성능 최적화를 위해, 사용자가 챕터를 읽을 때마다 상위 컬렉션인 `group_goals`의 통계 필드를 실시간으로 업데이트합니다.

## 1. 배경 및 목적
- **배경**: Admin Web에서 목표 목록 조회 시 모든 `group_map_state`를 전수 조사하여 진행률을 계산함에 따른 성능 저하.
- **목적**: `group_goals` 문서에 요약된 통계 필드를 유지하여 쿼리 효율성 증대 및 성능 개선.

## 2. 변경 사항

### 2.1 데이터 모델 수정 (`GroupGoalModel`)
`lib/data/models/group_goal_model.dart`에 다음 필드 추가:
- `total_cleared_count`: 그룹 전체의 누적 읽기 챕터 수 (int)
- `active_participant_count`: 1장 이상 읽은 고유 사용자 수 (int)
- `updated_at`: 마지막 업데이트 시간 (DateTime?)

### 2.2 리포지토리 로직 수정 (`GroupGoalRepository`)
`lib/data/repositories/group_goal_repository.dart`의 다음 메서드 수정:

#### `completeChapter` (단일 완료)
- `group_goals`의 `total_cleared_count`를 `increment(1)`
- 사용자의 기존 `clearedCount`가 0이면 `active_participant_count`를 `increment(1)`
- `updated_at`을 `serverTimestamp()`로 설정

#### `completeChapters` (일괄 완료)
- `addedClearedCount`만큼 `total_cleared_count`를 `increment`
- 사용자의 기존 `clearedCount`가 0이고 `addedClearedCount > 0`이면 `active_participant_count`를 `increment(1)`
- `updated_at`을 `serverTimestamp()`로 설정

#### `toggleCollaborativeChapterCompletion` (토글 완료)
- `userClearedDelta` (+1 또는 -1)를 `total_cleared_count`에 반영
- 사용자의 기존 `clearedCount`가 0에서 1이 되면 `active_participant_count`를 `increment(1)`
- 사용자의 `clearedCount`가 1에서 0이 되면 `active_participant_count`를 `increment(-1)`
- `updated_at`을 `serverTimestamp()`로 설정

## 3. 구현 단계 (TDD 기반)

### Phase 1: 모델 업데이트 (Red)
- [x] `GroupGoalModel`에 새로운 필드 추가 및 테스트 코드 작성 (또는 기존 테스트 수정)

### Phase 2: 리포지토리 로직 구현 (Green)
- [x] `GroupGoalRepository.completeChapter` 수정 및 검증
- [x] `GroupGoalRepository.completeChapters` 수정 및 검증
- [x] `GroupGoalRepository.toggleCollaborativeChapterCompletion` 수정 및 검증

### Phase 3: 품질 검토 및 리팩토링 (Refactor)
- [x] 트랜잭션 내 원자적 업데이트 보장 확인
- [x] 코드 스타일 및 컨벤션 준수 확인

## 4. 퀄리티 게이트
- [ ] 모든 트랜잭션에서 `group_goals`와 `group_map_state`가 동시에 업데이트되는가?
- [ ] `active_participant_count` 증가/감소 조건이 정확한가? (0 -> 1 또는 1 -> 0)
- [ ] `updated_at` 필드가 서버 시간으로 정확히 기록되는가?
