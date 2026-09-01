/** Stable, machine-readable values used by the Opportunity risk contract. */
public without sharing class OpportunityRiskConstants {
    public static final String RISK_LEVEL_HEALTHY = 'HEALTHY';
    public static final String RISK_LEVEL_ATTENTION = 'ATTENTION';
    public static final String RISK_LEVEL_HIGH_RISK = 'HIGH_RISK';

    public static final String SEVERITY_LOW = 'LOW';
    public static final String SEVERITY_MEDIUM = 'MEDIUM';
    public static final String SEVERITY_HIGH = 'HIGH';

    public static final String CATEGORY_ENGAGEMENT = 'ENGAGEMENT';
    public static final String CATEGORY_TIMELINE = 'TIMELINE';
    public static final String CATEGORY_DATA_QUALITY = 'DATA_QUALITY';
    public static final String CATEGORY_COMMERCIAL = 'COMMERCIAL';

    public static final String PRIORITY_LOW = 'LOW';
    public static final String PRIORITY_MEDIUM = 'MEDIUM';
    public static final String PRIORITY_HIGH = 'HIGH';

    public static final String ACTION_UPDATE_CLOSE_DATE = 'UPDATE_CLOSE_DATE';
    public static final String ACTION_LOG_ACTIVITY = 'LOG_ACTIVITY';
    public static final String ACTION_COMPLETE_MISSING_DATA = 'COMPLETE_MISSING_DATA';

    public static String riskLevelForScore(Integer score) {
        if (score == null || score < 0 || score > 100) {
            throw new IllegalArgumentException('Risk score must be between 0 and 100.');
        }
        if (score >= 80) return RISK_LEVEL_HEALTHY;
        if (score >= 60) return RISK_LEVEL_ATTENTION;
        return RISK_LEVEL_HIGH_RISK;
    }
}
