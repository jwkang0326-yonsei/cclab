# PLAN-ios-deployment

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: iOS 앱의 TestFlight(운영/베타) 및 Firebase App Distribution(개발) 배포 자동화를 구축한다.
*   **Scope**:
    *   Fastlane Match를 통한 인증서 관리 (Private Git Repo 연동)
    *   `appstore` (TestFlight) 및 `adhoc` (Firebase) 프로비저닝 프로필 생성
    *   Firebase App Distribution용 `firebase_dist` 레인 구현
    *   GitHub Actions 워크플로우(`ios-dev-deploy.yml`) 구축
*   **User Story**: 개발자가 코드를 푸시하면 iOS 앱이 자동으로 빌드되어 Firebase(개발팀 확인용) 또는 TestFlight(최종 검수용)에 업로드된다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Certificate Management**: Fastlane Match (Git storage mode)
    *   **Deployment Tool**: Fastlane
    *   **Storage**: `https://github.com/jwkang0326-yonsei/cclab_private.git`
    *   **Authentication**: App Store Connect API Key
*   **Workflow**:
    1.  `match`를 통해 인증서 및 프로필 다운로드
    2.  Flutter iOS 빌드 (`flutter build ios --no-codesign`)
    3.  Fastlane `gym`(build_app)으로 아카이빙 및 서명
    4.  Firebase 또는 TestFlight 업로드

## 3. Risk Assessment (리스크 평가)
| Risk (위험요소) | Probability (확률) | Impact (영향) | Mitigation Strategy (완화 전략) |
| :--- | :--- | :--- | :--- |
| 인증서 충돌 | High | High | 기존 인증서를 정리하거나 `match nuke`를 통한 초기화 고려 (주의 필요) |
| GitHub Action 시간 초과 | Medium | Medium | macOS 러너의 비용과 시간을 고려하여 빌드 최적화 |
| 2FA 인증 이슈 | Medium | High | App Store Connect API Key를 사용하여 세션 만료 문제 방지 |

## 4. Phase Breakdown (단계별 계획)

### Phase 1: Match Configuration
*   **Goal**: 인증서 공유 저장소 연동 및 기본 설정 완료
*   **Quality Gate**: `Matchfile` 설정 완료, 로컬 `match` 실행 성공

#### Tasks
*   [x] 🟢 **GREEN**: `app/ios/fastlane/Matchfile` 업데이트 (Git URL 및 타입 설정)
*   [x] 🟢 **GREEN**: `app/ios/fastlane/Fastfile`에 `match` 호출 로직 추가
*   [x] 📝 GitHub Secrets 설정 가이드 작성

---

### Phase 2: Firebase App Distribution (iOS)
*   **Goal**: iOS 개발 빌드를 Firebase로 배포
*   **Quality Gate**: Firebase 콘솔에 iOS 빌드 업로드 확인

#### Tasks
*   [x] 🟢 **GREEN**: `adhoc` 프로필 생성 및 Match 저장소 업로드 (로컬 실행 완료)
*   [x] 🟢 **GREEN**: `Fastfile`에 `firebase_dist` 레인 구현
*   [x] 🟢 **GREEN**: `ios-dev-deploy.yml` 워크플로우 생성

---

### Phase 3: TestFlight Deployment (iOS)
*   **Goal**: TestFlight 자동 배포 완성
*   **Quality Gate**: TestFlight에 새로운 빌드 버전 등장 확인

#### Tasks
*   [x] 🟢 **GREEN**: `appstore` 프로필 생성 및 Match 저장소 업로드 (로컬 실행 완료)
*   [x] 🟢 **GREEN**: `Fastfile`의 `beta` 레인 고도화 (API Key 사용)
*   [x] 🟢 **GREEN**: `store-deploy.yml`의 `deploy_ios` 잡 활성화 및 검증

## 5. Progress & Notes (진행 상황 및 노트)
*   **Status**: In Progress
*   **Last Updated**: 2026-02-12
