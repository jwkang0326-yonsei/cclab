# [System Design] WithBible Architecture & Data Model

**작성일:** 2026.01.19
**문서 버전:** v1.0

---

## 1. System Architecture

### 1.1. Overview
WithBible은 **Flutter** 기반의 크로스 플랫폼 모바일 앱과 **Firebase** 기반의 Serverless 백엔드로 구성됩니다. MVP 단계에서는 빠른 개발과 운영 효율성을 위해 완전 관리형 서비스(SaaS)를 적극 활용합니다.

```mermaid
graph TD
    UserApp[Mobile App (Flutter)] -->|Auth/Data| Firebase[Firebase Backend]
    
    subgraph "Client Layer"
        UserApp
    end

    subgraph "Backend Layer (Firebase)"
        Auth[Authentication]
        DB[Firestore NoSQL]
        Storage[Cloud Storage]
        Functions[Cloud Functions]
    end

    subgraph "Admin Layer"
        Console[Firebase Console (Super Admin)]
        WebAdmin[Web Admin Portal (React/Next.js) - Phase 2]
    end

    WebAdmin -->|Manage| Firebase
```

### 1.2. Technology Stack
*   **Client:** Flutter (Dart)
*   **Backend:** Firebase (Auth, Firestore, Functions, Storage, Analytics)
*   **State Management:** Riverpod or Provider
*   **CI/CD:** GitHub Actions

---

## 2. Role & Permission Policy (역할 및 권한)

사용자의 `role` 필드를 통해 권한을 제어합니다. 계층 구조는 다음과 같습니다.

| Level | Role Name | Description | Permissions |
| :--- | :--- | :--- | :--- |
| **LV 0** | **Super Admin** | 개발팀/운영자 | - 모든 교회/데이터 접근 권한<br>- **교회 생성 및 초기 세팅**<br>- 시스템 설정 변경 |
| **LV 1** | **Church Admin** | 교역자/담당 간사 | - **본인 교회 데이터만 접근**<br>- 그룹(셀/구역) 생성 및 관리<br>- 소속 성도 목록 관리<br>- 교회 통계 열람 |
| **LV 2** | **Group Leader** | 셀리더/구역장 | - **본인 그룹원 데이터(읽기 현황) 열람**<br>- 그룹원 격려(알림 발송) |
| **LV 3** | **Member** | 일반 성도 | - 본인 기록 생성/수정<br>- 소속 그룹/교회 집계 데이터 열람 (익명) |

### 🔍 Church Creation Process (교회 생성 프로세스)
*   **MVP Policy:** 무분별한 데이터 생성을 방지하기 위해 앱 내 '교회 생성' 기능은 제공하지 않습니다.
*   **Process:**
    1.  교회 관리자가 제휴 신청.
    2.  **Super Admin**이 DB에 교회 정보 등록 및 `invite_code` 발급.
    3.  교회 관리자에게 코드 전달 -> 성도들에게 배포.

---

## 3. Data Model (Firestore Schema)

NoSQL 구조의 특성을 살려 읽기 성능에 최적화된 설계를 적용합니다.

### 3.1. `churches` (Collection)
교회 기본 정보입니다.
```json
{
  "id": "church_uuid",
  "name": "창천교회",
  "invite_code": "CHANG1004",  // Unique Index
  "admin_uid": "user_uid_of_pastor",
  "stats": {
    "total_members": 150,
    "total_reads": 4500
  },
  "created_at": "timestamp"
}
```

### 3.2. `groups` (Collection)
교회 하위 조직 (셀, 구역, 목장 등)입니다.
```json
{
  "id": "group_uuid",
  "church_id": "church_uuid",
  "name": "청년1부 3셀",
  "leader_uid": "user_uid_of_leader",
  "created_at": "timestamp"
}
```

### 3.3. `users` (Collection)
사용자 프로필 및 설정입니다.
```json
{
  "uid": "firebase_auth_uid",
  "email": "user@example.com",
  "name": "이믿음",
  "role": "member", // super_admin, church_admin, leader, member
  "church_id": "church_uuid",
  "group_id": "group_uuid",
  "settings": {
    "push_enabled": true,
    "target_amount": 3 // 하루 목표 장수
  },
  "stats": {
    "current_streak": 5,
    "total_chapters": 120
  }
}
```

### 3.4. `records` (Collection)
일일 성경 읽기 기록입니다.
```json
{
  "id": "record_uuid",
  "user_uid": "user_uid",
  "church_id": "church_uuid", // 쿼리 성능을 위한 비정규화
  "group_id": "group_uuid",   // 쿼리 성능을 위한 비정규화
  "date": "2026-01-19",
  "bible_range": "Genesis 1-3",
  "quiz_result": true,
  "meditation": "하나님의 창조 섭리를 묵상했습니다.",
  "created_at": "timestamp"
}

### 3.5. `group_goals` (Collection)
그룹별 목표 설정입니다.
```json
{
  "id": "goal_uuid",
  "group_id": "group_uuid",
  "title": "1월 마태복음 정복",
  "type": "book", // book, whole, custom
  "target_range": ["Matthew"], // or "Matthew 1-28"
  "start_date": "2026-01-01",
  "end_date": "2026-01-31",
  "status": "active"
}
```

### 3.6. `group_map_state` (Collection)
그룹의 성경 읽기 지도 상태 (하나의 문서에 Map 형태로 저장하여 읽기 비용 절약).
*   **Document ID:** `group_uuid`
```json
{
  "chapters": {
    "Matthew_1": {
      "status": "CLEARED", // OPEN, LOCKED, CLEARED
      "user_id": "user_123",
      "updated_at": "timestamp"
    },
    "Matthew_2": {
      "status": "LOCKED",
      "user_id": "user_456",
      "locked_at": "timestamp" // Timeout 체크용
    }
    // ... 최대 1189개 키 (1MB 제한 내 충분)
  },
  "total_progress": 15.5 // (%)
}
```
```

---

## 4. Admin System Strategy (관리자 시스템 전략)

### 4.1. Phase 1: MVP (App Only)
*   **전략:** 별도의 관리자 웹사이트를 개발하지 않고, 최소한의 리소스로 운영.
*   **교회/그룹 생성:** 개발자(Super Admin)가 Firebase Console 또는 스크립트로 직접 주입.
*   **관리 기능:** 앱 내 '마이페이지'에서 리더/관리자 권한이 있는 경우에만 '우리 그룹 현황' 메뉴 노출.

### 4.2. Phase 2: Web Admin Portal
*   **전략:** 교역자가 PC에서 엑셀 작업 등을 할 수 있도록 웹 개발.
*   **기능:**
    *   성도 일괄 등록 (Excel Upload)
    *   조직 개편 (Drag & Drop)
    *   주보용 통계 텍스트 자동 생성 및 복사
    *   전체 공지사항 푸시 발송

## 5. Security & Validation
*   **Firestore Rules:** `church_id`가 일치하는 문서만 읽기/쓰기 가능하도록 엄격한 보안 규칙 적용.
*   **Cloud Functions:** 랭킹 집계, 통계 업데이트 등 무결성이 중요한 작업은 백엔드 트리거로 처리.
