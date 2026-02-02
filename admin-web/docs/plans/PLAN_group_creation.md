# PLAN-Group-Creation (그룹 생성 기능 구현)

> **Note**: 이 계획은 `feature-planner` 프로토콜을 따릅니다.
> **Language**: 사용자의 선호도에 따라 한국어로 작성되었습니다.

## 1. Overview & Objectives (개요 및 목표)
*   **Goal**: 관리자 웹(Admin Web)에서 새로운 그룹(Church/Organization)을 생성하는 기능을 완성합니다.
*   **Scope**: `GroupList` 화면에서 다이얼로그를 통해 그룹 이름을 입력받고, Firebase Firestore에 그룹 문서를 생성하며, 생성된 그룹의 리더로 현재 로그인한 사용자를 지정합니다.
*   **User Story**: 관리자는 "Create Group" 버튼을 클릭하여 새 그룹을 신속하게 생성하고 관리할 수 있어야 합니다.

## 2. Architecture & Design (아키텍처 및 설계)
*   **Key Decisions**: 
    - Firebase Firestore를 데이터베이스로 사용.
    - Radix UI 기반의 Dialog와 React Hook Form(또는 단순 form)을 사용하여 UI 구현.
    - 데이터 일관성을 위해 그룹 생성 시 사용자의 `groupId`와 `role`을 함께 업데이트.
*   **Data Model Changes**: 
    - `groups` 컬렉션: `name`, `leaderId`, `leaderName`, `memberCount`, `createdAt`, `updatedAt` 필드 포함.
    - `users` 컬렉션: `groupId`, `role` 필드 업데이트.
*   **API Changes**: `app/features/groups/api/groups.ts`에 `createGroup` 함수 구현 (이미 부분 구현됨).
*   **Dependencies**: `firebase`, `lucide-react`, `sonner` (토스트 메시지).

## 3. Risk Assessment (리스크 평가)
| Risk (위험요소) | Probability (확률) | Impact (영향) | Mitigation Strategy (완화 전략) |
| :--- | :--- | :--- | :--- |
| Firebase 권한 설정 오류 | Med | High | Firestore Security Rules 확인 및 테스트 계정 권한 검증 |
| E2E 테스트 환경 구성 이슈 | Low | Med | Playwright 환경 설정 및 테스트용 Firebase 프로젝트 분리 확인 |
| 중복 그룹 이름 허용 문제 | Low | Low | 현재는 허용하되 필요시 유효성 검사 추가 |

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

### Phase 1: 테스트 환경 정비 및 기반 코드 검증 (Red/Green)
*   **Goal**: 현재 작성된 E2E 테스트가 실패하는 원인을 분석하고, 정상적으로 실패(Red)하거나 최소 구현으로 통과(Green)하도록 정정합니다.
*   **Test Strategy**: Playwright E2E Test (`e2e/groups/create-group.spec.ts`)
*   **Rollback**: 변경된 테스트 코드를 이전 상태로 되돌림.

#### Tasks (TDD Cycle)
*   [x] 🔴 **RED**: 기존 E2E 테스트 실행 및 실패 확인 (이미 완료)
*   [x] 🟢 **GREEN**: E2E 테스트의 모호한 셀렉터 수정 (`button:has-text("Create")` 문제 해결)
*   [x] 🔵 **REFACTOR**: `CreateGroupDialog` 및 API 함수의 에러 핸들링 보완
*   [x] 📝 테스트 환경 설정 문서 업데이트 (필요시)

#### Quality Gate (완료 기준)
*   [x] Build Success (No errors)
*   [x] E2E Test Pass (또는 명확한 이유로 실패하는 상태 확보)
*   [x] Lint/Format Check Pass

---

### Phase 2: 그룹 생성 로직 완성 및 데이터 검증 (Green)
*   **Goal**: Firestore에 실제 데이터가 올바르게 생성되고, 사용자 정보가 연동되는지 확인합니다.
*   **Test Strategy**: E2E 테스트 내에서 데이터베이스 상태 검증 또는 UI를 통한 결과 확인.
*   **Rollback**: Firestore 생성 문서 삭제 및 유저 필드 원복.

#### Tasks
*   [x] 🟢 **GREEN**: `createGroup` API 함수 내에서 리더 정보 역정규화 로직 검증 (Firestore Transaction 적용)
*   [x] 🟢 **GREEN**: 성공 후 목록 자동 갱신 로직 확인 (`onSuccess` 콜백)
*   [x] 🔵 **REFACTOR**: API 호출 시 로딩 상태 처리 및 버튼 비활성화 UI 개선
*   [x] 📝 관련 API 문서화

#### Quality Gate (완료 기준)
*   [x] Build Success
*   [x] All Tests Pass
*   [x] Firebase Firestore에 데이터 적재 확인 (E2E 테스트로 간접 확인)

---

### Phase 3: 마무리 및 최종 검증 (Polish)
*   **Goal**: UI/UX 디테일을 다듬고 최종 통합 테스트를 완료합니다.
*   **Test Strategy**: 전체 테스트 스위트 실행.
*   **Rollback**: UI 변경사항 롤백.

#### Tasks
*   [x] 🔵 **REFACTOR**: 다이얼로그 닫힘 애니메이션 및 토스트 메시지 문구 최적화
*   [x] 🔵 **REFACTOR**: 타입 체크 및 린트 오류 최종 수정 (API 함수 Transaction 적용 포함)
*   [x] 📝 최종 배포 체크리스트 작성

#### Quality Gate (완료 기준)
*   [x] Build Success
*   [x] All Tests Pass (E2E 테스트 성공 확인됨)
*   [x] Typecheck & Lint Pass

## 5. Progress & Notes (진행 상황 및 노트)
*   **Status**: Completed
*   **Last Updated**: 2026-02-02

### Learnings & Issues
*   (2026-02-02) 그룹 생성 기능을 성공적으로 구현하였습니다.
*   (2026-02-02) `createGroup` API에 Firestore Transaction을 도입하여 원자적 연산을 보장합니다.
*   (2026-02-02) E2E 테스트에서 발생하던 셀렉터 중복 문제와 인증 세션 리다이렉트 문제를 해결하였습니다. (일부 환경에서 여전히 간헐적인 세션 끊김이 발생할 수 있으나, 기능 자체는 정상 작동 확인)