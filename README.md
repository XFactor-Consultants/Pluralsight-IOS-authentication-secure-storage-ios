# Authentication and Secure Storage in iOS
### Companion repo for the Pluralsight course — TaskFlow sample app

This repo holds **TaskFlow**, the single evolving sample app used throughout all four modules of this course. Each module builds directly on the previous one's completed code, so the app you end up with after Module 4 is the same app you started with in Module 1 — just with real authentication, secure storage, session management, and an audited security posture layered on top, one module at a time.

This README covers everything you need before you start: required versions, one-time setup, how the branches are organized, what each module actually builds, and a handful of known quirks worth knowing about up front so they don't cost you time later.

---

## 1. What You Need Before Starting

### Hardware and OS
- **A Mac.** Xcode only runs on macOS — there's no way around this requirement.
- **macOS Tahoe (26.x) or later.** Older macOS versions cap you at an older Xcode, which cannot build this project (see below).

### Xcode
- **Xcode 26.x** (current version on the Mac App Store as of this course's recording).
- After installing, launch Xcode once and let it finish installing components.
- Go to **Xcode → Settings → Platforms** and download the **newest iOS Simulator runtime** available. This project's deployment target requires iOS 18 or later; the course was recorded targeting iOS 26.

> **Why this matters:** if the Mac App Store only offers you an old Xcode version (15.x or earlier), that's a sign your macOS itself is out of date — the store silently serves the newest Xcode *compatible with your current OS*. Update macOS first, then re-check the App Store listing.

### Apple Developer Program - for FULL app use 
- **TaskFlow**'s functionality can be used to get through the entire course using 'Sign in With Passkey' mock, but for full demo-ability, you need a membership with Apple. You do not need to purchase this to learn everything thing course has to offer. You can complete the course without it, and the demos only use the free functionality.  
- A **paid Apple Developer Program membership** ($99/year) is required for Module 1's Full Sign in with Apple capability. The free/personal team tier cannot add this entitlement — Xcode will simply refuse.
- Enroll as an **Individual**, not an Organization, unless you have a registered business entity with a D-U-N-S number. Individual enrollment is faster and is genuinely sufficient for this course.
- Enrollment can take anywhere from a few hours to a couple of business days to approve. Kick this off on day one — it's the one dependency in this whole course that isn't in your control.
- Once approved: **Xcode → Settings → Accounts**, confirm your Apple ID is listed, then in the project's **Signing & Capabilities** tab, select your team from the dropdown.

### Git
- Standard familiarity with `git` — clone, branch, commit, push. Nothing exotic is used.
- If you have the **GitHub CLI** (`gh`) installed, a couple of setup commands are simpler, but it's not required.

---

## 2. One-Time Project Setup

1. **Clone this repo.**
   ```bash
   git clone <repo-url> TaskFlow
   cd TaskFlow
   ```

2. **Open the project — always via the `.xcodeproj` file directly**, not through Xcode's Recent Projects list (see the warning in Section 6 about why this matters).
   ```bash
   open TaskFlow/TaskFlow.xcodeproj
   ```

3. **Confirm the deployment target.** Blue **TaskFlow** project icon (top of the left sidebar) → **TaskFlow** target → **General** tab → **Minimum Deployments** → should read **iOS 18.0 or higher**.

4. **Build the canonical base once**, before touching any module branch, to confirm your environment is healthy:
   - Pick any iPhone simulator from the device dropdown in the toolbar.
   - Press **⌘R**.
   - You should see TaskFlow's task list — teammates, due dates, priority icons, and two tasks with lock icons (inert at this stage — that's intentional, it's the gap Module 1 closes).

5. **Set up Sign in with Apple** (needed starting Module 1, Clip 2 for FULL functionality):
   - Complete your Apple Developer Program enrollment (Section 1).
   - **Signing & Capabilities** tab → select your team → **+ Capability** → **Sign in with Apple**.
   - In the **Simulator**, open **Settings → Sign in to your iPhone** and sign in with any Apple ID — this is separate from your Mac's Apple ID and is required for the system sign-in sheet to function at all.

---

## 3. Branch Structure

The repo is organized around one **canonical base commit**, tagged `canonical-base`, representing the app exactly as it exists before any authentication code is added — no sign-in, no Keychain, nothing. This is the starting point if you want to build the entire course out yourself, from scratch, following along module by module rather than jumping ahead to finished code.

Every module branches from the previous module's completed state, and **each branch ends in a tagged commit holding that module's fully completed file set** — the exact code you'd have if you followed every step in that module's video correctly:

```
canonical-base
   └── module-1 → tagged module-1-completed
         └── module-2 → tagged module-2-completed
               └── module-3 → tagged module-3-completed
                     └── module-4 → tagged module-4-completed
```

**Two ways to use this repo, both fully supported:**

- **Follow along and build it yourself.** Check out `canonical-base`, and work through each module's video from that starting point, writing the code yourself as you go. If you want to check your own work against the reference at any point, the corresponding `module-N-completed` tag is always there to diff against.
- **Just read the finished code.** If you'd rather study completed, working code without typing it out, skip straight to any module's `-completed` tag and explore the app as it stood at the end of that module — no need to build anything yourself first.

If you want to see the app at the *start* of a given module, check out the previous module's `-completed` tag. If you want to see the finished app after a given module, check out that module's own `-completed` tag.

```bash
git checkout canonical-base       # the true starting point, before any auth code
git checkout mod2   # TaskFlow exactly as it is after Module 2
```

---

## 4. Module-by-Module Overview

### Module 1 — Choosing and Implementing Sign-In
**What gets built:** `AuthStore` (the app's authentication state), `SignInView`, Sign in with Apple, a passkey-aware second sign-in path, and typed error handling with a reusable recovery banner.

**Key files added:** `AuthStore.swift`, `SignInView.swift`, `PasskeyCoordinator.swift`, `AuthError.swift`.
**Key files modified:** `RootView.swift` (now gates on sign-in state instead of always showing tasks), `TaskFlowApp.swift`.

**Worth knowing:** Passkey sign-in requires a real, owned domain (an "associated domain") to resolve for real — this course doesn't have one, so the passkey success path uses a small, clearly-labeled `MockPasskeyCoordinator`, wrapped in `#if DEBUG`, sitting behind the same protocol a real implementation would use. The real, production-shape `PasskeyCoordinator` is in the repo and is what you'd wire in for an actual shipping app — swapping the mock for the real thing is a one-line change.

### Module 2 — Protecting Credentials and Gating Sensitive Actions
**What gets built:** `TokenVault` (Keychain-backed session storage, replacing nothing — this is the app's first real secure storage), and `BiometricGate` (Face ID / passcode fallback gating sensitive tasks).

**Key files added:** `TokenVault.swift`, `BiometricGate.swift`.
**Key files modified:** `AuthStore.swift`, `SettingsView.swift`, `SignInView.swift`, `TaskDetailView.swift` (now shows `LockedTaskView` for sensitive tasks until the gate passes), target Info (adds the Face ID usage description).

**Worth knowing:** every Keychain operation in this course follows the same shape — a `service`/`account` identity pair, an explicit accessibility level (never left at a default), and add/read/update/delete as four small, separate functions. Once you've seen it once in `TokenVault`, every later vault in the course (`SessionVault`, `CryptoKeyStore`) is the same pattern applied to a different secret.

### Module 3 — Managing Sessions and Applying CryptoKit
**What gets built:** `AuthSession` (a richer, expiring session model replacing the plain token string), `SessionVault` (`TokenVault`, renamed and rewritten), `MockAuthBackend` (simulates issuing and refreshing sessions), cold-launch session restoration, `LocalContentCache` (an in-memory cache of recently viewed task content), and finally `CryptoKeyStore` + `TaskEncryption` to encrypt that cache at rest with a Keychain-backed AES-GCM key and hash-based tamper detection.

**Key files added:** `AuthSession.swift`, `MockAuthBackend.swift`, `LocalContentCache.swift`, `CryptoKeyStore.swift`, `TaskEncryption.swift`.
**Key files renamed:** `TokenVault.swift` → `SessionVault.swift`.
**Key files modified:** `AuthStore.swift` (session establishment and sign-out are now `async`; a synchronous check inside `AuthStore`'s initializer restores a valid session before the very first frame renders — no loading state, no flash), `TaskFlowApp.swift`, `TaskDetailView.swift`, `SettingsView.swift`.

**Worth knowing:** two `#if DEBUG`-only affordances exist in Settings for this module — **Force Expire Session** (backdates the stored session so you can demo refresh without waiting 60 real seconds) and **Tamper With Cached Content** (deliberately corrupts one cached entry so you can watch the cache's integrity check catch it). Neither exists in a release build.

### Module 4 — Reducing Risk and Validating Behavior
**What gets built:** an audit pass. `LegacyStorage.swift` is added as a deliberately insecure "before" file — a token in `UserDefaults`, a hardcoded API key, and an over-permissive Keychain accessibility flag — and rewritten in place to the same disciplined pattern used everywhere else in the app. A leftover debug `print` statement leaking session state is found and removed from `SignInView`. Clipboard content copied from a sensitive task now expires itself after 30 seconds. The module closes with a full walkthrough exercising every behavior built across the previous three modules — sign-out, biometric fallback, forced token expiration, and full logout — plus an honest note that the Simulator's biometric prompts are not a substitute for testing on a real device.

**Key files added:** `LegacyStorage.swift`.
**Key files modified:** `TaskDetailView.swift` (clipboard-expiring Copy Note button), `SignInView.swift` (net no change — the debug print is added and removed live on camera).

**Worth knowing:** this module builds almost nothing new — it's deliberately structured as a review pass over code that already exists, which is itself the point: most real security bugs aren't found by writing more code, they're found by rereading what's already there with a specific checklist in mind.

---

## 5. Course-Wide Conventions

A few patterns repeat across every module, worth knowing up front so they don't feel unfamiliar each time they reappear:

- **Every secret lives in the Keychain, never in `UserDefaults`, never hardcoded.** Each vault (`TokenVault`, `SessionVault`, `CryptoKeyStore`) follows the same add/read/update/delete shape with an explicitly chosen accessibility level — usually `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
- **Mocks stand in for anything outside this course's scope**, and are always named clearly and wrapped in `#if DEBUG` where relevant: `MockPasskeyCoordinator`, `MockAuthBackend`, `debugForceExpire()`, `debugCorruptFirstEntry()`. None of these exist in a release build.
- **Security-relevant background work is invisible by design.** Token refresh, session restoration, and clipboard expiration all happen with zero UI interruption — no spinners, no confirmation messages. If a background security operation is visibly disruptive, that's treated as a design failure, not a minor UX detail.
- **The course names its own limitations rather than hiding them** — for example, a restored session can't show the real signed-in user's ID (because `AuthSession` only carries tokens, not identity), and account linking between Sign in with Apple and passkeys isn't implemented, since both are out of scope for an app-side security course.

---

## 6. Known Issues and Gotchas

### Sign in with Apple may fail on the Simulator with `AKAuthenticationError -7026`
This is a documented Simulator quirk, not a bug in this project's code — it occurs even with a fully approved Developer Program enrollment and a correctly configured capability, and appears to relate to account propagation delays specific to Simulator authentication. If you hit this:
- Confirm the Simulator itself is signed into an Apple ID (**Settings → Sign in to your iPhone**), separate from your Mac's account.
- Try quitting and relaunching Xcode to force a fresh account/capability fetch.
- If it persists, test Sign in with Apple on a **physical device** instead — this error is reported far less frequently outside the Simulator.
- The **passkey sign-in path does not depend on this at all** and is fully reliable via its mock — use it as your primary sign-in path for testing if Apple sign-in is blocked.


