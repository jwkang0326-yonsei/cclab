# PLAN-init-and-home-ui

> **Note**: This plan follows the `feature-planner` protocol.
> **Language**: Korean

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: Flutter 프로젝트 초기 환경을 구축하고, 'WithBible'의 핵심 디자인 컨셉(모던 가드닝)이 적용된 **메인 홈 화면**과 **네비게이션**을 구현한다.
*   **Scope**:
    *   Flutter Project Create & Setup (Lint, CI)
    *   Design System (Colors, Fonts, Theme)
    *   Bottom Navigation (Home, Group, Report)
    *   Home Screen UI Skeleton (Mock Data)
*   **User Story**: 사용자는 앱을 실행하여 깔끔한 '모던 가드닝' 테마를 경험하고, 하단 탭을 통해 주요 메뉴로 이동할 수 있으며, 홈 화면에서 나의 '영적 성장 나무'와 '오늘의 말씀' 카드를 볼 수 있다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**:
    *   **Architecture**: Clean Architecture + Riverpod (State Management)
    *   **UI Framework**: Flutter (Material 3)
    *   **Navigation**: GoRouter (URL 기반 라우팅 지원 및 확장성 고려)
*   **Folder Structure**:
    *   `lib/core/theme`: 디자인 시스템 정의
    *   `lib/features/home`: 홈 화면 관련 위젯 및 로직
    *   `lib/features/common`: 공통 위젯 (Bottom Nav 등)
*   **Dependencies**: `flutter_riverpod`, `go_router`, `google_fonts`

## 3. Risk Assessment (리스크 평가)
| Risk (위험요소) | Probability (확률) | Impact (영향) | Mitigation Strategy (완화 전략) |
| :--- | :--- | :--- | :--- |
| 디자인 컨셉 불일치 | Medium | Medium | 초기 단계에서 Color/Font 테마를 빠르게 구현하여 사용자(기획자) 피드백 수렴 |
| 과도한 UI 구현 시간 | Medium | Low | 복잡한 인터랙션 제외, 정적(Static) UI 먼저 구현 후 애니메이션 추가 |

## 4. Phase Breakdown (단계별 계획)

> **CRITICAL INSTRUCTIONS**: After completing each phase:
> 1.  ✅ Check off completed task checkboxes
> 2.  🧪 Run all quality gate validation commands
> 3.  ⚠️ Verify ALL quality gate items pass
> 4.  📅 Update "Last Updated" date
> 5.  📝 Document learnings in Notes section
> 6.  ➡️ Only then proceed to next phase
>
> ⛔ DO NOT skip quality gates or proceed with failing checks

### Phase 1: Project Initialization & Environment Setup
*   **Goal**: 에러 없이 빌드되는 깨끗한 Flutter 프로젝트 환경 구축
*   **Test Strategy**: `flutter test` (기본 Counter 앱 테스트 통과 확인)
*   **Rollback**: `git clean -fdx` 및 프로젝트 재생성

#### Tasks (TDD Cycle)
*   [x] 🔴 **RED**: (Skip - 초기 세팅 단계)
*   [x] 🟢 **GREEN**: `flutter create .` 및 기본 디렉토리 정리
*   [x] 🟢 **GREEN**: `analysis_options.yaml` 설정 (Lint 적용)
*   [x] 🟢 **GREEN**: `.gitignore` 설정
*   [x] 🔵 **REFACTOR**: 불필요한 주석 및 파일 제거
*   [x] 📝 Update documentation (README.md)

#### Quality Gate (완료 기준)
*   [x] Build Success (`flutter run` runs without errors)
*   [x] Lint Check Pass (`flutter analyze` returns no issues)
*   [x] Project Structure matches Clean Architecture guidelines

---

### Phase 2: Design System Implementation
*   **Goal**: '모던 가드닝' 컨셉의 컬러, 폰트, 테마 적용
*   **Test Strategy**: Widget Test (Theme 적용 확인)
*   **Rollback**: `lib/core/theme` 폴더 롤백

#### Tasks
*   [x] 🔴 **RED**: Write widget test checking for specific Primary Color & Font Family
*   [x] 🟢 **GREEN**: Add `google_fonts` dependency
*   [x] 🟢 **GREEN**: Define `AppColors` (Green/Wood tones) & `AppTextStyles`
*   [x] 🟢 **GREEN**: Implement `AppTheme` class and apply to `MaterialApp`
*   [x] 🔵 **REFACTOR**: Centralize theme logic
*   [x] 📝 Update documentation

#### Quality Gate
*   [x] Build Success
*   [x] Tests Pass (`Theme` is correctly applied)
*   [x] Visual verification of color palette

---

### Phase 3: Navigation & Main Skeleton
*   **Goal**: 하단 탭 바(Bottom Navigation) 및 화면 라우팅 구조 완성
*   **Test Strategy**: Widget Test (탭 클릭 시 화면 전환 검증)
*   **Rollback**: `lib/router` 및 `MainScreen` 롤백

#### Tasks
*   [x] 🔴 **RED**: Write test ensuring 3 tabs exist and switch pages
*   [x] 🟢 **GREEN**: Add `go_router`, `flutter_riverpod` dependencies
*   [x] 🟢 **GREEN**: Implement `AppRouter`
*   [x] 🟢 **GREEN**: Create `MainLayout` with `BottomNavigationBar`
*   [x] 🟢 **GREEN**: Create placeholder screens (Home, Group, Report)
*   [x] 🔵 **REFACTOR**: Separate navigation logic into provider
*   [x] 📝 Update documentation

#### Quality Gate
*   [x] Build Success
*   [x] All Tests Pass (Navigation works)
*   [x] Lint/Format Check Pass

---

### Phase 4: Home Screen UI (Mock)
*   **Goal**: 홈 화면의 시각적 완성도 확보 (나무, 체크카드)
*   **Test Strategy**: Golden Test (UI 시각 검증) or Widget Test (요소 존재 여부)
*   **Rollback**: `lib/features/home` 롤백

#### Tasks
*   [x] 🔴 **RED**: Write test checking for 'Tree Widget' and 'Today Card' presence
*   [x] 🟢 **GREEN**: Implement `HomeHeader` (User greeting)
*   [x] 🟢 **GREEN**: Implement `GrowthTreeWidget` (Placeholder image/icon)
*   [x] 🟢 **GREEN**: Implement `TodayBibleCard` (Mock data)
*   [x] 🔵 **REFACTOR**: Extract reusable widgets (Cards, Buttons)
*   [x] 📝 Update documentation

#### Quality Gate
*   [x] Build Success
*   [x] UI matches 'Modern Gardening' concept (Visual Check)
*   [x] All Tests Pass

## 5. Progress & Notes (진행 상황 및 노트)
*   **Status**: Completed
*   **Last Updated**: 2026-01-19

### Learnings & Issues
*   **CardTheme Conflict**: `CardTheme` 타입 충돌 이슈로 인해 테마 파일에서 일시적으로 제외함. 추후 Flutter/SDK 업데이트 시 재확인 필요.
*   **ProviderScope**: Riverpod 테스트 시 `pumpWidget` 내부에 `ProviderScope`를 반드시 포함해야 함.
*   **Navigation Test**: 화면 전환 테스트 시, 단순 텍스트 매칭보다는 실제 위젯의 존재 여부나 유니크한 텍스트를 찾는 것이 더 견고함.

### Learnings & Issues
*   (To be filled during development)
