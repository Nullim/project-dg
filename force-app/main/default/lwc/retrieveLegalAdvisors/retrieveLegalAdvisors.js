import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import parseLegalAdvisors from '@salesforce/apex/ucl_LegalAdvisorParser.parseLegalAdvisors';

export default class RetrieveLegalAdvisors extends LightningElement {
  handleClick() {
    parseLegalAdvisors()
      .then(result => {
        if (result && typeof result === 'string') {
          this.showToast('Success', result, 'success');
        }
      })
      .catch(error => {
        this.showToast('Error', error.body.message, 'error');
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