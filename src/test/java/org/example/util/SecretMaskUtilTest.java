package org.example.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class SecretMaskUtilTest {

    @Test
    void nullValue_returnsNull() {
        assertNull(SecretMaskUtil.mask(null));
    }

    @Test
    void emptyValue_returnsNull() {
        assertNull(SecretMaskUtil.mask(""));
    }

    @Test
    void shortValue_returnsFourDots() {
        assertEquals("••••", SecretMaskUtil.mask("abcd1234"));
    }

    @Test
    void longValue_masksMiddle() {
        assertEquals("abcd••••7890", SecretMaskUtil.mask("abcdef1234567890"));
    }
}
