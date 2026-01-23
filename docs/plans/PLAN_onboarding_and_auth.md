# PLAN-onboarding-and-auth

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: 사용자 인증(Google Login)을 구현하고, '초대 코드' 입력을 통해 소속 교회를 매칭하여 앱 진입 권한을 부여한다.
*   **Scope**:
    *   Firebase Authentication (Google Sign-In) 연동.
    *   Onboarding UI (로그인 화면, 초대 코드 입력 화면).
    *   Firestore 'churches' 컬렉션 조회 및 유저 'church_id' 매핑 로직.
    *   로그인 상태 및 소속 여부에 따른 라우팅 리다이렉트 (Guard).
*   **User Story**: 
    1. 앱을 처음 켠 사용자는 'Google로 시작하기' 버튼을 누른다.
    2. 로그인이 완료되면 '초대 코드 입력' 화면으로 이동한다.
    3. 교회에서 받은 코드를 입력하면 해당 교회 이름이 뜨고 가입이 완료된다.
    4. 이후 앱 실행 시 자동으로 홈 화면으로 진입한다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Auth Provider**: `firebase_auth` + `google_sign_in`.
    *   **State Management**: Riverpod `StreamProvider`로 인증 상태 감지.
    *   **Routing Guard**: `GoRouter`의 `redirect` 기능을 사용하여 인증되지 않은 유저는 '/login', 인증되었으나 교회가 없는 유저는 '/onboarding'으로 보냄.
    *   **Repository Pattern**: `AuthRepository`, `ChurchRepository` 분리.
*   **Data Model**:
    *   `users` 컬렉션에 `church_id` 필드 추가.
    *   `churches` 컬렉션 구조 확정 (invite_code 필드 필수).

## 3. Phase Breakdown (단계별 계획)

### Phase 1: Authentication Setup (Google Login)
*   **Goal**: Firebase Google 로그인 연동 및 로그인 화면 UI 구현.
*   **Test Strategy**: Unit Test (Repository Mocking), Widget Test (로그인 버튼 존재 여부).
*   **Rollback**: `firebase_auth` 패키지 제거 및 Auth 관련 코드 삭제.

#### Tasks
*   [x] 🔴 **RED**: Write tests for AuthRepository (signIn, signOut).
*   [x] 🟢 **GREEN**: Add `firebase_auth`, `google_sign_in` dependencies.
*   [x] 🟢 **GREEN**: Implement `AuthRepository` & `AuthProvider`.
*   [x] 🟢 **GREEN**: Create `LoginScreen` UI with Google Button.
*   [x] 🔵 **REFACTOR**: Connect UI to Repository via Riverpod.
*   [x] 📝 Update documentation.

#### Quality Gate
*   [x] Build Success.
*   [x] Google Login works (Manual Verify).
*   [x] Auth State changes correctly detected.

---

### Phase 2: Firestore Setup & User Profile
*   **Goal**: 로그인 시 Firestore에 유저 정보(`users`) 생성/저장.
*   **Test Strategy**: Mock Firestore Test.
*   **Rollback**: Firestore Rules 롤백.

#### Tasks
*   [x] 🔴 **RED**: Write tests for UserRepository (create/get user).
*   [x] 🟢 **GREEN**: Add `cloud_firestore` dependency.
*   [x] 🟢 **GREEN**: Implement `UserRepository`.
*   [x] 🟢 **GREEN**: Update Auth flow to create user doc on first login.
*   [x] 🔵 **REFACTOR**: Ensure safe data merging.
*   [x] 📝 Update documentation.

#### Quality Gate
*   [x] Build Success.
*   [x] User document created in Firestore upon login.

---

### Phase 3: Church Matching (Invite Code)
*   **Goal**: 초대 코드 입력 UI 및 교회 매칭 로직 구현.
*   **Test Strategy**: Integration Test (코드 입력 -> DB 조회 -> 성공/실패).
*   **Rollback**: `ChurchRepository` 코드 롤백.

#### Tasks
*   [x] 🔴 **RED**: Write tests for ChurchRepository (verifyCode).
*   [x] 🟢 **GREEN**: Implement `ChurchRepository`.
*   [x] 🟢 **GREEN**: Create `OnboardingScreen` (Code Input Field).
*   [x] 🟢 **GREEN**: Implement 'Join Church' logic (Update user's `church_id`).
*   [x] 🔵 **REFACTOR**: Add error handling (Invalid code, Network error).
*   [x] 📝 Update documentation.

#### Quality Gate
*   [x] Build Success.
*   [x] Valid code joins church, Invalid code shows error.

---

### Phase 4: Router Guard & Redirection
*   **Goal**: 인증 및 교회 가입 여부에 따라 올바른 화면으로 자동 이동.
*   **Test Strategy**: Unit Test (GoRouter redirect logic).

#### Tasks
*   [x] 🔴 **RED**: Write test cases for redirect logic.
*   [x] 🟢 **GREEN**: Update `AppRouter` with `redirect` logic.
*   [x] 🟢 **GREEN**: Define '/login' and '/onboarding' routes.
*   [x] 🔵 **REFACTOR**: Optimize stream listening for redirects.
*   [x] 📝 Update documentation.

#### Quality Gate
*   [x] Unauthenticated -> Login Screen.
*   [x] Authenticated but No Church -> Onboarding Screen.
*   [x] All Set -> Home Screen.

## 4. Progress & Notes (진행 상황 및 노트)
*   **Status**: Completed
*   **Last Updated**: 2026-01-19

### Learnings & Issues
*   **Breaking Change in `google_sign_in` 7.2.0**: 
    *   `GoogleSignIn()` constructor removed -> Use `GoogleSignIn.instance`.
    *   `initialize()` must be called explicitly.
    *   `signIn()` replaced by `authenticate()`.
    *   `authentication` is now a synchronous getter.
    *   `accessToken` removed from `GoogleSignInAuthentication` (idToken only).
*   **Router Redirect & Riverpod**: Redirect logic requires watching `authState` and `userProfile`. Tests must mock these providers to verify navigation behavior properly.
