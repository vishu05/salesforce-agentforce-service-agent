// Seed Account + Contact + 2 Orders for Agentforce Service Agent demos.
// Idempotent on Contact Email = af.demo.customer@example.com

String emailKey = 'af.demo.customer@example.com';

Account acc;
List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = 'AF Demo Customer Account' LIMIT 1];
if (accs.isEmpty()) {
    acc = new Account(Name = 'AF Demo Customer Account');
    insert acc;
} else {
    acc = accs[0];
}

Contact con;
List<Contact> cons = [
    SELECT Id, FirstName, LastName, Email, AccountId
    FROM Contact
    WHERE Email = :emailKey
    LIMIT 1
];
if (cons.isEmpty()) {
    con = new Contact(
        FirstName = 'Ava',
        LastName = 'Patel',
        Email = emailKey,
        AccountId = acc.Id
    );
    insert con;
} else {
    con = cons[0];
    if (con.AccountId == null) {
        con.AccountId = acc.Id;
        update con;
    }
}

List<Orders__c> existing = [
    SELECT Id, Name FROM Orders__c WHERE Contact__c = :con.Id
];
if (existing.isEmpty()) {
    insert new List<Orders__c>{
        new Orders__c(
            Name = 'ORD-1001',
            Contact__c = con.Id,
            Amount__c = 129.99,
            Order_Date__c = Date.today().addDays(-12),
            Status__c = 'Shipped'
        ),
        new Orders__c(
            Name = 'ORD-1002',
            Contact__c = con.Id,
            Amount__c = 49.50,
            Order_Date__c = Date.today().addDays(-3),
            Status__c = 'Confirmed'
        )
    };
}

System.debug('Seed complete. Contact=' + con.Id + ' Email=' + emailKey);
System.debug('Use order numbers ORD-1001 / ORD-1002 and name Ava Patel with email ' + emailKey);
