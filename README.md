Overview

This template provides a lightweight, automated solution for managing Google Consent Mode (v2). It acts as a bridge between the browser's cookie storage, the Data Layer, and GTM’s internal consent engine. It ensures that user privacy preferences are respected instantly upon interaction without requiring a page reload.

Core Functionalities

Automatic Dual-Source Detection: The template intelligently prioritizes "live" interaction data from the dataLayer during an update event. If no live event is detected (such as on a fresh page load), it falls back to reading the persisted JSON cookie.

Seamless "No-Reload" Updates: By utilizing the copyFromDataLayer API, the template captures consent changes the moment they occur. This allows tags to trigger immediately after a user clicks "Accept" or "Preferences."

Strict Fallback Logic: To ensure compliance, any missing or malformed data defaults to a denied state, preventing unauthorized tracking.

Simplified Mapping: Eliminates the need for creating multiple manual Data Layer Variables in GTM. It automatically maps the four primary consent keys:

ad_storage

analytics_storage

ad_user_data

ad_personalization

How It Works

Default State: On Consent Initialization, the tag reads the nalla_consent_preferences cookie. If the user is new, it sets the initial state to denied.

User Interaction: When a user interacts with the banner, the banner script saves the cookie and pushes a user_consent_update event to the Data Layer.

Instant Update: The template catches this event, extracts the new statuses directly from the Data Layer push, and executes an update command to GTM’s Consent Mode.

Technical Requirements
Permissions: Requires "Access Cookies" (for nalla_consent_preferences) and "Access Data Layer" (Wildcard or specific keys) enabled in the template settings.

Cookie Format: Expects a JSON stringified object:
{"ad_storage":"granted", "analytics_storage":"granted", ...}

code to be included in the website head section on all pages 

Coockie banner HTML code:

<div id="nalla-banner" style="position: fixed; bottom: 0; width: 100%; background: #1a1a1a; color: #fff; padding: 20px; z-index: 10000; font-family: sans-serif; border-top: 3px solid #3498db;">
  <div style="max-width: 1000px; margin: 0 auto; display: flex; flex-direction: column; gap: 15px;">
    <div>
      <h3 style="margin: 0 0 10px 0;">Privacy Preferences (v2)</h3>
      <p style="font-size: 14px; color: #ccc;">Please select your preferences for each data type below.</p>
    </div>
    
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-size: 13px; background: #2c2c2c; padding: 15px; border-radius: 4px;">
      <label style="cursor:pointer;"><input type="checkbox" id="check-ad-storage" checked> Ad Storage</label>
      <label style="cursor:pointer;"><input type="checkbox" id="check-analytics-storage" checked> Analytics Storage</label>
      <label style="cursor:pointer;"><input type="checkbox" id="check-ad-user-data" checked> Ad User Data</label>
      <label style="cursor:pointer;"><input type="checkbox" id="check-ad-personalization" checked> Ad Personalization</label>
    </div>

    <div style="display: flex; gap: 10px;">
      <button onclick="sendConsent('denied', 'denied', 'denied', 'denied')" style="padding: 10px 20px; cursor: pointer; background: #444; color: #fff; border: none; border-radius: 4px;">Reject All</button>
      <button onclick="sendCustomConsent()" style="padding: 10px 20px; cursor: pointer; background: #3498db; color: #fff; border: none; border-radius: 4px; font-weight: bold;">Save My Choices</button>
      <button onclick="sendConsent('granted', 'granted', 'granted', 'granted')" style="padding: 10px 20px; cursor: pointer; background: #27ae60; color: #fff; border: none; border-radius: 4px; font-weight: bold;">Accept All</button>
    </div>
  </div>
</div>


Script code for storing the user consent state in the cookies of browser

<script>
  const COOKIE_NAME = 'nalla_consent_preferences';

  function setNallaCookie(value) {
    const date = new Date();
    date.setTime(date.getTime() + (30 * 24 * 60 * 60 * 1000));
    document.cookie = COOKIE_NAME + "=" + JSON.stringify(value) + "; expires=" + date.toUTCString() + "; path=/; SameSite=Lax";
  }

  function getNallaCookie() {
    const value = "; " + document.cookie;
    const parts = value.split("; " + COOKIE_NAME + "=");
    if (parts.length === 2) {
      try { return JSON.parse(parts.pop().split(";").shift()); } catch (e) { return null; }
    }
    return null;
  }

  // --- UI TOGGLE LOGIC ---
  function hideBanner() {
    document.getElementById('nalla-banner').style.display = 'none';
    document.getElementById('consent-icon').style.display = 'flex'; // Show floating icon
  }

  function showBanner() {
    document.getElementById('nalla-banner').style.display = 'block';
    document.getElementById('consent-icon').style.display = 'none'; // Hide floating icon
  }

  // --- CONSENT LOGIC ---
  function sendCustomConsent() {
    const adsStatus = document.getElementById('check-ad-storage').checked ? 'granted' : 'denied';
    const analyticsStatus = document.getElementById('check-analytics-storage').checked ? 'granted' : 'denied';
    const userDataStatus = document.getElementById('check-ad-user-data').checked ? 'granted' : 'denied';
    const personalizationStatus = document.getElementById('check-ad-personalization').checked ? 'granted' : 'denied';
    
    sendConsent(adsStatus, analyticsStatus, userDataStatus, personalizationStatus); 
  }

  function sendConsent(ad_val, analytics_val, userData_val, personalization_val) {
    const consentObject = {
      ad_storage: ad_val,
      analytics_storage: analytics_val,
      ad_user_data: userData_val,
      ad_personalization: personalization_val,
      consent_selected: true
    };

    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({
      'event': 'user_consent_update',
      ...consentObject
    });

    setNallaCookie(consentObject);
    hideBanner();
  }

  // ON PAGE LOAD
  window.addEventListener('DOMContentLoaded', function() {
    const savedConsent = getNallaCookie();
    
    if (savedConsent && savedConsent.consent_selected) {
      // User already interacted: Hide banner, show icon
      hideBanner();
      
      // Sync GTM
      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push({
        'event': 'user_consent_update',
        ...savedConsent
      });

      // Update UI Checkboxes to match saved state
      document.getElementById('check-ad-storage').checked = (savedConsent.ad_storage === 'granted');
      document.getElementById('check-analytics-storage').checked = (savedConsent.analytics_storage === 'granted');
      document.getElementById('check-ad-user-data').checked = (savedConsent.ad_user_data === 'granted');
      document.getElementById('check-ad-personalization').checked = (savedConsent.ad_personalization === 'granted');
    } else {
      // First visit: Show banner, hide icon
      showBanner();
    }
  });
</script>
	<div id="consent-icon" onclick="showBanner()" style="position: fixed; bottom: 20px; right: 20px; width: 50px; height: 50px; background: #3498db; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; cursor: pointer; z-index: 9999; box-shadow: 0 4px 10px rgba(0,0,0,0.3); display: none;">
  ⚙️
</div>


You can always modify the code:)



