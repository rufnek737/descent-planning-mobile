# WORK LOG — 2026-07-09/10

Jeppesen 접근차트 파싱 정확도 개선 + 수동입력 UX 전환 + 후원 섹션 + 맥 CLI 빌드 세션.

## 오늘 한 일

### 개발자 커피 후원 섹션
- SETUP 화면 하단에 "☕ 개발자에게 커피 사주기" 박스 추가 (커피 ₩1,500 / 커피+케익 ₩4,500)
- **결제수단 미정**: 카카오페이 송금링크는 실명 노출 + 금액 미고정으로 사용자가 거부. 앱내구입(IAP)은 스토어 정식출시 필요 → 보류 상태

### Jeppesen 접근차트 공간(좌표) 기반 파서 신설
- 문제: 이미지 PDF(텍스트레이어 없음)를 정규식으로만 파싱 → 미스드어프로치 인셋 fix 혼입, 고도/거리 오류
- **OCR 플러그인 확장**: iOS `NativeOcrPlugin.swift`(Vision), Android `OcrPlugin.java`(ML Kit) 가 이제 단어별 픽셀좌표(`words`) 반환
- **다회전 OCR**: 페이지를 0/±45/±90° + 흑백 임계처리본으로 여러 번 OCR → 사선 레그라벨 복구, 좌표는 원본프레임으로 역변환 병합
- **그래프 파서** `parseApproachChartSpatial` (index.html): 인셋 제외, (IAF)/(IF) 태그 근접매칭, 거리+코스 라벨을 화면방위와 대조해 레그 배정, IAF→IF 그래프탐색. Macao/GIMPO 차트로 검증
- 유니코드 유사문자(키릴 М→M) 정규화, 선회각 제한(급선회 차단), MANDATORY 인접고도 우선, FT/METER 박스 제외

### 수동입력 우선으로 전환 (OCR 한계 인정)
- 작은 거리숫자(7.4 등)는 Apple Vision조차 불안정 → 실측 확인. 정확도의 답은 "순서·숫자는 사람이, 좌표조회만 앱이"
- **ROUTE QUICK IMPORT 개편**: fix 뒤에 숫자 붙이면 자동분류(고도≥500 / 코스≤360 / 소수점=거리, 순서무관). 스페이스→`-` 자동, 대문자 자동, 실시간 미리보기 카드
- known-sequence 모드: 조종사가 순서 입력 → 그래프탐색 생략하고 좌표조회로 숫자만 채움. 퍼지매칭(O/0, I/L/1, S/5, B/8), 최종접근코스(briefing strip 334°) fallback
- 자동파싱 선택박스(Apply) 제거, 차트 업로드 후 공항정보(② AIRPORT) 자동채움

### SETUP 화면 정리 (사용자 요청)
- **① CHARTS · ② AIRPORT & RUNWAY 제거** (DOM엔 `#legacy-setup`으로 숨겨 코드 호환 유지)
- 활주로는 루트에 `RWY33L`로 입력 → i-rwy/i-crs 자동설정, 표고는 ROUTE QUICK IMPORT의 Field Elevation 칸으로 이동
- 섹션 재번호 ① ROUTE QUICK IMPORT / ② SAVED ROUTES / ③ WAYPOINTS, 전반 글씨 확대
- ND 웨이포인트 고도 라벨 `036`→`3600` (FL식 → 실제 피트)
- sw.js 캐시 cache-69 → cache-85

### 맥 CLI 빌드/설치 워크플로우
- `npx cap open ios` 가 `.xcworkspace` 부재로 실패(SPM 프로젝트, workspace가 .xcodeproj 내장) → Xcode에서 `App.xcodeproj` 직접 열기
- CLI 설치: `xcodebuild -project App.xcodeproj -scheme App -destination id=<UDID> -derivedDataPath <별도경로> ENABLE_DEBUG_DYLIB=NO build` → `xcrun devicectl device install/launch`
- **주의**: `ENABLE_DEBUG_DYLIB=NO` 빌드를 Xcode와 같은 DerivedData에 넣으면 이후 Xcode Run 시 debug dylib 불일치로 SIGKILL. 반드시 별도 derivedDataPath 사용
- poppler(brew) 설치로 PDF 렌더링

## 다음 할 일
- 후원 결제수단 최종 결정 (앱내구입 vs 다른 방식)
- 여러 접근차트로 known-sequence 입력 실사용 검증
- (선택) 차트 업로드/OCR 자동채움 되살릴지 결정 — 현재 숨김만 함

---

# WORK LOG — 2026-06-09

## 오늘 한 일
- EXT ON 모드 TRACK MILES 고정 버그 수정 (2차): `extState.selectedIdx` 사용으로 변경
  - 1차 수정은 `extTargetIdx` 사용했으나, 내부 시퀀싱이 RWY로 앞당겨질 때 여전히 고정됨
  - 최종: 항상 사용자가 선택한 EXT fix(selectedIdx)까지 직선거리 + 이후 레그 합산
- iOS WKWebView 블랙 스크린 버그 수정: 앱 포그라운드 복귀 시 강제 리페인트 추가 (`resume` + `appStateChange` 이중 리스너)
- sw.js 캐시 cache-66 → cache-69
- 로컬 폴더 구조 정리: `Desktop\app 개발` → `Desktop\projects`, `descent-app-apk` 통합

## 다음 할 일
- Android APK 재빌드 후 TRACK MILES 업데이트 동작 확인
- iOS 재빌드 (맥에서): git pull → npx cap sync ios → Xcode Run

---

# WORK LOG — 2026-06-06

iOS 네이티브 앱 추가 + 라이트모드 + STAR 제거 + 영어화 + UX 미세조정 작업 세션.

---

## 🚀 다음 세션 시작하는 법 (다른 컴퓨터에서)

### 1. Repo clone (처음 한 번만)
```bash
git clone https://github.com/rufnek737/descent-planning-mobile.git
cd descent-planning-mobile
npm install
```

> 윈도우: `C:\Users\PC\Desktop\descent-app-apk\`
> 맥: `~/projects/descent-planning-mobile/`

### 2. 이어서 작업할 때
```bash
cd <프로젝트_폴더>
git pull
```

이 WORK_LOG.md 의 맨 위 (이 섹션 + 아래 "현재 상태") 만 읽으면 컨텍스트 1분 안에 회복.

### 3. 현재 상태 (2026-06-06 마감 시점)

| 항목 | 상태 |
|---|---|
| **최신 commit** | `1b1b349` — nd aircraft: drop in the user-supplied B737 SVG silhouette |
| **sw.js 캐시** | `cache-66` |
| **GitHub repo** | [rufnek737/descent-planning-mobile](https://github.com/rufnek737/descent-planning-mobile) (Public) |
| **안드로이드 빌드** | ✅ 사용자 폰에 본인 + 동료 배포 가능 |
| **iOS 빌드** | ⚠️ 라운드 3+ 변경분 (vh→%, 화살표 제거, B737 SVG) iOS rebuild 필요 |
| **Apple Developer** | 미가입. 다음 유료 앱 만들 때 결제 예정 ($99/년) |

### 4. 빌드 명령 (외워두면 좋음)

**안드로이드 (윈도우)**:
```powershell
cd C:\Users\PC\Desktop\descent-app-apk
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
$env:Path += ";$env:LOCALAPPDATA\Android\Sdk\platform-tools"
npx cap sync android
cd android
.\gradlew assembleDebug
adb install -r app\build\outputs\apk\debug\app-debug.apk
```

**iOS (맥)**:
```bash
cd ~/projects/descent-planning-mobile
git pull
npx cap sync ios
```
Xcode → ⇧⌘K → ▶ Run

### 5. 다음에 할 일 (우선순위)

1. **iOS rebuild** — Mac에서 git pull + sync + Xcode Run 해서 최신 변경 확인 (특히 B737 비행기, TYPE 화살표 제거, vh→%)
2. **안드로이드 동료 배포** — APK 카톡/Drive 로 전달 + 설치 안내서 한 페이지
3. **회귀 테스트** — RKSI 33L/15L, RJBB 06R/32R 등 다른 차트 OCR + approach 파싱 정확도 확인
4. **iOS Apple Vision vs Android ML Kit OCR 출력 비교** — 줄바꿈/단어분리 패턴 다르면 파서 보정
5. **라이트 모드 미세 조정** — 사용자 피드백 받고
6. **다음 유료 앱 진행 시 $99 결제** → 이 앱도 같은 계정에 + TestFlight 무제한 배포

### 6. 매 변경 시 잊지 말 것

- `www/` 코드 수정 → **sw.js 의 `CACHE_NAME` +1 필수**. 안 올리면 폰에서 옛 코드 캐싱돼서 새 코드 안 보임.
- 사용자가 데이터 삭제 안 해도 자동 갱신되려면 매 수정마다 +1.
- 매 의미있는 변경 + commit 시 **이 WORK_LOG.md 도 같이 업데이트** + 같은 commit 에 묶기 (메모리 룰).

---

## 오늘 한 일

### 트랙 A — PWA (동료 배포용)
- `descent-app-apk/www/index.html` → `v65/index.html` 로 최신 코드 동기화
  (5/28 v65 변경분은 `rufnek737/descent-planning` 의 `backup-528` 브랜치에 안전 보관)
- iOS 메타태그 추가: `apple-touch-icon`, `apple-mobile-web-app-status-bar-style`, `viewport-fit=cover`
- `apple-touch-icon.png` 180x180 생성 (assets/icon.png에서 변환)
- sw.js 캐시: `cache-50` → `cache-66` (매 코드 변경마다 +1 — 안 올리면 안드로이드/PWA 가 옛 캐시 들고 새 코드 못 받음)
- Netlify 자동 배포 ([rufnek737/descent-planning](https://github.com/rufnek737/descent-planning))
- **사용자 결정**: 이번 수정분부터는 Netlify 배포 안 함 (PWA 대신 네이티브 앱으로 동료 배포)

### 트랙 B — iOS 네이티브 앱
- 새 GitHub repo: **[rufnek737/descent-planning-mobile](https://github.com/rufnek737/descent-planning-mobile)** (public)
- 윈도우의 `descent-app-apk` 폴더 전체 push (`.gitignore` 로 node_modules / android build / ios Pods 제외)
- 맥에서 환경 설정:
  - Xcode Command Line Tools
  - Homebrew + Node + CocoaPods
  - GitHub CLI (`gh auth login`)
- `npx cap add ios` + `npx cap sync ios`
- 무료 Apple ID 로 본인 아이폰 사이드로드 (7일 재서명 필요)

### iOS 네이티브 OCR — Apple Vision Framework
- `ios/App/App/NativeOcrPlugin.swift` — Apple Vision Framework 사용한 OCR 플러그인 작성
- `ios/App/App/NativeOcrPlugin.m` — Capacitor 등록용 Objective-C 브릿지 (`CAP_PLUGIN` 매크로)
- **Capacitor 6 + SPM 자체 plugin 등록 문제** 해결:
  - 자동 발견 안 됨 → `ios/App/App/CustomBridgeViewController.swift` 작성
  - `capacitorDidLoad()` 에서 `bridge?.registerPluginInstance(NativeOcrPlugin())` 명시 호출
  - Main.storyboard 의 root view controller class를 `CAPBridgeViewController` → `CustomBridgeViewController` 로 교체 (Identity Inspector)
- Android의 기존 `OcrPlugin.java` (ML Kit) 와 동일한 plugin name `NativeOcr` 사용 → JS 측 코드 변경 0
- **결과**: API 키 없이 iOS에서도 OCR 동작 ✅

### 버그 / UX 수정
1. **iOS 시계와 헤더 겹침** — `.scr` 컨테이너에 `padding-top: env(safe-area-inset-top)`
2. **viewport-fit=cover 정상화**: 빼면 Android layout 깨짐 → 복원 + CSS safe-area 처리
3. **Cloud Vision API 키 입력 UI 삭제** (CHARTS 섹션) — 동료에게 의미 없는 UX
4. **라이트/다크 토글** (SETUP 화면만):
   - 우측 상단 ☀/🌙 버튼 (현재 모드 표시 — 다크=🌙, 라이트=☀)
   - `#s1.light` CSS 변수 override + 하드코딩 다크 박스 (`.pdf-result`, `.wt` 테이블, save/parse 버튼 등) 명시 override
   - localStorage 'theme' 키로 영구 저장
   - 라이트 톤: 항공 차트 풍 (`#f5f6f8` / `#ffffff` / 다크 슬레이트 텍스트)
5. **STAR/ARRIVAL 파싱 완전 제거** (approach-only):
   - `parseJeppRoutingTableText` early return `[]`
   - `buildKnownJeppArrivalRoutes` early return `[]`
   - `parseStarsFromOCR` early return `[]`
   - `fallbackStarsFromText` 는 이름만 STAR — 실제로는 approach 파서, 보존
   - 코드 본문은 dead code 로 보존 (재활성화는 한 줄 revert)
6. **HTML 스플래시 화살표 좌표 보정** (사용자 시각 조정 4회 반복):
   - 점선 끝점 y: `213` → `178` (각도 약 8.6° 강하)
   - polygon 모양: `18,0 -10,-10 -10,10` → `28,0 0,-10 0,10` ← **origin = 꼬리 base 중심**
   - head transform: `translate(212,178) rotate(9)` — 점선 끝점과 정확히 일치
   - 핵심: polygon origin 이 꼬리 base 가 되면 point 위치 계산이 1:1 — 점선 끝 = 머리 시작
7. **APK 양 폰 재빌드 + 설치 완료** (안드로이드: assembleDebug + adb install / iOS: Xcode Run)
8. **WORK_LOG.md 작성** — 이번 세션 + 다음 세션 컨텍스트 박제
10. **ND 화면 하단 안전영역 처리** (Android 보정 3회 시도):
    - 1차: `.scr` padding-bottom max(env, 48px) — 자식 vh 가 viewport 기준이라 padding 침범. 효과 약함.
    - 2차: portrait `.fmc` 에 직접 padding-bottom 추가 — 자식 콘텐츠 viewport 기준은 그대로라 효과 약함.
    - **3차 (최종)**: portrait `.nd-left`, `.fmc` 의 `vh` 단위 → `%` 로 변경. `.scr` 의 padding box 안에서 비율 분할 → 자식이 padding 영역 안 침범. 안전영역 처리 완전 작동.
    - iOS 는 home indicator safe-area 자동 잡혀서 변경 영향 없음.
11. **WAYPOINTS 테이블 TYPE select 화살표 — 결국 완전 제거** (5회 시도 후 사용자 요청대로 fallback):
    - 1차: padding-right: 18px — 효과 없음
    - 2차: appearance:none + SVG ▼ — 텍스트 잘림
    - 3차: padding/size 미세조정 — IAF "F" 잘림
    - 4차: background shorthand → background-color 수정 — 그래도 화살표가 텍스트 위에 겹쳐 보임
    - **5차 (최종)**: SVG background-image 완전 제거. `appearance:none + text-align:center + text-align-last:center` 만 유지. 화살표 자체가 안 보이고 텍스트만 가운데 정렬로 깔끔. 사용자가 select 클릭하면 OS-level dropdown 으로 옵션 표시.
13. **ND 비행기 아이콘 세련되게 변경** (4회 시도, 사용자 디자인 적용):
    - 1차: 후퇴날개 → "너무 전투기"
    - 2차: 평평 날개 → nose 너무 뾰족
    - 3차: nose 둥글게 → 여전히 사용자 만족 못 함
    - **4차 (최종)**: 사용자 제공 SVG (`b737_marker_C_final.svg`) 를 그대로 Path2D 로 가져와서 적용. 단일 path 안에 동체 + 날개 + 꼬리 다 포함, cubic bezier 로 부드러운 곡선. scale 0.13 으로 ND 사이즈에 맞춤. lineJoin/lineCap round, stroke 2px. 항공차트 풍 깔끔한 B737 실루엣.
14. **세션 종료 정리** — WORK_LOG.md 맨 위에 "다음 세션 시작하는 법" 섹션 추가 + 현재 상태/빌드명령/다음 할 일 명시. 다른 컴퓨터에서 clone + git pull 만으로 컨텍스트 회복 가능.
12. **테마 토글 ☀ → ☀️ (variation selector)**:
    - 기존 `☀` (U+2600) 는 monochrome 텍스트 character. 안드로이드는 작게, iOS 는 다른 크기로 표시.
    - `☀️` (U+2600 + U+FE0F variation selector) 로 emoji-style 강제. 양쪽 OS 모두 컬러 emoji + 🌙 와 비슷한 시각 크기.

9. **SETUP 화면 + 에러 메시지 전체 영어화** (commit 진행 중):
   - UI 라벨 9곳: CHARTS 헤더, upload 라벨, "Re-upload", "PDF Parse Result", "Extracted text", "Apply", WAYPOINTS 헤더 등
   - PDF/OCR 진행 상태 메시지 전부 영어로 (Reading PDF, Parsing PDF, OCR rendering, OCR recognizing 등)
   - 에러 메시지 전부 영어로 (timeout, PDF.js missing, OCR engine unavailable, Route sequence not found 등)
   - SAVED ROUTES: "No saved routes", "Click to load", "Delete"
   - 테이블 버튼 title: "Insert row below", "Delete"
   - 토스트 알림 + alert 모두 영어
   - **PDF.js fallback 로직 버그 fix**: `errMsg.includes('로드 실패')` → `errMsg.includes('failed to load')` (영어화된 메시지와 매칭되게)
   - 코드 주석은 그대로 (사용자 안 보임)

---

## 다음에 이어서 할 일

### 1. 안드로이드 APK 동료 배포
본인 폰엔 깔림. 다음은 동료 배포:
- APK 파일 (`android\app\build\outputs\apk\debug\app-debug.apk`) 카톡/Drive로 전달
- 설치 가이드 메모 (외부 출처 허용 → 설치 → 신뢰)
- 차트 PDF 어디서 받고 어떻게 업로드하는지 한 페이지 가이드

빌드/설치 명령 (또 필요할 때):
```powershell
cd C:\Users\PC\Desktop\descent-app-apk
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
$env:Path += ";$env:LOCALAPPDATA\Android\Sdk\platform-tools"
npx cap sync android
cd android
.\gradlew assembleDebug
adb install -r app\build\outputs\apk\debug\app-debug.apk
```

### 2. 회귀 테스트 (approach 파싱 정확도)
STAR 제거 후 approach 파서가 다음 차트들에서 잘 동작하는지:
- ✅ RKSI 33R (ils33r-jepp.pdf) — 이미 확인됨
- ⏳ RKSI 33L, 15L (ILSZ15L-jepp.pdf, ils33L.pdf)
- ⏳ RJBB 06R, 32R (Rjbb 06R.pdf, ILS32r.pdf)
- ⏳ RJBB 24L (ils33r-jepp.pdf 와 같은 폴더의 차트들)

기대: 각 차트별 IAF → IF → FAF → RWY 시퀀스 자동 추출 + ④ WAYPOINTS 자동 입력.

### 3. Apple Vision vs ML Kit/Cloud Vision OCR 출력 비교
Apple Vision Framework 가 다른 OCR과 줄바꿈 / 단어 분리 패턴이 살짝 다를 수 있음.
ils33r 테스트 시 OCR raw text 는 완벽했지만, 라우트 파서가 못 잡으면 줄 구분/공백 차이 의심.
필요 시 `NativeOcrPlugin.swift` 의 텍스트 결합 방식 조정 (현재 `\n` join).

### 4. 라이트 모드 미세 조정 (피드백 받고)
- ④ WAYPOINTS 테이블 입력 필드 색 (라이트 모드 시 흰 배경 + 다크 텍스트로 변경됨)
- PDF 차트 미리보기 영역 테두리 (현재 다크용 #1a2a3a → 라이트에서 어색하면 조정)
- 다른 사용 안 본 컴포넌트들 (모달, 알림 등)

### 5. 동료 배포 가이드 작성 (안드로이드)
- APK 어떻게 설치하는지 (외부 출처 허용, 설치, 신뢰)
- 차트 PDF 어디서 받아서 어떻게 올리는지
- ☀/🌙 토글 사용법 한 줄
- 한 페이지 메모 정도

### 8. SVG splash 화살표 — 추가 조정 가능성
현재 좌표:
- line: `(60,155) → (212,178)`, 각도 ≈ 8.6°
- polygon: `28,0 0,-10 0,10` (origin = 꼬리 base)
- transform: `translate(212,178) rotate(9)`

추후 변경 옵션:
- 더 평평하게: y2 `178` → `170` (각도 ≈ 5.6°) + rotate `9` → `6`
- 완전 수평: y2 = y1 = `155` + rotate `0`
- 머리 작게: polygon `22,0 0,-7 0,7`

### 6. 다음 유료 앱 진행 시
- **Apple Developer Program $99/년** 가입 → 이 앱도 같은 계정에 등록 → TestFlight 로 동료 무제한 배포 가능 (7일 만료 사라짐)
- Bundle ID `com.rufnek.descentplanning` 그대로 사용 가능 (free Apple ID 와 paid account 의 App ID 는 분리)

### 7. 코드 동기화 워크플로우 단순화 (선택)
현재 같은 코드가 세 군데:
- `descent-app-apk\www\` (네이티브 빌드용)
- `app 개발\descent planning\...v65\` (PWA, Netlify 배포용 — 이번 결정으로 거의 동결)
- `descent-app-apk` GitHub 의 `www/` (자동 push)

PWA 더 이상 안 쓸 거면 v65 폴더는 그냥 archive로 두고 `descent-app-apk\www\` 만 단일 소스로.
나중에 PWA 재배포 필요하면 그때 다시 동기화.

---

## Repo 정보

| 용도 | repo |
|---|---|
| Capacitor 앱 (Android + iOS) | [rufnek737/descent-planning-mobile](https://github.com/rufnek737/descent-planning-mobile) |
| PWA (v65, Netlify) | [rufnek737/descent-planning](https://github.com/rufnek737/descent-planning) |

로컬 경로:
- 윈도우: `C:\Users\PC\Desktop\descent-app-apk\`
- 맥: `~/Desktop/descent-planning-mobile/`

---

## Capacitor 6 SPM 자체 plugin 등록 — 기억할 패턴

향후 다른 native plugin 추가 시 동일 패턴:

1. `ios/App/App/<Name>Plugin.swift` — `@objc(<Name>Plugin)` + `CAPPlugin` 상속
2. `ios/App/App/<Name>Plugin.m` — `CAP_PLUGIN(<Name>Plugin, "<JsName>", ...)`
3. **`CustomBridgeViewController.capacitorDidLoad()` 에 `bridge?.registerPluginInstance(<Name>Plugin())` 한 줄 추가**
4. Xcode 에서 새 파일 2개 Add Files → Target Membership: App ✅
5. `⇧⌘K` → `▶ Run`

자체 plugin 은 자동 발견 안 됨. SPM 모듈로 따로 떼지 않는 한 위 4단계 필수.
