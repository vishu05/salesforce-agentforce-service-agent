# UAT-01 results — Flow smoke (18 Nov 2026)

Target org: `vishu4sfdc@saibersys.com` (vscodeOrg)

| Check | Result |
|---|---|
| Seed Contact Ava Patel / af.demo.customer@example.com | PASS |
| Orders ORD-1001 / ORD-1002 | PASS |
| `AF_Get_Order_By_Order_Number` → ORD-1001 | PASS |
| `AF_Get_Orders_By_Contact` → 2 orders | PASS |
| `AF_Create_a_Case` → Case **00001440** | PASS |
| `AF_Get_Case_Status` → New | PASS |
| `AF_Get_Case_Details` → same CaseNumber | PASS |

**Agent Builder conversational UAT:** blocked on this org — Salesforce Go → Agentforce returns no provisioned features (Einstein Generative AI / Agentforce not licensed on this older DE). Re-run conversational rows in `UAT-01-agent-conversations.md` after authorizing an Agentforce Developer Edition.
