/// @Branch: Localization Implementation
///
/// App localization support for multiple languages
/// Provides translations for English and placeholder language
library;

import 'package:flutter/material.dart';

class AppLocalizations {

  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('sn', ''),
  ];

  // Common
  String get appName => _getLocalizedValue({
    'en': 'Campus Market',
    'sn': 'Campus Market', // Placeholder
  });

  String get loading =>
      _getLocalizedValue({'en': 'Loading...', 'sn': 'Loading...'});

  String get error => _getLocalizedValue({'en': 'Error', 'sn': 'Error'});

  String get retry => _getLocalizedValue({'en': 'Retry', 'sn': 'Retry'});

  String get cancel => _getLocalizedValue({'en': 'Cancel', 'sn': 'Cancel'});

  String get save => _getLocalizedValue({'en': 'Save', 'sn': 'Save'});

  String get delete => _getLocalizedValue({'en': 'Delete', 'sn': 'Delete'});

  String get edit => _getLocalizedValue({'en': 'Edit', 'sn': 'Edit'});

  String get search => _getLocalizedValue({'en': 'Search', 'sn': 'Search'});

  String get filter => _getLocalizedValue({'en': 'Filter', 'sn': 'Filter'});

  String get sort => _getLocalizedValue({'en': 'Sort', 'sn': 'Sort'});

  // Navigation
  String get home => _getLocalizedValue({'en': 'Home', 'sn': 'Home'});

  String get marketplace =>
      _getLocalizedValue({'en': 'Marketplace', 'sn': 'Marketplace'});

  String get accommodation =>
      _getLocalizedValue({'en': 'Housing', 'sn': 'Housing'});

  String get events => _getLocalizedValue({'en': 'Events', 'sn': 'Events'});

  String get chat => _getLocalizedValue({'en': 'Chat', 'sn': 'Chat'});

  String get profile => _getLocalizedValue({'en': 'Profile', 'sn': 'Profile'});

  String get settings =>
      _getLocalizedValue({'en': 'Settings', 'sn': 'Settings'});

  // Authentication
  String get signIn => _getLocalizedValue({'en': 'Sign In', 'sn': 'Sign In'});

  String get signUp => _getLocalizedValue({'en': 'Sign Up', 'sn': 'Sign Up'});

  String get signOut =>
      _getLocalizedValue({'en': 'Sign Out', 'sn': 'Sign Out'});

  String get email => _getLocalizedValue({'en': 'Email', 'sn': 'Email'});

  String get password =>
      _getLocalizedValue({'en': 'Password', 'sn': 'Password'});

  String get firstName =>
      _getLocalizedValue({'en': 'First Name', 'sn': 'First Name'});

  String get lastName =>
      _getLocalizedValue({'en': 'Last Name', 'sn': 'Last Name'});

  String get forgotPassword =>
      _getLocalizedValue({'en': 'Forgot Password?', 'sn': 'Forgot Password?'});

  // Marketplace
  String get sellItem =>
      _getLocalizedValue({'en': 'Sell Item', 'sn': 'Sell Item'});

  String get buyNow => _getLocalizedValue({'en': 'Buy Now', 'sn': 'Buy Now'});

  String get makeOffer =>
      _getLocalizedValue({'en': 'Make Offer', 'sn': 'Make Offer'});

  String get contactSeller =>
      _getLocalizedValue({'en': 'Contact Seller', 'sn': 'Contact Seller'});

  String get addToFavorites =>
      _getLocalizedValue({'en': 'Add to Favorites', 'sn': 'Add to Favorites'});

  String get removeFromFavorites => _getLocalizedValue({
    'en': 'Remove from Favorites',
    'sn': 'Remove from Favorites',
  });

  // Accommodation
  String get findRoom =>
      _getLocalizedValue({'en': 'Find Room', 'sn': 'Find Room'});

  String get listRoom =>
      _getLocalizedValue({'en': 'List Room', 'sn': 'List Room'});

  String get bookNow =>
      _getLocalizedValue({'en': 'Book Now', 'sn': 'Book Now'});

  String get contactHost =>
      _getLocalizedValue({'en': 'Contact Host', 'sn': 'Contact Host'});

  // Events
  String get createEvent =>
      _getLocalizedValue({'en': 'Create Event', 'sn': 'Create Event'});

  String get rsvp => _getLocalizedValue({'en': 'RSVP', 'sn': 'RSVP'});

  String get buyTickets =>
      _getLocalizedValue({'en': 'Buy Tickets', 'sn': 'Buy Tickets'});

  String get shareEvent =>
      _getLocalizedValue({'en': 'Share Event', 'sn': 'Share Event'});

  // Chat
  String get sendMessage =>
      _getLocalizedValue({'en': 'Send Message', 'sn': 'Send Message'});

  String get typeMessage => _getLocalizedValue({
    'en': 'Type a message...',
    'sn': 'Type a message...',
  });

  String get online => _getLocalizedValue({'en': 'Online', 'sn': 'Online'});

  String get offline => _getLocalizedValue({'en': 'Offline', 'sn': 'Offline'});

  // Admin
  String get adminDashboard =>
      _getLocalizedValue({'en': 'Admin Dashboard', 'sn': 'Admin Dashboard'});

  String get adminLogin =>
      _getLocalizedValue({'en': 'Admin Login', 'sn': 'Admin Login'});

  String get manageUsers =>
      _getLocalizedValue({'en': 'Manage Users', 'sn': 'Manage Users'});

  String get manageListings =>
      _getLocalizedValue({'en': 'Manage Listings', 'sn': 'Manage Listings'});

  String get manageEvents =>
      _getLocalizedValue({'en': 'Manage Events', 'sn': 'Manage Events'});

  String get reports => _getLocalizedValue({'en': 'Reports', 'sn': 'Reports'});

  // Helper method
  String _getLocalizedValue(Map<String, String> values) => values[locale.languageCode] ?? values['en']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
