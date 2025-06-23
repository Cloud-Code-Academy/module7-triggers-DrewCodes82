trigger AccountTrigger on Account (before insert) {

    if (Trigger.isBefore && Trigger.IsInsert){
        for (Account acc : Trigger.new){
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
        }

    }

}