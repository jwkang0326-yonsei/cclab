# Feature Plan: 그룹 생성 기능 (Group Creation)

**작성일:** 2026-01-23
**상태:** Planning
**작성자:** Gemini Agent

## 1. 개요 (Overview)
관리자 웹(Admin Web)에서 새로운 그룹(Church/Organization)을 생성하는 기능을 구현합니다.
현재 `GroupList` 화면에 "Create Group" 버튼은 존재하지만 동작하지 않는 상태입니다. 이를 활성화하여 이름을 입력받고 Firestore에 새 그룹 문서를 생성하는 기능을 완성합니다.

## 2. 목표 (Objectives)
- **UI:** `GroupList` 화면에서 "Create Group" 버튼 클릭 시 다이얼로그 표시.
- **Input:** 그룹 이름 입력 (유효성 검사 포함).
- **Data:** Firestore `groups` 컬렉션에 새로운 문서 생성.
  - 생성 시 현재 로그인한 관리자의 ID를 `leaderId`로 자동 지정.
- **UX:** 생성 성공 시 토스트 메시지 표시 및 목록 자동 갱신.

## 3. 단계별 구현 계획 (Implementation Phases)

### Phase 1: 테스트 작성 (TDD - Red)
*목표: 실패하는 E2E 테스트를 먼저 작성하여 요구사항을 명확히 합니다.*

1. **E2E 테스트 파일 생성**: `e2e/groups/create-group.spec.ts`
2. **테스트 시나리오**:
    - 로그인 수행.
    - 그룹 목록 페이지 이동.
    - "Create Group" 버튼 클릭.
    - 다이얼로그에 "New Test Group" 입력 후 저장.
    - 목록에 "New Test Group"이 추가되었는지 검증.
    - (추가 검증) 생성된 그룹의 리더가 본인인지 데이터베이스 수준 또는 UI 수준에서 확인 (Phase 2에서 구현).
3. **예상 결과**: UI 요소 및 로직 부재로 테스트 실패.

### Phase 2: 기능 구현 (Green)
*목표: 테스트를 통과하는 최소한의 코드를 작성합니다.*

1. **API 함수 추가**: `app/features/groups/api/groups.ts`
    - `createGroup(name: string, leaderId: string)` 함수 구현.
    - Firestore `addDoc` 활용 및 `leaderId` 포함.
2. **UI 컴포넌트 생성**: `app/features/groups/components/create-group-dialog.tsx`
    - Radix UI Dialog + Form (React Hook Form + Zod) 사용.
    - 현재 로그인한 유저 정보를 가져와서 API에 전달.
3. **화면 연동**: `app/features/groups/screens/group-list.tsx`
    - "Create Group" 버튼에 다이얼로그 연결.
    - 생성 성공 후 `revalidate` 또는 리스트 갱신 트리거.

### Phase 3: 검증 및 리팩토링 (Refactor)
*목표: 코드 품질을 확보하고 배포 준비를 마칩니다.*

1. **E2E 테스트 재실행**: 모든 테스트 통과 확인.
2. **Lint & Typecheck**: `npm run lint`, `npm run typecheck` 수행.
3. **코드 정리**: 불필요한 로그 제거, 주석 보완.

## 4. 퀄리티 게이트 (Quality Gates)
각 단계 종료 시 아래 항목을 반드시 만족해야 합니다.

- [ ] **Gate 1 (Test)**: `npm run test:e2e` 실행 시 신규 테스트가 의도대로 실패(Red)하는가?
- [ ] **Gate 2 (Impl)**: `npm run test:e2e`가 모두 통과(Green)하는가?
- [ ] **Gate 3 (Audit)**: `npm run typecheck` 및 `npm run lint`에 오류가 없는가?

## 5. 승인 요청 (Approval Request)
위 계획대로 **Phase 1 (테스트 작성)** 을 시작하시겠습니까?
