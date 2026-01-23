# PLAN-daily-record-and-growth

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: 사용자가 매일 성경 읽기를 기록(Check-in)하고, 그 결과가 홈 화면의 '영적 성장 나무'와 '연속 읽기(Streak)'에 실시간으로 반영되도록 구현한다.
*   **Scope**:
    *   Firestore `records` 컬렉션 모델링 및 연동.
    *   사용자 `stats` (총 읽은 수, 연속일수) 업데이트 로직.
    *   홈 화면 UI 연동 (체크 버튼 동작, 나무 성장 상태 반영).
    *   간단한 묵상(한 줄 메모) 입력 기능.
*   **User Story**:
    1.  사용자는 홈 화면에서 '오늘의 말씀' 카드를 확인한다.
    2.  '읽음 체크' 버튼을 누르면 간단한 묵상을 입력할 수 있는 바텀 시트가 뜬다.
    3.  저장하면 나무 아이콘이 성장한 모습으로 변하고, '오늘 읽기 완료' 상태로 바뀐다.
    4.  나의 연속 읽기(Streak) 횟수가 1 증가한다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Data Structure**: `records` 컬렉션은 `user_id`와 `date`를 복합 인덱스로 활용하여 쿼리 최적화.
    *   **State Management**: `RecordRepository`를 통해 데이터를 가져오고, `HomeViewModel` (Riverpod)에서 UI 상태(읽음 여부, 나무 단계)를 관리.
    *   **Transaction**: 기록 생성과 유저 스탯(`current_streak`, `total_chapters`) 업데이트는 Firestore Transaction으로 원자성 보장.
    *   **Optimistic UI**: 네트워크 지연을 숨기기 위해 로컬 상태를 먼저 업데이트(선택 사항).
*   **Data Model**:
    *   `RecordModel`: `id`, `userId`, `date` (YYYY-MM-DD), `meditation` (String?), `timestamp`.
    *   `UserStats`: `currentStreak`, `totalReads`.

## 3. Phase Breakdown (단계별 계획)

### Phase 1: Data Layer & Repository
*   **Goal**: Firestore `records` 컬렉션에 대한 CRUD 및 유저 통계 업데이트 기능 구현.
*   **Test Strategy**: Mock Firestore Test (트랜잭션 시뮬레이션).
*   **Rollback**: `RecordRepository` 파일 삭제.

#### Tasks
*   [ ] 🔴 **RED**: Write tests for `RecordRepository` (createRecord, getTodayRecord).
*   [ ] 🟢 **GREEN**: Define `RecordModel` and `UserModel` (update with stats).
*   [ ] 🟢 **GREEN**: Implement `RecordRepository` with Firestore.
*   [ ] 🟢 **GREEN**: Implement `updateUserStats` method (using Transaction).
*   [ ] 🔵 **REFACTOR**: Ensure date handling is consistent (UTC vs Local).
*   [ ] 📝 Update documentation.

#### Quality Gate
*   [ ] Build Success.
*   [ ] Tests Pass (Record creation updates user stats correctly).

---

### Phase 2: Domain Logic & State Management
*   **Goal**: UI에서 사용할 '오늘 읽음 여부', '현재 나무 단계' 등을 계산하는 로직 구현.
*   **Test Strategy**: Unit Test (ViewModel 상태 변화 검증).

#### Tasks
*   [ ] 🔴 **RED**: Write tests for `HomeViewModel` (fetch status, mark as read).
*   [ ] 🟢 **GREEN**: Implement `HomeViewModel` (Provider).
*   [ ] 🟢 **GREEN**: Connect `RecordRepository` to ViewModel.
*   [ ] 🟢 **GREEN**: Define logic for Tree Growth Stage based on stats (e.g., Level 1~5).
*   [ ] 🔵 **REFACTOR**: Handle loading and error states.
*   [ ] 📝 Update documentation.

#### Quality Gate
*   [ ] Build Success.
*   [ ] ViewModel correctly exposes stream of user's daily record status.

---

### Phase 3: UI Integration (Home Screen)
*   **Goal**: 홈 화면에 실제 데이터를 연동하여 인터랙티브한 경험 제공.
*   **Test Strategy**: Widget Test (버튼 클릭 -> 상태 변경 -> UI 반영).

#### Tasks
*   [ ] 🔴 **RED**: Write widget tests for `HomeHeader` (stats) and `TodayBibleCard` (interaction).
*   [ ] 🟢 **GREEN**: Update `HomeHeader` to show real user name and streak.
*   [ ] 🟢 **GREEN**: Update `TodayBibleCard` with Check-in button.
*   [ ] 🟢 **GREEN**: Create `CheckInBottomSheet` for meditation input.
*   [ ] 🟢 **GREEN**: Animate `GrowthTreeWidget` upon completion.
*   [ ] 🔵 **REFACTOR**: Polish UI visuals (Validation, Feedback).
*   [ ] 📝 Update documentation.

#### Quality Gate
*   [ ] Build Success.
*   [ ] Complete user flow: Check-in -> Tree Grows -> Stats Update.
