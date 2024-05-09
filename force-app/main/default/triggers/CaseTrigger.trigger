trigger CaseTrigger on Case (after insert, after update) {
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        CaseHandler.updateNonconformance(trigger.new);
    }
}