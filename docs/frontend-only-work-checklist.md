# 프론트 단독 작업 체크리스트

이 문서는 백엔드 API 확정이나 서버 응답 변경 없이 프론트엔드에서 독립적으로 진행할 수 있는 작업을 정리합니다. 버튼 동작, 페이지 이동, 로컬 상태 전이, dialog, bottom sheet, 애니메이션, 반응형 QA처럼 앱 사용감에 직접 영향을 주지만 서버 구현에 의존하지 않는 항목을 우선 다룹니다.

## 참고 문서

- `README.md`
- `docs/routing-guide.md`
- `docs/screen-publishing-rules.md`
- `docs/shared-widget-guide.md`
- `docs/design-token-rules.md`
- `docs/state-management-guide.md`
- `docs/testing-guide.md`
- `docs/figma-frame-map.md`

## 프론트 단독 작업 판단 기준

아래 조건을 모두 만족하면 백엔드 영향 없이 진행 가능한 작업으로 분류합니다.

- [ ] `COMMONPLANT_USE_API=false` 또는 로컬 Provider/더미 데이터만으로 재현할 수 있다.
- [ ] 실제 서버 저장, 삭제, 인증, 이미지 업로드, 주소 API 결과가 없어도 동작을 확인할 수 있다.
- [ ] API request/response schema 변경이 필요하지 않다.
- [ ] 화면 위젯 내부에서 임시 상태 또는 feature `presentation/providers`로 상태 전이를 검증할 수 있다.
- [ ] 실패/빈 상태는 프론트에서 사용자용 메시지와 재시도 동작으로 표현할 수 있다.
- [ ] 작업 결과를 widget test 또는 route test로 검증할 수 있다.

아래 항목은 백엔드 확인 또는 API 연동 작업으로 분리합니다.

- [ ] 소셜 로그인 성공/실패와 토큰 저장 정책
- [ ] 서버에 장소, 식물, 메모, 친구 요청을 실제로 생성/수정/삭제하는 동작
- [ ] 서버에서 내려주는 주소, 사용자, 식물 종 검색 결과
- [ ] 이미지 업로드 URL, multipart 정책, 권한 에러 처리
- [ ] API 에러 코드별 사용자 메시지 매핑
- [ ] staging API, 테스트 계정, seed 데이터가 필요한 integration test

## 우선 처리 후보

현재 코드 기준으로 백엔드 없이도 UX 완성도를 높일 수 있는 항목입니다.

- [ ] 주소 검색에서 선택한 주소를 장소 등록/수정 폼으로 `pop(result)` 전달한다.
  - 대상: `lib/features/place/presentation/pages/address_search_page.dart`
  - 대상: `lib/features/place/presentation/pages/place_form_page.dart`
- [ ] 장소 이미지 추가 버튼에 로컬 선택/삭제 상태를 연결한다.
  - 대상: `lib/features/place/presentation/pages/place_form_page.dart`
- [ ] 메모 목록의 수정 액션이 팝업 닫기로만 끝나지 않도록 수정 화면 또는 로컬 편집 흐름을 연결한다.
  - 대상: `lib/features/memo/presentation/pages/memo_list_page.dart`
- [ ] 식물 수정 사진 버튼에 선택/삭제 상태를 연결한다.
  - 대상: `lib/features/plant/presentation/pages/plant_form_page.dart`
- [ ] 식물 등록의 마지막 물 준 날짜 선택 UI를 로컬 날짜 picker 상태로 구현한다.
  - 대상: `lib/features/plant/presentation/pages/plant_form_page.dart`
- [ ] 홈 하단 탭의 탭 가능 상태와 준비 중 처리를 정리한다.
  - 대상: `lib/features/home/presentation/home_screen.dart`

## 공통 체크리스트

### 라우팅과 페이지 이동

- [ ] 시작하기, 로그인, 프로필 완료, 약관 보기/복귀 플로우가 끊기지 않는다.
- [ ] 홈 카드, 추가 버튼, 요청 버튼, 상세 화면 FAB 액션이 의도한 route로 이동한다.
- [ ] 생성/수정 화면에서 `context.push`, 완료 후 `context.go` 또는 `context.pop(result)` 사용이 흐름에 맞다.
- [ ] 주소 검색, 친구 추가, 메모 작성처럼 이전 화면으로 값을 돌려줘야 하는 흐름은 `pop(result)`를 사용한다.
- [ ] `placeId`, `plantId`가 없거나 비어 있을 때 빈 상태 또는 오류 상태를 표시한다.
- [ ] 뒤로가기, 취소, 완료 버튼이 같은 화면에서 서로 다른 목적을 명확히 가진다.

### 버튼과 상태 전이

- [ ] 모든 CTA는 enabled, disabled, loading 상태를 가진다.
- [ ] 제출 버튼은 중복 탭을 방지한다.
- [ ] 선택/해제 버튼은 현재 선택 상태를 화면에 즉시 반영한다.
- [ ] 삭제, 나가기, 초기화처럼 되돌리기 어려운 동작은 확인 dialog를 거친다.
- [ ] 버튼 텍스트는 한 줄로 유지하고 작은 화면에서 잘리지 않는다.
- [ ] 터치 영역은 최소 44 logical pixel 이상 확보한다.

### Dialog, Bottom Sheet, Popup

- [ ] 프로필 사진 bottom sheet는 선택, 기본 이미지 변경, 취소 상태를 분리한다.
- [ ] 사진 권한 dialog는 허용, 제한 선택, 거부 상태를 로컬 상태로 검증한다.
- [ ] 친구 삭제, 장소 나가기, 메모 삭제 dialog는 취소/확인 후 닫힘 상태가 명확하다.
- [ ] FAB dial은 열기, 닫기, 바깥 탭, 액션 선택 동작을 모두 검증한다.
- [ ] 메모 수정/삭제 popup은 작은 화면에서도 화면 밖으로 잘리지 않는다.
- [ ] overlay가 열린 상태에서 뒤로가기 또는 다른 액션을 눌러도 중복 overlay가 남지 않는다.

### 애니메이션과 마이크로 인터랙션

- [ ] FAB dial open/close 애니메이션이 자연스럽다.
- [ ] 검색 결과와 empty 상태 전환이 갑작스럽게 튀지 않는다.
- [ ] 요청 수락/삭제, 친구 선택/해제, 사진 추가/삭제 상태 전환이 즉시 보인다.
- [ ] 버튼 press/ripple 효과가 공용 위젯 기준과 일관된다.
- [ ] 페이지 전환 애니메이션은 route 정책과 충돌하지 않는다.

### 반응형과 접근성

- [ ] 작은 화면에서 긴 한글 문구가 overflow되지 않는다.
- [ ] 키보드가 올라왔을 때 입력 필드와 하단 CTA가 가려지지 않는다.
- [ ] `SafeArea`, `SingleChildScrollView`, `Expanded`, `Flexible`을 적절히 사용한다.
- [ ] 아이콘 버튼에는 `tooltip` 또는 `semanticsLabel`이 있다.
- [ ] 상태값은 색상만으로 구분하지 않고 텍스트나 선택 상태도 함께 제공한다.
- [ ] 화면 확대, 긴 닉네임, 긴 장소명, 긴 주소에서도 레이아웃이 무너지지 않는다.

## 도메인별 체크리스트

### Login, Onboarding, Terms

- [ ] 온보딩 시작하기 버튼이 로그인 화면으로 이동한다.
- [ ] 카카오, 구글, Apple 로그인 버튼은 API 미연동 상태에서도 다음 화면 진입 smoke flow를 제공한다.
- [ ] 프로필 닉네임 입력은 2자 미만, 10자 초과, 정상 입력 상태를 구분한다.
- [ ] 프로필 완료 버튼은 닉네임 유효성, 약관 동의 여부, 제출 중 상태를 반영한다.
- [ ] 약관 보기 후 프로필 화면으로 돌아오면 약관 동의 상태가 유지된다.
- [ ] 프로필 사진 선택 sheet와 권한 dialog를 widget test로 검증한다.

### Home

- [ ] 장소가 없을 때 장소 추가 tile이 노출되고 장소 등록으로 이동한다.
- [ ] 장소가 있을 때 장소 카드와 헤더 추가 버튼이 노출된다.
- [ ] 식물 추가는 장소가 없으면 disabled 상태로 보인다.
- [ ] 장소 요청 버튼은 요청 목록으로 이동한다.
- [ ] 하단 탭의 미구현 영역은 준비 중 처리 또는 명확한 비활성 상태를 가진다.
- [ ] 홈 loading, error, empty, success 상태가 구분된다.

### Place

- [ ] 장소 요청 확인/삭제 버튼은 누른 항목만 결과 상태로 바꾼다.
- [ ] 장소 등록에서 이름과 주소 입력 여부에 따라 다음 버튼이 활성화된다.
- [ ] 주소 검색 선택 결과가 장소 등록/수정 화면 필드에 반영된다.
- [ ] 장소 이미지 추가 버튼은 선택 전/선택 후/삭제 상태를 가진다.
- [ ] 친구 추가 검색은 검색 전, 결과 있음, 결과 없음, 선택 후 상태를 구분한다.
- [ ] 친구 관리 삭제 dialog 확인 시 선택 마크와 목록 상태가 함께 갱신된다.
- [ ] 장소 상세 FAB는 리더/팀원 역할에 따라 액션 구성이 달라진다.
- [ ] 장소 나가기 dialog의 취소/확인 동작을 검증한다.

### Plant

- [ ] 식물 검색은 검색 전, 결과 있음, 결과 없음 상태를 구분한다.
- [ ] 검색 결과 선택 시 식물 등록 2단계로 식물명이 전달된다.
- [ ] 식물 등록 2단계에서 장소 카드 선택 상태가 명확하다.
- [ ] 마지막 물 준 날짜는 로컬 날짜 picker로 선택/초기화할 수 있다.
- [ ] 등록 취소는 이전 화면 또는 홈으로 일관되게 이동한다.
- [ ] 식물 수정 이름 입력은 변경 여부와 제출 중 상태를 반영한다.
- [ ] 식물 수정 사진 버튼은 선택/삭제 상태를 가진다.
- [ ] 식물 상세의 메모 전체보기와 작성하기 버튼이 메모 route로 이동한다.

### Memo

- [ ] 메모 작성 사진 추가 버튼은 최대 개수와 삭제 상태를 반영한다.
- [ ] 메모 본문 입력 길이와 완료 버튼 활성화 조건을 검증한다.
- [ ] 작성 완료 후 메모 목록으로 이동하고 로컬 목록에 추가된다.
- [ ] 메모 목록 empty 상태와 작성 CTA가 함께 보인다.
- [ ] 메모 메뉴 popup은 수정/삭제 액션을 모두 제공한다.
- [ ] 메모 수정 액션은 별도 편집 화면 또는 로컬 편집 상태로 연결한다.
- [ ] 메모 삭제 dialog 확인 시 로컬 목록에서 해당 항목이 제거된다.

## 테스트 기준

프론트 단독 작업은 네트워크 호출 없이 빠른 widget/unit test로 검증합니다.

- [ ] 새 화면 또는 새 상태의 초기 렌더링 테스트를 추가한다.
- [ ] 버튼 enabled/disabled/loading 상태 변화를 테스트한다.
- [ ] `tap`, `enterText`, `pumpAndSettle`로 주요 상호작용을 검증한다.
- [ ] dialog, bottom sheet, popup의 열림/닫힘/확인 액션을 테스트한다.
- [ ] route 이동 또는 `pop(result)` 흐름을 테스트한다.
- [ ] Provider가 필요한 화면은 `ProviderScope` override로 네트워크 의존성을 제거한다.
- [ ] 테스트에서 실제 API, 실제 저장소, 실제 이미지 업로드에 의존하지 않는다.

문서만 수정한 경우 아래 명령을 실행합니다.

```bash
git diff --check
```

Flutter 코드가 변경된 경우 아래 명령을 실행합니다.

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

## 후속 이슈 분리 기준

아래 조건 중 하나라도 해당하면 이 체크리스트 항목을 별도 GitHub 이슈로 분리합니다.

- [ ] 둘 이상의 route 또는 feature를 함께 수정해야 한다.
- [ ] 공용 위젯 옵션 확장 또는 디자인 토큰 추가가 필요하다.
- [ ] API 연동 여부에 따라 로컬/원격 상태 분기가 생긴다.
- [ ] widget test 외에 repository, mapper, provider test가 필요하다.
- [ ] Figma node-id 재확인 또는 문서 갱신이 선행되어야 한다.
- [ ] 작업 결과가 Project 10 category/status, assignees, milestone 갱신 대상이다.
