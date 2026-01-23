
import { test, expect } from '@playwright/test';

test.describe('Church Dashboard', () => {
    test.beforeEach(async ({ page }) => {
        // Mock authentication by setting the expected "logged in" state if possible,
        // or just login via UI for now since we don't have a global auth fixture yet.
        // For this test, we'll assume the user logs in first.
        await page.goto('/login');
        await page.fill('input[name="email"]', 'admin@example.com');
        await page.fill('input[name="password"]', 'password');
        await page.click('button[type="submit"]');
        // Wait for redirect
        await page.waitForURL(/\/dashboard/);
    });

    test('should display statistics overview', async ({ page }) => {
        // Check for Stats Cards
        await expect(page.locator('text=Total Members')).toBeVisible();
        await expect(page.locator('text=Active Groups')).toBeVisible();
        await expect(page.locator('text=Chapters Read')).toBeVisible();
        await expect(page.locator('text=Completion Rate')).toBeVisible();

        // Check for Charts (by checking generic container or title)
        await expect(page.locator('text=Weekly Reading Progress')).toBeVisible();
        await expect(page.locator('text=Group Participation')).toBeVisible();
    });
});
