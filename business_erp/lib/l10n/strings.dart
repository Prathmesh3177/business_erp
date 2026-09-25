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
    'appTitle': 'Solar Shop ERP',
    'setupTitle': 'Set up this installation',
    'organizationLegalName': 'Organization legal name',
    'organizationDisplayName': 'Display name',
    'branchName': 'Branch name',
    'financialYear': 'Financial year',
    'saveSetup': 'Create installation',
    'language': 'मराठी',
    'loading': 'Opening encrypted local data…',
    'startupFailed': 'The encrypted local data could not be opened. Existing data was not changed.',
    'retry': 'Retry',
    'snapshot': 'Create recovery snapshot',
    'snapshotCreated': 'Verified recovery snapshot created',
    'singleAuthority':
        'This installation is the single write authority for this branch.',
  };

  static const _marathi = <String, String>{
    'appTitle': 'सोलर शॉप ईआरपी',
    'setupTitle': 'ही स्थापना तयार करा',
    'organizationLegalName': 'संस्थेचे कायदेशीर नाव',
    'organizationDisplayName': 'दर्शनी नाव',
    'branchName': 'शाखेचे नाव',
    'financialYear': 'आर्थिक वर्ष',
    'saveSetup': 'स्थापना तयार करा',
    'language': 'English',
    'loading': 'कूटबद्ध स्थानिक डेटा उघडत आहे…',
    'startupFailed':
        'कूटबद्ध स्थानिक डेटा उघडता आला नाही. जुना डेटा बदललेला नाही.',
    'retry': 'पुन्हा प्रयत्न करा',
    'snapshot': 'पुनर्प्राप्ती प्रत तयार करा',
    'snapshotCreated': 'तपासलेली पुनर्प्राप्ती प्रत तयार झाली',
    'singleAuthority': 'या शाखेसाठी ही स्थापना एकमेव लेखन प्राधिकरण आहे.',
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
