# HaqDaar - Secure Digital Funding Platform

## Overview

HaqDaar (meaning 'One Who Deserves Rights' in Urdu) is a mobile-first platform that enables non-profit organisations to distribute aid digitally through unique, tamper-proof QR tokens. The goal is to eliminate cash leakage, fraud, and administrative overhead in Pakistan's humanitarian aid sector by ensuring that every rupee of aid reaches its intended recipient with full accountability.

## Style, Design, and Features (As Implemented)

### Core Functionality
- **Onboarding & Login:** A simple onboarding flow leading to a login screen.
- **Dashboard (Home Screen):** A central hub displaying key information and providing access to other features.
- **QR Code Generation:** Users can view their unique QR code for receiving payments.
- **Scan & Pay:** The app includes a QR code scanner to initiate payments.
- **Payment Confirmation:** A screen to review and confirm transaction details before finalizing.
- **Transaction History:** A list of past transactions with details.
- **User Profile:** A screen for managing account settings and logging out.

### Technical Implementation
- **Project:** Flutter application targeting Android & iOS.
- **Dependencies:** 
  - `provider` for state management.
  - `go_router` for navigation.
  - `google_fonts` for typography.
  - `qr_flutter` for QR code generation.
  - `mobile_scanner` for QR code scanning.
- **Theming:** Centralized `ThemeData` with Material 3, `ColorScheme.fromSeed`, custom `TextTheme` using Google Fonts, and support for light/dark modes.
- **Navigation:** A combination of a `BottomNavigationBar` for the main sections (Home, QR, History, Profile) and direct routing for other screens like Onboarding, Login, and Scan & Pay.

## Current Plan: Phase 2 - Firebase Integration & Visual Polish

This phase focuses on strengthening the Firebase backend integration and adding high-quality visual elements using Lottie.

### 1. Visual Enhancement with Lottie
- **Action:** Integrate Lottie animations into the `OnboardingScreen` and `PaymentConfirmationScreen`.
- **Goal:** Improve user engagement and provide satisfying feedback for successful transactions.

### 2. Profile Management & Image Upload
- **Action:** Add `firebase_storage` dependency and implement profile image uploads.
- **Details:** Allow users to pick an image from their gallery and store it in Firebase Storage, linking the URL to their Firestore profile.

### 3. Advanced Firestore Integration
- **Action:** Refine `FirestoreService` for better error handling and real-time updates.
- **Goal:** Ensure the app remains responsive and provides clear feedback during network issues or permission errors.

### 4. Admin Panel Enhancements
- **Action:** Add more administrative controls, such as viewing aggregate transaction stats or managing aid distribution quotas.
