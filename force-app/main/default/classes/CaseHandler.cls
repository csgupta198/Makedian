public with sharing class CaseHandler {
    private static boolean flag = false;
    public static void updateNonconformance(List<Case> caseList){
        try{
            if(flag){
                return;
            }
            flag = true;
            List<SQX_Nonconformance__c> nonConfList = new List<SQX_Nonconformance__c>();
            for(Case cs : caseList){
                Schema.DescribeSObjectResult nonConfObj = SQX_Nonconformance__c.sObjectType.getDescribe();
                if(cs.Type == 'Problem' && cs.SQX_NC_Reference__c == null && nonConfObj.isCreateable()){
                    SQX_Nonconformance__c nonConf = new SQX_Nonconformance__c();
                    nonConf.SQX_Priority__c = cs.Priority;
                    nonConf.SQX_Title__c = cs.Subject;
                    nonConf.SQX_Description__c = cs.Description;
                    nonConf.SQX_QMS_Reference_Number__c = cs.CaseNumber;
                    nonConfList.add(nonConf);
                }
            }
            Set<Id> nonConfIds = new Set<Id>();
            if(!nonConfList.isEmpty()){
                List<Database.SaveResult> result = Database.Insert(nonConfList,false);
                for(Database.SaveResult res : result){
                    if (res.isSuccess()) {
                        nonConfIds.add(res.getId());
                    }
                }
            }
            List<SQX_Nonconformance__c> nonConfCreatedList = [SELECT Id, SQX_Priority__c, SQX_Title__c,SQX_Description__c, SQX_QMS_Reference_Number__c 
                                                              FROM SQX_Nonconformance__c WHERE Id IN : nonConfIds];
            Map<String, Id> csNumberVsnonConformance = new Map<String, Id>();
            for(SQX_Nonconformance__c conf : nonConfCreatedList){
                csNumberVsnonConformance.put(conf.SQX_QMS_Reference_Number__c, conf.Id);
            }
            List<Case> caseForUpdate = new List<Case>();
            for(Case cs : caseList){
                if(csNumberVsnonConformance.containsKey(cs.CaseNumber)){
                    Case newCs = new Case();
                    newCs.Id = cs.Id;
                    newCs.SQX_NC_Reference__c = csNumberVsnonConformance.get(cs.CaseNumber);
                    caseForUpdate.add(newCs);
                }
            }
            if(!caseForUpdate.isEmpty()){
                Update caseForUpdate;
            }
        }
        catch(Exception ex){
            System.debug('Message-->'+ex.getMessage()+' Line Number-->'+ex.getLineNumber());
        }
    }
}