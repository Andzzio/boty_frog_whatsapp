import 'package:boty_frog/core/logger.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';

Handler middleware(Handler handler) {
  initLogger();
  final env = DotEnv()..load();
  return handler.use(
    provider<DotEnv>(
      (context) => env,
    ),
  );
}
