# Business Requirements Document (BRD)

## Agentforce Customer Service Agent

| Item | Detail |
|---|---|
| Version | 1.1 — 18 Nov 2026 |
| Owner | Vishwender Saida |
| Target org | Personal Salesforce Developer Edition (Agentforce-capable) |
| Status | Approved for Phase-1 build (Agent Builder + Flows + Prompt) |

---

## 1. Business problem

Human service agents spend time on repetitive, low-complexity work: looking up orders, confirming case status, opening routine cases, and summarizing case context. Customers expect instant, conversational answers. The business needs an **autonomous AI service agent** grounded in Salesforce CRM data that handles these inquiries and escalates only when human judgment is required.

## 2. Business objectives

| ID | Objective | Success measure |
|---|---|---|
| BO-01 | Reduce handle time for order lookup & case status | Demo: answer in conversational preview without human agent |
| BO-02 | Enable 24×7 self-service case creation | Case created with Contact linkage from chat |
| BO-03 | Give agents/customers instant case narrative | Prompt-based summary with Overview / Activity / Contacts |
| BO-04 | Keep responses trustworthy | No Salesforce IDs; no ungrounded “general” answers |
| BO-05 | Portfolio / learning deliverable | Repo + docs + tested agent in personal org |

## 3. Stakeholders & personas

| Persona | Need |
|---|---|
| **Customer / end user** | Ask about orders and cases in natural language; open a case without waiting |
| **Human service agent** | Freed from routine lookups; receives escalated cases after 24h non-attendance (messaging commitment) |
| **Service admin / builder** | Configure Topics, Instructions, Flows, Prompt; assign Agentforce user permissions |
| **Business owner** | Consistent brand tone; compliance (no Id leakage, grounded answers only) |

## 4. In scope (Phase 1)

1. Enable Einstein + Agentforce (prerequisite).
2. Create **Agentforce Service Agent** with custom Topics.
3. Topics: **Cases**, **Order Enquiries**, **Summaries Case**.
4. Autolaunched Flows as Agent Actions:
   - Create a Case (+ create Contact if missing)
   - Get Case Status
   - Get Orders by Contact
   - Get Order by Order Number
   - Get Case Details
5. Prompt Template: **Case Summary**.
6. Seed demo Contact + Orders + validate conversational preview.
7. Document FDD/TDD, UAT, push to GitHub.

## 5. Out of scope (Phase 1)

- Experience Cloud / Messaging channel / website embed.
- Live agent handoff / Omni-Channel routing.
- Payment, refunds, inventory changes.
- Knowledge-article grounded FAQs.
- Mobile app / Slack deployment.
- Multi-language production packaging.

## 6. Business requirements

| ID | Requirement | Priority | Trace |
|---|---|---|---|
| BR-01 | Customers can retrieve a single order by order number | Must | FR-ORD-01 |
| BR-02 | Customers can retrieve all orders for a verified contact (full name + email) | Must | FR-ORD-02 |
| BR-03 | Customers can create a support case by providing identity + subject + description | Must | FR-CASE-01 |
| BR-04 | If contact does not exist, system creates Contact then Case (no hard failure) | Must | FR-CASE-02 |
| BR-05 | Customers can check case status using identity + case number | Must | FR-CASE-04 |
| BR-06 | Customers can request a narrative case summary | Must | FR-SUM-01 |
| BR-07 | After case create, agent states 24-hour escalation commitment | Should | Instructions |
| BR-08 | Agent never exposes Salesforce record Ids | Must | NFR-SEC |
| BR-09 | Agent never invents CRM facts or gives ungrounded general advice | Must | NFR-SEC |
| BR-10 | Agent switches Topics when user changes intent (Cases ↔ Orders) | Must | FR-X-01 |
| BR-11 | Agent uses polite, empathetic, human-like language | Should | Instructions |
| BR-12 | Case created from agent is linked to Contact (and Account when present) | Must | FR-CASE-03 |

## 7. Functional requirements (summary)

See FDD/TDD Doc 02 for full FR catalogue. Capsule:

- **FR-AGT-01** Customer-facing Agentforce Service Agent exists and is runnable in Builder preview.
- **FR-CASE-01…05** Create case, get status, summarize case, null-status handling, collect required fields.
- **FR-ORD-01…03** Order by number; orders by contact; ask identifiers one-by-one when needed.
- **FR-DAT-01** Custom `Orders__c` with Contact, Amount, Date, Status.

## 8. Non-functional requirements

| ID | Requirement |
|---|---|
| NFR-01 | Responses grounded only in Flow/Prompt outputs + CRM data |
| NFR-02 | Actions are discrete Flows (one responsibility each) |
| NFR-03 | All metadata source-controlled; org rebuildable from repo + seed script |
| NFR-04 | Agent runs as dedicated Agentforce Service Agent user with least-privilege perm sets |
| NFR-05 | Conversational preview tests pass for the UAT scripts in `docs/uat/` |

## 9. Assumptions & dependencies

1. Target org supports **Einstein Generative AI + Agentforce**.
2. Orders for the demo use custom object `Orders__c` (Contact-centric), not B2C Commerce / standard Order alone.
3. Topic instruction text in `specs/topic-instructions.md` is the configuration source of truth.
4. Prompt Builder / GenAI features require Einstein On.

## 10. Risks

| Risk | Mitigation |
|---|---|
| Org lacks Agentforce license | Use Agentforce Developer Edition; document in README |
| LLM non-determinism | Tight Instructions + UAT utterance set; iterate |
| Id leakage if instruction omitted | Explicit instruction on every Topic |

## 11. Acceptance criteria (Phase 1)

1. In Agent Builder preview, order-by-number returns amount/date/status without requiring a human.
2. Orders-by-contact returns the seeded contact’s orders after name + email.
3. Create-case path creates Case (+ Contact if needed) visible on Contact related list.
4. Case status returns Status for a valid case number + identity; null path offers create-case.
5. Summarize case returns Overview / Activity / Contacts style narrative.
6. Repo on GitHub contains docs, metadata, seed script, UAT evidence notes.
