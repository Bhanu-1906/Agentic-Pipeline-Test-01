/** V1 read-only service boundary. It evaluates in memory and never persists risk data. */
public with sharing class OpportunityRiskService {
    @AuraEnabled(cacheable=true)
    public static OpportunityRiskResponse evaluate(Id opportunityId) {
        if (opportunityId == null) {
            throw new AuraHandledException('opportunityId is required.');
        }

        Opportunity opportunity = [
            SELECT Id, Name, LastActivityDate
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];
        Date today = Date.today();
        Integer daysSince = opportunity.LastActivityDate == null
            ? null : opportunity.LastActivityDate.daysBetween(today);

        // Deterministic scoring rules are deliberately out of scope for AG-192.
        return new OpportunityRiskResponse(
            opportunity.Id,
            opportunity.Name,
            100,
            'Risk evaluation is available.',
            opportunity.LastActivityDate,
            daysSince,
            System.now()
        );
    }
}
