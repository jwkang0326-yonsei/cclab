# Feature Plan: Bible Map Book Expansion & Selection

## 1. 개요 (Overview)
성경 읽기 지도(Bible Map) 화면에서 각 성경 책(Book) 단위로 챕터 목록을 접었다 펼칠 수 있는 기능과, 책 단위로 전체 챕터를 일괄 선택/해제할 수 있는 기능을 추가합니다. 이는 사용자가 긴 성경 목록을 효율적으로 탐색하고 관리할 수 있도록 돕습니다.

## 2. 목표 (Goals)
- **책 접기/펼치기**: 각 성경 책의 챕터 그리드를 숨기거나 보이게 할 수 있어야 함.
- **책 전체 선택/해제**: 책 제목 옆의 체크박스를 통해 해당 책의 모든 챕터를 선택하거나 선택 해제할 수 있어야 함.
- **UI 개선**: 책 제목 옆에 체크박스와 접기/펼치기 토글 아이콘(Chevron)을 배치.

## 3. 구현 상세 (Implementation Details)

### 3.1 상태 관리 (State Management)
- **위치**: `_BibleMapScreenState` (Local State)
- **추가 변수**:
  - `Set<String> _collapsedBookKeys`: 접혀있는(숨겨진) 책의 Key들을 저장. (기본값: 비어있음 = 모두 펼쳐짐)
  - `_isSelectionMode`: 기존 로직 유지하되, 체크박스 상호작용 시 자동으로 선택 모드로 진입.

### 3.2 UI 변경 (`_buildBookSection`)
- **헤더 영역**:
  - 기존: 텍스트 클릭 시 전체 선택.
  - 변경: `Row` 위젯 구성.
    - **Left**: `Checkbox`
      - 상태: 해당 책의 모든 챕터가 `_selectedKeys`에 포함되어 있으면 `true`, 하나도 없으면 `false`. (중간 상태는 고려하지 않거나 추후 개선)
      - 동작: 
        - 체크 시: 해당 책의 모든 챕터 키를 `_selectedKeys`에 추가.
        - 해제 시: 해당 책의 모든 챕터 키를 `_selectedKeys`에서 제거.
    - **Center**: 책 제목 (Text)
    - **Right**: `IconButton` (Toggle)
      - 아이콘: `_collapsedBookKeys` 포함 여부에 따라 `ExpandMore` / `ExpandLess`.
      - 동작: `_collapsedBookKeys`에 추가/제거하여 UI 갱신.

### 3.3 로직 (Logic)
- **`_toggleBookCollapse(String bookKey)`**: 책의 펼침 상태 토글.
- **`_toggleBookSelection(bool? value, String bookKey, int chapterCount)`**: 
  - `value == true`: 1~count 챕터 키 생성 후 `_selectedKeys`에 `addAll`.
  - `value == false`: 1~count 챕터 키 생성 후 `_selectedKeys`에서 `removeAll`.
  - 선택된 키가 하나라도 있으면 `_isSelectionMode = true`. 없으면 `false`.

## 4. 테스트 계획 (Test Plan)
- [ ] **UI 렌더링**: 각 책 옆에 체크박스와 토글 아이콘이 정상적으로 표시되는가?
- [ ] **접기/펼치기**: 토글 아이콘 클릭 시 챕터 그리드가 사라지고 나타나는가?
- [ ] **전체 선택**: 체크박스 선택 시 해당 책의 모든 챕터가 선택되는가?
- [ ] **전체 해제**: 체크박스 해제 시 해당 책의 모든 챕터 선택이 해제되는가?
- [ ] **부분 선택 반응**: 개별 챕터를 선택했다가 책 체크박스를 눌렀을 때 정상 동작하는가?

## 5. 단계별 실행 (Phases)
1. **상태 추가 및 토글 로직 구현**: `_collapsedBookKeys` 추가 및 토글 아이콘 구현.
2. **체크박스 및 전체 선택 로직 구현**: 헤더 UI 개편 및 선택 로직 연결.
3. **테스트 및 검증**: 앱 실행 후 동작 확인.
