package org.example.service.reputation;

import org.example.util.Constants;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ReputationLabelTest {

    @Test
    void score100IsGood() {
        assertEquals(Constants.REPUTATION_LABEL_GOOD, ReputationLabel.of(100));
    }

    @Test
    void scoreAtGoodThresholdIsGood() {
        assertEquals(Constants.REPUTATION_LABEL_GOOD, ReputationLabel.of(80));
    }

    @Test
    void scoreJustBelowGoodThresholdIsWatch() {
        assertEquals(Constants.REPUTATION_LABEL_WATCH, ReputationLabel.of(79));
    }

    @Test
    void scoreAtWatchThresholdIsWatch() {
        assertEquals(Constants.REPUTATION_LABEL_WATCH, ReputationLabel.of(60));
    }

    @Test
    void scoreJustBelowWatchThresholdIsRisk() {
        assertEquals(Constants.REPUTATION_LABEL_RISK, ReputationLabel.of(59));
    }

    @Test
    void scoreAtRiskThresholdIsRisk() {
        assertEquals(Constants.REPUTATION_LABEL_RISK, ReputationLabel.of(30));
    }

    @Test
    void scoreBelowRiskThresholdIsVeryHighRisk() {
        assertEquals(Constants.REPUTATION_LABEL_VERY_HIGH_RISK, ReputationLabel.of(29));
    }

    @Test
    void score0IsVeryHighRisk() {
        assertEquals(Constants.REPUTATION_LABEL_VERY_HIGH_RISK, ReputationLabel.of(0));
    }
}
