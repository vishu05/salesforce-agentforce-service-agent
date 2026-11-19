# Manual Agent Builder checklist

Use after Einstein + Agentforce are On in an Agentforce-capable Developer Edition.

1. Setup → Users → Einstein Service Agent user → assign **Service Agent Permissions** + **AF Service Agent Access**.
2. Setup → Agents → New Agent → **Agentforce Service Agent**.
3. Remove unused standard topics/actions.
4. Set Name / Role / Company / Description from `specs/topic-instructions.md`.
5. Create Topic **Cases** → paste instructions → add actions:
   - Flow `AF Create a Case` (inputs collect from user; output CaseRecord show in conversation)
   - Flow `AF Get Case Status` (output CaseStatus show in conversation)
6. Create Topic **Order Enquiries** → paste instructions → add actions:
   - Flow `AF Get Orders By Contact`
   - Flow `AF Get Order By Order Number`
7. Prompt Builder → create Case Summary prompt from `specs/topic-instructions.md`.
8. Create Topic **Summaries Case** → actions: `AF Get Case Details` + Case Summary prompt.
9. Conversational preview → run `docs/uat/UAT-01-agent-conversations.md`.
10. Retrieve agent metadata (optional): `sf project retrieve start -m BotDefinition,GenAiPlanner,GenAiPromptTemplate -o agentforceOrg`
