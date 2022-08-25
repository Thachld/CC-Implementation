trigger cc_ContentDocumentTrigger on ContentDocument (before Delete) {
    //string profile = UserInfo.
    String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
    for( ContentDocument item: trigger.old){
        if(profileName != 'System Administrator'){
            item.adderror('Can not delete file');
        }       
    }
}