@RestResource(urlMapping='/Contracts/*')
global with sharing class ContractHandler {

    @HttpPost
    global static void createContract(Id accountId, String status,
        Integer term, Date startDate ) {
        
        try {
            RestResponse res = RestContext.response;
            res.addHeader('Content-Type', 'application/json');
            JSONGenerator gen = JSON.createGenerator(true);
           
            Contract newContract = new Contract(
                AccountId = accountId,
                Status = status,
                ContractTerm = term,
                StartDate = startDate);
            insert newContract;
            res.statusCode = 201;

            String str = 'The contract ' + newContract.id +' has been inserted';
            String resp = res.statusCode + ', Created';
            gen.writeStartObject();
            gen.writeStringField('Data', str);
            gen.writeStringField('Status', resp);
            gen.writeEndObject();
            String jsonStr = gen.getAsString();
            res.responseBody = Blob.valueOf(jsonStr);
            
        }catch(Exception e) {

            String error = e.getMessage() + '\r\n' + e.getStackTraceString() + e.getTypeName();    
            RestContext.response.statusCode = 400;
    
            RestContext.response.responseBody = Blob.valueOf(error);
        } 
    } 

    @HttpPatch
    global static void getUpdatedField() {

        String restString;
        JSONGenerator gen = JSON.createGenerator(true);

        try{
            RestRequest request = RestContext.request;
            String contractId = request.requestURI.substring(
                request.requestURI.lastIndexOf('/')+1);
            RestResponse resp = RestContext.response;
            
            Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
            
            // Deserialize the JSON string into name-value pairs
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            
            // Iterate through each parameter field and value
            for(String fieldName : params.keySet()) {
                // Set the field and value on the Contact sObject
                if(fieldName.toLowerCase().contains('date')){
                    thisContract.put(fieldName, date.parse((String)params.get(fieldName)));
                }else{
                    thisContract.put(fieldName, params.get(fieldName));
                }
            }
            update thisContract;
            resp.addHeader('Content-Type', 'application/json');
            resp.statusCode = 200;

            restString = 'The contract ' + thisContract.id +' has been updated.';
            String statut = resp.statusCode + ', OK success code for Message request';
            gen.writeStartObject();
            gen.writeStringField('Data', restString);
            gen.writeStringField('Status', statut);
            gen.writeEndObject();
            String jsonStr = gen.getAsString();
            resp.responseBody = Blob.valueOf(jsonStr);
        }catch(Exception e) {
            if(e.getTypeName() == 'System.QueryException'){
                RestContext.response.statusCode = 404;
                gen.writeStartObject();
                gen.writeStringField('error', e.getMessage());
                gen.writeStringField('message', RestContext.response.statusCode + ' , le contract n\'existe pas');
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
}