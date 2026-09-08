# 폼 사진 선택·미리보기·교체 #295

- 기준: develop `8746287`, 작업 브랜치 `feature/form-image-selection-295`
- 이슈: [#295](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/295), 상위 [#74](https://github.com/UMC-CommonPlant/v3_CommonPlant_Frontend_Repo/issues/74)
- 휴대폰 최적화 우선. iPad·Mac 설치 가능성은 유지하고 전용 화면 최적화는 후순위다. 별도 macOS runner는 이 저장소에 없다.

## 구현

가입 프로필, 회원 정보 수정, 식물 등록·수정, 장소 등록·수정에서 앨범 사진 한 장을 선택한다. 선택 즉시 실제 파일을 미리보고, 같은 영역을 눌러 교체한다. `선택 취소`는 저장 전 파일만 버린다. 기존 서버 사진이 있으면 다시 표시하며 서버 사진 삭제 요청을 뜻하지 않는다.

- `ImageSelectionGateway`: OS 선택기, 취소, 접근 거부, SDK 오류, 파일 검사만 처리한다. `image_picker`는 FVM Flutter 3.35.7에서 해석된 lockfile 버전 1.2.2를 사용한다.
- `SelectedImage`: 파일 bytes와 MIME을 보관하고 매 제출마다 새 `MultipartFile`을 만든다. 재시도 시 이미 소비된 stream을 재사용하지 않는다.
- 각 기존 Form Controller가 선택·제출 상태를 관리한다. 새 인증 계층이나 업로드 관리 프레임워크는 없다.
- `CommonFormImageField`는 기존 원형·장소 사진 입력 위젯을 조합한다. 페이지는 미리보기와 callback, 사용자 안내만 연결한다.
- 사진 선택·파일 읽기 중 제출/재선택을 차단하고, 제출 중 사진 교체/초안 취소를 차단한다. OS 취소·선택 실패·서버 실패는 기존 초안을 보존한다.
- 폼 재생성, 계정 변경, dispose 이후의 늦은 결과는 반영하지 않는다.
- 작은 화면에서 사진 선택 후 키보드를 열면 입력 영역을 스크롤할 수 있고 완료 버튼은 키보드 위에 유지된다(320×640, 하단 inset 300 회귀 테스트).
- 실제 파일 header와 디코딩을 확인한다. JPEG/PNG/WebP, 0바이트 초과·10,485,760바이트 이하만 허용한다. 확장자만 변경한 파일, 손상된 사진, 초과 용량은 안내 후 거부한다. HEIC 원본이 반환되면 지원 형식으로 다시 선택하도록 안내한다. 촬영·크롭·압축·포맷 자동 변환은 추가하지 않았다.
- 가입 화면은 제출 가능한 로컬 파일을 미리보기로 표시한다. 소셜 `suggestedImgUrl`은 가입 API로 전송할 수 있는 파일이 아니므로 자동 다운로드·재업로드하거나 저장될 사진처럼 표시하지 않는다.
- API 비사용 모드에서도 선택·미리보기는 가능하지만 이미지 서버 저장이나 앱 재실행 후 파일 초안 복원을 제공하지 않는다.

## 확인한 서버 계약

2026-09-07 [dev OpenAPI](https://commonplant-dev.okbear.dev/api/v1/api-docs/json)와 backend main `f67ee6c9fb38ff33c69ebbdfa4e454d330eeb084`의 AuthServiceImpl, UserServiceImpl, PlaceServiceImpl, PlantServiceImpl, GarageImageService, GarageProperties를 대조했다.

| 폼 | 전송 | 사진을 선택하지 않은 수정 |
| --- | --- | --- |
| 가입 | `POST /auth/register`, `register` JSON + optional `image` | 파일이 없으면 기본 이미지로 가입 |
| 회원 정보 | `PUT /users`, `user` JSON + optional `image` | 서버가 기존 사진 보존 |
| 식물 | 기존 create/update JSON + optional `image` | 초기 `imageKey` 보존. URL만 있고 key가 없으면 차단 |
| 장소 | 기존 create/update JSON + optional `image` | 기존 사진 URL이 있으면 key를 조회할 수 없어 차단 |

새 파일을 명시적으로 선택한 Plant/Place 교체는 서버가 보유한 기존 key를 이용하므로 key 미조회 차단의 예외로 허용한다. 미선택 상태의 보존 가드는 유지한다. URL에서 key를 유추하지 않는다. 서버가 기존 객체 정리와 새 key 저장을 담당한다. 동시 수정 보호 계약은 여전히 미확정이다.

현재 저장소는 Garage이며 공개 URL은 만료되지 않는다. `/s3/images`는 레거시 독립 endpoint로 남아 있지만 폼에서 선업로드하지 않는다. live OpenAPI의 독립 Image 성공 response schema 미표기는 폼 직접 multipart 제출의 차단 사유가 아니다. 메모 이미지 서버 계약은 별도로 남긴다.

## 플랫폼

[공식 image_picker 문서](https://pub.dev/packages/image_picker/versions/1.2.2)에 따라 iOS `NSPhotoLibraryUsageDescription`을 추가하고 앨범 선택에 `requestFullMetadata: false`를 사용한다. 시스템 권한 UI를 흉내 내던 가입 화면 dialog는 실제 선택 흐름에서 제거했다. Android 저장소 광범위 권한은 추가하지 않았다.

현재 폼 초안은 메모리 수명만 가진다. Android가 선택 중 프로세스를 종료하면 시작 시 `retrieveLostData()`로 남은 결과를 비우며, 원래 폼/계정 문맥 없이 다른 폼에 자동 첨부하지 않는다. 재실행 후 사용자가 폼에서 다시 선택해야 한다. 이 경우의 실제 OS 동작은 기기 QA 대상이다.

## 검증 기록

- `fvm dart format --output=none --set-exit-if-changed .`: 333개 파일, 변경 없음
- `fvm flutter analyze`: 이상 없음
- `fvm flutter test`: 671개 통과, 1개 스킵(기존 Linux 전용 golden)
- `git diff --check`: 통과
- `fvm flutter build ios --debug --no-codesign`: 성공
- `fvm flutter build apk --release`: 성공(64.1MB)
- native 빌드는 multipart/UI 연결 커밋 `7d1b8db` 상태에서 실행했다. 이후 Dart 레이아웃 보완은 전체 format/analyze/test로 다시 검증했다.

자동 테스트는 gateway 파일 검사·취소·오류·중복 호출, 네 폼의 선택/교체/초안 보존/늦은 결과 무시, 이미지 단독 수정, multipart 전달 및 실패 후 재시도, 실제 페이지의 모바일 미리보기와 선택 취소를 확인한다. 기존 보존·인증·제출 잠금 회귀 테스트도 포함한다.

## 실기기 상태와 남은 확인

실제 앨범 선택·서버 저장 검증 완료 항목은 아직 **0개**다. 최초 시도의 개발자 모드·서명 차단은 후속 작업으로 해소했으며, 2026-09-08에는 iPhone 설치와 Runner 프로세스 실행을 확인했다. 무선 Dart VM 연결은 시간 초과로 미완료다. iPad는 연결 불가, Android 실기기는 감지되지 않았다.

1. iPhone을 USB로 연결하고 잠금 해제 상태에서 앱 화면을 확인한다. 로컬 네트워크 접근 요청이 나오면 허용한 뒤 디버거 연결을 재확인한다. 개발자 모드 활성화와 설치는 완료됐다.
2. 실행에 필요한 로컬 소셜 설정과 테스트 계정으로 로그인한다. 토큰/개인 사진 원본은 이슈에 붙이지 않는다.
3. 프로필·식물·장소에서 JPG/PNG/WebP 선택 → 미리보기 → 재선택 → 선택 취소를 확인한다. 취소/권한 거부/10MB 초과/HEIC 반환도 확인한다.
4. 실제 저장 후 상세·프로필 재조회와 앱 재실행에서 서버 사진을 확인한다. 네트워크 실패 후 재시도 때 초안이 남는지 확인한다.
5. 기존 사진이 있는 장소는 새 파일 교체를 확인하고, 파일 미선택 이름/주소 변경은 보존 안내로 차단되는지 확인한다. 새 장소 생성은 주소 검색 미연결 제한도 고려한다.
6. Android 기기에서 앨범 취소, 중복 탭, 선택 중 Activity/프로세스 종료 후 재실행을 확인한다.

Apple 로그인 backend #152와 refreshToken 재발급 #149 의존성은 기존 소셜 로그인 작업에 유지하며 이 PR에서 해소했다고 처리하지 않는다.

## 커밋 이력

| 커밋 | 범위 | 검증 |
| --- | --- | --- |
| `cdf5e9e` | 사진 선택 gateway·파일 검증·플랫폼 설정 | gateway 4개 테스트 통과 |
| `7d1b8db` | 폼 상태·multipart·미리보기와 회귀 테스트 | 전체 670개 통과·1개 스킵 |
| `159f4fd` | 사진 폼 키보드 가림·스크롤 보완 | 전체 671개 통과·1개 스킵 |

문서 마무리 커밋은 자기 해시를 같은 커밋에 기록하지 않는다.

## iPhone 재확인과 Bundle ID 변경

후속 재확인에서 iPhone 16 Pro는 유선 연결·paired·개발자 모드 enabled 상태였다. 개발자 모드 차단은 해소됐지만 설치는 Mac에 유효한 개발 서명 인증서가 없어 차단됐다(`No valid code signing certificates were found`, valid identities 0개).

사용자 요청으로 iOS Runner의 Debug/Profile/Release Bundle ID를 `com.commonplant.app`, RunnerTests를 `com.commonplant.app.RunnerTests`로 변경했다. 사용자의 로컬 Development Team 설정은 보존하고 커밋에서 제외한다. Android 식별자는 그대로다. 새 iOS ID에 맞는 Apple provisioning 및 Kakao/Google iOS 앱 등록이 필요하며 이 변경만으로 설치·소셜 로그인 검증이 끝난 것은 아니다.

변경 후 `plutil -lint`와 `git diff --check`, `fvm flutter build ios --debug --no-codesign`을 통과했다. 생성된 Runner.app의 CFBundleIdentifier도 `com.commonplant.app`으로 확인했다. Flutter 소스 변경은 없다.

## Personal Team capability 오류 보완

사용자의 Personal Team이 Sign in with Apple을 지원하지 않아 발생한 서명 오류를 확인했다. Debug entitlement를 빈 파일로 분리하고 빌드별 플래그를 기존 네이티브 Apple 지원 채널에 연결했다. Debug에서는 Apple 버튼·SDK를 차단하며 Profile/Release의 권한과 iPhone 제한을 유지한다. 사용자가 로컬에서 선택한 Team과 `com.commonplant.umc` Bundle ID, Info.plist 변경은 덮어쓰거나 커밋하지 않는다.

2026-09-08 재시도에서 Xcode 서명 빌드(17.0초), 실기기 설치와 Runner 프로세스 실행을 확인했다. 설치 artifact의 Apple entitlement가 없고 `CommonPlantAppleSignInEnabled = NO`임을 확인했다. 무선 Dart VM Service 검색은 75초 이후에도 완료되지 않아 대기하던 Flutter 실행 명령을 종료했다. 이후 사용자가 iPhone 앱 화면의 정상 동작을 확인했다. 반응 속도가 느리다는 피드백은 Debug·무선 실행 조건에서의 관찰이며 성능 원인은 확정하지 않았다. 앨범 선택·실제 로그인·서버 저장은 미검증이며 화면 실행 성공으로 대체하지 않는다.

현재 보완 코드에서 format(333개 파일 변경 없음), analyze, 전체 test(671개 통과·Linux 전용 golden 1개 스킵), plist/project 문법 검사와 `git diff --check`를 통과했다.

이번 실행은 `COMMONPLANT_USE_API`를 주입하지 않은 기본 모드다. `AuthSessionController`는 이 모드에서 인증된 fixture 세션을 반환하므로 로그인 화면을 건너뛴다. 실제 로그인 검증은 API 모드와 provider 설정으로 별도 실행해야 한다.

## 실기기 피드백: 로그인 선택과 비활성 버튼

- API 비사용 기본 모드의 시작하기가 인증된 fixture 세션 때문에 로그인 화면을 건너뛰던 문제를 수정했다. 화면 확인 모드에서는 인증 gate를 제외하고 기존 소셜 선택 → 로컬 프로필·약관 → 홈 흐름을 사용한다. API 모드의 인증 redirect와 세션 복원은 유지한다.
- 장소 폼은 스크롤 내용 위에 하단 버튼을 배치한다. Material 기본 비활성 배경이 반투명해 입력 구분선이 버튼 뒤로 비칠 수 있어 공통 버튼의 disabled 배경·전경색을 기존 토큰으로 명시했다. 입력 필드 자체의 구분선이나 비활성 탭 차단은 제거하지 않는다.
- 실제 앱 ProviderScope 기반 시작 흐름, 버튼 variant별 불투명 배경, 짧은 높이·키보드 300px 조건의 장소 다음 버튼을 회귀 테스트한다. Android integration smoke도 새 로컬 시작 순서로 갱신하되 실기기 실행 완료로 간주하지 않는다.

보완 후 format(333개 파일 변경 없음), analyze, 전체 unit/widget test 678개 통과·기존 Linux 전용 golden 1개 스킵 및 `git diff --check`를 확인했다.
