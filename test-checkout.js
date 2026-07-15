const { chromium } = require('playwright');
const path = require('path');

(async () => {
    console.log('Starting Playwright browser E2E test...');
    const browser = await chromium.launch({ headless: true });
    const context = await browser.newContext({
        viewport: { width: 1280, height: 800 }
    });
    const page = await context.newPage();

    // Directory for saving screenshots
    const scratchDir = '/home/nhan/.gemini/antigravity/brain/c10a591c-5eb6-4c82-938e-30ef951a031a/scratch';

    try {
        // Log console messages from the page
        page.on('console', msg => console.log('PAGE LOG:', msg.text()));
        page.on('pageerror', err => console.error('PAGE ERROR:', err));

        // 1. Navigate to Login Page
        console.log('Navigating to login page...');
        await page.goto('http://localhost:8080/Backend_java/auth/DangNhap.jsp');
        await page.waitForLoadState('networkidle');
        await page.screenshot({ path: path.join(scratchDir, '01_login_page.png') });

        // 2. Perform Login
        console.log('Filling in login form...');
        await page.fill('#login-username', 'Long01');
        await page.fill('#login-pass', '123456');
        console.log('Submitting login form...');
        await page.click('#main-login-btn');

        // Wait for redirect to dashboard
        console.log('Waiting for redirect to dashboard...');
        await page.waitForURL('**/staff/dashboard', { waitUntil: 'domcontentloaded', timeout: 15000 });
        console.log('Logged in successfully! Currently at:', page.url());
        await page.screenshot({ path: path.join(scratchDir, '02_dashboard.png') });

        // 3. Navigate to Check-in page
        console.log('Navigating to staff check-in page...');
        await page.goto('http://localhost:8080/Backend_java/staff/checkin', { waitUntil: 'domcontentloaded' });
        await page.waitForLoadState('networkidle');
        console.log('Check-in page loaded. Currently at:', page.url());
        // Wait 3 seconds for active sessions to load
        await page.waitForTimeout(3000);
        await page.screenshot({ path: path.join(scratchDir, '03_checkin_page.png') });

        // 4. Open staff invoice modal for DatSanID = 130
        const targetDatSanId = 130;
        console.log(`Opening staff invoice modal for DatSanID = ${targetDatSanId}...`);
        await page.evaluate((id) => {
            if (typeof openStaffInvoiceModal === 'function') {
                openStaffInvoiceModal(id);
            } else {
                console.error('openStaffInvoiceModal function not found on page!');
            }
        }, targetDatSanId);

        // Wait for modal and content to be visible
        console.log('Waiting for modal to load content...');
        const modalContent = page.locator('#staff-invoice-content');
        await modalContent.waitFor({ state: 'visible', timeout: 10000 });
        console.log('Modal loaded successfully!');
        await page.screenshot({ path: path.join(scratchDir, '04_modal_loaded.png') });

        // 5. Click Checkout Tab
        console.log('Switching to Checkout mode...');
        await page.click('#action-mode-btn-checkout');
        await page.waitForTimeout(1000);
        await page.screenshot({ path: path.join(scratchDir, '05_checkout_mode.png') });

        // 6. Select PayOS payment method
        console.log('Selecting PayOS payment method...');
        await page.click('#lbl-pay-transfer');
        await page.waitForTimeout(1000);
        await page.screenshot({ path: path.join(scratchDir, '06_payos_selected.png') });

        // 7. Click checkout button
        console.log('Clicking checkout submit button...');
        await page.click('#staff-payment-submit-btn');

        // Wait for PayOS awaiting state or processing
        console.log('Waiting for PayOS checkout URL and state transition...');
        // Let's wait up to 10 seconds for the transition
        await page.waitForTimeout(10000);
        await page.screenshot({ path: path.join(scratchDir, '07_payos_awaiting.png') });

        console.log('E2E simulation finished successfully.');
    } catch (error) {
        console.error('Error during E2E test execution:', error);
        await page.screenshot({ path: path.join(scratchDir, 'error_screenshot.png') });
    } finally {
        await browser.close();
    }
})();
