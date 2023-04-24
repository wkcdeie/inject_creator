import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:inject_creator/inject_creator.dart';

import 'src/instance_collector.dart';
import 'src/component_collector.dart';
import 'src/dependency_writer.dart';

InstanceCollector _instanceCollector = InstanceCollector();
ComponentCollector _componentCollector = ComponentCollector();

class CombinedInstanceGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    for (var checker in InstanceCollector.instanceCheckers) {
      for (var annotatedElement in library.annotatedWith(checker)) {
        if (annotatedElement.element is! ClassElement) {
          throw InvalidGenerationSourceError(
            '`Singleton`、`LazySingleton` or `Mutable` can only be used on class.',
            element: annotatedElement.element,
          );
        }
        _instanceCollector.collect(annotatedElement.element as ClassElement,
            annotatedElement.annotation);
      }
    }
    return '';
  }
}

class ComponentGenerator extends GeneratorForAnnotation<Component> {
  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind != ElementKind.CLASS) {
      throw InvalidGenerationSourceError(
        '`@Component` can only be used on class.',
        element: element,
      );
    }
    _componentCollector.collect(element as ClassElement, annotation);
    return null;
  }
}

class EnableInjectorGenerator extends GeneratorForAnnotation<EnableInjector> {
  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind != ElementKind.CLASS &&
        element.kind != ElementKind.FUNCTION) {
      throw InvalidGenerationSourceError(
        '`@EnableInjector` can only be used on class or function.',
        element: element,
      );
    }
    final entryPoint = annotation.peek('entryPoint')?.stringValue;
    if (entryPoint == null) {
      throw InvalidGenerationSourceError(
        '`entryPoint` cannot null.',
        element: element,
      );
    }
    return DependencyWriter(
            entryPoint: entryPoint,
            allReady: annotation.peek('allReady')?.boolValue ?? false,
            instance: _instanceCollector,
            component: _componentCollector)
        .write(buildStep);
  }
}
