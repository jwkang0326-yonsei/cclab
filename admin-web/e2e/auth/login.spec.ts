
import { test, expect } from '@playwright/test';

test.describe('Admin Login Flow', () => {
    test('should redirect to login page when accessing dashboard unauthenticated', async ({ page }) => {
        await page.goto('/dashboard');
        await expect(page).toHaveURL(/\/login/);
    });

    test('should allow login with valid credentials', async ({ page }) => {
        // Navigate to login
        await page.goto('/login');

        // Fill credentials
        await page.fill('input[name="email"]', 'admin@example.com');
        await page.fill('input[name="password"]', 'password123');

        // Submit
        await page.click('button[type="submit"]');

        // Assert redirection to dashboard
        // Note: This will fail until we implement the actual auth logic and mock/seed the user
        await expect(page).toHaveURL(/\/dashboard/);
    });

    test('should show error with invalid credentials', async ({ page }) => {
        await page.goto('/login');
        await page.fill('input[name="email"]', 'wrong@example.com');
        await page.fill('input[name="password"]', 'wrongpass');
        await page.click('button[type="submit"]');

        // Assert error message
        await expect(page.locator('text=Invalid credentials')).toBeVisible();
    });
});
