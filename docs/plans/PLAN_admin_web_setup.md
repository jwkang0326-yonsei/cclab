# PLAN-admin-web-setup

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: 'WithBible' 성경 통독 플랫폼을 위한 **교회 관리자 웹(Admin Web)**을 구축한다. 기존 Supabase 템플릿을 제거하고 Firebase로 전환하며, **교회 통계 대시보드** 및 **소그룹 관리** 기능을 구현한다.
*   **Scope**:
    *   **Admin Web Setup**: React(Vite) + Firebase SDK 연동 (기존 템플릿 정리).
    *   **Authentication**: 관리자 로그인 (Firebase Auth).
    *   **Dashboard**: 교회 전체 통독 현황 및 통계 시각화.
    *   **Group Management**: 소그룹(셀/구역) 편성, 리더 임명, 멤버 관리.
*   **User Story**: 교회 관리자(교역자/간사)는 웹에 로그인하여 우리 교회의 전체 통독 진도율을 확인하고, 청년부를 셀별로 편성하거나 리더를 임명할 수 있다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Framework**: React Router 7 (Vite based) - `admin-web` 디렉토리.
    *   **Backend**: Firebase (Firestore, Auth) - `cclab-4ec42` 프로젝트 공유.
    *   **UI Library**: Shadcn UI (Radix UI + Tailwind CSS) - 템플릿 내장 활용.
    *   **Data Access**: Firestore SDK (Client-side) with Security Rules or Admin SDK (via Cloud Functions if needed - MVP는 Client SDK 권장).
*   **Folder Structure (`admin-web/app`)**:
    *   `services/firebase.ts`: Firebase 설정.
    *   `features/auth`: 로그인.
    *   `features/dashboard`: 통계 차트 (Recharts 등 활용).
    *   `features/groups`: 그룹 CRUD 및 멤버 이동.

## 3. Risk Assessment (리스크 평가)
| Risk (위험요소) | Probability (확률) | Impact (영향) | Mitigation Strategy (완화 전략) |
| :--- | :--- | :--- | :--- |
| 복잡한 통계 쿼리 성능 | Medium | Medium | Firestore 집계 쿼리(`count`, `sum`) 활용, 필요 시 클라이언트에서 가공. |
| 개인정보 노출 | Low | High | Firestore Security Rules로 관리자(`role: admin`)만 접근 가능하도록 엄격히 제한. |
| 데이터 구조 변경 | High | Medium | `groups`, `users` 컬렉션 구조를 앱 개발팀과 확정 후 어드민 개발 착수. |

## 4. Phase Breakdown (단계별 계획)

> **CRITICAL INSTRUCTIONS**: After completing each phase:
> 1.  ✅ Check off completed task checkboxes
> 2.  🧪 Run all quality gate verification steps
> 3.  ⚠️ Verify ALL quality gate items pass
> 4.  📅 Update "Last Updated" date
> 5.  📝 Document learnings in Notes section
> 6.  ➡️ Only then proceed to next phase

### Phase 1: Environment Cleanup & Firebase Setup
*   **Goal**: Supabase 코드 제거 및 Firebase SDK 연동.
*   **Test Strategy**: Manual Verification (Console log on init).
*   **Rollback**: `git checkout .`

#### Tasks
*   [ ] 🔴 **RED**: Create `test-firebase.ts` failing to import.
*   [ ] 🟢 **GREEN**: Remove Supabase dependencies/files.
*   [ ] 🟢 **GREEN**: Install `firebase`.
*   [ ] 🟢 **GREEN**: Copy config from `app/lib/firebase_options.dart` to `.env`.
*   [ ] 🟢 **GREEN**: Initialize Firebase App in `app/services/firebase.ts`.
*   [ ] 🔵 **REFACTOR**: Build check (`npm run build`).

#### Quality Gate
*   [ ] Build Success.
*   [ ] Firebase App initialized successfully.

---

### Phase 2: Authentication (Admin Login)
*   **Goal**: 관리자 로그인 구현.
*   **Test Strategy**: E2E Test (Login success/fail).
*   **Rollback**: Revert `features/auth`.

#### Tasks
*   [ ] 🔴 **RED**: E2E test for Login page.
*   [ ] 🟢 **GREEN**: Create `LoginPage`.
*   [ ] 🟢 **GREEN**: Implement `signInWithEmailAndPassword`.
*   [ ] 🟢 **GREEN**: Implement ProtectedRoute (Session check).
*   [ ] 🔵 **REFACTOR**: AuthContext for user state.

#### Quality Gate
*   [ ] Login with valid credentials works.
*   [ ] Unauthenticated access redirects to Login.

---

### Phase 3: Church Dashboard (Statistics)
*   **Goal**: 교회 전체 통계(참여율, 진도율) 대시보드 구현.
*   **Test Strategy**: Component Test (Mock data rendering).
*   **Rollback**: Revert `features/dashboard`.

#### Tasks
*   [ ] 🔴 **RED**: Test for Dashboard component.
*   [ ] 🟢 **GREEN**: Fetch dummy statistics from Firestore (or mock).
*   [ ] 🟢 **GREEN**: Visualize data using Charts (e.g., Shadcn Charts or Recharts).
    *   (Suggestion: Weekly Participation Rate, Total Chapters Read)
*   [ ] 🔵 **REFACTOR**: Optimize data fetching.

#### Quality Gate
*   [ ] Dashboard displays accurate mock/real data.
*   [ ] Charts render correctly.

---

### Phase 4: Group Management
*   **Goal**: 소그룹 리스트 조회 및 상세 관리.
*   **Test Strategy**: Manual Verification (Firestore data update).
*   **Rollback**: Revert `features/groups`.

#### Tasks
*   [ ] 🔴 **RED**: Test for GroupList component.
*   [ ] 🟢 **GREEN**: Fetch `groups` collection from Firestore.
*   [ ] 🟢 **GREEN**: Display group list with summary (Leader, Member count).
*   [ ] 🟢 **GREEN**: Implement Group Detail view (Member list).
*   [ ] 🔵 **REFACTOR**: Pagination or Virtualization for large lists.

#### Quality Gate
*   [ ] Can view all groups.
*   [ ] Can see members within a group.

## 5. Progress & Notes (진행 상황 및 노트)
*   **Status**: Planning
*   **Last Updated**: 2026-01-20

### Learnings & Issues
*   (To be filled)
