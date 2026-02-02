import { test, expect } from '@playwright/test';

test.describe('Group Creation', () => {
    test.beforeEach(async ({ page }) => {
        // Login
        await page.goto('/login');
        await page.fill('input[name="email"]', 'kangwodnd@gmail.com');
        await page.fill('input[name="password"]', 'qwer!234');
        await page.click('button[type="submit"]');
        await page.waitForURL(/\/dashboard/);
    });

    test('should create a new group successfully', async ({ page }) => {
        // Ensure we are on the dashboard
        await expect(page.getByRole('heading', { name: '대시보드' })).toBeVisible();

        // Navigate to /groups via sidebar to avoid full page reload redirects
        await page.locator('aside').getByText('Groups').click();
        await page.waitForURL(/\/groups/);

        // 1. "Create Group" 버튼 클릭
        const createButton = page.locator('button:has-text("Create Group")');
        await expect(createButton).toBeVisible();
        await createButton.click();

        // 2. 다이얼로그 표시 확인
        const dialogTitle = page.locator('h2:has-text("Create New Group")');
        await expect(dialogTitle).toBeVisible();

        // 3. 그룹 이름 입력
        const groupName = `Test Group ${Date.now()}`;
        await page.fill('input[name="name"]', groupName);

        // 4. 저장 버튼 클릭
        await page.click('form button:has-text("Create")');

        // 5. 성공 토스트 또는 목록 갱신 확인
        await expect(page.locator(`text=${groupName}`)).toBeVisible();
    });
});