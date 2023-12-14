import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import parseLegalAdvisors from '@salesforce/apex/ucl_LegalAdvisorParser.parseLegalAdvisors';

export default class RetrieveLegalAdvisors extends LightningElement {
  handleClick() {
    parseLegalAdvisors()
      .then(result => {
        if (result.startsWith('Operations')) {
          this.showToast('Success', result, 'success');
        } else {
          this.showToast('Error', result, 'error');
        }
      })
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}