/**
 * This class contains unit tests for validating the behavior of Apex classes
 */
@isTest
private class ContractHandlerTest {

    @TestSetup
    static void makeData(){
        Account a = new Account(Name = 'Edge Communications 2');
        insert a;
        Contract c = new Contract(
            AccountId = a.id,
            Status = 'Draft',
            ContractTerm = 4,
            StartDate = date.parse('02/02/2024')
        );
        insert c;
    }
    @isTest
    static void createContractTest() {
        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse resp = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/Contracts';
        request.httpMethod = 'POST';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        // Call the method to test
        RestContext.response= resp;

        Account acc = [SELECT id FROM Account WHERE Name = 'Edge Communications 2'];
        ContractHandler.createContract(acc.id, 'Draft', 5, date.parse('11/02/2024'));
        Test.stopTest(); 

        // Verify results
        String actual = resp.responseBody.toString(); //Convert Blob to String
        System.assert(actual.contains('has been inserted'), true);
        System.assertEquals(201 ,resp.statusCode, 'Created'); //Assert with expected status code. Status Code needs to be set in the main class.
    }

    @isTest
    static void patchContractTest(){
        //Account acc = [SELECT id FROM Account WHERE Name = 'Edge Communications 2'];
        Contract contract = [SELECT id, Status FROM Contract /*WHERE id = :acc.id AND StartDate = :date.parse('02/02/2024')*/ LIMIT 1];
        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/Contracts/'+contract.id;
        request.httpMethod = 'PATCH';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        request.RequestBody = Blob.valueOf('{"Status" : "Activated", "StartDate" : "13/06/2024"}');
        // Call the method to test
        RestContext.response= response;

        ContractHandler.getUpdatedField(); 
        // Verify results
        String actual = response.responseBody.toString(); //Convert Blob to String
        System.assert(actual.contains('has been updated'), true);
        System.assertEquals(200 ,response.statusCode, 'success'); //Assert with expected status code. Status Code needs to be set in the main class.
        Test.stopTest(); 
        Contract contract1 = [SELECT id, Status From Contract WHERE id = :contract.id];
        System.assertEquals('Activated', contract1.Status, 'ok');
    }
    @isTest
    static void exceptionTest(){
        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties

        request.requestUri = '/services/apexrest/Contracts/XXXXXXXXX';//set up an uncomplete id 
        request.httpMethod = 'PATCH';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        request.RequestBody = Blob.valueOf('{"Status" : "Activated", "StartDate" : "13/06/2024"}');
        // Call the method to test
        RestContext.response= response;

        ContractHandler.getUpdatedField(); 
        Test.stopTest(); 

        // Verify results
        String actual = response.responseBody.toString(); //Convert Blob to String
        System.assert(actual.contains('le contract n\'existe pas'));
        System.assertEquals(404 ,response.statusCode); //Assert with expected status code. Status Code needs to be set in the main class.

    }

}