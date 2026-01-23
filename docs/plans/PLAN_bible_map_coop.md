# PLAN-bible-map-coop

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: 그룹(구역/셀) 단위로 성경 읽기 목표를 설정하고, '성경 지도(Map)'를 통해 시각적으로 읽기 현황을 공유하며 협력(Territory Conquest)하는 기능을 구현한다.
*   **Scope**:
    *   **Group Goal**: 리더의 목표 설정 (이번 달 신약, 1년 1독 등).
    *   **Bible Map UI**: 성경 66권/장을 그리드/타일 형태로 시각화.
    *   **Selection & Locking**: 사용자가 읽을 구역을 '찜(Lock)'하고 독점하는 로직.
    *   **Conquest Integration**: 읽기 완료 시 지도 상태 변경(완료) 및 기여도 반영.
*   **User Story**:
    1.  **리더**는 그룹의 이번 달 목표를 "마태복음 전체"로 설정한다.
    2.  **멤버**는 성경 지도에 들어와 회색(미개척)인 '마태복음 5장'을 눌러 "내가 읽기"를 선택한다.
    3.  지도에서 해당 타일은 내 퍼스널 컬러로 바뀌고 '읽는 중' 표시가 뜬다(다른 사람은 선택 불가).
    4.  멤버가 성경을 다 읽고 인증하면, 타일이 꽉 찬 색상(완료)으로 변하고 "우리 그룹이 마태복음의 5%를 정복했어요!" 알림이 뜬다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Map State Storage**: 성경 전체(1189장)의 상태를 효율적으로 관리하기 위해, 그룹당 하나의 문서(`group_map_state`)에 Map/Array 형태로 상태를 저장한다. (Firestore Document Size < 1MB 활용)
    *   **Concurrency**: '구역 예약(Locking)' 시 동시성 제어를 위해 Firestore Transaction을 필수적으로 사용한다.
    *   **Visualization**: Flutter의 `CustomPainter` 또는 `GridView`를 활용하여 퍼포먼스 최적화된 맵 렌더링.
*   **Data Model Extensions**:
    *   `GroupGoal`: `id`, `group_id`, `target_range` (Start~End Book/Chapter), `start_date`, `end_date`, `status` ('ACTIVE', 'COMPLETED', 'ARCHIVED').
    *   `GroupMapState`: Document ID (`goal_id`). **Important**: 1:1 mapping with Goal.
        *   `groupId`: stored as field for querying.
        *   `chapters`: Map<String, ChapterStatus>
            *   `ChapterStatus`:
                *   `status`: 'OPEN' | 'LOCKED' | 'CLEARED'
                *   `lockedBy`: User ID (nullable)
                *   `lockedAt`: Timestamp (nullable)
                *   `clearedBy`: User ID (nullable)
                *   `clearedAt`: Timestamp (nullable)
        *   `stats`: Top-level statistics for leaderboard and progress.
            *   `totalChapters`: Total count (e.g., 260 for NT).
            *   `clearedCount`: Number of chapters cleared.
            *   `userStats`: Map<String, UserMapStat> (Key: User ID)
                *   `username`: Cached display name.
                *   `clearedCount`: How many chapters this user cleared.
                *   `lockedCount`: Currently locked by this user.
                *   `lastActiveAt`: Timestamp.

## 3. Phase Breakdown (단계별 계획)

### Phase 1: Data Modeling & Goal Setting (데이터 모델 및 목표 설정)
*   **Goal**: 그룹 목표를 DB에 저장하고, 이를 기반으로 빈 Map State를 초기화하는 로직 구현.
*   **Test Strategy**: Unit Test (Goal 생성 시 State 초기화 검증).

#### Tasks
*   [ ] 🔴 **RED**: Write tests for `GroupGoalService` (createGoal, initializeMap).
*   [ ] 🟢 **GREEN**: Define `GroupGoal` and `GroupMapState` models.
*   [ ] 🟢 **GREEN**: Implement `GroupGoalRepository` with Firestore.
*   [ ] 🟢 **GREEN**: Implement "Create Goal" UI for Leaders (Simple Date/Range Picker).
*   [ ] 📝 Update documentation.

#### Quality Gate
*   [ ] Build Success.
*   [ ] Goal 생성 시 Firestore에 `group_goals`와 `group_map_state` 문서가 올바르게 생성됨.

---

### Phase 2: Map Visualization & Interaction (지도 시각화 및 예약)
*   **Goal**: 성경 지도를 화면에 그리고, 터치하여 '내 구역'으로 예약(Locking)하는 기능 구현.
*   **Test Strategy**: Widget Test (타일 터치 -> 상태 변경 -> 색상 변화).

#### Tasks
*   [ ] 🔴 **RED**: Write tests for `MapViewModel` (lockChapter transaction).
*   [ ] 🟢 **GREEN**: Implement `BibleMapWidget` (Grid Layout for Books/Chapters).
    *   *Tip*: 책(Book) 단위로 묶어서 보여주는 계층형 UI 고려.
    *   *Requirement*: **Navigation UX** 강화 (중요).
        *   **Sticky Headers**: 스크롤 시 현재 성경 책 이름(예: 창세기)이 상단에 고정.
        *   **Quick Jump Sidebar**: 우측/하단에 성경 목록(약어)을 배치하여 터치 시 해당 위치로 스무스 스크롤.
        *   **Mini-map**: (옵션) 전체 지도의 축소판을 통해 현재 위치 파악.
*   [ ] 🟢 **GREEN**: Connect to `GroupMapState` stream (Real-time updates).
*   [ ] 🟢 **GREEN**: Implement `lockChapter` transaction (Check if already locked -> Lock).
*   [ ] 🔵 **REFACTOR**: Optimize rendering for 1000+ items (if showing whole Bible).
*   [ ] 📝 Update documentation.

#### Quality Gate
*   [ ] Build Success.
*   [ ] 두 사용자가 동시에 같은 구역을 누를 때, 한 명만 성공하고 다른 명은 실패 알림을 받음(Transaction 검증).

---

### Phase 3: Conquest & Integration (정복 및 읽기 연동)
*   **Goal**: 실제 읽기(Check-in) 완료 시, 예약된 구역을 '완료(Cleared)' 처리하고 통계를 갱신.
*   **Test Strategy**: Integration Test (Check-in Flow -> Map Update).

#### Tasks
*   [ ] 🔴 **RED**: Write tests for `ReadingService` integration (completeReading updates Map).
*   [ ] 🟢 **GREEN**: Update `ReadingService` to check if the chapter was locked by user.
*   [ ] 🟢 **GREEN**: Update `GroupMapState` status to 'CLEARED' upon reading completion.
*   [ ] 🟢 **GREEN**: Add "Release" logic (Lock timeout or manual cancel).
*   [ ] 🟢 **GREEN**: Implement Zoom-out / Conquest Rate View (Overall Progress).
*   [ ] 📝 Update documentation.

#### Quality Gate
*   [ ] Build Success.
*   [ ] 읽기 완료 후 다시 지도로 돌아왔을 때 해당 타일이 '완료' 색상으로 변경되어 있어야 함.

---

### Phase 4: AI Custom Map Designer (AI 맞춤형 지도 생성)
*   **Goal**: 사용자가 이미지를 업로드하면, AI가 성경 지도(Grid)에 맞는 픽셀 아트/도안으로 변환해 주는 기능.
*   **Key Features**:
    *   **Image Upload**: 갤러리/카메라 이미지 입력.
    *   **AI Analysis (Image-to-Grid)**: 이미지를 분석하여 1189개(또는 목표 분량)의 타일 색상/배치로 변환.
        *   *Scenario*: 십자가 사진 업로드 -> 십자가 모양으로 배치된 성경 읽기표 생성.
    *   **Editor**: 변환된 결과를 사용자가 미세 조정 (색상 변경, 타일 On/Off).
*   **Technical Approach**:
    *   **Option A (Client-side)**: Flutter `image` 패키지를 활용한 픽셀화(Pixelation) 알고리즘 적용 (저비용, 빠른 반응).
    *   **Option B (Server-side)**: Cloud Functions + Vision API (복잡한 형태 인식 및 최적화된 도안 생성).
    *   **MVP Decision**: 우선 **Client-side** 알고리즘으로 PoC 진행 후, 품질 향상 필요 시 서버 도입.

#### Tasks
*   [ ] 🔴 **RED**: Write tests for `ImageToGridService` (pixelateImage).
*   [ ] 🟢 **GREEN**: Implement Image Upload & Crop UI.
*   [ ] 🟢 **GREEN**: Implement `Pixelation Algorithm` (Downsampling image to Map Grid size).
*   [ ] 🟢 **GREEN**: Implement `CustomMapEditor` (Grid 수정 기능).
*   [ ] 🟢 **GREEN**: Save custom layout to `group_goals` (type='custom').
*   [ ] 📝 Update documentation.

#### Quality Gate
*   [ ] 이미지를 넣었을 때, 식별 가능한 수준의 픽셀 아트 그리드가 생성되어야 함.
*   [ ] 생성된 커스텀 맵이 실제 그룹 목표로 설정되고 동작해야 함.
