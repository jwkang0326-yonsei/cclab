# Feature Plan: Auth Data Sync & Group Stats

## 1. 개요 (Overview)
- **목표**: Google 로그인 시 사용자 정보(이름, 이메일) 동기화 문제를 해결하고, 그룹 멤버 승인 시 멤버 수(`memberCnt`)가 자동으로 집계되도록 기능을 개선합니다.
- **관련 기능**: Google Sign-In, 그룹 관리(멤버 승인).

## 2. 문제점 및 원인 (Problems & Causes)
1.  **사용자 정보(이름/이메일) 누락**:
    - 현행 로직은 최초 가입 시(`existingUser == null`)에만 `createUser`를 호출함.
    - 이미 문서가 존재하는 유저는 로그인 시 Google의 최신 정보(이름, 이메일)로 업데이트되지 않음.
    - `church_id` 등 다른 필드가 비어있을 때 이를 보정할 기회가 없음.
2.  **그룹 멤버 수(`memberCnt`) 미반영**:
    - 멤버 승인(`updateMemberStatus`) 시 단순히 유저의 상태만 변경하고 있음.
    - 그룹 문서(`groups/{groupId}`)의 카운터가 증가하지 않음.

## 3. 구현 계획 (Implementation Plan)

### Phase 1: Auth 로직 개선 (User Data Sync)
- **목표**: 로그인 성공 시 항상 사용자 정보를 최신으로 갱신.
- **작업 내용**:
    - `LoginScreen`의 `onPressed` 로직 수정.
    - `existingUser` 여부와 관계없이 `UserRepository.createUser`(또는 `syncGoogleUser`)를 호출하여 `name`, `email`을 업데이트.
    - `SetOptions(merge: true)`를 유지하여 기존 `church_id`나 `groupId`가 날아가지 않도록 주의.

### Phase 2: 그룹 멤버 승인 트랜잭션 구현 (Group Stats)
- **목표**: 멤버 승인 시 데이터 무결성 보장 (User Status Update + Group Count Increment).
- **작업 내용**:
    - `GroupRepository`에 `approveMember(String userId)` 메서드 구현.
    - **Firestore Transaction** 사용:
        1.  `users/{userId}` 읽기 -> `groupId` 및 현재 상태 확인.
        2.  `groups/{groupId}` 읽기 -> 현재 `memberCnt` 확인.
        3.  User Doc 업데이트: `groupStatus` = 'active'.
        4.  Group Doc 업데이트: `memberCnt` = `memberCnt` + 1.

## 4. 테스트 계획 (Test Plan)
1.  **로그인 테스트**:
    - 기존 유저로 로그인 시, Firestore의 `name` 필드를 임의로 변경해두고 로그인을 시도.
    - 로그인 후 Firestore의 `name`이 Google 프로필 이름으로 복구되는지 확인.
2.  **멤버 승인 테스트**:
    - 리더 계정으로 대기 상태(`pending`)인 멤버 승인.
    - 승인 직후 `groups` 컬렉션의 해당 그룹 문서의 `memberCnt`가 1 증가하는지 확인.
    - 동시성 테스트(선택): 빠르게 여러 명을 승인해도 카운트가 정확한지 확인.

## 5. 승인 요청 (Approval Request)
위 계획에 따라 수정을 진행하시겠습니까?
