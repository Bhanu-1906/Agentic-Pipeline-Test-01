@IsTest
private class OpportunityRiskContractTest {
    @IsTest
    static void responsePopulatesAndSerializesAllFields() {
        Datetime evaluatedAt = Datetime.newInstanceGmt(2026, 9, 1, 12, 30, 0);
        OpportunityRiskResponse response = new OpportunityRiskResponse(
            '006000000000001AAA', 'Acme Renewal', 79, 'Needs attention.',
            Date.newInstance(2026, 8, 29), 3, evaluatedAt
        );
        response.addRiskFactor(new OpportunityRiskResponse.RiskFactor(
            'STALE_ACTIVITY', 'Stale activity', 'No recent customer interaction.', 12,
            OpportunityRiskConstants.SEVERITY_MEDIUM, OpportunityRiskConstants.CATEGORY_ENGAGEMENT
        ));
        response.addRiskFactor(new OpportunityRiskResponse.RiskFactor(
            'LATE_CLOSE', 'Close date risk', 'Close date is approaching.', 8,
            OpportunityRiskConstants.SEVERITY_HIGH, OpportunityRiskConstants.CATEGORY_TIMELINE
        ));
        response.addMissingInformation(new OpportunityRiskResponse.MissingInformation(
            'NextStep', 'Next Step', 'A next step is required to plan follow-up.',
            OpportunityRiskConstants.PRIORITY_HIGH
        ));
        response.addRecommendedAction(new OpportunityRiskResponse.RecommendedAction(
            OpportunityRiskConstants.ACTION_LOG_ACTIVITY, 'Log activity',
            'Record the customer conversation.', OpportunityRiskConstants.PRIORITY_MEDIUM,
            2, 'Follow up with Acme'
        ));

        Map<String, Object> serialized = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(response));
        System.assertEquals('006000000000001AAA', serialized.get('opportunityId'));
        System.assertEquals('Acme Renewal', serialized.get('opportunityName'));
        System.assertEquals(79, serialized.get('riskScore'));
        System.assertEquals('ATTENTION', serialized.get('riskLevel'));
        System.assertEquals('Needs attention.', serialized.get('riskSummary'));
        System.assertEquals(2, ((List<Object>) serialized.get('riskFactors')).size());
        System.assertEquals(1, ((List<Object>) serialized.get('missingInformation')).size());
        System.assertEquals(1, ((List<Object>) serialized.get('recommendedActions')).size());
        Map<String, Object> factor = (Map<String, Object>) ((List<Object>) serialized.get('riskFactors'))[0];
        System.assertEquals('STALE_ACTIVITY', factor.get('factorCode'));
        System.assertEquals('Stale activity', factor.get('title'));
        System.assertEquals('No recent customer interaction.', factor.get('description'));
        System.assertEquals(12, factor.get('points'));
        System.assertEquals('MEDIUM', factor.get('severity'));
        System.assertEquals('ENGAGEMENT', factor.get('category'));
        Map<String, Object> missing = (Map<String, Object>) ((List<Object>) serialized.get('missingInformation'))[0];
        System.assertEquals('NextStep', missing.get('fieldName'));
        System.assertEquals('Next Step', missing.get('label'));
        System.assertEquals('A next step is required to plan follow-up.', missing.get('reason'));
        System.assertEquals('HIGH', missing.get('priority'));
        Map<String, Object> action = (Map<String, Object>) ((List<Object>) serialized.get('recommendedActions'))[0];
        System.assertEquals('LOG_ACTIVITY', action.get('actionCode'));
        System.assertEquals('Log activity', action.get('title'));
        System.assertEquals('Record the customer conversation.', action.get('description'));
        System.assertEquals('MEDIUM', action.get('priority'));
        System.assertEquals(2, action.get('dueDateOffset'));
        System.assertEquals('Follow up with Acme', action.get('taskSubject'));
        System.assertEquals('2026-08-29', serialized.get('lastActivityDate'));
        System.assertEquals(3, serialized.get('daysSinceLastActivity'));
        System.assert(serialized.containsKey('evaluatedAt'));
        System.assertEquals(null, serialized.get('aiExplanation'));
    }

    @IsTest
    static void bandsIncludeEveryBoundary() {
        System.assertEquals('HIGH_RISK', OpportunityRiskConstants.riskLevelForScore(0));
        System.assertEquals('HIGH_RISK', OpportunityRiskConstants.riskLevelForScore(59));
        System.assertEquals('ATTENTION', OpportunityRiskConstants.riskLevelForScore(60));
        System.assertEquals('ATTENTION', OpportunityRiskConstants.riskLevelForScore(79));
        System.assertEquals('HEALTHY', OpportunityRiskConstants.riskLevelForScore(80));
        System.assertEquals('HEALTHY', OpportunityRiskConstants.riskLevelForScore(100));
    }

    @IsTest
    static void invalidScoresAreRejected() {
        for (Integer score : new List<Integer>{null, -1, 101}) {
            try {
                OpportunityRiskConstants.riskLevelForScore(score);
                System.assert(false, 'Invalid scores must be rejected.');
            } catch (IllegalArgumentException expected) {
                System.assertEquals('Risk score must be between 0 and 100.', expected.getMessage());
            }
        }
    }

    @IsTest
    static void emptyCollectionsAreSafeAndServiceDoesNotPersist() {
        Opportunity opportunity = new Opportunity(Name = 'Read-only test', StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
        insert opportunity;
        Test.startTest();
        OpportunityRiskResponse response = OpportunityRiskService.evaluate(opportunity.Id);
        Integer serviceDmlStatements = Limits.getDmlStatements();
        Test.stopTest();
        System.assertEquals(0, serviceDmlStatements, 'V1 evaluation must not perform DML.');
        System.assertEquals(100, response.riskScore);
        System.assertEquals('HEALTHY', response.riskLevel);
        System.assertNotEquals(null, response.riskFactors);
        System.assertEquals(0, response.riskFactors.size());
        System.assertEquals(0, response.missingInformation.size());
        System.assertEquals(0, response.recommendedActions.size());
        System.assertEquals(opportunity.Id, response.opportunityId);
        System.assertEquals('Read-only test', response.opportunityName);
        System.assertEquals(null, response.lastActivityDate);
        System.assertEquals(null, response.daysSinceLastActivity);
        System.assertNotEquals(null, response.evaluatedAt);
    }
}
