# 로그인 확장 (Email, Kakao, Refactoring) 계획

## 1. 개요
*   **목표:** 기존 구글, 애플 로그인 외에 이메일 로그인과 카카오 로그인을 추가하고, 사용자 이름/직책 설정 기능을 구현함.
*   **상태:** 완료 (2026-02-02)

## 2. 구현 완료 내역

### Phase 1: 패키지 추가 및 기본 설정
*   [x] `kakao_flutter_sdk` 패키지 추가 (v1.9.0).
*   [x] `android/app/build.gradle.kts`에 `manifestPlaceholders` 추가 (카카오 키 설정).
*   [x] `ios/Runner/Info.plist`에 URL 스킴 추가.

### Phase 2: AuthRepository 확장
*   [x] `AuthRepository`에 이메일 로그인/가입 메서드 추가.
*   [x] `AuthRepository`에 카카오 로그인 메서드 추가.

### Phase 3: UI 구현
*   [x] `LoginScreen` 리팩토링: 버튼 정리.
*   [x] 이메일 로그인/회원가입 UI 구현 (메인 화면 통합).
*   [x] 카카오 로그인 버튼 추가 및 연동.
*   [x] `ProfileSetupScreen` 구현: 이름/직책 입력 및 수정.

### Phase 4: 테스트 및 검증
*   [x] Android/iOS 빌드 및 실행 테스트 완료.
*   [x] 크래시 이슈(`ClassNotFoundException`) 해결: `AndroidManifest.xml` 수정 및 `manifestPlaceholders` 적용.
*   [x] 이름/직책 설정 로직 검증: 로그인 성공 시 필수 정보 누락 확인 후 이동.

## 3. 메모
*   카카오 SDK 1.10.0은 Flutter SDK 버전 이슈로 사용 불가하여 1.9.0 사용.
*   `AndroidManifest.xml`에 수동으로 Activity를 추가하면 크래시 발생. `manifestPlaceholders` 사용 권장.
*   `UserModel`에 `position` 필드 추가됨.
