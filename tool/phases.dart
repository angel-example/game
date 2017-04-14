import 'package:build_runner/build_runner.dart';
import 'package:owl_codegen/json_generator.dart';
import 'package:source_gen/builder.dart';

final PhaseGroup PHASES = new PhaseGroup.singleAction(
    new GeneratorBuilder([new JsonGenerator()], isStandalone: true),
    new InputSet('game', const ['lib/src/models/*.dart']));
