# Descent Planning 개발 명령어

## HTML 수정 후 APK 생성

1. www/index.html 수정

2. Sync

```bash
npx cap sync android
```

3. Android Studio 열기

```bash
npx cap open android
```

4. APK 생성

Build
→ Generate App Bundles or APKs
→ Generate APKs

---

APK 위치

android/app/build/outputs/apk/debug/app-debug.apk

---

## iOS

```bash
npx cap sync ios
npx cap open ios
```

추후수정사항 발생시

가장 깔끔한 순서
A. Windows에서 수정한 경우
Windows에서 index.html 수정
↓
GitHub에 push
↓
Windows에서 Android APK rebuild
↓
Mac에서 git pull
↓
Mac에서 iOS rebuild

명령어:

git add .
git commit -m "Fix app issue"
git push

Mac에서:

cd ~/Projects/descent-planning-mobile
git pull
npx cap sync ios
npx cap open ios

Xcode에서 ▶️ 실행.
