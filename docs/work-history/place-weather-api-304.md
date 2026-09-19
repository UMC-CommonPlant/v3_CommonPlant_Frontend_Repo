# 공공데이터 초단기 날씨 조회 준비 #304

## 목적과 범위

장소 좌표 계약을 기다리는 동안 프런트엔드 공공데이터 API 조회 계층을 준비한다. 사용자는 2026-09-20 **현재 기온·습도 + 날씨 아이콘** 구성을 선택했다. 현재 수치는 초단기실황, 하늘상태는 가까운 미래의 초단기예보로 보완한다. 며칠 뒤 예보가 필요한 단기예보는 이번 범위에 포함하지 않는다.

이번에는 실제 API 호출 코드·응답 검증·재시도·Provider를 구현했다. 아직 Place 화면에서 구독하지 않으며 기존 fixture UI는 바꾸지 않았다. 실제 장소의 기온·습도·아이콘 표시와 같은 위치의 재호출 버튼은 좌표 계약 확정 후 연결한다. 기상청 데이터는 지역의 실외 기상 정보이며 실내·토양 측정값이 아니다.

## 공식 계약과 구현

- [공공데이터포털 기상청 단기예보 조회서비스](https://www.data.go.kr/data/15084084/openapi.do): 하나의 서비스에 초단기실황·초단기예보·단기예보가 포함된다. 이 서비스의 활용신청 인증키를 사용한다.
- [기상청 API 허브 공식 가이드](https://apihub.kma.go.kr/apiList.do?seqApi=10)의 동네예보 조회 활용가이드 `260623`을 확인했다. API 허브 인증키와 공공데이터포털 키를 혼용하지 않는다.
- 요청 origin: `https://apis.data.go.kr`, 경로: `/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst`, `/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst`.
- `dataType=JSON`, `pageNo=1`, `numOfRows=1000`, `base_date`, `base_time`, `nx`, `ny`, `serviceKey`를 사용한다. 응답의 `response.header.resultCode`와 `response.body.items.item`을 검사한다.
- 실황은 KST 매시 정각 기준, 10분 이후 제공된 발표분을 선택한다. 예보는 매시 30분 기준, 45분 이후 제공된 발표분을 선택한다. 날짜/연도 경계와 단말 시간대에 영향받지 않도록 요청 시간을 UTC에서 KST로 계산한다.
- 실황의 `T1H`, `REH`, `PTY`를 현재 기온·습도·강수형태로 보관한다. 예보 `SKY`에서 요청 시각 이후 가장 가까운 정시를 선택한다. `observedAt`, `forecastIssuedAt`, `skyForecastAt`은 UTC 시각으로 분리해 보관한다.
- 하늘상태 1/3/4와 강수형태 0~7만 받아 enum으로 변환한다. 새로운 코드·결측값(900 이상 또는 -900 이하)·중복 필수 항목·다른 격자/발표분·부족한 응답은 임의 값으로 보완하지 않고 오류 처리한다.

기상청 격자를 뜻하는 `WeatherGrid(nx, ny)`만 받는다. 문서상 임시 `xPosition`·`yPosition`의 의미는 미정이므로 Place DTO나 위경도 변환을 추가하지 않았다.

## 5초 제한과 시도 횟수

`PlaceWeatherRepository.fetch`는 실황·예보를 병렬로 요청하고 두 응답을 합치는 **시도 전체**와 5초 타이머를 race한다. 성공하면 즉시 반환하고, 오류/결측/timeout이면 해당 시도의 요청을 취소한 뒤 즉시 다음 시도로 넘어간다. 최초 포함 최대 3회이며 HTTP 요청은 최대 6개, 모두 timeout이면 약 15초다. 취소된 흐름은 재시도하지 않는다. 한 응답만 성공했을 때 부분 성공 화면 정책은 도입하지 않았다.

`placeWeatherProvider(grid)`는 autoDispose family이며 같은 격자 구독은 한 흐름을 공유한다. 활성 사용자 데이터 세션을 구독하고 화면 이탈·세션 교체·무효화 시 CancelToken을 취소한다. Provider의 기본 재시도는 꺼 두어 3회 예산을 중첩하지 않는다. 수동 재조회는 Provider를 무효화해 새 예산으로 시작한다. 버튼의 중복 탭 잠금과 loading/error 표시 검증은 후속 UI 작업에서 진행한다.

자동 갱신·영속 캐시·오프라인 과거 데이터 표시 정책은 추가하지 않았다. 아직 실제 화면에서 Provider를 구독하지 않아 앱 실행만으로 요청이 발생하지 않는다.

## 인증키 설정과 요청 분리

1. 공공데이터포털에서 위 서비스를 활용신청한다.
2. `env/weather.example.json`을 git 제외 대상인 `env/local.weather.json`으로 복사한다.
3. `COMMONPLANT_WEATHER_SERVICE_KEY`에 **일반 인증키(Decoding)** 를 입력한다. URL 인코딩은 Dio가 한 번 수행한다. 실제 키를 문서·커밋·로그에 넣지 않는다.
4. 좌표/화면 연결 후 앱 실행 시 기존 설정과 함께 `--dart-define-from-file=env/local.weather.json`을 전달한다. 키 주입만으로 현재 앱 화면에서 날씨 요청이 시작되지는 않는다.

날씨 Dio는 공통 network 위치에 두지만 CommonPlant 서버용 Dio와 별도로 생성한다. 인증 interceptor와 로그 interceptor를 붙이지 않으며 외부 redirect를 따르지 않는다. 네트워크 예외에 원본 요청 URL·키·서버 원문을 남기지 않는다. 앱에 주입한 공공데이터 키는 서버 비밀키처럼 보호되는 구조가 아니므로 실제 배포 시 사용량/발급 정책을 확인한다.

## 검증과 커밋

| 커밋 | 범위 | 검증 |
| --- | --- | --- |
| `3476592` | 공식 요청·모델·mapper·전용 Dio와 환경값 | API 계약 테스트 22개 통과 |
| `c410671` | 5초·3회·취소 흐름과 Provider | 비동기 경계 테스트 12개 통과 |

2026-09-20 전체 검증:

- `fvm dart format --output=none --set-exit-if-changed .`: 349개 파일 변경 없음
- `fvm flutter analyze`: 이상 없음
- `fvm flutter test`: 724개 통과, 기존 Linux golden 1개 macOS에서 스킵
- `git diff --check`: 통과
- 새 날씨 테스트는 34개이며 실제 네트워크 없이 실행했다. 원본 작업 디렉터리의 개인 iOS 설정 변경은 그대로 보존했다.

## 남은 연결·QA

- [ ] 백엔드 장소 좌표의 최종 필드명·endpoint·응답 위치·타입·좌표계 확인: PLACE-07
- [ ] 확인된 좌표를 기상청 격자로 변환하고 Place 조회와 연결
- [ ] 기온·습도·아이콘 UI, 예보 시각 구분, loading/실패/좌표 없음 처리
- [ ] 동일 날씨 위치 재호출 버튼·중복 탭 차단·휴대폰 접근성 검증
- [ ] 조회 시점·갱신 주기·캐시 정책 확정
- [ ] 실제 활용승인 키와 좌표로 공공데이터 응답·지연·실패·재호출 QA

실제 서버 호출·기기 QA는 미실행이다. 자동 테스트는 fake 응답/전송으로 실행하며 서비스 연결 완료를 의미하지 않는다. 소셜 로그인·사진 업로드의 기존 미검증 상태(#293, #295)와도 무관하다. PR 병합은 사용자가 진행한다.
