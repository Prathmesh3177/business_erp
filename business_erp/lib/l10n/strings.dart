import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('mr')];
  static const delegate = _AppStringsDelegate();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  static const _english = <String, String>{
    'appTitle': 'Shree Krushna Sales ERP',
    'shopName': 'Shree Krushna Sales',
    'shopAddress':
        'Rajmata Jijau Chowk, Jantre Plaza, Dhoki Road, Kalamb- 413507',
    'shopPhone': 'Mo. 7020422291 / 9881630001',
    'setupTitle': 'Set up Shree Krushna Sales ERP',
    'organizationLegalName': 'Organization legal name',
    'organizationDisplayName': 'Display name',
    'branchName': 'Branch name',
    'financialYear': 'Financial year',
    'saveSetup': 'Create installation',
    'language': 'मराठी',
    'loading': 'Opening Shree Krushna Sales local data…',
    'startupFailed': 'The encrypted local data could not be opened. Existing data was not changed.',
    'retry': 'Retry',
    'snapshot': 'Create recovery snapshot',
    'snapshotCreated': 'Verified recovery snapshot created',
    'singleAuthority':
        'This installation is the single write authority for this branch.',
    'adminAccount': 'Initial Administrator Account',
    'adminUsername': 'Admin Username',
    'adminFullName': 'Full Name',
    'adminPassword': 'Password',
    'recoveryKeyTitle': 'Admin Recovery Key',
    'recoveryKeyNotice': 'Save this recovery key in a secure location. It can reset the administrator password if lost.',
    'loginTitle': 'Sign In to Solar Shop ERP',
    'username': 'Username',
    'password': 'Password',
    'login': 'Sign In',
    'logout': 'Sign Out',
    'lockSession': 'Lock Session',
    'unlockTitle': 'Session Locked',
    'unlock': 'Unlock',
    'forgotPassword': 'Forgot Password / Use Recovery Key',
    'resetPasswordTitle': 'Reset Admin Password',
    'recoveryKeyLabel': 'Recovery Key (16 chars)',
    'newPassword': 'New Password',
    'resetPassword': 'Reset Password',
    'userManagement': 'User Management',
    'addUser': 'Add User',
    'role': 'Role',
    'status': 'Status',
    'active': 'Active',
    'disabled': 'Disabled',
    'auditLog': 'Audit Log',
    'actor': 'Actor',
    'action': 'Action',
    'timestamp': 'Timestamp',
  };

  static const _marathi = <String, String>{
    'appTitle': 'श्री कृष्णा सेल्स ईआरपी',
    'shopName': 'श्री कृष्णा सेल्स',
    'shopAddress': 'राजमाता जिजाऊ चौक, जंत्रे प्लाझा, ढोकी रोड, कळंब- 413507',
    'shopPhone': 'Mo. 7020422291 / 9881630001',
    'setupTitle': 'श्री कृष्णा सेल्स ईआरपी स्थापना तयार करा',
    'organizationLegalName': 'संस्थेचे कायदेशीर नाव',
    'organizationDisplayName': 'दर्शनी नाव',
    'branchName': 'शाखेचे नाव',
    'financialYear': 'आर्थिक वर्ष',
    'saveSetup': 'स्थापना तयार करा',
    'language': 'English',
    'loading': 'श्री कृष्णा सेल्स डेटा उघडत आहे…',
    'startupFailed': 'स्थानिक डेटा उघडता आला नाही. जुना डेटा बदललेला नाही.',
    'retry': 'पुन्हा प्रयत्न करा',
    'snapshot': 'पुनर्प्राप्ती प्रत तयार करा',
    'snapshotCreated': 'तपासलेली पुनर्प्राप्ती प्रत तयार झाली',
    'singleAuthority': 'या शाखेसाठी ही स्थापना एकमेव लेखन प्राधिकरण आहे.',
    'adminAccount': 'प्रारंभिक प्रशासक खाते',
    'adminUsername': 'प्रशासक वापरकर्ता नाव',
    'adminFullName': 'पूर्ण नाव',
    'adminPassword': 'पासवर्ड',
    'recoveryKeyTitle': 'प्रशासक पुनर्प्राप्ती की',
    'recoveryKeyNotice': 'ही पुनर्प्राप्ती की सुरक्षित ठिकाणी जतन करा. पासवर्ड विसरल्यास ही की वापरून पासवर्ड रिसेट करता येतो.',
    'loginTitle': 'सोलर शॉप ईआरपी मध्ये साइन इन करा',
    'username': 'वापरकर्ता नाव',
    'password': 'पासवर्ड',
    'login': 'साइन इन करा',
    'logout': 'साइन आउट',
    'lockSession': 'सत्र लॉक करा',
    'unlockTitle': 'सत्र लॉक केले आहे',
    'unlock': 'अनलॉक करा',
    'forgotPassword': 'पासवर्ड विसरलात / पुनर्प्राप्ती की वापरा',
    'resetPasswordTitle': 'प्रशासक पासवर्ड रिसेट करा',
    'recoveryKeyLabel': 'पुनर्प्राप्ती की',
    'newPassword': 'नवीन पासवर्ड',
    'resetPassword': 'पासवर्ड रिसेट करा',
    'userManagement': 'वापरकर्ता व्यवस्थापन',
    'addUser': 'वापरकर्ता जोडा',
    'role': 'भूमिका',
    'status': 'स्थिती',
    'active': 'सक्रिय',
    'disabled': 'अक्षम',
    'auditLog': 'ऑडिट लॉग',
    'actor': 'कर्ता',
    'action': 'कृती',
    'timestamp': 'वेळ',
  };

  String get(String key) =>
      (locale.languageCode == 'mr' ? _marathi : _english)[key] ?? key;
}

final class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture(AppStrings(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
