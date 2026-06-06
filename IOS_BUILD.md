# iOS 빌드 가이드 (macOS)

본인 아이폰에 직접 사이드로드해서 쓰는 절차. 무료 Apple ID로 7일마다 재빌드.

## 0. 사전 준비 (한 번만)

### Xcode Command Line Tools
```bash
xcode-select --install
```

### Homebrew (없으면)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Node.js LTS + CocoaPods
```bash
brew install node cocoapods
```

> M2 맥은 `sudo gem install cocoapods` 으로 깔면 종종 깨짐. `brew install cocoapods` 가 가장 안전.

확인:
```bash
node -v   # v18 이상이면 OK (Capacitor 6 요구사항)
pod --version
xcodebuild -version
```

---

## 1. 프로젝트 clone & 의존성 설치

```bash
cd ~/Desktop   # 원하는 위치
git clone https://github.com/rufnek737/descent-planning-mobile.git
cd descent-planning-mobile
npm install
```

`npm install` 은 24MB짜리 `node_modules/` 를 생성. 1~2분 소요.

---

## 2. iOS 플랫폼 추가

```bash
npx cap add ios
npx cap sync ios
```

이 두 명령이 하는 일:
- `ios/` 폴더 생성 (Xcode 프로젝트 + Podfile)
- `www/` 내용을 iOS WebView 자산으로 복사
- CocoaPods 의존성 설치 (`Pods/` 폴더 생성, 5분~10분 첫 빌드)

완료되면 `ios/App/App.xcworkspace` 가 생김.

---

## 3. Xcode 열기

```bash
npx cap open ios
```

Xcode가 `App.xcworkspace` 자동으로 엽니다. (절대 `.xcodeproj` 가 아닌 `.xcworkspace` 로 열어야 함 — Pods 때문)

---

## 4. Xcode 안에서 코드 서명 설정

1. 왼쪽 프로젝트 네비게이터에서 **App** (파란 프로젝트 아이콘) 클릭
2. **TARGETS → App** 선택
3. **Signing & Capabilities** 탭
4. **Team** 드롭다운 → **Add an Account...** → 본인 Apple ID 로그인 (무료)
5. 다시 **Team** 드롭다운 → `(Personal Team)` 선택
6. **Bundle Identifier** 확인: `com.rufnek.descentplanning` (그대로 두기, 충돌 안 남)

> "Failed to register bundle identifier" 에러 뜨면 Bundle Identifier 끝에 `.dev` 등을 붙여서 유니크하게: `com.rufnek.descentplanning.dev`

---

## 5. 아이폰 연결 & 신뢰

1. 라이트닝/USB-C 케이블로 아이폰을 맥에 연결
2. 아이폰에 "이 컴퓨터를 신뢰?" 알림 → **신뢰**
3. Xcode 상단 디바이스 선택 메뉴에서 본인 아이폰 선택 (예: "OOO's iPhone")

---

## 6. 빌드 & 설치

1. Xcode 좌상단 **▶ (Run) 버튼** 클릭
2. 빌드 5~10분 (첫 빌드만 오래, 이후는 빠름)
3. 아이폰에 앱이 자동 설치되고 실행 시도
4. **아이폰에 "신뢰되지 않은 개발자" 에러 뜸** → 정상

### 개발자 신뢰 절차 (아이폰)

1. 아이폰 → **설정 → 일반 → VPN 및 기기 관리**
2. **개발자 앱** 섹션에 본인 Apple ID 이메일 → 탭
3. **"<email> 신뢰"** 버튼 탭 → **신뢰**
4. 홈 화면에서 Descent Planning 아이콘 탭 → 정상 실행

---

## 7. 7일 후 재서명

무료 Apple ID 의 한계로 **앱이 7일 후 안 열림** ("이 앱은 더 이상 사용할 수 없습니다").

재서명 방법:
1. 아이폰 USB로 맥 연결
2. Xcode 열기 (`open ios/App/App.xcworkspace` 또는 `npx cap open ios`)
3. ▶ Run 버튼만 누르면 끝 (5분)

> 코드 안 바꿔도 7일마다 한 번씩 이걸 해야 함. Apple 정책이라 우회 못 함.

---

## 8. PWA 코드 업데이트했을 때

윈도우에서 `www/index.html` 수정 → GitHub push 했다면, 맥에서:

```bash
cd descent-planning-mobile
git pull
npx cap sync ios   # www/ 변경분을 iOS 빌드로 동기화
# 그 다음 Xcode ▶ Run
```

`npx cap sync ios` 안 하면 iOS 앱에 옛날 www/ 가 그대로 박혀 있음.

---

## 트러블슈팅

### `pod install` 실패 (M2)
```bash
sudo gem install ffi
arch -x86_64 pod install --project-directory=ios/App
```

### "No such module 'Capacitor'"
- Xcode 워크스페이스(`.xcworkspace`) 가 아니라 프로젝트(`.xcodeproj`)를 열었을 가능성. `npx cap open ios` 로 다시 열기.

### 빌드는 되는데 흰 화면
- `www/` 에 `index.html` 있는지 확인
- Safari 디버거로 WebView 콘솔 보기: 맥 Safari → 개발 메뉴 → [아이폰 이름] → [앱 WebView] 선택

### Cloud Vision OCR 안 됨
- 앱 CHARTS 섹션에서 API 키 입력 (localStorage 저장)
- iOS 에선 ML Kit 네이티브 플러그인은 작동 안 함 (Android 전용). Cloud Vision 또는 Tesseract 로 자동 폴백됨.

---

## 향후 유료 계정 ($99/년) 으로 전환할 때

1. https://developer.apple.com 에서 Apple Developer Program 가입
2. Xcode → Settings → Accounts → 동일 Apple ID 로 다시 로그인하면 자동으로 유료 팀 추가
3. **Team** 드롭다운에서 `(Personal Team)` 대신 새 유료 팀 선택
4. 그러면 7일 만료 없어짐, TestFlight 로 동료 무제한 배포 가능
5. 같은 Bundle ID 그대로 써도 됨
