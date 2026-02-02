# Feature Plan: Apple 로그인 (Sign in with Apple) 구현

## 1. 개요 (Overview)
*   **목표:** iOS 앱 스토어 심사 지침(4.8)을 준수하고 iOS 사용자에게 편리한 로그인 경험을 제공하기 위해 Apple 로그인 기능을 추가한다.
*   **배경:** 타사 소셜 로그인(구글 등)을 사용하는 iOS 앱은 반드시 Apple 로그인을 동등한 옵션으로 제공해야 한다.
*   **범위:**
    *   `sign_in_with_apple` 패키지 추가.
    *   Auth Repository 및 Firebase Auth 연동 로직 구현.
    *   로그인 화면(LoginScreen)에 Apple 로그인 버튼 추가 (iOS 전용).

## 2. 요구사항 (Requirements)
*   **기능:**
    *   사용자는 Apple ID로 로그인할 수 있어야 한다.
    *   로그인 성공 시 Firebase Auth에 사용자 세션이 생성되어야 한다.
    *   기존 User Repository 로직과 연동하여 DB에 사용자 정보(UID, 이메일, 이름)가 저장/동기화되어야 한다.
*   **UI/UX:**
    *   iOS 플랫폼에서만 'Apple로 시작하기' 버튼이 노출되어야 한다.
    *   Apple 디자인 가이드를 준수하는 버튼(`SignInWithAppleButton`)을 사용한다.
    *   버튼 위치는 구글 로그인 버튼과 인접하게 배치한다.

## 3. 기술 설계 (Technical Design)
*   **Dependencies:**
    *   `sign_in_with_apple: ^6.1.0` (최신 버전 확인 필요)
    *   `crypto` (Nonce 생성을 위해 필요할 수 있음)
*   **Architecture:**
    *   `AuthRepository`: `signInWithApple()` 메서드 추가.
        *   Nonce 생성 (Replay Attack 방지).
        *   Apple 네이티브 UI 요청.
        *   `OAuthProvider`를 통해 Firebase Auth `signInWithCredential` 호출.
    *   `LoginScreen`: `Platform.isIOS` 체크 후 버튼 렌더링.
*   **Data Model:**
    *   기존 `UserModel` 재사용.
    *   Apple 로그인은 이메일/이름 정보가 최초 로그인 시에만 제공될 수 있으므로, 해당 정보가 누락되지 않도록 처리 필요.

## 4. 구현 단계 (Implementation Steps)

### Phase 1: 설정 및 의존성 추가 (Setup)
- [ ] `pubspec.yaml`에 `sign_in_with_apple`, `crypto` 패키지 추가.
- [ ] iOS 설정 확인 (Capability 관련 내용은 문서화).

### Phase 2: 비즈니스 로직 구현 (Business Logic)
- [ ] `AuthRepository`에 `signInWithApple` 구현.
    - [ ] Nonce 생성 유틸리티 함수 작성.
    - [ ] `SignInWithApple.getAppleIDCredential` 호출.
    - [ ] Firebase Auth 연동.

### Phase 3: UI 구현 (UI Implementation)
- [ ] `LoginScreen`에 iOS 플랫폼 체크 로직 추가.
- [ ] `SignInWithAppleButton` 위젯 배치 및 핸들러 연결.
- [ ] 로그인 성공 후 기존 `UserRepository` 동기화 로직 재사용/검증.

### Phase 4: 테스트 및 검증 (Verification)
- [ ] 단위 테스트: `AuthRepository` Mock 테스트.
- [ ] 빌드 테스트: iOS 시뮬레이터 빌드 확인.

## 5. 품질 게이트 (Quality Gates)
*   [ ] `flutter analyze` 통과.
*   [ ] iOS 시뮬레이터에서 버튼 노출 및 정상 동작 확인 (실제 로그인은 시뮬레이터/실기기 환경에 따라 제약 있을 수 있음).
