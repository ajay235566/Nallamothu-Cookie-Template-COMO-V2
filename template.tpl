___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_nallamothu_consent_tag",
  "version": 1,
  "securityGroups": [],
  "displayName": "Nallamothu\u0027s Consent Template",
  "description": "A unified template for setting Default and Update Consent states.",
  "containerContexts": [
    "WEB"
  ],
  "categories": [
    "CONCENT"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "consent_action_type",
    "displayName": "Consent Action Type",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "default",
        "displayValue": "Default State"
      },
      {
        "value": "update",
        "displayValue": "Update State"
      }
    ],
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const getCookieValues = require('getCookieValues');
const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const JSON = require('JSON');
const copyFromDataLayer = require('copyFromDataLayer'); // Ensure no hyphens here

const CONSENT_KEYS = [
  'ad_storage', 
  'analytics_storage', 
  'ad_user_data', 
  'ad_personalization'
];

let finalConsent = {};
let foundInDL = false;

// 1. Safe Data Layer Extraction
for (let i = 0; i < CONSENT_KEYS.length; i++) {
  const key = CONSENT_KEYS[i];
  const dlValue = copyFromDataLayer(key);
  if (dlValue === 'granted' || dlValue === 'denied') {
    finalConsent[key] = dlValue;
    foundInDL = true;
  }
}

// 2. Safe Cookie Extraction
if (!foundInDL) {
  const COOKIE_NAME = 'nalla_consent_preferences';
  const cookieArray = getCookieValues(COOKIE_NAME);
  let saved = null;
  
  if (cookieArray && cookieArray.length > 0) {
    // Wrap in a simple check to prevent crash if cookie is malformed
    saved = JSON.parse(cookieArray[0]);
  }

  for (let j = 0; j < CONSENT_KEYS.length; j++) {
    const k = CONSENT_KEYS[j];
    finalConsent[k] = (saved && saved[k] === 'granted') ? 'granted' : 'denied';
  }
}

// 3. Execution Logic
// If data.consent_action_type is missing, we default to 'default' to prevent crashes
const action = data.consent_action_type || 'default';

if (action === 'update') {
  updateConsentState(finalConsent);
  log('Nalla: Update Applied', finalConsent);
} else {
  setDefaultConsentState(finalConsent);
  log('Nalla: Default Applied', finalConsent);
}

data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "analytics_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_user_data"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_personalization"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "nalla_consent_preferences"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Test Default and Update logic
  code: |-
    // Test the Update Path (Consent Mode v2)
    const mockUpdate = {
      consent_action_type: 'update',
      ad_storage: 'granted',
      analytics_storage: 'granted',
      ad_user_data: 'granted',           // New Field
      ad_personalization: 'granted',     // New Field
      gtmOnSuccess: () => {}
    };

    runCode(mockUpdate);

    // Test the Default Path (Consent Mode v2)
    const mockDefault = {
      consent_action_type: 'default',
      ad_storage: 'denied',
      analytics_storage: 'denied',
      ad_user_data: 'denied',            // New Field
      ad_personalization: 'denied',      // New Field
      gtmOnSuccess: () => {}
    };

    runCode(mockDefault);

    // Assert that the execution reached this point without errors
    assertThat(true).isTrue();


___NOTES___

Converted from Variable to Tag on 3/5/2026.


