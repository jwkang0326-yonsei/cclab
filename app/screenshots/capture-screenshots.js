/**
 * 앱 스토어 스크린샷 자동 캡처 스크립트
 * 
 * 사용법:
 *   npx playwright install chromium  # 최초 1회
 *   node screenshots/capture-screenshots.js
 * 
 * 파란색 테두리 문제 해결:
 *   - CSS로 모든 focus outline 비활성화
 *   - networkidle 대기 후 캡처
 *   - 정확한 뷰포트 크기로 캡처
 */

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

// ============================================
// 설정
// ============================================

const APP_URL = 'https://cclab-4ec42.firebaseapp.com';
const OUTPUT_DIR = path.join(__dirname);

// 캡처할 화면 목록 (경로 또는 해시)
const SCREENS = [
    { name: '01_login', path: '/', waitFor: 2000 },
    // 로그인 필요한 화면은 수동 로그인 후 캡처
    // { name: '02_home', path: '/home', waitFor: 2000 },
    // { name: '03_group', path: '/group', waitFor: 2000 },
    // { name: '04_statistics', path: '/statistics', waitFor: 2000 },
];

// iOS App Store 해상도
const IOS_DEVICES = [
    { name: '6.7', width: 430, height: 932, scale: 3 },   // iPhone 15 Pro Max
    { name: '6.5', width: 428, height: 926, scale: 3 },   // iPhone 14 Plus
    { name: '5.5', width: 414, height: 736, scale: 3 },   // iPhone 8 Plus
];

// Google Play Store 해상도
const ANDROID_DEVICES = [
    { name: 'phone', width: 360, height: 640, scale: 3 },      // 1080x1920
    { name: 'tablet7', width: 600, height: 960, scale: 2 },    // 1200x1920
    { name: 'tablet10', width: 800, height: 1280, scale: 1.5 }, // 1920x1200 (landscape 가능)
];

// ============================================
// 파란색 테두리 제거 CSS
// ============================================

const REMOVE_FOCUS_CSS = `
  *:focus,
  *:focus-visible,
  *:focus-within {
    outline: none !important;
    box-shadow: none !important;
  }
  
  /* Chrome 기본 포커스 링 제거 */
  *::-webkit-focus-ring-color {
    outline-color: transparent !important;
  }
  
  /* 선택 하이라이트 제거 */
  ::selection {
    background: transparent !important;
  }
`;

// ============================================
// 메인 함수
// ============================================

async function captureScreenshots() {
    console.log('🚀 앱 스토어 스크린샷 캡처 시작\n');

    const browser = await chromium.launch({
        headless: true, // headless 모드로 실행
    });

    try {
        // iOS 스크린샷 캡처
        console.log('📱 iOS 스크린샷 캡처 중...\n');
        for (const device of IOS_DEVICES) {
            await captureForDevice(browser, 'ios', device);
        }

        // Android 스크린샷 캡처
        console.log('\n🤖 Android 스크린샷 캡처 중...\n');
        for (const device of ANDROID_DEVICES) {
            await captureForDevice(browser, 'android', device);
        }

        console.log('\n✅ 모든 스크린샷 캡처 완료!');
        console.log(`📁 저장 위치: ${OUTPUT_DIR}`);

    } finally {
        await browser.close();
    }
}

async function captureForDevice(browser, platform, device) {
    const outputPath = path.join(OUTPUT_DIR, platform, device.name);

    // 디렉토리 생성
    if (!fs.existsSync(outputPath)) {
        fs.mkdirSync(outputPath, { recursive: true });
    }

    console.log(`  📐 ${platform}/${device.name} (${device.width}x${device.height})`);

    const context = await browser.newContext({
        viewport: {
            width: device.width,
            height: device.height,
        },
        deviceScaleFactor: device.scale,
        isMobile: platform === 'ios' || (platform === 'android' && device.name === 'phone'),
        hasTouch: true,
    });

    const page = await context.newPage();

    // 파란색 테두리 제거 CSS 주입
    await page.addStyleTag({ content: REMOVE_FOCUS_CSS });

    for (const screen of SCREENS) {
        const url = APP_URL + screen.path;
        const filename = path.join(outputPath, `${screen.name}.png`);

        try {
            // 페이지 이동 및 로드 대기
            await page.goto(url, {
                waitUntil: 'networkidle',
                timeout: 30000
            });

            // CSS 재주입 (SPA 네비게이션 대응)
            await page.addStyleTag({ content: REMOVE_FOCUS_CSS });

            // 추가 대기 시간
            if (screen.waitFor) {
                await page.waitForTimeout(screen.waitFor);
            }

            // 포커스 제거 (빈 영역 클릭)
            await page.mouse.click(0, 0);

            // 스크린샷 캡처
            await page.screenshot({
                path: filename,
                fullPage: false, // 뷰포트만 캡처
            });

            console.log(`    ✓ ${screen.name}.png`);

        } catch (error) {
            console.error(`    ✗ ${screen.name} 캡처 실패: ${error.message}`);
        }
    }

    await context.close();
}

// ============================================
// 로그인 후 내부 화면 캡처용 함수
// ============================================

async function captureWithLogin() {
    console.log('🔐 로그인 모드로 스크린샷 캡처\n');
    console.log('브라우저가 열리면 로그인을 완료하세요.\n');

    const browser = await chromium.launch({
        headless: false, // 브라우저 창 표시
    });

    const context = await browser.newContext({
        viewport: { width: 430, height: 932 },
        deviceScaleFactor: 3,
        isMobile: true,
        hasTouch: true,
    });

    const page = await context.newPage();
    await page.goto(APP_URL);

    // readline 설정
    const readline = require('readline');
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });

    const askQuestion = (question) => new Promise(resolve => {
        rl.question(question, resolve);
    });

    // 캡처할 화면 목록
    const internalScreens = [
        { name: '02_home', label: '홈(성경읽기)' },
        { name: '03_group', label: '그룹' },
        { name: '04_statistics', label: '통계' },
    ];

    console.log('\n📋 캡처할 화면 목록:');
    internalScreens.forEach((s, i) => console.log(`   ${i + 1}. ${s.label}`));
    console.log('\n각 화면으로 이동 후 Enter를 누르면 캡처됩니다.\n');

    await askQuestion('1. 먼저 로그인 후 홈 화면이 보이면 Enter...');

    // 파란색 테두리 제거 CSS 주입
    await page.addStyleTag({ content: REMOVE_FOCUS_CSS });

    // 각 화면을 순차적으로 캡처
    for (let i = 0; i < internalScreens.length; i++) {
        const screen = internalScreens[i];

        if (i > 0) {
            await askQuestion(`\n${i + 1}. "${screen.label}" 탭을 클릭한 후 Enter...`);
        }

        console.log(`\n📸 ${screen.label} 캡처 중...`);

        await page.waitForTimeout(500);
        await page.addStyleTag({ content: REMOVE_FOCUS_CSS });

        // iOS 해상도별 캡처
        for (const device of IOS_DEVICES) {
            const outputPath = path.join(OUTPUT_DIR, 'ios', device.name);

            if (!fs.existsSync(outputPath)) {
                fs.mkdirSync(outputPath, { recursive: true });
            }

            await page.setViewportSize({
                width: device.width,
                height: device.height,
            });

            await page.waitForTimeout(300);
            await page.addStyleTag({ content: REMOVE_FOCUS_CSS });

            await page.screenshot({
                path: path.join(outputPath, `${screen.name}.png`),
                fullPage: false,
            });

            console.log(`  ✓ ios/${device.name}/${screen.name}.png`);
        }

        // Android 해상도별 캡처
        for (const device of ANDROID_DEVICES) {
            const outputPath = path.join(OUTPUT_DIR, 'android', device.name);

            if (!fs.existsSync(outputPath)) {
                fs.mkdirSync(outputPath, { recursive: true });
            }

            await page.setViewportSize({
                width: device.width,
                height: device.height,
            });

            await page.waitForTimeout(300);
            await page.addStyleTag({ content: REMOVE_FOCUS_CSS });

            await page.screenshot({
                path: path.join(outputPath, `${screen.name}.png`),
                fullPage: false,
            });

            console.log(`  ✓ android/${device.name}/${screen.name}.png`);
        }
    }

    rl.close();
    await browser.close();
    console.log('\n✅ 모든 화면 캡처 완료!');
}

// ============================================
// 실행
// ============================================

const args = process.argv.slice(2);

if (args.includes('--login')) {
    captureWithLogin().catch(console.error);
} else {
    captureScreenshots().catch(console.error);
}
