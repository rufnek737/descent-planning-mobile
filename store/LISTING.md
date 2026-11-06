# Store listing — Descent Planning

복사해서 App Store Connect / Play Console에 붙여넣는 용도. 앱의 실체(오프라인 학습·시뮬레이션 도구, 실제 항법 용도 아님)와
어긋나는 표현은 심사 반려 사유가 되므로 아래 문구를 그대로 쓰는 것을 권장.

## 공통

| 항목 | 값 |
|---|---|
| 앱 이름 | Descent Planning |
| 번들 ID / 패키지명 | `com.rufnek.descentplanning` |
| 카테고리 | Education (대안: Utilities) — Navigation 카테고리는 피할 것 (실제 항법 앱으로 오해 + 추가 심사) |
| 개인정보처리방침 URL | https://rufnekcrew.com/descent/privacy (2026-11-06 배포 완료, 200 확인 — 제출 가능) |
| 이용약관 URL | https://rufnekcrew.com/descent/terms (위와 동일) |
| 저작권 표기 | 2026 RufnekCrew (기존 앱 공통) |
| 지원 이메일 | info@rufnekcrew.com |
| 가격 | 무료 (iOS: 소모성 후원 IAP 2종 / Android: 외부 후원 링크) |

## 한국어

**부제목 (iOS, 30자)**: B737 하강·접근 계획 연습

**짧은 설명 (Play, 80자)**: B737 하강·접근 계획을 연습하는 오프라인 ND 시뮬레이터

**설명**
Descent Planning은 B737 하강·접근 계획 개념을 연습하기 위한 오프라인 학습 시뮬레이터입니다.

· 웨이포인트·고도·코스·거리를 직접 입력하면 경로가 자동으로 구성됩니다
· 진북이 위로 고정된 ND(Navigation Display) 스타일 화면에서 경로와 활주로를 확인합니다
· 고도·속도를 직접 조작하며 TRACK MILES, 수직 편차(VERT DEV), V/S 등을 연습합니다
· 만든 경로는 기기에 저장해 다시 불러올 수 있습니다
· 계정·로그인·네트워크 연결이 필요 없습니다

※ 실제 항공기·항법장비와 연결되지 않으며 실시간 항법·기상·ATC 데이터를 사용하지 않습니다. 모든 값은 사용자가 직접 입력하는 학습용 시뮬레이션이며, 실제 비행·디스패치·운항 판단의 근거로 사용할 수 없습니다.

개발자 후원은 선택 사항이며, 후원 여부와 관계없이 모든 기능이 동일하게 제공됩니다.

**키워드 (iOS, 100자)**: 항공,하강,접근,ND,B737,조종사,시뮬레이터,descent,approach,pilot,aviation,training

## English

**Subtitle (30)**: B737 descent planning practice
**Short description (Play, 80)**: Offline B737 descent & approach planning practice simulator.

**Description**
Descent Planning is an offline study simulator for practicing B737 descent and approach planning.

• Type waypoints, altitudes, courses and distances — the route is built for you
• Review the route and runway on a north-up, ND-style display
• Adjust altitude and speed to practice track miles, vertical deviation and vertical speed
• Save routes on your device and reload them later
• No account, no login, no network connection required

Not connected to any aircraft or navigation equipment, and uses no live navigation, weather or ATC data. All values are entered by you; this is a training simulation and must not be used as a basis for real flight, dispatch or operational decisions.

Supporting the developer is optional and unlocks nothing — every feature is identical either way.

## 개인정보 설문 답변

**Apple — App Privacy**: "Data Not Collected" (수집하는 데이터 없음). 계정·분석·광고 SDK 없음. 후원 결제는 Apple이 처리.

**Google Play — Data safety**
- 데이터 수집: 아니오 / 데이터 공유: 아니오
- 전송 중 암호화: 해당 없음 (앱이 개발자 서버와 통신하지 않음)
- 데이터 삭제 요청: 앱 삭제 시 로컬 데이터 전부 삭제

**연령 등급 설문**: 폭력·성적 콘텐츠·도박·사용자 생성 콘텐츠·위치 공유 모두 "없음" → 전체 이용가 예상.
Apple 설문의 "무제한 웹 접근" 항목은 "아니오" (후원 외부 링크는 Android/웹 한정, iOS 미노출).

## 필요한 그래픽 자산

| 스토어 | 항목 | 규격 |
|---|---|---|
| Apple | iPhone 6.9" 스크린샷 (필수, 1~10장) | 1320×2868 (세로) |
| Apple | iPad 13" 스크린샷 (유니버설 앱이라 필수) | 2064×2752 (세로) |
| Apple | 앱 아이콘 | 1024×1024 (프로젝트에 포함됨) |
| Google | 휴대전화 스크린샷 (최소 2장) | 16:9 또는 9:16, 변 320~3840px |
| Google | 앱 아이콘 | 512×512 PNG |
| Google | 그래픽 이미지(feature graphic) | 1024×500 |

※ iOS 스크린샷은 **기기 해상도와 정확히 일치**해야 함 (다른 크기는 "스크린샷 크기가 잘못되었습니다"로 거부된 이력 있음).

스크린샷 추천 구성: ① SETUP(경로 입력 + 웨이포인트 표) ② ND 화면(경로+비행기) ③ ND + FMC 하단 PROGRESS 정보.
스크린샷에는 안전 고지와 모순되는 요소(실제 항공사 로고, "navigation"/"flight" 실사용을 암시하는 문구)를 넣지 말 것.

## Apple 심사 노트 (App Review Information → Notes)

> No account or login exists, so no demo account is needed. This is an offline educational simulator for practicing descent/approach planning. It is not connected to any aircraft system and does not provide real navigation. No login is required. The in-app "developer support" section uses StoreKit consumable IAPs (com.rufnek.descentplanning.coffee / .coffeecake) and unlocks no features. A first-launch safety notice must be acknowledged once.

## 제출 전 체크리스트

### iOS
1. App Store Connect → 앱 → **+ 새로운 앱** (플랫폼 iOS, 번들 ID `com.rufnek.descentplanning`, SKU 임의)
   - 번들 ID 드롭다운에 없으면 developer.apple.com → Identifiers에서 App ID 먼저 등록
2. 계약·세금·은행 → **Paid Apps Agreement** 동의 (IAP 상품 생성의 전제)
3. 기능 → 인앱 구입 → 소모성 2종 생성 (`coffee` ₩1,500대 / `coffeecake` ₩4,500대), 심사용 스크린샷·표시 이름 입력
   - **인앱 상품은 앱 버전과 같은 제출에 포함**시켜야 함. 상품이 준비 안 된 채 구매 버튼이 눌러도 안 사지면 반려 사유 (CrewSwap 반려 이력)
4. Xcode Release 아카이브 → 업로드 → TestFlight 내부 테스트로 IAP 실결제 샌드박스 확인
5. 메타데이터·스크린샷·개인정보·연령 등급 입력 후 심사 제출

※ **3.1.1 위험**: 날고적고는 "아무 기능도 해제하지 않는 구독/인앱상품"이 반려됐음. 이 앱의 커피 IAP는 의도적으로 아무것도 해제하지 않는 후원(tip) 상품이라 같은 지적이 올 수 있음. 반려되면 후원 섹션을 iOS 빌드에서 빼고 재제출하는 것이 가장 빠름.

### Android
1. keystore 생성 (아래 명령) → `android/keystore.properties` 작성 (둘 다 git 제외 처리됨)
2. `cd android && ./gradlew bundleRelease` → `app/build/outputs/bundle/release/app-release.aab`
3. Play Console → 앱 만들기 → Play 앱 서명 사용 → 내부 테스트 트랙에 AAB 업로드
4. 데이터 보안, 콘텐츠 등급, 타겟층(성인/일반), 광고 없음, 정부 앱 아님 설문 작성
5. Google 최초 프로덕션 출시는 수동공개·단계적출시가 불가 — 심사 통과 즉시 전체 공개됨. 동시 출시를 맞추려면 비공개 테스트 트랙을 먼저 거칠 것.
6. Play 계정은 조직 계정(RufnekCrew)이라 계정 세부정보 입력은 이미 끝난 상태. 개인 계정용 비공개 테스트 요건(12명·14일)은 적용되지 않을 것으로 보이나, 앱 생성 후 Play Console 안내에서 확인

```bash
keytool -genkeypair -v -storetype JKS -keystore ~/descent-upload.jks \
  -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

`android/keystore.properties`:
```
storeFile=/Users/kaymac/descent-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```
keystore 파일과 비밀번호는 반드시 별도 백업할 것 (Play 앱 서명을 켜면 분실 시 업로드 키 재설정이 가능하지만 절차가 번거로움).
