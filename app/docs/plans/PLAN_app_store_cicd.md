# PLAN-App-Store-CICD (양대 마켓 자동 배포 구축)

> **Note**: 이 계획은 `feature-planner` 프로토콜을 따릅니다.
> **Language**: 사용자의 선호도에 따라 한국어로 작성되었습니다.

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: Flutter 앱을 Google Play Store(Android)와 Apple App Store(iOS)에 자동으로 빌드하고 배포하는 CI/CD 파이프라인을 구축합니다.
*   **Scope**:
    *   **Android**: Fastlane을 이용한 Google Play Internal/Alpha 트랙 배포.
    *   **iOS**: Fastlane을 이용한 TestFlight 배포 (기존 계획 보완).
    *   **GitHub Actions**: 통합 워크플로우 작성 및 Secrets 관리.
*   **User Story**: `release` 브랜치에 코드를 푸시하거나 태그를 생성하면, 자동으로 양대 마켓의 테스터들에게 새 버전이 배포됩니다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Tools**: Fastlane (배포 자동화), GitHub Actions (CI 서버).
*   **Signing Strategy**:
    *   **Android**: Keystore 파일을 GitHub Secrets에 Base64로 인코딩하여 저장하거나, Fastlane Match(선택) 사용.
    *   **iOS**: Fastlane Match를 사용하여 인증서 및 프로파일 동기화.
*   **Versioning**: `pubspec.yaml`의 버전을 기준으로 자동으로 빌드 번호를 증가시키는 전략 채택.

## 3. Risk Assessment (리스크 평가)
| Risk (위험요소) | Probability (확률) | Impact (영향) | Mitigation Strategy (완화 전략) |
| :--- | :--- | :--- | :--- |
| Google Play API 권한 오류 | Med | High | 서비스 계정 권한(관리자) 및 JSON 키 재발급 절차 문서화 |
| Apple 2FA 및 세션 만료 | High | High | App Store Connect API Key(.p8) 사용으로 세션 만료 문제 해결 |
| 빌드 서명 파일 유출 | Low | Critical | GitHub Secrets 암호화 저장 및 Base64 인코딩/디코딩 스크립트 활용 |

## 4. Phase Breakdown (단계별 계획)

> **CRITICAL INSTRUCTIONS**: 각 단계 완료 후 Quality Gate를 통과해야 다음 단계로 진행합니다.

### Phase 1: Android 배포 환경 구성 (Google Play)
*   **Goal**: 로컬에서 Fastlane으로 Google Play Store 내부 테스트(Internal) 트랙에 업로드 성공.
*   **Prerequisites**:
    *   Google Play Console에 앱 생성 완료 (수동으로 첫 빌드 업로드 필요).
    *   서비스 계정 JSON 키 발급.
*   **Tasks**:
    *   [ ] 📝 **Init**: `android` 폴더에서 `fastlane init` 실행.
    *   [ ] 🔑 **Keystore**: 서명 키 설정 및 `key.properties` 연동 확인.
    *   [ ] 🛠 **Lane**: `Fastfile`에 `internal` 레인 작성 (upload_to_play_store).
    *   [ ] 🧪 **Verify**: 로컬에서 `fastlane internal` 실행 성공.

### Phase 2: iOS 배포 환경 구성 (App Store)
*   **Goal**: 로컬에서 Fastlane으로 TestFlight 업로드 성공 (기존 계획 Phase 1 완료 및 검증).
*   **Tasks**:
    *   [ ] 📝 **Config**: `Appfile`, `Matchfile`에 실제 정보 입력 확인.
    *   [ ] 🔑 **Certificates**: `fastlane match appstore` 실행하여 인증서 생성.
    *   [ ] 🧪 **Verify**: 로컬에서 `fastlane beta` 실행 성공.

### Phase 3: GitHub Actions 통합 (CI/CD)
*   **Goal**: GitHub Actions에서 Android 및 iOS 빌드/배포를 동시에 수행.
*   **Tasks**:
    *   [ ] 🔐 **Secrets**: `ANDROID_KEYSTORE_BASE64`, `PLAY_STORE_JSON_KEY_BASE64` 등 Secrets 등록.
    *   [ ] 📄 **Workflow**: `.github/workflows/store-deploy.yml` 작성.
    *   [ ] 🔄 **Trigger**: `v*` 태그 푸시 시 배포되도록 트리거 설정.

### Phase 4: 문서화 및 인수인계
*   **Goal**: 배포 프로세스 및 Secrets 갱신 방법 문서화.
*   **Tasks**:
    *   [ ] 📝 **Guide**: `docs/store-deploy-guide.md` 작성.

## 5. Required Information (필요 정보)

사용자(관리자)는 다음 정보를 준비하여 GitHub Secrets에 등록해야 합니다.

**Android**:
1.  `ANDROID_KEYSTORE_BASE64`: `.jks` 파일을 Base64로 인코딩한 문자열.
2.  `ANDROID_KEY_PASSWORD`: 키 비밀번호.
3.  `ANDROID_STORE_PASSWORD`: 스토어 비밀번호.
4.  `ANDROID_KEY_ALIAS`: 키 별칭.
5.  `PLAY_STORE_JSON_KEY_BASE64`: Google Play API 서비스 계정 JSON 파일(Base64).

**iOS**:
1.  `MATCH_PASSWORD`: Match 저장소 비밀번호.
2.  `MATCH_GIT_BASIC_AUTHORIZATION`: 인증서 Repo 접근 토큰.
3.  `APP_STORE_CONNECT_API_KEY_KEY`: .p8 파일 내용.
4.  `APP_STORE_CONNECT_API_KEY_KEY_ID`: Key ID.
5.  `APP_STORE_CONNECT_API_KEY_ISSUER_ID`: Issuer ID.

## 6. Progress & Notes
*   **Status**: Planning
*   **Last Updated**: 2026-02-11
