# Agentforce Service Agent — Customer Support AI

Replication of the YouTube hands-on build: an **Agentforce Service Agent** that looks up orders, creates/status-checks Cases, and summarizes Cases.

**Source video:** https://www.youtube.com/watch?v=mVNjeNgxxQw  
**Companion blog:** https://www.sfdcgirl.com/2025/02/Agentforce-Service-Agent.html

## Documents

| Doc | Purpose |
|---|---|
| [docs/00-Video-Transcript-Analysis.md](docs/00-Video-Transcript-Analysis.md) | Transcript / walkthrough analysis |
| [docs/01-Business-Requirements-Document.md](docs/01-Business-Requirements-Document.md) | BRD |
| [docs/02-Functional-and-Technical-Design-Document.md](docs/02-Functional-and-Technical-Design-Document.md) | FDD / TDD |
| [specs/topic-instructions.md](specs/topic-instructions.md) | Copy-paste Topic + Prompt text |
| [docs/uat/UAT-01-agent-conversations.md](docs/uat/UAT-01-agent-conversations.md) | Conversational UAT |

## What is in source control

- Custom object `Orders__c` (Contact, Amount, Order Date, Status)
- Autolaunched Flows (Agent Actions):
  - `AF_Create_a_Case`
  - `AF_Get_Case_Status`
  - `AF_Get_Orders_By_Contact`
  - `AF_Get_Order_By_Order_Number`
  - `AF_Get_Case_Details`
- Permission set `AF_Service_Agent_Access`
- Seed script + Topic instruction pack

Agent Builder Topic/Prompt wiring is completed in an **Agentforce-capable** org (Einstein On + Agents On), then optionally retrieved with Agent DX.

## Org requirement (important)

Older Developer Edition orgs often **do not** include Einstein Generative AI / Agentforce. Use a free **Agentforce Developer Edition**:

https://www.salesforce.com/form/developer-signup/?d=pb

Then:

1. Setup → **Einstein Setup** → Turn on Einstein  
2. Setup → **Agents** (or Salesforce Go → Agentforce) → Turn on Agentforce  
3. Assign **Service Agent Permissions** (+ Agentforce Service Agent User) to the Einstein Service Agent user  
4. Authorize the org: `sf org login web -a agentforceOrg`  
5. Deploy + seed + create agent (steps below)

## Deploy

```bash
cd Agentforce-Service-Agent-Project
sf project deploy start -o agentforceOrg --source-dir force-app --wait 10
sf apex run -o agentforceOrg -f scripts/apex/seed-demo-data.apex
sf org assign permset -o agentforceOrg -n AF_Service_Agent_Access --on-behalf-of <einstein-service-agent-username>
```

## Create the agent (UI — matches the video)

1. Setup → Agents → **New Agent** → Agentforce Service Agent  
2. Remove standard topics/actions  
3. Fill role/company from `specs/topic-instructions.md`  
4. Add Topics **Cases**, **Order Enquiries**, **Summaries Case** with instructions from the same file  
5. Attach Flow actions + create Prompt Template for Case Summary  
6. Test in conversational preview using UAT-01

## Demo credentials (seed data)

| Field | Value |
|---|---|
| Contact | Ava Patel |
| Email | af.demo.customer@example.com |
| Orders | ORD-1001 (Shipped), ORD-1002 (Confirmed) |

## Status

- [x] Transcript analysis
- [x] BRD + FDD/TDD
- [x] `Orders__c` + 5 Agent Flows + permset deployed to `vishu4sfdc@saibersys.com`
- [x] Flow smoke UAT PASS (Case 00001440; ORD-1001/1002)
- [x] GitHub: https://github.com/vishu05/salesforce-agentforce-service-agent
- [ ] Einstein / Agentforce enablement (current DE has **no** Agentforce license in Salesforce Go)
- [ ] Agent Builder Topics + Prompt + conversational UAT (needs Agentforce Developer Edition)
