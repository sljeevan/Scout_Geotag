import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/local/session_store.dart';
import 'data/remote/sitepin_api_client.dart';
import 'data/repositories/admin_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/project_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/sync_repository.dart';
import 'data/repositories/tag_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'state/admin_state.dart';
import 'state/auth_state.dart';
import 'state/project_state.dart';
import 'state/profile_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }
  runApp(const SitePinApp());
}

class SitePinApp extends StatelessWidget {
  const SitePinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionStore = SessionStore();
    final api = SitePinApiClient();
    final authRepo = AuthRepository(api: api, sessionStore: sessionStore);
    final projectRepo = ProjectRepository();
    final tagRepo = TagRepository(api: api, sessionStore: sessionStore);
    final syncRepo = SyncRepository(
        projects: projectRepo, api: api, sessionStore: sessionStore);
    final adminRepo = AdminRepository(api: api, sessionStore: sessionStore);
    final profileRepo = ProfileRepository(api: api, sessionStore: sessionStore);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthState(authRepo: authRepo, sessionStore: sessionStore)
                ..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectState(
              projectRepo: projectRepo,
              syncRepo: syncRepo,
              sessionStore: sessionStore,
              tagRepo: tagRepo),
        ),
        ChangeNotifierProvider(create: (_) => AdminState(adminRepo: adminRepo)),
        ChangeNotifierProvider(
          create: (_) => ProfileState(profileRepo: profileRepo)..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scout',
        theme: AppTheme.light,
        home: const _EntryPoint(),
      ),
    );
  }
}

class _EntryPoint extends StatelessWidget {
  const _EntryPoint();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (auth.loggedIn) return const HomeScreen();
    return const LoginScreen();
  }
}
