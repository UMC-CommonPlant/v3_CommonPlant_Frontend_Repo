# 폼 검증 및 에러 메시지 작성 기준

커먼플랜트의 입력 UI는 `CommonTextField`를 중심으로 구성합니다. 폼 검증은 화면마다 임시 문자열과 조건문을 흩뿌리지 않고, 재사용 가능한 validator와 Controller 상태로 관리합니다.

## 현재 입력 컴포넌트

| 위젯 | 용도 |
| --- | --- |
| `CommonTextField` | 일반 텍스트 입력 |
| `CommonSearchTextField` | 검색 입력 |
| `CommonAddressOrPlaceField` | 주소 또는 장소 선택 |
| `CommonPhotoAddButton` | 사진 추가 |
| `CommonPlaceImageAddButton` | 장소 이미지 추가 |
| `CommonCircleImageBox` | 프로필 이미지 입력 |

## CommonTextField 상태

`CommonTextField`는 아래 상태를 가집니다.

| 상태 | 의미 |
| --- | --- |
| `normal` | 기본 상태 |
| `success` | 검증 성공 |
| `error` | 검증 실패 |
| `disabled` | 입력 불가 |

상태와 helper text는 `CommonTextFieldValidation`으로 반환합니다.

```dart
CommonTextField(
  hintText: '닉네임을 입력해 주세요',
  maxLength: 10,
  validator: (value, isFocused) {
    if (value.trim().length < 2) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.error,
        helperText: '2자 이상 입력해 주세요',
      );
    }

    return const CommonTextFieldValidation(
      state: CommonTextFieldState.success,
      helperText: '사용 가능한 닉네임입니다',
    );
  },
)
```

## 검증 위치 기준

| 검증 종류 | 위치 |
| --- | --- |
| 글자 수, 필수값, 간단한 형식 | field validator 또는 form widget |
| 여러 입력값 조합 검증 | form Controller |
| 서버 중복 확인 | Controller 또는 Provider |
| API 실패 메시지 | repository/controller의 에러 매핑 이후 화면 표시 |

간단한 샘플 화면에서는 StatefulWidget 내부 validator를 사용할 수 있습니다. 실제 기능 화면에서는 제출 가능 여부와 서버 검증 결과를 Controller 상태로 분리합니다.

## 메시지 작성 기준

- 사용자가 무엇을 고치면 되는지 알려줍니다.
- 서버 내부 용어, enum, raw error code를 그대로 노출하지 않습니다.
- 문장 톤은 짧고 직접적으로 유지합니다.
- 같은 원인의 메시지는 feature 안에서 재사용합니다.
- 성공 메시지는 필요한 경우에만 보여줍니다.

좋은 예시:

- `2~10자의 닉네임으로 입력해 주세요`
- `이미 사용 중인 닉네임입니다`
- `사진을 1장 이상 추가해 주세요`
- `네트워크 연결을 확인한 뒤 다시 시도해 주세요`

피해야 하는 예시:

- `BAD_REQUEST`
- `Exception: duplicate nickname`
- `실패했습니다`
- `올바르지 않습니다`

## 포커스와 helper text 기준

- 입력 중에는 과한 성공 메시지를 노출하지 않습니다.
- 사용자가 수정 중인 값에는 즉시 수정 가능한 오류만 보여줍니다.
- 포커스가 벗어난 뒤 최종 성공/실패 메시지를 보여주는 방식을 우선합니다.
- 제출 시점에는 모든 필수 입력의 오류를 한 번에 확인할 수 있어야 합니다.

현재 `HomeScreen` 샘플은 포커스 중에는 normal, 포커스 해제 후 success를 보여주는 흐름을 사용합니다.

## 제출 버튼 상태

제출 버튼은 아래 조건을 고려합니다.

- 필수 입력값이 비어 있으면 disabled
- 로컬 검증 실패 시 disabled 또는 error 표시
- API 제출 중에는 중복 탭 방지
- API 실패 후에는 사용자가 다시 제출할 수 있어야 함

버튼 UI는 `CommonButton`의 `onPressed: null` 상태를 활용합니다.

## 서버 에러 처리

API 연동이 들어오면 아래 순서로 처리합니다.

1. datasource에서 네트워크 오류와 서버 응답 오류를 구분합니다.
2. repository 또는 controller에서 앱 공통 에러 타입으로 변환합니다.
3. form controller에서 field error와 form-level error를 분리합니다.
4. 화면은 사용자용 메시지만 표시합니다.

| 에러 위치 | 예시 |
| --- | --- |
| Field error | 닉네임 중복, 제목 글자 수 초과 |
| Form-level error | 네트워크 실패, 인증 만료, 서버 오류 |
| Dialog/Snackbar | 삭제 실패, 저장 완료 후 안내 |

## 체크리스트

- [ ] 필수값, 길이, 형식 검증이 명확한가?
- [ ] 서버 에러 문자열을 화면에 그대로 노출하지 않는가?
- [ ] field error와 form-level error가 분리되어 있는가?
- [ ] 제출 중 중복 탭을 막는가?
- [ ] 키보드 타입과 maxLength가 입력 목적에 맞는가?
- [ ] helper text가 작은 화면에서 overflow 되지 않는가?
- [ ] 테스트에서 정상/오류 입력을 검증했는가?

## 결정 필요

- 백엔드 에러 코드와 앱 사용자 메시지 매핑표가 필요합니다.
- Toast, Snackbar, Dialog 중 어떤 상황에 어떤 피드백을 사용할지 공통 UX 정책이 필요합니다.
