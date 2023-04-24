import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'instance_collector.dart';

class ComponentNode {
  final String clsName;
  final String importUri;
  final String? disposeMethod;
  final List<ComponentFieldNode> fields;

  ComponentNode(
      {required this.clsName,
      required this.importUri,
      this.disposeMethod,
      required this.fields});
}

class ComponentFieldNode {
  final String name;
  final String clsName;
  final String importUri;
  final bool isAsync;
  final bool singleton;
  final bool isLazy;
  final String? tag;
  final String? as;

  ComponentFieldNode(
      {required this.name,
      required this.clsName,
      required this.importUri,
      required this.isAsync,
      required this.singleton,
      required this.isLazy,
      this.tag,
      this.as});
}

class ComponentCollector {
  final Set<ComponentNode> _nodes = {};
  final Set<String> _excludeFields = {'hashCode'};

  Set<ComponentNode> get nodes => _nodes;

  void collect(ClassElement element, ConstantReader annotation) {
    List<ComponentFieldNode> fields = [];
    for (var field in element.fields) {
      if (field.isStatic ||
          !field.isPublic ||
          field.getter == null ||
          _excludeFields.contains(field.displayName)) {
        continue;
      }
      final fieldType = field.type;
      final isAsync =
          fieldType.isDartAsyncFuture || fieldType.isDartAsyncFutureOr;
      String? clsName;
      String? importUri;
      if (isAsync) {
        final type = fieldType as InterfaceType;
        final el = type.typeArguments.first.element;
        clsName = el?.displayName;
        importUri = el?.source?.uri.toString();
      }
      clsName ??= fieldType.element?.displayName;
      importUri ??= fieldType.element?.source?.uri.toString();
      bool singleton = false, isLazy = false;
      String? tag, as;
      for (var checker in InstanceCollector.instanceCheckers) {
        var annotation =
            checker.firstAnnotationOf(field, throwOnUnresolved: false);
        if (annotation == null) {
          annotation = checker.firstAnnotationOf(field.getter!);
        }
        if (annotation != null) {
          final reader = ConstantReader(annotation);
          singleton = reader.peek('singleton')?.boolValue ?? false;
          isLazy = reader.peek('isLazy')?.boolValue ?? false;
          tag = reader.peek('tag')?.stringValue;
          as = reader.peek('as')?.stringValue;
        }
      }
      fields.add(ComponentFieldNode(
        name: field.displayName,
        clsName: clsName!,
        importUri: importUri!,
        isAsync: isAsync,
        singleton: singleton,
        isLazy: isLazy,
        tag: tag,
        as: as,
      ));
    }
    _nodes.add(ComponentNode(
      clsName: element.displayName,
      importUri: element.source.uri.toString(),
      fields: fields,
      disposeMethod: element.methods
          .firstWhereOrNull((method) =>
              InstanceCollector.disposeMethodChecker
                  .firstAnnotationOf(method) !=
              null)
          ?.displayName,
    ));
  }
}
