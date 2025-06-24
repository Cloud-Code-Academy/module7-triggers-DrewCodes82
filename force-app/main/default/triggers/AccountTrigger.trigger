trigger AccountTrigger on Account (before insert) {


    if (Trigger.isBefore && Trigger.IsInsert){
        for (Account acc : Trigger.new){
            /*
            * Question 1
            * Account Trigger
            * When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
            * Trigger should only fire on insert.
            */
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
            /*
            * Question 2
            * Account Trigger
            * When an account is inserted copy the shipping address to the billing address.
            * BONUS: Check if the shipping fields are empty before copying.
            * Trigger should only fire on insert.
            */
            if (acc.ShippingStreet != null 
            && acc.ShippingCity != null 
            && acc.ShippingState != null 
            && acc.ShippingCountry != null
            && acc.ShippingPostalCode != null){
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingCountry = acc.ShippingCountry;
                acc.BillingPostalCode = acc.ShippingPostalCode;
            }
            /*
            * Question 3
            * Account Trigger
            * When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
            * Trigger should only fire on insert.
            */ 
            if (acc.Phone != null 
                && acc.Website != null
                && acc.Fax != null) {
                    acc.Rating = 'Hot';
                }
        }

    }

    

}