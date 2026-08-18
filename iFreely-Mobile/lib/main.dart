import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flut/BlocObserver.dart';
import 'package:flut/bloc/feed/feed_bloc.dart';
import 'package:flut/bloc/freelancer_jobs/freelancer_jobs_bloc.dart';
import 'package:flut/bloc/login/login_bloc.dart';
import 'package:flut/bloc/profile/profile_bloc.dart';
import 'package:flut/bloc/messaging/conversation_bloc.dart';
import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/bloc/proposals/proposals_bloc.dart';
import 'package:flut/bloc/register/register_bloc.dart';
import 'package:flut/bloc/talents/talents_bloc.dart';
import 'package:flut/consts/handle_notifications.dart';
import 'package:flut/consts/hive_consts.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/models/conversation.dart';
import 'package:flut/models/message.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/repos/feed_repo.dart';
import 'package:flut/repos/job_creation_repo.dart';
import 'package:flut/repos/messaging_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  await Hive.initFlutter();

  // NOTE/DEBUG: if you want to remove sessions, just un comment this
  // await Hive.deleteBoxFromDisk(HiveConsts.USER_SESSION);

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [MessageSchema, ConversationSchema],
    directory: dir.path,
  );
  await AuthRepo.init_intial_route();

  runApp(iFreelyMainEntry(isar: isar));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FlutterDownloader.initialize();
  void _request() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
       await Permission.videos.request();
       await Permission.photos.request();
    } else {
      await Permission.storage.request();
    }
    await Permission.notification.request();
    await Permission.microphone.request();
  }

  _request();

  Bloc.observer = DebugBlocObserver();
}

class iFreelyMainEntry extends StatelessWidget {
  final isar;
  iFreelyMainEntry({super.key, required this.isar});
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepo>(create: (ctx) => AuthRepo()),
        RepositoryProvider<FeedRepo>(
            create: (ctx) => FeedRepo(ctx.read<AuthRepo>())),
        RepositoryProvider<JobCreationRepo>(
            create: (ctx) => JobCreationRepo(ctx.read<AuthRepo>())),
        RepositoryProvider<MessagingRepo>(create: (ctx) => MessagingRepo(isar)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => ProfileBloc(ctx.read<AuthRepo>()),
          ),
          BlocProvider(
            create: (ctx) => LoginBloc(ctx.read<AuthRepo>()),
          ),
          BlocProvider(
            create: (ctx) => RegisterBloc(ctx.read<AuthRepo>()),
          ),
          BlocProvider(
            create: (ctx) => FeedBloc(ctx.read<FeedRepo>()),
          ),
          BlocProvider(
            create: (ctx) => ProposalsBloc(ctx.read<AuthRepo>()),
          ),
          BlocProvider(
            create: (ctx) => FreelancerJobsBloc(ctx.read<AuthRepo>()),
          ),
          BlocProvider(
            create: (ctx) => TalentsBloc(ctx.read<AuthRepo>()),
          ),
          BlocProvider(
              create: (ctx) => ConversationBloc(ctx.read<MessagingRepo>())),
          BlocProvider(
              create: (ctx) => MessagingBloc(ctx.read<MessagingRepo>())),
        ],
        child: MaterialApp(
          title: 'iFreely',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: "Poppins",
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF7360DF),
              background: Color(0xFFFAFAFA),
            ),
            useMaterial3: true,
          ),
          onGenerateRoute: Routes.generateRoute,
          initialRoute: Routes.intial_route,
        ),
      ),
    );
  }
}
