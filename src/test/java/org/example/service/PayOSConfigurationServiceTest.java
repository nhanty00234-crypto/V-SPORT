package org.example.service;

import org.example.dto.payment.PayOSCredentials;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PayOSConfigurationServiceTest {

    private static final PayOSCredentials NOT_CONFIGURED = new PayOSCredentials(null, null, null);
    private static final PayOSCredentials FULLY_CONFIGURED =
            new PayOSCredentials("old-client", "old-api-key", "old-checksum");

    @Test
    void firstTimeConfig_missingField_isRejected() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(NOT_CONFIGURED, "new-client", "", "");
        assertFalse(outcome.valid);
        assertEquals("API Key không được để trống.", outcome.errorMessage);
    }

    @Test
    void firstTimeConfig_allThreeProvided_succeeds() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(NOT_CONFIGURED, "client-1", "api-1", "checksum-1");
        assertTrue(outcome.valid);
        assertEquals("client-1", outcome.finalClientId);
        assertEquals(List.of("CLIENT_ID", "API_KEY", "CHECKSUM_KEY"), outcome.fieldsChanged);
    }

    @Test
    void allFieldsBlank_keepsOldValues_noChange() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "", "", "");
        assertTrue(outcome.valid);
        assertEquals("old-client", outcome.finalClientId);
        assertEquals("old-api-key", outcome.finalApiKey);
        assertEquals("old-checksum", outcome.finalChecksumKey);
        assertTrue(outcome.fieldsChanged.isEmpty());
    }

    @Test
    void onlyApiKeyProvided_keepsOtherTwo() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "", "new-api-key", "");
        assertTrue(outcome.valid);
        assertEquals("old-client", outcome.finalClientId);
        assertEquals("new-api-key", outcome.finalApiKey);
        assertEquals("old-checksum", outcome.finalChecksumKey);
        assertEquals(List.of("API_KEY"), outcome.fieldsChanged);
    }

    @Test
    void maskedValueSubmitted_isRejected() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "abcd••••7890", "", "");
        assertFalse(outcome.valid);
    }

    @Test
    void controlCharacterSubmitted_isRejected() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "line1\nline2", "", "");
        assertFalse(outcome.valid);
    }
}
