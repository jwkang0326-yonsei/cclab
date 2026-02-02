# PLAN-iOS-CICD-Setup (iOS 자동 배포 구축)

> **Note**: 이 계획은 `feature-planner` 프로토콜을 따릅니다.
> **Language**: 사용자의 선호도에 따라 한국어로 작성되었습니다.

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: Flutter 앱의 iOS 버전을 GitHub Actions를 통해 자동으로 빌드하고 TestFlight에 배포하는 CI/CD 파이프라인을 구축합니다.
*   **Scope**:
    *   Fastlane 설정 (인증서 관리 및 빌드 명령).
    *   GitHub Actions 워크플로우 작성.
    *   Apple App Store Connect API 키 연동.
*   **User Story**: 개발자가 `main` 브랜치에 코드를 푸시하면, 자동으로 iOS 앱이 빌드되어 TestFlight에 업로드되어 테스터들이 즉시 확인할 수 있습니다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Fastlane Match**: 인증서와 프로비저닝 프로필을 안전하게 관리하기 위해 Fastlane Match를 사용합니다. (Private Repository 또는 Google Cloud Storage 등을 저장소로 활용)
    *   **GitHub Actions**: macOS 런너를 사용하여 빌드를 수행합니다.
*   **Dependencies**: `fastlane`, `ruby`, `cocoapods`.
*   **Secrets Management**: 민감한 정보(API Key, Match Password 등)는 GitHub Repository Secrets에 저장합니다.

## 3. Risk Assessment (리스크 평가)
| Risk (위험요소) | Probability (확률) | Impact (영향) | Mitigation Strategy (완화 전략) |
| :--- | :--- | :--- | :--- |
| Apple 2FA 인증 문제 | High | High | App Store Connect API Key를 사용하여 2FA 우회 및 자동화 처리 |
| 인증서 만료/불일치 | Med | High | Fastlane Match를 통해 인증서를 중앙에서 관리하고 갱신 |
| 빌드 시간 증가 | High | Low | GitHub Actions 캐시(Cache) 활용하여 Pods 및 Flutter 의존성 로딩 속도 단축 |

## 4. Phase Breakdown (단계별 계획)

> **CRITICAL INSTRUCTIONS**: 각 단계 완료 후 Quality Gate를 통과해야 다음 단계로 진행합니다.

### Phase 1: 로컬 Fastlane 환경 구성 (Local Setup)
*   **Goal**: 로컬 머신에서 Fastlane을 초기화하고 수동으로 빌드 및 업로드가 가능한지 확인합니다.
*   **Test Strategy**: 로컬 터미널에서 `fastlane beta` 실행 시 에러 없이 TestFlight 업로드 성공.
*   **Rollback**: `ios/fastlane` 폴더 삭제 및 `Gemfile` 원복.

#### Tasks
*   [ ] 📝 **Init**: `ios` 디렉토리에서 `fastlane init` 실행.
*   [ ] 🔑 **Certificates**: `fastlane match` 설정 (인증서 저장소 연결).
*   [ ] 🛠 **Lane**: `Fastfile`에 `beta` 레인 작성 (build_app -> upload_to_testflight).
*   [ ] 🧪 **Verify**: 로컬에서 빌드 테스트 실행.

#### Quality Gate
*   [ ] 로컬에서 ipa 파일 생성 성공.
*   [ ] TestFlight 업로드 성공 확인.

---

### Phase 2: GitHub Actions 워크플로우 작성 (CI Configuration)
*   **Goal**: GitHub 서버(Runner)에서 빌드가 돌아가도록 스크립트를 작성합니다.
*   **Test Strategy**: 코드를 푸시했을 때 Actions 탭에서 워크플로우가 초록색(Success)으로 끝나는지 확인.
*   **Rollback**: `.github/workflows/ios-deploy.yml` 파일 삭제.

#### Tasks
*   [ ] 🔐 **Secrets**: GitHub Repo Settings에 필요한 Secrets 등록 (APP_STORE_CONNECT_KEY, MATCH_PASSWORD 등).
*   [ ] 📄 **Workflow**: `.github/workflows/ios-deploy.yml` 파일 생성.
*   [ ] ⚡️ **Optimization**: Flutter 및 Pods 캐싱 설정 추가.

#### Quality Gate
*   [ ] GitHub Actions 빌드 성공.
*   [ ] TestFlight에 새 빌드 번호 등장.

---

### Phase 3: 문서화 및 인수인계 (Documentation)
*   **Goal**: 추후 유지보수를 위해 설정 방법과 Secrets 관리법을 문서화합니다.
*   **Test Strategy**: 동료 개발자가 문서를 보고 설정을 이해할 수 있는지 확인.

#### Tasks
*   [ ] 📝 **Guide**: `docs/ios-cicd-guide.md` 작성 (Secrets 목록 및 갱신 방법).
*   [ ] 🧹 **Cleanup**: 불필요한 로그 및 임시 파일 정리.

## 5. Progress & Notes (진행 상황 및 노트)
*   **Status**: Planning
*   **Last Updated**: 2026-02-02

### Learnings & Issues
*   (작성 예정)
