// Smoke-test Agentforce backing Flows without Agent Builder.
Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'af.demo.customer@example.com' LIMIT 1];
Orders__c ord = [SELECT Id, Name, Amount__c, Status__c FROM Orders__c WHERE Name = 'ORD-1001' LIMIT 1];
System.assertEquals('Shipped', ord.Status__c, 'ORD-1001 should be Shipped');

Map<String, Object> orderInputs = new Map<String, Object>{ 'OrderNumber' => 'ORD-1001' };
Flow.Interview.AF_Get_Order_By_Order_Number orderFlow = new Flow.Interview.AF_Get_Order_By_Order_Number(orderInputs);
orderFlow.start();
Orders__c outOrder = (Orders__c) orderFlow.getVariableValue('OrderRecord');
System.assertNotEquals(null, outOrder, 'Order flow should return a record');
System.assertEquals('ORD-1001', outOrder.Name);

Map<String, Object> listInputs = new Map<String, Object>{
    'FullName' => con.FirstName + ' ' + con.LastName,
    'Email' => con.Email
};
Flow.Interview.AF_Get_Orders_By_Contact listFlow = new Flow.Interview.AF_Get_Orders_By_Contact(listInputs);
listFlow.start();
List<Orders__c> orders = (List<Orders__c>) listFlow.getVariableValue('OrderRecords');
System.assert(orders != null && orders.size() >= 2, 'Expected at least 2 orders for demo contact');

Map<String, Object> caseInputs = new Map<String, Object>{
    'FirstName' => con.FirstName,
    'LastName' => con.LastName,
    'Email' => con.Email,
    'Subject' => 'AF smoke test case',
    'Description' => 'Created by smoke-test-flows.apex'
};
Flow.Interview.AF_Create_a_Case createFlow = new Flow.Interview.AF_Create_a_Case(caseInputs);
createFlow.start();
Case created = (Case) createFlow.getVariableValue('CaseRecord');
System.assertNotEquals(null, created, 'Create case flow should return Case');
System.assertNotEquals(null, created.CaseNumber);

Map<String, Object> statusInputs = new Map<String, Object>{
    'FirstName' => con.FirstName,
    'LastName' => con.LastName,
    'Email' => con.Email,
    'CaseNumber' => created.CaseNumber
};
Flow.Interview.AF_Get_Case_Status statusFlow = new Flow.Interview.AF_Get_Case_Status(statusInputs);
statusFlow.start();
String status = (String) statusFlow.getVariableValue('CaseStatus');
System.assertEquals('New', status);

Map<String, Object> detailInputs = new Map<String, Object>{ 'CaseNumber' => created.CaseNumber };
Flow.Interview.AF_Get_Case_Details detailFlow = new Flow.Interview.AF_Get_Case_Details(detailInputs);
detailFlow.start();
Case detail = (Case) detailFlow.getVariableValue('CaseRecord');
System.assertEquals(created.CaseNumber, detail.CaseNumber);

System.debug('SMOKE PASS case=' + created.CaseNumber + ' orders=' + orders.size());
