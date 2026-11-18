# Video Transcript Analysis

| Item | Detail |
|---|---|
| Source | [Agentforce Service Agent hands-on video](https://www.youtube.com/watch?v=mVNjeNgxxQw) |
| Video ID | `mVNjeNgxxQw` |
| Creator / companion blog | Monika Ramchandani (Sfdc Girl) — [AgentForce Hands-On Project : Customer Service Agent](https://www.sfdcgirl.com/2025/02/Agentforce-Service-Agent.html) |
| Extracted | 18 Nov 2026 (page captions + companion blog) |
| Application | **Agentforce Service Agent** — AI customer-service agent on Salesforce |

**Legend:** 🟢 demonstrated · 🟡 mentioned/promised · 🔴 gap / prerequisite outside video · 🔵 replication decision

---

## 1. What the video is about

Build and configure an **Agentforce Service Agent** that can:

1. Look up **order details** by order number.
2. List **orders for a contact** (full name + email).
3. **Create a support Case** (and Contact if missing).
4. Return **case status**.
5. **Summarize a Case** using a Prompt Template.

The presenter first demos a finished agent in Agent Builder conversational preview, then walks through Topics, Instructions, Flow actions, and a Case Summary prompt.

---

## 2. Prerequisites called out in the video 🔴

- Org must be **Agentforce-enabled** (Einstein On + Agents On).
- Trail / prior setup video for Agentforce user + configs (linked in description).
- Companion blog has copy-paste Topic instructions, Flow XML, and Prompt text.
- Blog setup steps: Agentforce playground signup → Einstein Setup On → Agents On → assign **Service Agent Permissions** to the Einstein Service Agent user (alongside Agentforce Service Agent User).

---

## 3. Agent creation path 🟢

1. Setup → **Agents** → New Agent → choose **Agentforce Service Agent**.
2. Remove all **standard topics/actions** (presenter uses only custom actions).
3. Fill agent basics: description, role, company (“cupcakes” in blog sample), running user (Agentforce Service Agent user).
4. Optional: enrich event logs with conversational data.
5. Land in Agent Builder canvas (Topics left, conversation preview right).

---

## 4. Topic: Cases 🟢

| Field | Content (from video + blog) |
|---|---|
| Label / API | Cases / `Cases` |
| Classification | Used to create support cases and get case status |
| Scope | Create support cases; provide status updates |

**Instructions (paraphrased + blog text):**
1. If `CaseStatus` output is null → meaningful “no matching case” message.
2. Create new case → use **Create a Case** action.
3. Always polite / kind.
4. Never provide general (ungrounded) information.
5. Never show Salesforce IDs.
6. Be helpful and polite.
7. Order inquiry → switch to **Order Enquiries** topic.
8. If status null → ask whether to create a case.
9. Collect: First Name, Last Name, Email, Subject, Description.
10. After create: “Your case is important to us, and we will escalate it after 24 hours of non-attendance.”
11. Status check → ask First Name, Last Name, Email, Case Number.
12. Be empathetic while collecting details.

**Actions:**
- **Create a Case** (autolaunched Flow): Get Contact by First/Last/Email → if exists create Case; else create Contact then Case → Get Case → output Case record to conversation.
- **Get Case Status** (autolaunched Flow): Case Number + Contact identity → output Case Status (null-safe messaging via instructions).

**Demo proof:** Case created under Contact; Account auto-linked; status “New”; owner Einstein Service Agent.

---

## 5. Topic: Order Enquiries 🟢

| Field | Content |
|---|---|
| Label / API | Order Enquiries / `Order_Enquiries` |
| Classification | Get order details |
| Scope | Get orders via the topic’s actions |

**Instructions:**
1. Search by contact → ask full name + email.
2. Search by order number → ask order number.
3–5. Rephrase variants; ask name and email **one by one**.
6. Use genuine human language.
7. Case status / create case → switch to **Cases** topic.

**Actions:**
- **Get Orders by Contact ID** — Contact by name/email → Orders for that Contact → collection output.
- **Get Order by Order Number** — Order Name/Number → single Order record.

**Data note 🔴/🔵:** Companion Flow XML uses custom object `Orders__c` (blog comment confirms this was not called out clearly in prose). Video UI shows Order Id / Amount / Date / Status. Replication uses **`Orders__c`** with Contact lookup to match the published flows.

**Instruction gap called out in video:** Order topic lacked “never show Salesforce Id”, so IDs appeared in order replies — Cases topic hid them.

---

## 6. Topic: Summaries Case 🟢

| Field | Content |
|---|---|
| Label / API | Summaries Case / `Summaries_Case` |
| Classification | Summarize case by case number |
| Scope | Provide full relevant case summary |

**Instructions:**
1. Empathy + professionalism.
2. Ask for case number when summarizing (agent may reuse case number already in chat memory).
3. Get Case Details action → then Case Summary prompt action.
4. Display `promptResponse` as the summary.

**Actions:**
- **Get Case Details** (Flow) — Case Number → Case record.
- **Case Summary** (Prompt Template) — grounded Case JSON → narrative sections: Case Overview, Activity, Contacts. Strict INSTRUCTIONS vs DATA separation; third-person; no invented facts.

---

## 7. Cross-cutting behaviours demonstrated 🟢

- Natural language understanding (not rigid keyword bots).
- Topic switching mid-conversation.
- Conversation memory (summarize “the above case” without re-asking number).
- Flow I/O contract: agent→flow = Available for Input; flow→agent = Available for Output.
- One focused Flow per action (create vs get status vs get orders) — keep actions specific.
- Agent action UI: describe inputs (collect from user / required) and outputs (show in conversation).

---

## 8. Gaps / non-goals from this single video

| Gap | Impact |
|---|---|
| Full Agentforce org enablement | Must use Agentforce-capable DE / playground |
| Exact Flow XML in video (blog incomplete fragments) | Rebuild clean Flows from described logic |
| Messaging / Experience site channel deployment | Not shown — Agent Builder preview only |
| Standard Order object vs `Orders__c` | Use custom object per blog |
| Packaging of GenAi / Bot metadata | May require UI + Agent DX after Einstein On |

---

## 9. Extracted requirement IDs (for BRD / FDD)

- FR-AGT-01…06 agent capabilities  
- FR-CASE-01…05 case create/status/summary  
- FR-ORD-01…03 order lookup  
- NFR-SEC-01 no Salesforce Ids / no ungrounded answers  
- BR-01…05 business rules (escalation message, contact auto-create, etc.)
