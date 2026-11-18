# UAT-01 — Agentforce conversational preview

**Demo identity**
- Name: Ava Patel
- Email: af.demo.customer@example.com
- Orders: `ORD-1001` (Shipped), `ORD-1002` (Confirmed)

| # | Utterance path | Expected | Result | Notes |
|---|---|---|---|---|
| 1 | “I want to know about my order” → by order number → `ORD-1001` | Amount, date, status (Shipped); no Salesforce Id | ☐ | |
| 2 | “Get all order details for my contact” → Ava Patel → email | Lists ORD-1001 and ORD-1002 | ☐ | |
| 3 | “Help me create a support case” → collect fields → subject/desc | Case created on Contact; confirmation + 24h escalate message | ☐ | |
| 4 | “Get my case status” → identity + case number | Status only (e.g. New) | ☐ | |
| 5 | Random case number | No match message; offer to create case | ☐ | |
| 6 | “Summarize the above case” (after #3) | Overview / Activity / Contacts narrative | ☐ | |
| 7 | Mid-chat switch: while in Cases, ask about an order | Routes to Order Enquiries | ☐ | |

**Flow smoke (anonymous Apex / Flow debug) if Agentforce UI blocked**
- Invoke `AF_Get_Order_By_Order_Number` with ORD-1001 → record returned
- Invoke `AF_Create_a_Case` with new email → Contact + Case created
