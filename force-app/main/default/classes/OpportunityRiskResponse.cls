/** Serializable, runtime-only response shared by Apex and the LWC. */
public without sharing class OpportunityRiskResponse {
    @AuraEnabled public Id opportunityId { get; set; }
    @AuraEnabled public String opportunityName { get; set; }
    @AuraEnabled public Integer riskScore { get; set; }
    @AuraEnabled public String riskLevel { get; set; }
    @AuraEnabled public String riskSummary { get; set; }
    @AuraEnabled public List<RiskFactor> riskFactors { get; set; }
    @AuraEnabled public List<MissingInformation> missingInformation { get; set; }
    @AuraEnabled public List<RecommendedAction> recommendedActions { get; set; }
    @AuraEnabled public Date lastActivityDate { get; set; }
    @AuraEnabled public Integer daysSinceLastActivity { get; set; }
    @AuraEnabled public Datetime evaluatedAt { get; set; }
    // Reserved for a future explanation provider; it is not populated by V1.
    @AuraEnabled public String aiExplanation { get; set; }

    public OpportunityRiskResponse() {
        riskFactors = new List<RiskFactor>();
        missingInformation = new List<MissingInformation>();
        recommendedActions = new List<RecommendedAction>();
        evaluatedAt = System.now();
    }

    public OpportunityRiskResponse(Id opportunityId, String opportunityName, Integer riskScore,
                                   String riskSummary, Date lastActivityDate,
                                   Integer daysSinceLastActivity, Datetime evaluatedAt) {
        this();
        this.opportunityId = opportunityId;
        this.opportunityName = opportunityName;
        this.riskScore = riskScore;
        this.riskLevel = OpportunityRiskConstants.riskLevelForScore(riskScore);
        this.riskSummary = riskSummary;
        this.lastActivityDate = lastActivityDate;
        this.daysSinceLastActivity = daysSinceLastActivity;
        this.evaluatedAt = evaluatedAt == null ? System.now() : evaluatedAt;
    }

    public void addRiskFactor(RiskFactor factor) {
        if (factor != null) riskFactors.add(factor);
    }

    public void addMissingInformation(MissingInformation item) {
        if (item != null) missingInformation.add(item);
    }

    public void addRecommendedAction(RecommendedAction action) {
        if (action != null) recommendedActions.add(action);
    }

    public class RiskFactor {
        @AuraEnabled public String factorCode { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public Integer points { get; set; }
        @AuraEnabled public String severity { get; set; }
        @AuraEnabled public String category { get; set; }

        public RiskFactor() {}
        public RiskFactor(String factorCode, String title, String description, Integer points,
                          String severity, String category) {
            this.factorCode = factorCode;
            this.title = title;
            this.description = description;
            this.points = points;
            this.severity = severity;
            this.category = category;
        }
    }

    public class MissingInformation {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String reason { get; set; }
        @AuraEnabled public String priority { get; set; }

        public MissingInformation() {}
        public MissingInformation(String fieldName, String label, String reason, String priority) {
            this.fieldName = fieldName;
            this.label = label;
            this.reason = reason;
            this.priority = priority;
        }
    }

    public class RecommendedAction {
        @AuraEnabled public String actionCode { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String priority { get; set; }
        @AuraEnabled public Integer dueDateOffset { get; set; }
        @AuraEnabled public String taskSubject { get; set; }

        public RecommendedAction() {}
        public RecommendedAction(String actionCode, String title, String description,
                                 String priority, Integer dueDateOffset, String taskSubject) {
            this.actionCode = actionCode;
            this.title = title;
            this.description = description;
            this.priority = priority;
            this.dueDateOffset = dueDateOffset;
            this.taskSubject = taskSubject;
        }
    }
}
