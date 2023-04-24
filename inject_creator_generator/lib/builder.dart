import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder combinedInstanceBuilder(BuilderOptions options) =>
    LibraryBuilder(CombinedInstanceGenerator(),
        generatedExtension: '.so.dart');

Builder componentBuilder(BuilderOptions options) =>
    LibraryBuilder(ComponentGenerator(),
        generatedExtension: '.3rd.dart');

Builder dependencyWriteBuilder(BuilderOptions options) =>
    LibraryBuilder(EnableInjectorGenerator(),
        generatedExtension: '.dep.dart');
