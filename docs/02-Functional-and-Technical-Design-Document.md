# Functional & Technical Design Document (FDD / TDD)

## Agentforce Customer Service Agent

| Item | Detail |
|---|---|
| Version | 1.1 — 18 Nov 2026 |
| Related | BRD `01-Business-Requirements-Document.md` |

---

# PART A — FUNCTIONAL DESIGN

## 1. Solution overview

An **Agentforce Service Agent** exposes three Topics. Each Topic has Instructions (policy) and Actions (Flows / Prompt). Customers converse in natural language; the planner selects Topic → Action → returns grounded CRM results.

```
Customer utterance
        │
        ▼
 Agentforce Planner (Topic classification)
        │
        ├── Cases ──────────────► Create Case Flow / Get Case Status Flow
        ├── Order Enquiries ────► Get Orders by Contact / Get Order by Number
        └── Summaries Case ─────► Get Case Details Flow → Case Summary Prompt
```

## 2. Functional requirements

| ID | Requirement | Topic / Action |
|---|---|---|
| FR-AGT-01 | Agent type = Agentforce Service Agent; custom Topics for Cases / Orders / Summary | Agent |
| FR-AGT-02 | Company / role / description configurable; runs as Agentforce Service Agent user | Agent |
| FR-AGT-03 | Optional conversational event-log enrichment | Agent |
| FR-CASE-01 | Collect First Name, Last Name, Email, Subject, Description to create Case | Create a Case |
| FR-CASE-02 | If Contact missing, create Contact then Case | Create a Case |
| FR-CASE-03 | Return Case Number, Subject, Description, Status in chat (no Id) | Create a Case |
| FR-CASE-04 | Status lookup requires First/Last/Email + Case Number | Get Case Status |
| FR-CASE-05 | Null status → no-match message + offer to create case | Instructions |
| FR-ORD-01 | Order by number → Amount, Date, Status (and Name) | Get Order by Order Number |
| FR-ORD-02 | Orders by contact → list for Contact | Get Orders by Contact ID |
| FR-ORD-03 | Ask full name then email sequentially when searching by contact | Instructions |
| FR-SUM-01 | Get Case by number then summarize via Prompt | Get Case Details + Case Summary |
| FR-SUM-02 | Summary sections: Case Overview, Activity, Contacts | Prompt |
| FR-X-01 | Cross-topic routing Cases ↔ Orders | Instructions |
| FR-X-02 | Never show Salesforce Ids; never ungrounded general info | Instructions |

## 3. User journeys

### J1 — Order by number
1. User: “Tell me about my order.”
2. Agent: order number or contact?
3. User provides order number.
4. Action returns order fields → agent narrates.

### J2 — Orders by contact
1. User asks for all orders for their contact.
2. Agent asks full name, then email.
3. Flow returns order collection → agent lists them.

### J3 — Create case
1. User asks to create a support case.
2. Agent collects required fields.
3. Flow creates Contact if needed + Case.
4. Agent confirms + 24h escalation message.

### J4 — Case status
1. User asks for status.
2. Agent collects identity + case number.
3. Flow returns Status or null path.

### J5 — Summarize case
1. User asks to summarize (optionally “the above case”).
2. Get Case Details → Prompt → narrative summary.

## 4. Business rules (implemented as Instructions / Flow)

| Rule | Implementation |
|---|---|
| Auto-create Contact when unknown | Flow decision on Create Case |
| Escalation messaging | Topic instruction after create |
| No Id leakage | Topic instruction |
| One Flow per action | Design standard |
| Order object = `Orders__c` | Data model (Contact-centric) |

---

# PART B — TECHNICAL DESIGN

## 5. Org prerequisites

1. Einstein Generative AI **On** (Setup → Einstein Setup).
2. Agentforce / Agents **On**.
3. Einstein Service Agent user has:
   - Agentforce Service Agent User
   - Service Agent Permissions
4. Object permissions for Case, Contact, `Orders__c` on that user (via perm set `AF_Service_Agent_Access`).

## 6. Data model

### 6.1 Standard
- `Contact` — FirstName, LastName, Email, AccountId
- `Case` — Subject, Description, Status, Priority, ContactId, AccountId, CaseNumber

### 6.2 Custom: `Orders__c`
| Field | API | Type | Notes |
|---|---|---|---|
| Order Number | `Name` | Text | Used as “order number” in chat |
| Contact | `Contact__c` | Lookup(Contact) | Required for by-contact query |
| Amount | `Amount__c` | Currency | |
| Order Date | `Order_Date__c` | Date | |
| Status | `Status__c` | Picklist | New, Confirmed, Shipped, Delivered, Cancelled |

> Why custom? Standard `Order` is Account-centric and needs Contracts/Pricebooks. A Contact-centric custom object keeps Phase-1 setup simple and matches the agent’s “orders for my contact” journeys.

## 7. Flows (Autolaunched)

| API Name | Purpose | Key I/O |
|---|---|---|
| `AF_Create_a_Case` | Create Case (+ Contact) | In: FirstName, LastName, Email, Subject, Description; Out: CaseRecord |
| `AF_Get_Case_Status` | Status by CaseNumber + Contact | In: FirstName, LastName, Email, CaseNumber; Out: CaseStatus |
| `AF_Get_Orders_By_Contact` | List orders for contact | In: FullName, Email; Out: OrderRecords (collection) |
| `AF_Get_Order_By_Order_Number` | Single order | In: OrderNumber; Out: OrderRecord |
| `AF_Get_Case_Details` | Case for summary | In: CaseNumber; Out: CaseRecord |

**I/O contract:** Input vars = Available for Input; Output vars = Available for Output. Agent Action descriptions tell the planner when to collect vs display.

## 8. Prompt Template

| Item | Value |
|---|---|
| Name | `AF_Case_Summary` |
| Type | Flex / Record summary style (Case grounded) |
| Inputs | Case record / JSON description |
| Output | `promptResponse` shown in conversation |

Prompt body follows `specs/topic-instructions.md`: INSTRUCTIONS vs DATA firewall; 3rd person; sections Case Overview → Activity → Contacts; no invented facts; limited jargon.

## 9. Agent Topics (configuration)

Source of truth for Topic text: `specs/topic-instructions.md`. Created via Agent Builder and/or `sf agent` after Einstein is enabled.

| Topic | Actions |
|---|---|
| Cases | AF_Create_a_Case, AF_Get_Case_Status |
| Order_Enquiries | AF_Get_Orders_By_Contact, AF_Get_Order_By_Order_Number |
| Summaries_Case | AF_Get_Case_Details, AF_Case_Summary (prompt) |

## 10. Security

- Agent runs as dedicated user — grant only Case/Contact/`Orders__c` CRUD needed.
- No guest site in Phase 1.
- Instructions forbid Id exposure and ungrounded answers (defense in depth with Flow field selection).

## 11. Deployment sequence

1. Deploy custom object + fields + perm set.
2. Deploy Flows; activate.
3. Deploy Prompt Template (requires Einstein).
4. Enable Einstein + Agentforce; assign perm sets to agent user.
5. Create Agent; attach Topics/Actions; remove unused standard Topics.
6. Seed Contact + Orders; run UAT utterances.
7. Retrieve agent metadata; commit; push GitHub.

## 12. Test approach

- Apex not primary (Flows + Agent). Optional Flow tests / Agent test spec via `sf agent test`.
- Manual UAT scripts in `docs/uat/`.
- Seed script: `scripts/apex/seed-demo-data.apex`.
