import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/ithar_db.dart';
import 'services/repository.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ItharDb.init();
  await ItharDb.seedIfEmpty();
  await NotificationService.instance.init();

  final repo = AppRepository();
  await repo.load();

  runApp(
    ChangeNotifierProvider<AppRepository>.value(
      value: repo,
      child: const ItharApp(),
    ),
  );
}
