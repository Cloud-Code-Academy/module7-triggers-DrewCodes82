trigger OpportunityTrigger on Opportunity (before update, after update, before delete) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        /*
        * Question 5
        * Opportunity Trigger
        * When an opportunity is updated validate that the amount is greater than 5000.
        * Error Message: 'Opportunity amount must be greater than 5000'
        * Trigger should only fire on update.
        */
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount < 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate && !TriggerControl.hasRunOpportunityContactUpdate){
        /*
        * Question 7
        * Opportunity Trigger
        * When an opportunity is updated set the primary contact on the opportunity to the contact on the same account with the title of 'CEO'.
        * Trigger should only fire on update.
        */
        TriggerControl.hasRunOpportunityContactUpdate = true;
        // Get the AccountIds related to the Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        // Get the Contact related to the Accounts where the Title = CEO
        Map<Id, Contact> accountIdToCEO = new Map<Id, Contact>();
        for (Contact con : [
            SELECT Id, AccountId
            FROM Contact 
            WHERE AccountId IN :accountIds 
            AND Title = 'CEO'
            ]) {
            if (!accountIdToCEO.containsKey(con.AccountId)) {
                accountIdToCEO.put(con.AccountId, con);
            }
                            }
        // Create List of Opportunities to be updated
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        // Loop through new Opportunities to be updated, set the fields, add the opp to List
        for (Opportunity opp : Trigger.new) {
            if (accountIdToCEO.containsKey(opp.AccountId)) {
                Opportunity updatedOpp = new Opportunity();
                updatedOpp.Id = opp.Id;
                updatedOpp.Primary_Contact__c = accountIdToCEO.get(opp.AccountId).Id;
                oppsToUpdate.add(updatedOpp);
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        /*
        * Question 6
        * Opportunity Trigger
        * When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
        * Error Message: 'Cannot delete closed opportunity for a banking account that is won'
        * Trigger should only fire on delete.
        */
        // Add AccountIds for Opportunities to a List for Query
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.old) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        // Get all Accounts for the related Opporunities and store them in a Map for future reference
        Map<Id, Account> idsToAccounts = new Map<Id, Account>([SELECT Id, Industry
                                                                FROM Account
                                                                WHERE Id IN :accountIds]);
        // Loop through the Opporunities to be deleted, getting the related Account to check Industry field
        for (Opportunity opp : Trigger.old) {
            Account relatedAccount = idsToAccounts.get(opp.AccountId);
            if (opp.StageName == 'Closed Won' 
                && relatedAccount.Industry != null 
                && relatedAccount.Industry == 'Banking') {
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }

    }
}