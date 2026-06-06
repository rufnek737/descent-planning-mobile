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
