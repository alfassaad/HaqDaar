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

## Current Plan: Phase 1 - Beneficiary UI Foundation (Completed)

This initial phase focused on building the foundational UI and navigation for the beneficiary-facing application.

### 1. Project Scaffolding & Dependency Management (Completed)
- **Action:** Added initial required packages to `pubspec.yaml`:
  - `provider`, `go_router`, `google_fonts`, `qr_flutter`, `mobile_scanner`

### 2. Core Application Structure (Completed)
- **Action:** Established the root of the application in `lib/main.dart`.
- **Details:**
  - Implemented `ThemeProvider` for theme management.
  - Configured `MaterialApp.router` with `go_router`.
  - Defined light and dark themes.

### 3. Create Initial Screens & Navigation (Completed)
- **Action:** Built the basic screen structure and navigation routes.
- **Screens Created:**
  - `OnboardingScreen`
  - `LoginScreen`
  - `HomeScreen`
  - `QRScreen`
  - `HistoryScreen`
  - `ProfileScreen`
  - `ScanAndPayScreen`
  - `PaymentConfirmationScreen`
- **Navigation:** Implemented a `BottomNavigationBar` and the complete routing logic with `go_router`.

### 4. Design the Beneficiary Home Screen (Completed)
- **Action:** Developed the UI for the `HomeScreen` with a balance display and action buttons.

### 5. Implemented QR Code and Scanning Features (Completed)
- **Action:** Integrated `qr_flutter` to display user QR codes and `mobile_scanner` to scan QR codes for payments, with navigation to a payment confirmation screen.

### 6. Completed History and Profile Screens (Completed)
- **Action:** Implemented the UI for the transaction history and user profile screens.
