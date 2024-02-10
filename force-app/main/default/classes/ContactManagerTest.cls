/**
 * This class contains unit tests for validating the behavior of Apex classes
 */
@isTest
private class ContactManagerTest {

    @TestSetup
    static void makeData(){
        Contact con = new Contact(
            FirstName = 'Asmaa',
            LastName = 'Zaho',
            Email = 'zahasma2@gmail.com');
        insert con;
    }
    @isTest static void testCreateContact() {
        
        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse resp = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/Contacts';
        request.httpMethod = 'POST';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        // Call the method to test
        RestContext.response= resp;
        ContactManager.createContact('Ibra','SAOU', 'ibrsaou@gmail.com');        
        // Verify results
        String actual = resp.responseBody.toString(); //Convert Blob to String
        System.assert(actual.contains('has been inserted'), true);
        System.assertEquals(201 ,resp.statusCode, 'Created'); //Assert with expected status code. Status Code needs to be set in the main class.

        ContactManager.createContact('Ibra','SAOU', 'ibrsaou@gmail.com');
        Test.stopTest(); 
        System.assert(resp.responseBody.toString().contains('already exist'), true);
        System.assertEquals(200,resp.statusCode, 'success');
        }
    @isTest static void testUpdateContact() {
        Contact con = [SELECT id, firstName FROM Contact WHERE lastName = 'Zaho'];
        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/Contacts/'+con.id;
        request.httpMethod = 'PATCH';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        request.RequestBody = Blob.valueOf('{"firstName" : "Asuma"}');
        // Call the method to test
        RestContext.response= response;

        ContactManager.getUpdatedField();        
        // Verify results
        String actual = response.responseBody.toString(); //Convert Blob to String
        System.assert(actual.contains('has been updated'), true);
        System.assertEquals(200 ,response.statusCode, 'success'); //Assert with expected status code. Status Code needs to be set in the main class.
        Test.stopTest(); 
        Contact con1 = [SELECT id, firstName From Contact WHERE id = :con.id];
        System.assertEquals('Asuma', con1.FirstName, 'ok');
    }     

    @isTest static void testDeactivateContact(){
        Contact con = [SELECT id, Activated__c FROM Contact WHERE lastName = 'Zaho'];
        System.assert(con.Activated__c);
        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/Contacts/'+con.id;
        request.httpMethod = 'DELETE';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        // Call the method to test
        RestContext.response= response;

        ContactManager.deleteContact();        
        // Verify results
        String actual = response.responseBody.toString(); //Convert Blob to String
        Test.stopTest();

        Contact con1 = [SELECT id, Activated__c FROM Contact WHERE lastName = 'Zaho'];
        System.assert(actual.contains('has been deactivated'), true);
        System.assertEquals(200 ,response.statusCode, 'success');
        //System.assertEquals(con1.Activated__c, false);
        System.assert(con1.id == con.id);
        System.assert(con1.Activated__c == false);

    }

    
    @isTest static void testUpdateContactexception() {
        
        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/Contacts/XXXXXXXX';
        request.httpMethod = 'PATCH';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        request.RequestBody = Blob.valueOf('{"firstName" : "Asuma"}');
        // Call the method to test
        RestContext.response= response;

        ContactManager.getUpdatedField();  
        Test.stopTest(); 
      
        // Verify results
        String actual = response.responseBody.toString(); //Convert Blob to String
        System.assert(actual.contains('le contact n\'existe pas'), true);
        System.assertEquals(404 ,response.statusCode, 'success'); //Assert with expected status code. Status Code needs to be set in the main class.

    }  
    
    @isTest static void testDeactivateContactException(){

        Test.startTest();
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/Contacts/XXXXXXXXXXX';
        request.httpMethod = 'DELETE';
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        // Call the method to test
        RestContext.response= response;

        ContactManager.deleteContact();        
        // Verify results
        String actual = response.responseBody.toString(); //Convert Blob to String
        Test.stopTest();

        System.assert(actual.contains('le contact n\'existe pas'), true);
        System.assertEquals(404 ,response.statusCode, 'success');
    }

}