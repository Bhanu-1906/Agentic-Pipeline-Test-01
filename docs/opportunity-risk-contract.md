# Opportunity Risk V1 Contract

This repository uses Salesforce DX source format: Apex is under `force-app/main/default/classes`, and the future LWC bundle is `force-app/main/default/lwc/opportunityRiskCenter`. The package is unpackaged and deploys from the `force-app` directory using `sfdx-project.json`.

## Runtime boundary

`OpportunityRiskService.evaluate(opportunityId)` is an `@AuraEnabled(cacheable=true)` read-only Apex method. It returns an `OpportunityRiskResponse` and performs no insert, update, delete, or risk-record persistence. A future LWC may consume it with `@wire` for reactive record-page rendering or imperatively for an explicit refresh. V1 does not implement deterministic scoring rules, Task creation, or an interactive UI.

## Response schema

| Field | Apex / JSON type | Meaning |
|---|---|---|
| `opportunityId` | `Id` / string | Evaluated Opportunity ID |
| `opportunityName` | `String` | Opportunity name |
| `riskScore` | `Integer` | Inclusive score from 0 (highest risk) through 100 (healthiest) |
| `riskLevel` | `String` | Stable band code derived from `riskScore` |
| `riskSummary` | `String` | Human-readable summary |
| `riskFactors` | `RiskFactor[]` | Explanations and point penalties |
| `missingInformation` | `MissingInformation[]` | Data gaps and their urgency |
| `recommendedActions` | `RecommendedAction[]` | Task-ready follow-up suggestions |
| `lastActivityDate` | `Date` / `YYYY-MM-DD` | Most recent activity date, when available |
| `daysSinceLastActivity` | `Integer` | Calendar days from last activity to evaluation date, null when unavailable |
| `evaluatedAt` | `Datetime` / ISO-8601 | Evaluation timestamp in the Salesforce JSON representation |
| `aiExplanation` | `String` / null | Reserved for a future AI explanation provider; not populated in V1 |

Nested models are serialized with these fields:

- `RiskFactor`: `factorCode`, `title`, `description`, `points`, `severity`, `category`.
- `MissingInformation`: `fieldName` (Salesforce API identifier), `label`, `reason`, `priority`.
- `RecommendedAction`: `actionCode`, `title`, `description`, `priority`, `dueDateOffset` (days from evaluation), `taskSubject`.

## Stable codes and bands

Codes are machine-readable and must not be replaced by translated or UI labels. Initial extensible values are:

- Risk levels: `HEALTHY`, `ATTENTION`, `HIGH_RISK`.
- Factor severity and action/data priority: `LOW`, `MEDIUM`, `HIGH`.
- Categories: `ENGAGEMENT`, `TIMELINE`, `DATA_QUALITY`, `COMMERCIAL`.
- Action codes: `UPDATE_CLOSE_DATE`, `LOG_ACTIVITY`, `COMPLETE_MISSING_DATA`.

| Score | Code | Interpretation |
|---:|---|---|
| 80–100 | `HEALTHY` | Low risk |
| 60–79 | `ATTENTION` | Requires attention |
| 0–59 | `HIGH_RISK` | High risk |

Scores outside 0–100 (including null) are invalid and rejected by the model's band mapper.

## Example serialized payload

```json
{
  "opportunityId": "006000000000001AAA",
  "opportunityName": "Acme Renewal",
  "riskScore": 79,
  "riskLevel": "ATTENTION",
  "riskSummary": "Needs attention.",
  "riskFactors": [{"factorCode":"STALE_ACTIVITY","title":"Stale activity","description":"No recent customer interaction.","points":12,"severity":"MEDIUM","category":"ENGAGEMENT"}],
  "missingInformation": [{"fieldName":"NextStep","label":"Next Step","reason":"A next step is required to plan follow-up.","priority":"HIGH"}],
  "recommendedActions": [{"actionCode":"LOG_ACTIVITY","title":"Log activity","description":"Record the customer conversation.","priority":"MEDIUM","dueDateOffset":2,"taskSubject":"Follow up with Acme"}],
  "lastActivityDate": "2026-08-29",
  "daysSinceLastActivity": 3,
  "evaluatedAt": "2026-09-01T12:30:00.000Z",
  "aiExplanation": null
}
```
