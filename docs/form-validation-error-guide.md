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

입력값과 제출 가능 여부는 각 feature의 Form Controller 상태로 관리하고, focus와 helper 표시처럼 Flutter 생명주기에 연결된 처리는 field widget에서 맡습니다.

## 제출 버튼 상태

제출 버튼은 아래 조건을 고려합니다.

- 필수 입력값이 비어 있으면 disabled
- 로컬 검증 실패 시 disabled 또는 error 표시
- API 제출 중에는 중복 탭 방지
- API 실패 후에는 사용자가 다시 제출할 수 있어야 함

버튼 UI는 `CommonButton`의 `onPressed: null` 상태를 활용합니다.

[#250](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/250)에서 Place·Plant·회원정보 수정·가입 프로필의 입력 변경이 진행 중 제출 상태를 유지하도록 수정했습니다. 입력 자체는 계속 수정할 수 있지만, 완료 전 다시 호출한 `submit()`은 API를 추가 호출하거나 성공 이동 결과를 반환하지 않습니다.

- 입력 변경은 진행 중 `submitting` 상태를 `idle`로 바꾸지 않습니다. 실패 안내를 지우는 동작과 요청 잠금 해제를 구분합니다.
- 요청에 사용할 값은 첫 `await` 전에 확정합니다. 가입 프로필도 인증 세션을 기다리기 전에 닉네임을 캡처합니다.
- 실패하면 수정 중이던 입력을 보존하고 유효성 검증에 따라 재시도합니다. 성공 시 기존 화면 이동을 유지하며, 대기 중 새로 입력한 값을 자동으로 추가 저장하지 않습니다.
- 버튼뿐 아니라 Controller 호출 경계도 `Completer` 회귀 테스트로 확인합니다. [검증·제한](work-history/form-submit-lock-250.md)을 참고하며, 서버의 중복 처리 방지까지 보장하는 계약은 아닙니다.

식물 등록처럼 필수 선택지를 원격에서 가져오는 폼은 목록의 loading/error/empty에서도 제출할 수 없습니다. #251은 `canSubmit`을 버튼에 연결하고, 선택·제출 직전에 최신 장소 상태를 재확인합니다. 조회 재시도와 홈 안내는 기존 상태 화면을 사용하며, API 비사용 fixture만 유지합니다([상태 기준](state-management-guide.md#폼에-필요한-원격-목록)).

원격 수정에 필요한 식별자도 입력 검증과 별도로 확인합니다. #252 Plant 수정은 장소 code가 null·빈 값·공백이면 `missingPlace` 상태에서 제출을 막고 장소 화면을 통한 재진입을 안내합니다. 필수 문맥이 없어 API를 생략한 경우를 성공으로 반환하거나 로컬 목록을 변경하지 않습니다. API 실패는 초안을 보존하며 사용자용 오류와 재시도를 제공합니다([검증·제한](work-history/plant-edit-place-code-252.md)).

#253 주소 선택 결과는 생성·수정 폼의 기존 주소 입력과 API 필수 검증에 연결합니다. 선택한 주소의 앞뒤 공백은 제거하며 취소·빈 결과는 기존 입력을 지우지 않습니다. API 모드에서 실제 검색이 미연결이면 샘플로 필수 검증을 통과시키지 않습니다. 기존 서버 주소는 보존하고, 주소를 직접 지운 뒤 제출하면 기존 필수 안내가 나옵니다. API 비사용 모드의 주소 선택·선택 사항 정책은 유지합니다([검증·제한](work-history/place-address-result-253.md)).

disabled 입력의 clear 동작은 [#255](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/255)로 별도 추적합니다.

여러 폼에서 제출 상태가 반복되면 `shared/forms/form_submit_state.dart`의
`FormSubmitState`를 feature별 Riverpod Controller 상태로 사용합니다.

- 화면은 feature Controller의 `state.isSubmitting`을 버튼 `isLoading`과 `onPressed` 조건에 반영합니다.
- 제출 로직과 화면별 실패 문구는 feature Controller가 관리합니다.
- 실패 후에는 `state.errorMessage`를 Snackbar, Dialog 등 화면 정책에 맞게 사용자 메시지로 표시합니다.
- repository 호출과 Provider invalidate는 Controller가 담당하고, route 이동은 화면에 유지합니다.

## 서버 에러 처리

API 연동이 들어오면 아래 순서로 처리합니다.

1. datasource에서 네트워크 오류와 서버 응답 오류를 구분합니다.
2. repository 또는 controller에서 앱 공통 에러 타입으로 변환합니다.
3. form controller에서 field error와 form-level error를 분리합니다.
4. 화면은 사용자용 메시지만 표시합니다.

#275부터 `ApiException`은 표준 오류의 `status`, `code`, `traceId`와 validation `errors[].field/reason`을 분리합니다. `errors[].value`는 사용자 입력 원문일 수 있으므로 읽거나 상태·로그에 보존하지 않습니다. 화면에는 HTTP·전송 범주의 안전한 요약 메시지를 사용하고, field `reason`은 해당 입력 아래에 표시합니다. 입력을 바꾸면 이전 제출의 field error와 form-level error를 초기화하되 제출 중 잠금은 유지합니다.

| 에러 위치 | 예시 |
| --- | --- |
| Field error | 닉네임 중복, 제목 글자 수 초과 |
| Form-level error | 네트워크 실패, 인증 만료, 서버 오류 |
| Dialog/Snackbar | 삭제 실패, 저장 완료 후 안내 |

## 체크리스트

- [ ] 필수값, 길이, 형식 검증이 명확한가?
- [ ] 서버 에러 문자열을 화면에 그대로 노출하지 않는가?
- [ ] field error와 form-level error가 분리되어 있는가?
- [ ] 요청 중 입력을 바꿔도 중복 제출이 차단되고 실패 후 수정값으로 재시도할 수 있는가?
- [ ] 키보드 타입과 maxLength가 입력 목적에 맞는가?
- [ ] helper text가 작은 화면에서 overflow 되지 않는가?
- [ ] 테스트에서 정상/오류 입력을 검증했는가?

## 결정 필요

- HTTP·전송 범주, 확인된 field code와 인증 만료 code의 기본 매핑은 #275에서 확정했습니다. 새 code는 백엔드 계약을 확인한 뒤 추가하며 raw message를 임시 fallback으로 사용하지 않습니다.
- Toast, Snackbar, Dialog 중 어떤 상황에 어떤 피드백을 사용할지 공통 UX 정책은 남아 있습니다.
