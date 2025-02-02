// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// /* eslint-disable mozilla/balanced-listeners, no-undef */
import CreditCardHelper from "resource://gre/modules/shared/EntryFile.sys.mjs";

// Define supported message types.
const messageTypes = {
  FILL_CREDIT_CARD_FORM: "fill-credit-card-form",
  CAPTURE_CREDIT_CARD_FORM: "capture-credit-card-form",
};

const transformers = {
  forward: (payload) => payload,
};

// Helper function to send a message back to swift.
const sendMessage =
  (type, transformer = transformers.forward) =>
  (payload) =>
    window.webkit.messageHandlers.creditCardMessageHandler?.postMessage({
      type,
      payload: transformer(payload),
    });

const sendCaptureCreditCardFormMessage = sendMessage(
  messageTypes.CAPTURE_CREDIT_CARD_FORM
);

const sendFillCreditCardFormMessage = sendMessage(
  messageTypes.FILL_CREDIT_CARD_FORM
);

// Create a CreditCardHelper object and expose it to the window object.
// The CreditCardHelper should:
// - expose a method .fillFormFields(payload) that can be called from swift to fill in data.
// - call sendCaptureCreditCardFormMessage(payload) when a credit card form submission is detected.
// - call sendFillCreditCardFormMessage(payload) when a credit card form is detected.
// The implementation file can be changed in Client/Assets/CC_Script/Overrides.ios.js
Object.defineProperty(window.__firefox__, "CreditCardHelper", {
  enumerable: false,
  configurable: false,
  writable: false,
  value: Object.freeze(
    new CreditCardHelper(
      sendCaptureCreditCardFormMessage,
      sendFillCreditCardFormMessage
    )
  ),
});
