# PLAN-group-management

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: 교회 내 소그룹(구역, 셀)을 생성하고, 초대 링크(Deep Link)를 통해 멤버를 그룹에 가입시킨다.
*   **Scope**:
    *   **Group Creation**: 그룹 생성 UI 및 Firestore `groups` 컬렉션 저장.
    *   **Invitation**: 그룹 초대용 Deep Link 생성 및 공유 기능 (`withbible://invite/group/:groupId`).
    *   **Joining**: 링크 클릭 시 앱 진입 및 해당 그룹으로 멤버 정보(`group_id`) 업데이트.
    *   **UI**: '내 그룹' 화면 (생성 전/후), 그룹 생성 바텀시트, 초대하기 버튼.
*   **User Story**:
    1.  **리더**: '그룹' 탭에서 "새 그룹 만들기"를 누른다. 그룹명(예: "청년1부 3셀")을 입력하면 그룹이 생성된다.
    2.  **리더**: "멤버 초대하기" 버튼을 눌러 카카오톡 등으로 링크를 공유한다.
    3.  **멤버**: 공유받은 링크를 클릭하면 앱이 열리고 "청년1부 3셀 그룹에 가입하시겠습니까?" 팝업이 뜬다.
    4.  **멤버**: "가입하기"를 누르면 나의 그룹 정보가 업데이트되고 그룹 화면이 보인다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Repository Pattern**: `GroupRepository` 신설.
    *   **Role Policy**: 현재 정책상 누구나 그룹을 만들 수 있게 허용하되, 생성 시 `leader_uid`를 본인으로 설정. (추후 권한 제어 가능)
    *   **Deep Linking**: `GoRouter`의 URL 처리 기능을 활용.
        *   Scheme: `https` (Web fallback) or Custom Scheme. MVP는 개발 용이성을 위해 Custom Scheme (`withbible://`) 또는 `go_router` path handling 활용.
        *   Route: `/invite/group/:groupId`
*   **Data Model**:
    *   **GroupModel**: `id`, `churchId`, `name`, `leaderUid`, `memberCount`, `createdAt`.
    *   **UserModel**: `groupId` 필드 활용.

## 3. Phase Breakdown (단계별 계획)

### Phase 1: Group Data Layer & Creation Logic
*   **Goal**: 그룹 데이터 모델링 및 Firestore 생성 기능 구현.
*   **Test Strategy**: Mock Firestore Test (그룹 생성 시 유저의 `groupId`는 업데이트 되지 않음 - 별도 로직).
*   **Rollback**: `GroupRepository` 삭제.

#### Tasks
*   [x] 🔴 **RED**: Write tests for `GroupRepository` (createGroup, fetchGroup).
*   [x] 🟢 **GREEN**: Define `GroupModel`.
*   [x] 🟢 **GREEN**: Implement `GroupRepository`.
*   [x] 🟢 **GREEN**: Create `CreateGroupUseCase` (Create group -> Return ID).
*   [x] 🔵 **REFACTOR**: Error handling (Same name validation etc.).
*   [x] 📝 Update documentation.

#### Quality Gate
*   [x] Build Success.
*   [x] Unit Tests Pass.

---

### Phase 2: Group Creation UI
*   **Goal**: 사용자가 그룹을 만들 수 있는 UI 구현.
*   **Test Strategy**: Widget Test (입력 폼, 버튼 동작).

#### Tasks
*   [x] 🔴 **RED**: Write tests for `GroupCreateBottomSheet`.
*   [x] 🟢 **GREEN**: Implement `GroupViewModel` (Create Group logic).
*   [x] 🟢 **GREEN**: Update `GroupScreen` (Show "Create Group" if no group).
*   [x] 🟢 **GREEN**: Implement `GroupCreateBottomSheet` UI.
*   [x] 🔵 **REFACTOR**: UX improvement (Loading indicator, Success Snackbar).

#### Quality Gate
*   [x] Build Success.
*   [x] User can create a group via UI.
*   [x] Firestore reflects the new group.

### Phase 3: Invitation & Deep Linking
*   **Goal**: 초대 링크 생성 및 앱 진입 시 처리 로직 구현.
*   **Test Strategy**: Unit Test (Router redirect logic), Manual Test (Deep Link click).

#### Tasks
*   [x] 🔴 **RED**: Write tests for `AppRouter` (Handle `/invite/group/:id`).
*   [x] 🟢 **GREEN**: Configure `GoRouter` for Deep Link path `/invite/group/:groupId`.
*   [x] 🟢 **GREEN**: Implement `JoinGroupScreen` (or Dialog) triggered by this route.
*   [x] 🟢 **GREEN**: Implement `joinGroup` logic (Request to join - Status 'pending').
*   [x] 🟢 **GREEN**: Add "Share Invite Link" button in `GroupScreen` (using `share_plus` package).
*   [x] 🔵 **REFACTOR**: Handle edge cases (Already in group, Invalid group ID).
*   [x] 📝 Update documentation.

#### Quality Gate
*   [x] Build Success.
*   [x] Accessing `/invite/group/{id}` shows join confirmation.
*   [x] User status becomes 'pending' for that group.

---

### Phase 4: Group Administration (Approval & Admins)
*   **Goal**: 그룹장의 멤버 가입 승인/거절 및 관리자(부리더) 임명 기능 구현.
*   **Test Strategy**: Unit Test (권한 체크 로직), Widget Test (관리자 화면).

#### Tasks
*   [x] 🔴 **RED**: Write tests for `GroupRepository` (approveMember, updateMemberRole).
*   [x] 🟢 **GREEN**: Update `GroupModel` or `UserModel` to support roles (leader, admin, member) and status (pending, active).
*   [x] 🟢 **GREEN**: Implement `GroupAdminScreen` (List of pending requests).
*   [x] 🟢 **GREEN**: Implement 'Approve/Reject' logic.
*   [x] 🟢 **GREEN**: Implement 'Promote to Admin' logic.
*   [x] 🔵 **REFACTOR**: Secure database rules (Only leader/admin can approve).
*   [x] 📝 Update documentation.

#### Quality Gate
*   [x] Build Success.
*   [x] Leader can see pending requests and approve/reject them.
*   [x] Leader can promote a member to admin.

## 4. Progress & Notes (진행 상황 및 노트)
*   **Status**: Completed
*   **Last Updated**: 2026-01-19

### Learnings & Issues
*   **Mock Generation**: `build_runner` with transitive dependencies required adding it as a direct dev dependency.
*   **Riverpod**: `StateNotifier` requires explicit import or `state_notifier` package in some contexts. Using `Notifier` is a more modern alternative.
*   **Testing**: Proper relative imports are crucial for Flutter tests to resolve packages correctly.
*   **Group Admin**: Added `groupStatus` to `UserModel` to handle pending requests efficiently.
