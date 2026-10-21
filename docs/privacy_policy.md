# Privacy Policy for Life Reset — Scroll Se Goal Tak

**Last Updated:** October 2026  
**Effective Date:** October 2026  
**Contact Email:** aliaddaofficial@gmail.com  

---

## 1. Introduction

This Privacy Policy explains how **Life Reset — Scroll Se Goal Tak** ("the App", "we", "our") handles your information. 

We believe that your personal goals, daily habits, focus sessions, and screen-time reflections are strictly personal. Life Reset is built with a **100% offline-first, privacy-by-design architecture**. 

The App does not require user registration or account creation, contains no advertising or third-party analytics trackers, and does not transmit any of your personal data to external servers or third parties.

---

## 2. Information Handled by the Application

All information you input into Life Reset is stored exclusively on your physical Android device in the App's private local database and preference store.

### A. Information You Create and Manage
- **Goals & Priorities:** Goal titles, optional descriptions, target completion dates, daily top-3 priority designations, and completion timestamps.
- **Habits & Streaks:** Habit names, optional descriptions, icon selections, color preferences, and daily calendar completion checkmarks.
- **Focus Timer Records:** Planned focus duration, actual elapsed focus seconds, optional linked goal references, session labels, and start/completion timestamps.
- **Recreational Screen-Time Logs:** Manual estimates you enter regarding time spent on external social media apps, calendar dates, logging timestamps, and optional user notes. *(Note: The App does not monitor your device usage automatically or inspect other applications; all entries are created manually by you).*
- **Preferences & Active Timer State:** Your chosen daily scrolling time limit, default focus timer duration, and transient timer recovery timestamps used to restore an in-progress timer if the App process is interrupted.

---

## 3. Data Collection and External Transmission

- **Zero External Data Transmission:** The App does not collect, transmit, upload, or sync your data to any remote server or cloud service.
- **Zero Internet Permissions:** The production release of the App does not request or hold Android network permissions (`android.permission.INTERNET`). It is technically incapable of sending data over the internet.
- **No Third-Party Analytics or Advertising:** The App does not integrate any third-party advertising SDKs, tracking frameworks, or analytics services (such as Google Analytics, Firebase, or Facebook SDK).
- **No Device Identifiers or Hardware Tracking:** The App does not collect your phone's IMEI, MAC address, advertising ID (GAID), GPS location, contacts, photos, or media files. All internal record IDs are randomly generated UUIDs created locally on your device.

---

## 4. How Your Data Is Stored and Secured

- **On-Device Sandbox:** All information is stored inside Android's protected application sandbox directory (`/data/data/com.life.reset.app/`). Under the Android operating system security model, other applications installed on your phone cannot access this private data.
- **Local SQLite Database:** Structured records are stored in a local SQLite database (`life_reset.db`).
- **Local Key-Value Preferences:** Configuration settings and timer recovery data are stored using Android's standard local `SharedPreferences`.

---

## 5. Data Export (Portability)

Life Reset provides a built-in data export feature accessible via **Settings & Privacy > Export All Data (JSON)**:
- When triggered, the App compiles your local goals, habits, completion history, focus sessions, manual screen-time logs, and configuration preferences into a standard, human-readable JSON text string.
- You can preview this exported text and use the "Copy to Clipboard" button to place the data onto your device's clipboard.
- The App does not send or upload this exported text anywhere. Once copied to your clipboard, you have complete control over where you paste, store, or backup the information.
- *Security Note:* Please exercise caution when copying personal records to the system clipboard, as other applications on your device that have clipboard access permissions may be able to read clipboard contents.

---

## 6. Data Retention and Deletion

You have complete control over the retention and deletion of your data:

1. **In-App Reset ("Delete All App Data"):**
   - You can permanently erase all stored goals, habits, streaks, focus logs, and screen-time entries at any time by navigating to **Settings & Privacy > Reset & Clear > Delete All App Data**.
   - This action requires two separate confirmations to prevent accidental deletion and immediately executes an atomic database wipe and preference clearance.
2. **Device Storage Settings ("Clear Storage"):**
   - You can wipe all application data at the operating system level by going to your phone's **Settings > Apps > Life Reset > Storage > Clear Storage** (or "Clear Data").
3. **Application Uninstallation:**
   - Uninstalling Life Reset from your Android device immediately and permanently deletes the App's private internal storage sandbox, including the SQLite database and all saved preferences. No data remains on your phone after uninstallation.

---

## 7. Operating System Backups

If you have enabled Android's system-level device backup (such as Google Drive device backup) in your phone's operating system settings, your device may include the App's local sandbox files as part of your encrypted personal phone backup managed by Google. This is an operating system feature controlled entirely by your personal Android system settings and Google account preferences, not an in-app data transmission.

---

## 8. Children’s Privacy

Life Reset is a general audience self-improvement and productivity application. We do not knowingly collect, request, or solicit any personal information from children under the age of 13 (or any user of any age). Because the App does not collect or transmit any personal data, it fully complies with the Children's Online Privacy Protection Act (COPPA) and international child privacy regulations.

---

## 9. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect future feature enhancements or regulatory changes. Any updates will be documented with a revised "Last Updated" date. Because the App does not collect your contact details or communicate over a network, you can review the latest policy version by checking the App's official distribution page or documentation.

---

## 10. Contact Information

If you have any questions, suggestions, or concerns regarding this Privacy Policy or your data privacy while using Life Reset — Scroll Se Goal Tak, please contact:

**Developer Support Contact:**  
Email: [aliaddaofficial@gmail.com](mailto:aliaddaofficial@gmail.com)  
Application: Life Reset — Scroll Se Goal Tak (`com.life.reset.app`)
