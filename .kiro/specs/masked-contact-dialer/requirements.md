# Requirements Document

## Introduction

Masked Contact Dialer is a Flutter-based Android application that provides a privacy-oriented local contact management interface. The application allows users to create custom contact entries with separate display labels and actual destination numbers, enabling personalized contact organization while routing calls to the correct real phone number. The application operates entirely offline with local-only data storage, requires no server or cloud dependency, and focuses on fast one-tap calling with a modern Material 3 UI.

## Glossary

- **App**: The Masked Contact Dialer Flutter Android application
- **Contact_Entry**: A locally stored record containing a display name, display number, real number, optional profile image, and optional notes/tags
- **Display_Name**: The custom label shown in the App UI for a Contact_Entry
- **Display_Number**: The phone number visually shown in the App UI for a Contact_Entry, which may differ from the Real_Number
- **Real_Number**: The actual phone number used when initiating a call for a Contact_Entry
- **Contact_List**: The scrollable list of all Contact_Entry records displayed on the Home_Screen
- **Home_Screen**: The primary screen of the App displaying the Contact_List, search bar, and navigation elements
- **Add_Contact_Screen**: The screen where users create or edit a Contact_Entry
- **Detail_Screen**: The screen displaying full details of a selected Contact_Entry
- **Settings_Screen**: The screen where users configure App preferences including security options
- **Search_Page**: The screen providing live search and filtering across Contact_Entry records
- **Dialer_Service**: The App component responsible for initiating phone calls via Android Intent APIs
- **Storage_Service**: The App component responsible for persisting and retrieving data using Hive local database
- **Auth_Service**: The App component responsible for app lock, PIN authentication, and biometric unlock
- **Favorites_List**: A filtered subset of Contact_Entry records marked as favorites by the user
- **Call_History**: A local log of calls initiated through the App, including timestamps and contact references
- **Hidden_Section**: A PIN-protected area of the App where sensitive Contact_Entry records can be concealed from the main Contact_List
- **Category**: A user-defined label used to organize Contact_Entry records into groups

## Requirements

### Requirement 1: Contact Entry Creation

**User Story:** As a user, I want to create custom contact entries with separate display and real numbers, so that I can organize my contacts with personalized labels while routing calls to the correct destination.

#### Acceptance Criteria

1. WHEN the user submits the Add_Contact_Screen form with a valid Display_Name, Display_Number, and Real_Number, THE App SHALL create a new Contact_Entry and persist it via the Storage_Service.
2. WHEN the user submits the Add_Contact_Screen form without a Display_Name, THE App SHALL display a validation error message indicating that Display_Name is required.
3. WHEN the user submits the Add_Contact_Screen form without a Real_Number, THE App SHALL display a validation error message indicating that Real_Number is required.
4. WHEN the user submits the Add_Contact_Screen form with an empty Display_Number, THE App SHALL store the Real_Number as the Display_Number for that Contact_Entry.
5. WHEN the user provides a profile image on the Add_Contact_Screen, THE App SHALL store the image locally and associate it with the Contact_Entry.
6. WHEN the user provides notes or tags on the Add_Contact_Screen, THE App SHALL store the notes and tags as metadata on the Contact_Entry.
7. THE App SHALL allow creation of an unlimited number of Contact_Entry records, constrained only by available device storage.

### Requirement 2: Contact Entry Editing and Deletion

**User Story:** As a user, I want to edit or delete my contact entries at any time, so that I can keep my contact information up to date.

#### Acceptance Criteria

1. WHEN the user modifies any field of an existing Contact_Entry on the Add_Contact_Screen and saves, THE App SHALL update the persisted Contact_Entry via the Storage_Service.
2. WHEN the user confirms deletion of a Contact_Entry, THE App SHALL remove the Contact_Entry from the Storage_Service and from the Contact_List.
3. WHEN the user requests deletion of a Contact_Entry, THE App SHALL display a confirmation dialog before performing the deletion.

### Requirement 3: Contact Category Organization

**User Story:** As a user, I want to organize my contacts into categories, so that I can group related contacts together.

#### Acceptance Criteria

1. WHEN the user assigns a Category to a Contact_Entry, THE App SHALL persist the Category association via the Storage_Service.
2. WHEN the user selects a Category filter on the Home_Screen, THE App SHALL display only Contact_Entry records belonging to the selected Category.
3. WHEN the user creates a new Category name, THE App SHALL add the Category to the list of available categories in the Storage_Service.
4. WHEN the user removes a Category from a Contact_Entry, THE App SHALL update the Contact_Entry to have no Category association.

### Requirement 4: One-Tap Call Initiation via ACTION_DIAL

**User Story:** As a user, I want to tap a call button and have the Android dialer open with the real number pre-filled, so that I can confirm and place the call manually.

#### Acceptance Criteria

1. WHEN the user taps the call button on a Contact_Entry and the call mode is set to ACTION_DIAL, THE Dialer_Service SHALL launch the Android native dialer with the Real_Number of the Contact_Entry pre-filled.
2. WHEN the Dialer_Service launches the Android native dialer, THE Dialer_Service SHALL complete the launch within 1 second of the user tap.
3. THE Dialer_Service SHALL use only the Real_Number for call routing, regardless of the Display_Number shown in the UI.

### Requirement 5: One-Tap Call Initiation via ACTION_CALL

**User Story:** As a user, I want to directly place a call with one tap without opening the dialer, so that I can make calls faster.

#### Acceptance Criteria

1. WHEN the user taps the call button on a Contact_Entry and the call mode is set to ACTION_CALL and the CALL_PHONE permission is granted, THE Dialer_Service SHALL directly initiate a phone call to the Real_Number of the Contact_Entry.
2. IF the CALL_PHONE permission is not granted when the user taps the call button in ACTION_CALL mode, THEN THE App SHALL request the CALL_PHONE permission from the user.
3. IF the user denies the CALL_PHONE permission, THEN THE App SHALL fall back to ACTION_DIAL mode and launch the Android native dialer with the Real_Number pre-filled.
4. WHERE the optional call confirmation setting is enabled, THE App SHALL display a confirmation popup before initiating the call.

### Requirement 6: Home Screen Contact Display

**User Story:** As a user, I want to see all my contacts on the home screen with their display names and display numbers, so that I can quickly find and call contacts.

#### Acceptance Criteria

1. WHEN the App launches and authentication succeeds, THE Home_Screen SHALL display the Contact_List with each Contact_Entry showing the Display_Name, Display_Number, and profile image.
2. THE Home_Screen SHALL NOT display the Real_Number of any Contact_Entry in the Contact_List view.
3. WHEN the Contact_List contains favorited Contact_Entry records, THE Home_Screen SHALL display favorited contacts at the top of the Contact_List.
4. THE App SHALL launch and display the Home_Screen within 2 seconds on a device with standard specifications.

### Requirement 7: Contact Detail View

**User Story:** As a user, I want to view full details of a contact including both display and real numbers, so that I can review and manage the contact mapping.

#### Acceptance Criteria

1. WHEN the user taps a Contact_Entry in the Contact_List, THE App SHALL navigate to the Detail_Screen showing the Display_Name, Display_Number, Real_Number, profile image, notes, tags, and Category of the Contact_Entry.
2. WHEN the user taps the edit button on the Detail_Screen, THE App SHALL navigate to the Add_Contact_Screen pre-populated with the Contact_Entry data.
3. WHEN the user taps the call button on the Detail_Screen, THE Dialer_Service SHALL initiate a call to the Real_Number using the configured call mode.

### Requirement 8: Material 3 UI Design

**User Story:** As a user, I want a clean, modern interface with smooth animations, so that the app feels polished and easy to use.

#### Acceptance Criteria

1. THE App SHALL render all screens using Material 3 design components including rounded cards, dynamic color theming, and ripple animations.
2. THE App SHALL display a Floating Action Button on the Home_Screen for creating new Contact_Entry records.
3. THE App SHALL apply smooth transition animations when navigating between screens.
4. THE App SHALL display gradient-generated avatars for Contact_Entry records that have no profile image assigned.

### Requirement 9: Local Offline Storage

**User Story:** As a user, I want all my data stored locally on my device with no internet dependency, so that the app works fully offline.

#### Acceptance Criteria

1. THE Storage_Service SHALL persist all Contact_Entry records, user preferences, theme settings, favorites, and Call_History using the Hive local database.
2. THE App SHALL function with full feature availability when the device has no internet connection.
3. WHEN the user creates, edits, or deletes a Contact_Entry, THE Storage_Service SHALL persist the change immediately to the local database.
4. THE Storage_Service SHALL retrieve and display Contact_Entry records without perceptible delay for collections of up to 1000 records.

### Requirement 10: App Lock and PIN Authentication

**User Story:** As a user, I want to lock the app with a PIN, so that unauthorized users cannot access my contact mappings.

#### Acceptance Criteria

1. WHERE the app lock setting is enabled, THE Auth_Service SHALL require PIN entry before granting access to the App.
2. WHEN the user enters an incorrect PIN, THE Auth_Service SHALL display an error message and remain on the authentication screen.
3. WHEN the user enters the correct PIN, THE Auth_Service SHALL grant access to the App and navigate to the Home_Screen.
4. WHEN the user enables app lock for the first time, THE Auth_Service SHALL prompt the user to create a PIN of at least 4 digits.

### Requirement 11: Biometric Authentication

**User Story:** As a user, I want to unlock the app with my fingerprint, so that I can access my contacts quickly and securely.

#### Acceptance Criteria

1. WHERE the biometric unlock setting is enabled and the device supports biometric authentication, THE Auth_Service SHALL offer fingerprint unlock as an alternative to PIN entry.
2. WHEN the user provides a valid fingerprint, THE Auth_Service SHALL grant access to the App and navigate to the Home_Screen.
3. IF biometric authentication fails, THEN THE Auth_Service SHALL fall back to PIN entry.
4. IF the device does not support biometric authentication, THEN THE App SHALL hide the biometric unlock option in the Settings_Screen.

### Requirement 12: Search and Filtering

**User Story:** As a user, I want to search and filter my contacts by name, number, or tags, so that I can quickly find specific contacts.

#### Acceptance Criteria

1. WHEN the user types in the search bar on the Search_Page, THE App SHALL filter the Contact_List in real time to show only Contact_Entry records matching the search query against Display_Name, Display_Number, or tags.
2. WHEN the user selects the favorites filter, THE App SHALL display only Contact_Entry records marked as favorites.
3. WHEN the user selects alphabetical sorting, THE App SHALL sort the Contact_List by Display_Name in ascending alphabetical order.
4. WHEN the search query matches no Contact_Entry records, THE App SHALL display an empty state message indicating no results were found.

### Requirement 13: Favorites and Quick Access

**User Story:** As a user, I want to mark contacts as favorites and access them quickly, so that I can call my most-used contacts faster.

#### Acceptance Criteria

1. WHEN the user marks a Contact_Entry as a favorite, THE App SHALL persist the favorite status via the Storage_Service and display a star indicator on the Contact_Entry.
2. WHEN the user removes the favorite status from a Contact_Entry, THE App SHALL update the Storage_Service and remove the star indicator.
3. THE Home_Screen SHALL display a quick access panel showing the most recently called and favorited Contact_Entry records.
4. WHEN the user pins a Contact_Entry to the top, THE App SHALL display the pinned Contact_Entry above non-pinned entries in the Contact_List.

### Requirement 14: Recent Calls History

**User Story:** As a user, I want to see a history of calls I made through the app, so that I can track my calling activity.

#### Acceptance Criteria

1. WHEN the Dialer_Service initiates a call, THE App SHALL log the call in the Call_History with the Contact_Entry reference, timestamp, and call mode used.
2. THE App SHALL display the Call_History as a chronologically sorted list with the most recent call at the top.
3. WHEN the user taps the clear history action, THE App SHALL remove all entries from the Call_History after displaying a confirmation dialog.
4. THE App SHALL track and display the call frequency count for each Contact_Entry in the Call_History.
5. WHERE the export logs setting is enabled, THE App SHALL allow the user to export the Call_History as a text file to local device storage.

### Requirement 15: Hidden Mode

**User Story:** As a user, I want to hide sensitive contacts in a PIN-protected section, so that they are not visible to anyone casually viewing the app.

#### Acceptance Criteria

1. WHEN the user moves a Contact_Entry to the Hidden_Section, THE App SHALL remove the Contact_Entry from the main Contact_List and store it in the Hidden_Section.
2. WHEN the user enters the correct Hidden_Section PIN, THE App SHALL display all Contact_Entry records stored in the Hidden_Section.
3. IF the user enters an incorrect Hidden_Section PIN, THEN THE App SHALL display an error message and deny access to the Hidden_Section.
4. WHILE the App is in the background or in the recent apps view, THE App SHALL blur the app preview to prevent content from being visible.
5. WHEN the user moves a Contact_Entry out of the Hidden_Section, THE App SHALL restore the Contact_Entry to the main Contact_List.


