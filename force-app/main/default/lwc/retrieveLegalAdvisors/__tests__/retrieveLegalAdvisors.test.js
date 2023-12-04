import { createElement } from 'lwc';
import RetrieveLegalAdvisors from 'c/retrieveLegalAdvisors';
import parseLegalAdvisors from '@salesforce/apex/ucl_LegalAdvisorParser.parseLegalAdvisors';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';

jest.mock('@salesforce/apex/ucl_LegalAdvisorParser.parseLegalAdvisors', () => ({
  default: jest.fn()
}), { virtual: true });


describe('c-retrieve-legal-advisors', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it('handles successful server response', () => {
    const element = createElement('c-retrieve-legal-advisors', {
      is: RetrieveLegalAdvisors
    });
    document.body.appendChild(element);

    parseLegalAdvisors.mockResolvedValue('Successful response');
    element.handleClick();
    expect(parseLegalAdvisors).toHaveBeenCalledTimes(1);

    return Promise.resolve().then(() => {
      const toastEvent = new CustomEvent(ShowToastEventName);
      expect(toastEvent.detail.title).toBe('Success');
    });
  });

  it('handles server error', () => {
    const element = createElement('c-retrieve-legal-advisors', {
      is: RetrieveLegalAdvisors
    });
    document.body.appendChild(element);

    parseLegalAdvisors.mockRejectedValue({ body: { message: 'Server error' } });
    element.handleClick();

    expect(parseLegalAdvisors).toHaveBeenCalledTimes(1);
    return Promise.resolve().then(() => {
      const toastEvent = new CustomEvent(ShowToastEventName);
      expect(toastEvent.detail.title).toBe('Error');
    });
  });
});
