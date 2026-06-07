# WORK LOG — 2026-06-06

iOS 네이티브 앱 추가 + 라이트모드 + STAR 제거 작업 세션.

---

## 오늘 한 일

### 트랙 A — PWA (동료 배포용)
- `descent-app-apk/www/index.html` → `v65/index.html` 로 최신 코드 동기화
  (5/28 v65 변경분은 `rufnek737/descent-planning` 의 `backup-528` 브랜치에 안전 보관)
- iOS 메타태그 추가: `apple-touch-icon`, `apple-mobile-web-app-status-bar-style`, `viewport-fit=cover`
- `apple-touch-icon.png` 180x180 생성 (assets/icon.png에서 변환)
- sw.js 캐시: `cache-50` → `cache-61` (매 코드 변경마다 +1 — 안 올리면 안드로이드/PWA 가 옛 캐시 들고 새 코드 못 받음)
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
11. **WAYPOINTS 테이블 TYPE select 화살표 겹침 fix** (Android 보정 2회 시도):
    - 1차: `.wt select` 에 `padding-right: 18px` — 안드로이드 native dropdown 화살표가 padding 무시하고 텍스트 위에 그려져서 효과 없음.
    - 2차: `-webkit-appearance:none + appearance:none` + SVG ▼ 화살표. padding-right 14 / position right 3px / size 7x4 → IAF 의 F 살짝 잘림.
    - **3차 미세조정**: padding-right 14 → **22**, position right 3px → 5px, size 7x4 → 8x5. 텍스트 + 화살표 안 겹침.
    - 라이트 모드용 다크 슬레이트(#1e293b) 색 별도 override (`#s1.light .wt select`).

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
