import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:masked_contact_dialer/models/call_history_entry.dart';
import 'package:masked_contact_dialer/models/category_model.dart';
import 'package:masked_contact_dialer/models/contact_model.dart';
import 'package:masked_contact_dialer/utils/constants.dart';
import 'package:masked_contact_dialer/utils/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter (sets up path_provider directory).
  await Hive.initFlutter();

  // Register type adapters for all Hive-persisted models.
  Hive.registerAdapter(ContactModelAdapter());
  Hive.registerAdapter(CallHistoryEntryAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  // Open all Hive boxes used by the application.
  await Hive.openBox<ContactModel>(HiveBoxes.contacts);
  await Hive.openBox<CallHistoryEntry>(HiveBoxes.callHistory);
  await Hive.openBox<CategoryModel>(HiveBoxes.categories);
  await Hive.openBox<dynamic>(HiveBoxes.settings);

  runApp(
    const ProviderScope(
      child: MaskedContactDialerApp(),
    ),
  );
}

/// Root widget for the Masked Contact Dialer application.
class MaskedContactDialerApp extends StatelessWidget {
  const MaskedContactDialerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('Masked Contact Dialer'),
        ),
      ),
    );
  }
}
