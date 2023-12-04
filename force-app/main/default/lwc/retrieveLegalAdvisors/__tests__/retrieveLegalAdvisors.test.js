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

  async function flushPromises() {
    return Promise.resolve();
  }

  it('handles successful response', async () => {
    const TOAST_TITLE = 'Success';
    const TOAST_MESSAGE = 'Operations succesful!';
    const TOAST_VARIANT = 'success';

    const element = createElement('c-retrieve-legal-advisors', {
      is: RetrieveLegalAdvisors
    });
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    
    parseLegalAdvisors.mockResolvedValue('Operations succesful!');
    const button = element.shadowRoot.querySelector('lightning-button');
    button.click();

    expect(parseLegalAdvisors).toHaveBeenCalledTimes(1);

    await flushPromises();
    expect(handler).toHaveBeenCalled();
    const toastEvent = handler.mock.calls[0][0];
    expect(toastEvent.detail.title).toBe(TOAST_TITLE);
    expect(toastEvent.detail.message).toBe(TOAST_MESSAGE);
    expect(toastEvent.detail.variant).toBe(TOAST_VARIANT);
  });

  it('handles error', async () => {
    const TOAST_TITLE = 'Error';
    const TOAST_MESSAGE = 'Failed to retrieve data';
    const TOAST_VARIANT = 'error';

    const element = createElement('c-retrieve-legal-advisors', {
      is: RetrieveLegalAdvisors
    });
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    parseLegalAdvisors.mockResolvedValue('Failed to retrieve data');
    const button = element.shadowRoot.querySelector('lightning-button');
    button.click();

    expect(parseLegalAdvisors).toHaveBeenCalledTimes(1);

    await flushPromises();
    expect(handler).toHaveBeenCalled();
    const toastEvent = handler.mock.calls[0][0];
    expect(toastEvent.detail.title).toBe(TOAST_TITLE);
    expect(toastEvent.detail.message).toBe(TOAST_MESSAGE);
    expect(toastEvent.detail.variant).toBe(TOAST_VARIANT);
  });
});
