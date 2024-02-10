@RestResource(urlMapping='/Contacts/*')
global with sharing class ContactManager {

    @HttpPatch
    global static void getUpdatedField() {

        String restString;
        JSONGenerator gen = JSON.createGenerator(true);

        try{
            RestRequest request = RestContext.request;
            String contactId = request.requestURI.substring(
                request.requestURI.lastIndexOf('/')+1);
            RestResponse resp = RestContext.response;

            Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
            
            // Deserialize the JSON string into name-value pairs
                Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            
                // Iterate through each parameter field and value
            for(String fieldName : params.keySet()) {
                // Set the field and value on the Contact sObject
                thisContact.put(fieldName, params.get(fieldName));
            }
            update thisContact;
            resp.addHeader('Content-Type', 'application/json');
            resp.statusCode = 200;
            restString = 'The contact with id ' + thisContact.id +' has been updated.' + ' The fields have been updated are ' + String.join(params.KeySet(), ',');
            gen.writeStartObject();
            gen.writeStringField('Data', restString);
            gen.writeStringField('Status', resp.statusCode + ', OK success code for Message request');
            gen.writeEndObject();
            String jsonStr = gen.getAsString();
            resp.responseBody = Blob.valueOf(jsonStr);
        }catch(Exception e) {
            if(e.getTypeName() == 'System.QueryException'){
                RestContext.response.statusCode = 404;
                gen.writeStartObject();
                gen.writeStringField('error', e.getMessage());
                gen.writeStringField('message', RestContext.response.statusCode + ' , le contact n\'existe pas');
                gen.writeEndObject();
                String jsonStr = gen.getAsString();
                RestContext.response.responseBody = Blob.valueOf(jsonStr);
            }else{
            String error = e.getMessage() + '\r\n' + e.getStackTraceString() + e.getTypeName();
        
            RestContext.response.statusCode = 400;
    
            RestContext.response.responseBody = Blob.valueOf(error);
            }
        }
    }

    @HttpPost
    global static void createContact(String firstName, String lastName,
        String email) {

        try {
            RestResponse res = RestContext.response;
            List<Contact> con = [SELECT Id, Email FROM Contact WHERE Email = :email];
            res.addHeader('Content-Type', 'application/json');
            JSONGenerator gen = JSON.createGenerator(true);

 
            if(con.size() > 0){
                res.statusCode = 200;
                gen.writeStartObject();
                gen.writeStringField('Data', 'The contact  '+ con[0].id + ' already exist ');
                gen.writeStringField('Status', res.statusCode + ' , OK success code for Message request');
                gen.writeEndObject();
                String jsonStr = gen.getAsString();
                res.responseBody = Blob.valueOf(jsonStr);
            }else{
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = Email);
            insert newContact;
            res.statusCode = 201;
            gen.writeStartObject();
            gen.writeStringField('Data', 'The contact ' + newContact.id +' has been inserted,');
            gen.writeStringField('Status',  res.statusCode + ' : Created ');
            gen.writeEndObject();
            String jsonStr = gen.getAsString();
            res.responseBody = Blob.valueOf(jsonStr);
            }
        }catch(Exception e) {

            String error = e.getMessage() + '\r\n' + e.getStackTraceString() + e.getTypeName();
        
            RestContext.response.statusCode = 400;
    
            RestContext.response.responseBody = Blob.valueOf(error);
        }
        
    } 

    @HttpDelete 
    global static void deleteContact() {

        JSONGenerator gen = JSON.createGenerator(true);

        try{
            RestResponse res = RestContext.response;
            RestRequest request = RestContext.request;
            String contactId = request.requestURI.substring(
                request.requestURI.lastIndexOf('/')+1);
            Contact thisContact = [SELECT Id, Activated__c FROM Contact WHERE Id = :contactId LIMIT 1];
            res.addHeader('Content-Type', 'application/json');


            res.statusCode = 200;

            gen.writeStartObject();
            gen.writeStringField('Data', 'The contact  ' + thisContact.Id + ' has been deactivated,');
            gen.writeStringField('Status', res.statusCode + ', OK success code for Message request');
            gen.writeEndObject();

            String jsonStr = gen.getAsString();
            res.responseBody = Blob.valueOf(jsonStr);

            thisContact.Activated__c = false;
            update thisContact;
        }catch(Exception e) {

            if(e.getTypeName() == 'System.QueryException'){
                RestContext.response.statusCode = 404;
                gen.writeStartObject();
                gen.writeStringField('error', e.getMessage());
                gen.writeStringField('message', RestContext.response.statusCode + ' , le contact n\'existe pas');
                gen.writeEndObject();
                String jsonStr = gen.getAsString();
                RestContext.response.responseBody = Blob.valueOf(jsonStr);
            }else{
            String error = e.getMessage() + '\r\n' + e.getStackTraceString() + e.getTypeName();
    
            System.debug(error);
    
            RestContext.response.statusCode = 400;
    
            RestContext.response.responseBody = Blob.valueOf(error);
            }  
        }    
}

}