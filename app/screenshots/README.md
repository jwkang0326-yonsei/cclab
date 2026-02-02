# 앱 스토어 스크린샷 자동 캡처

iOS App Store와 Google Play Store에 제출할 스크린샷을 자동으로 캡처하는 스크립트입니다.

## 설치

```bash
cd screenshots
npm install
npx playwright install chromium
```

## 사용법

### 기본 캡처 (로그인 화면만)

```bash
npm run capture
```

### 로그인 후 내부 화면 캡처

```bash
npm run capture:login
```

브라우저가 열리면:
1. Google 로그인을 완료합니다
2. 터미널에서 Enter를 누릅니다
3. 자동으로 모든 해상도에서 캡처됩니다

## 해상도

### iOS (App Store)
- 6.7" (430×932) - iPhone 15 Pro Max
- 6.5" (428×926) - iPhone 14 Plus
- 5.5" (414×736) - iPhone 8 Plus

### Android (Play Store)
- Phone (360×640) - 1080×1920
- 7" Tablet (600×960) - 1200×1920
- 10" Tablet (800×1280) - 1920×1200

## 출력 구조

```
screenshots/
├── ios/
│   ├── 6.7/
│   ├── 6.5/
│   └── 5.5/
└── android/
    ├── phone/
    ├── tablet7/
    └── tablet10/
```

## 파란색 테두리 문제

스크립트에서 자동으로 CSS를 주입하여 focus outline을 제거합니다.
