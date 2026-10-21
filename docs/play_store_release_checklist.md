# Life Reset — Google Play Store Release & Submission Guide
**Application ID:** `com.life.reset.app` | **Target SDK:** 36 (Android 16) | **Min SDK:** 24 (Android 7.0+)

---

## 1. Verified Artifacts & Binary Sizes

| Build Artifact | File Path | Actual File Size | Download Size on Device | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Android App Bundle (AAB)** | `build\app\outputs\bundle\release\app-release.aab` | **49.52 MB** (51,922,236 B) | **~17.9 MB** (via Google Play Dynamic Delivery) | Locally compiled with test key (Awaiting production keystore authorization) |
| **Universal Release APK** | `build\app\outputs\flutter-apk\app-release.apk` | **50.73 MB** (53,198,708 B) | **50.73 MB** (Contains all 3 CPU architectures) | Tested & verified on Android Emulator |
| **arm64-v8a Release APK** | `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk` | **17.96 MB** (18,831,634 B) | **17.96 MB** (Optimized for modern 64-bit phones) | Generated via `--split-per-abi` |
| **armeabi-v7a Release APK** | `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk` | **15.42 MB** (16,174,814 B) | **15.42 MB** (Optimized for 32-bit legacy phones) | Generated via `--split-per-abi` |
| **High-Res Store Icon** | `playstore_icon_512.png` | **32.99 KB** (33,778 B) | 512 × 512 px PNG (no alpha) | Verified on disk |

> [!NOTE]
> **Why is the AAB 49.52 MB while the device download is only ~17.9 MB?**
> The `.aab` file uploaded to Google Play is a multi-architecture container containing compiled C++/Dart libraries for `arm64-v8a`, `armeabi-v7a`, and `x86_64`. When a user installs Life Reset from Google Play, Google generates an optimized slice for their specific phone model. Modern Android phones will download only the `arm64-v8a` slice (~17.9 MB), saving user data and storage.

---

## 2. Emulator-Captured Store Screenshots

All screens have been verified and captured from the live release build running on the `Medium_Phone_API_37.0` Android emulator (1080 × 2400 resolution):

| Screenshot | Screen / Flow | File Path | Verified Behaviors |
| :--- | :--- | :--- | :--- |
| **01** | Home Screen | `screenshots\01_home_screen.png` | Minimal typography, empty priorities guidance, habit summary |
| **02** | Goals Screen | `screenshots\02_goals_screen.png` | Segmented filter (Active/Completed), empty state, priority counter |
| **03** | Focus Timer | `screenshots\03_focus_screen.png` | Preset duration pills (15/25/45/60 min), goal linking dropdown |
| **04** | Habits Screen | `screenshots\04_habits_screen.png` | Streak tracking cards, check-off interaction, habit creation |
| **05** | Progress Dashboard | `screenshots\05_progress_screen.png` | 7-day focus vs. screen-time balance, habit consistency chart |
| **06** | Settings Screen | `screenshots\06_settings_screen.png` | 100% offline badge, scroll target setter, JSON export, data wipe |
| **07** | Keyboard & Sheet | `screenshots\07_keyboard_goal_sheet.png` | Soft keyboard visibility without obscuring form fields |
| **08** | Goal Typed | `screenshots\08_goal_typed.png` | Input validation and daily priority toggle switch |
| **09** | Goal Created | `screenshots\09_goal_saved_list.png` | Real-time card insertion into SQLite database |
| **10** | Home with Goal | `screenshots\10_home_with_priority.png` | Active daily priority synchronized to Home screen |
| **11** | Timer Running | `screenshots\11_focus_timer_running.png` | Real-time wall-clock countdown and animated progress ring |
| **12** | Timer Paused | `screenshots\12_focus_timer_paused.png` | Elapsed time frozen accurately without timer drift |
| **13** | Timer Resumed | `screenshots\13_focus_timer_resumed.png` | Resumes countdown seamlessly from pause point |
| **14** | Restart Persistence | `screenshots\14_restarted_app_persistence.png` | App process terminated and restarted; SQLite data persists |
| **15** | Restored Timer | `screenshots\15_focus_restored_after_restart.png` | Timer state preserved across app kill/restart |
| **16** | JSON Export Sheet | `screenshots\16_json_export_sheet.png` | Portable JSON backup preview with all tables and preferences |
| **17** | Clipboard Snackbar | `screenshots\17_export_copied_snackbar.png` | Clean feedback confirmation when copying backup |
| **18** | Wipe Dialog 1 | `screenshots\18_wipe_dialog_1.png` | First destructive warning confirmation modal |
| **19** | Wipe Dialog 2 | `screenshots\19_wipe_dialog_2.png` | Final double-confirmation safeguards against accidental reset |
| **20** | Clean Reset State | `screenshots\20_wiped_home_state.png` | Database and preferences completely wiped to clean defaults |

---

## 3. Store Listing Metadata

### App Title & Tagline
- **App Name:** Life Reset
- **Tagline:** Scroll Se Goal Tak

### Descriptions
- **Short Description (79 / 80 characters):**
  > Scroll less, achieve more. Track goals, build habits, and master focus offline.
- **Full Description:**
  > **Life Reset — Scroll Se Goal Tak**
  > 
  > Are endless reels, shorts, and social media feeds stealing your best hours? **Life Reset** is a minimal, distraction-free productivity app designed to help you break unintentional scrolling cycles and channel your energy toward real-life achievements.
  > 
  > Whether preparing for competitive exams, learning a job skill, building healthy daily routines, or reclaiming focus, Life Reset gives you the tools you need with 100% privacy and zero clutter.
  > 
  > ---
  > 
  > ### Key Features:
  > 
  > 🎯 **Daily Focus Priorities (Rule of 3)**
  > Never get overwhelmed by endless to-do lists. Select up to 3 core daily priorities that matter most today and tick them off with satisfaction.
  > 
  > 🔁 **Streak & Habit Tracking**
  > Build atomic habits with real calendar streak calculations. See your current consistency and beat your personal longest records.
  > 
  > ⏱️ **Distraction-Free Focus Timer**
  > Boost productivity with a flexible Pomodoro-style timer (15, 25, 45, or 60 minutes) linked to your active goals. Sessions resume accurately even if you switch apps.
  > 
  > 📱 **Scrolling Awareness & Limits**
  > Log and monitor your time spent on social media apps. Set your personal daily scrolling budget and receive gentle warnings when exceeded.
  > 
  > 📊 **Weekly Progress Insights**
  > Review your 7-day balance between focus minutes and screen time, habit consistency, and goal completion rate without vanity metrics.
  > 
  > 🔒 **100% Offline & Private**
  > No account creation. No internet permission. No ads. No tracking SDKs. Your personal records stay strictly inside your phone’s SQLite database. You can export a full JSON backup to your clipboard at any time.

### Categorization & User-Provided Information
- **App Category:** Productivity
- **Privacy Policy URL:** To be provided by you (hosted on GitHub Pages, Google Sites, or your personal website before submission).
- **Developer Email:** To be provided by you (your Google Play Console registered support contact email).
- **Feature Graphic:** 1024 × 500 px banner (Forest green `#173C32` with app logo and tagline).

---

## 4. Google Play Data Safety Answers (Verified Against Merged Manifest)

The merged manifest (`build\app\intermediates\merged_manifests\release\processReleaseManifest\AndroidManifest.xml`) proves that **zero network permissions** exist in the app.

When filling out the Data Safety questionnaire in Google Play Console:
1. **Does your app collect or share any user data?** ➡️ **No**
2. **Does the app collect any personal, financial, health, or location information?** ➡️ **No**
3. **Is all user data stored locally on device only?** ➡️ **Yes**
4. **Is account creation required?** ➡️ **No**

---

## 5. Content Rating Questionnaire
- **Category:** Utility, Productivity, Communication, or Other.
- **Violence / Sexual Content / Profanity:** None (Answer **No** to all questions).
- **Online Interactions / Sharing:** None (Answer **No**).
- **Expected Rating:** **PEGI 3 / ESRB Everyone / USK 0**.

---

## 6. Personal Developer Account Testing Requirement (20-Tester Rule)
If your Google Play Console developer account was registered as a **Personal Account** after November 13, 2023:
1. Google requires you to publish first to a **Closed Testing Track**.
2. Recruit at least **20 testers** who opt in via the Google Play test link.
3. Keep the test active with opt-in status for **14 consecutive days**.
4. After 14 days, apply for production access in Google Play Console.
