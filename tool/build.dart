import 'package:build_runner/build_runner.dart';
import 'phases.dart';

main() => build(PHASES, deleteFilesByDefault: true);
