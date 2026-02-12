# PLAN-android-dev-deployment

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: `main` 브랜치에 코드가 푸시될 때마다 Firebase App Distribution을 통해 Android 앱(APK)을 자동으로 배포하여, 개발팀 및 테스터가 최신 빌드를 즉시 확인할 수 있도록 한다.
*   **Scope**:
    *   Firebase App Distribution 설정 (App ID 확인 및 테스터 그룹 설정)
    *   Fastlane에 `firebase_dist` 레인 추가
    *   GitHub Actions 워크플로우(`android-dev-deploy.yml`) 생성 및 기존 Secret 연동
*   **User Story**: 개발자가 기능을 완성하고 `main` 브랜치에 병합하면, 별도의 수동 작업 없이 Firebase를 통해 테스터들에게 "새로운 빌드가 준비되었습니다"라는 알림이 전송된다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Deployment Tool**: Fastlane + Firebase App Distribution Plugin (또는 Firebase CLI)
    *   **Authentication**: Google Service Account (`FIREBASE_SERVICE_ACCOUNT_CCLAB_4EC42`)
    *   **Trigger**: Push to `main` branch & Workflow Dispatch (manual)
*   **Workflow Flow**:
    1.  Code Checkout
    2.  Setup Java/Flutter/Ruby
    3.  Decode Keystore & Create `key.properties`
    4.  Build APK (`flutter build apk --release`)
    5.  Upload to Firebase via Fastlane or Firebase CLI

## 3. Risk Assessment (리스크 평가)
| Risk (위험요소) | Probability (확률) | Impact (영향) | Mitigation Strategy (완화 전략) |
| :--- | :--- | :--- | :--- |
| 인증 오류 (Service Account) | Medium | High | GitHub Secrets에 저장된 JSON 키의 권한을 사전에 확인하고, 로컬 테스트로 검증 |
| 빌드 시간 초과 | Low | Medium | GitHub Actions 캐시(Flutter, Gradle) 활용하여 빌드 시간 최적화 |
| 플러그인 호환성 (Fastlane) | Low | Low | Fastlane 플러그인 방식이 복잡할 경우 Firebase CLI 직접 호출 방식으로 선회 |

## 4. Phase Breakdown (단계별 계획)

### Phase 1: Local Setup & Fastlane Configuration
*   **Goal**: 로컬 환경에서 Firebase App Distribution 배포가 가능한 Fastlane 레인 구성
*   **Test Strategy**: 로컬에서 `fastlane android firebase_dist` 실행 (성공 여부 확인)
*   **Rollback**: `Fastfile` 변경 사항 취소

#### Tasks
*   [x] 🔴 **RED**: (N/A - CI 설정은 빌드 성공 여부가 테스트를 대신함)
*   [x] 🟢 **GREEN**: `app/android/fastlane/Fastfile`에 `firebase_dist` 레인 추가
*   [x] 🟢 **GREEN**: Firebase App ID 및 테스터 그룹 정보 설정
*   [x] 🔵 **REFACTOR**: Fastlane 코드 정리 및 환경 변수 활용

#### Quality Gate
*   [x] Fastlane lane defined in `Fastfile`
*   [x] Local build success (`flutter build apk --release`)

---

### Phase 2: GitHub Actions Workflow Implementation
*   **Goal**: GitHub Actions에서 자동 배포 워크플로우 완성
*   **Test Strategy**: 테스트 브랜치 푸시 또는 `workflow_dispatch`로 실행 결과 확인
*   **Rollback**: 생성된 `.yml` 파일 삭제

#### Tasks
*   [x] 🔴 **RED**: CI 실행 시 배포 단계에서 실패하는 것 확인 (초기 설정 미비 상태)
*   [x] 🟢 **GREEN**: `app/.github/workflows/android-dev-deploy.yml` 생성
*   [x] 🟢 **GREEN**: Keystore 복호화 및 Firebase Service Account 연동
*   [x] 🟢 **GREEN**: 빌드된 APK를 Firebase로 업로드하는 스텝 구현
*   [x] 🔵 **REFACTOR**: 워크플로우 스텝 최적화 및 캐싱 추가

#### Quality Gate
*   [x] GitHub Action execution success
*   [x] APK successfully uploaded to Firebase App Distribution
*   [x] Notification received by testers (Firebase console check)

## 5. Progress & Notes (진행 상황 및 노트)
*   **Status**: In Progress
*   **Last Updated**: 2026-02-12

### Learnings & Issues
*   (To be filled during development)
