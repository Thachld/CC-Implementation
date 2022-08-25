import { LightningElement } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import helpcentericon from '@salesforce/resourceUrl/helpcentericon';

import LEGAL_LABEL from '@salesforce/label/c.Legal';
import PRIVACY_POLICY_LABEL from '@salesforce/label/c.Privacy_policy';
import TERM_OF_USE_LABEL from '@salesforce/label/c.Terms_of_use';
import CONTACT_US_LABEL from '@salesforce/label/c.Contact_Us';
import HEADQUATER_LABEL from '@salesforce/label/c.Headquarters';
import HEAD_LOCATION_LABEL from '@salesforce/label/c.Location';
import HEAD_PHONE_LABEL from '@salesforce/label/c.Main_Phone';
import BRANCH_OFFICE_LABEL from '@salesforce/label/c.Branch_office';
import BRANCH_LOCATION_LABEL from '@salesforce/label/c.Branch_office_Location';
import BRANCH_PHONE_LABEL from '@salesforce/label/c.Branch_Phone';
import COPYRIGHT_LABEL from '@salesforce/label/c.Copyright';


export default class Helpcenterfooter extends LightningElement {

    LABEL_LEGAL = LEGAL_LABEL;
    LABEL_PRIVACY_POLICY = PRIVACY_POLICY_LABEL;
    LABEL_TERM_OF_USE = TERM_OF_USE_LABEL; 
    LABEL_CONTACT_US = CONTACT_US_LABEL;
    LABEL_HEADQUATER = HEADQUATER_LABEL;
    LABEL_HEAD_LOCATION = HEAD_LOCATION_LABEL;
    LABEL_HEAD_PHONE = HEAD_PHONE_LABEL;
    LABEL_BRANCH_OFFICE = BRANCH_OFFICE_LABEL;
    LABEL_BRANCH_LOCATION = BRANCH_LOCATION_LABEL;
    LABEL_BRANCH_PHONE = BRANCH_PHONE_LABEL;   

    get LABEL_COPYRIGHT(){
        var d = new Date();
        var curY = d.getFullYear();
        var cplabel = COPYRIGHT_LABEL + ' @ ' + curY + ' CỐC CỐC.';
        return cplabel;
    }


    phoneIcon = helpcentericon + '/images/phone.svg';
    emailIcon = helpcentericon + '/images/email.svg';
    locationIcon = helpcentericon + '/images/location.svg';
    logodarkIcon = helpcentericon + '/images/logo-dark.svg';
    skypeIcon = helpcentericon + '/images/skype.svg';
    symbolIcon = helpcentericon + '/images/symbol.png';

    get getTermOfUse(){
        if (LANG == 'en-US'){
            return '/s/article/Terms-of-Use?language=en_US';
        }else{
            return '/s/article/Điều-khoản-sử-dụng?language=vi';
        }
    }

    get getPrivacyPolicies(){
        if (LANG == 'en-US'){
            return '/s/article/Privacy-policy?language=en_US';
        }else{
            return '/s/article/Chính-sách-bảo-mật?language=vi';
        }
    }

    get getContactLink(){
        if (LANG == 'en_US'){
            return  'https://qc.coccoc.com/en/contact';
        }else{
            return 'https://qc.coccoc.com/vn/contact';
        }
    }

    get getQCHomeLink(){
        console.log(LANG);
        if (LANG == 'en-US'){
            return  'https://qc.coccoc.com/en/';
        }else{
            return 'https://qc.coccoc.com/vn/';
        }
    }
}