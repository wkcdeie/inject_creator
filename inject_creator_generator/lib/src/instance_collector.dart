import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:collection/collection.dart';
import 'package:inject_creator/inject_creator.dart';
import 'instance_node.dart';

class InstanceCollector {
  static final instanceCheckers = [
    TypeChecker.fromRuntime(Singleton),
    TypeChecker.fromRuntime(LazySingleton),
    TypeChecker.fromRuntime(Mutable),
  ];
  static final disposeMethodChecker = TypeChecker.fromRuntime(DisposeMethod);
  final _factoryMethodChecker = TypeChecker.fromRuntime(FactoryMethod);
  final _postConstructChecker = TypeChecker.fromRuntime(PostConstruct);
  final _aliasChecker = TypeChecker.fromRuntime(Alias);
  final Set<InstanceNode> _nodes = {};

  Set<InstanceNode> get nodes => _nodes;

  void collect(ClassElement element, ConstantReader annotation) {
    List<DependencyNode> dependencyNodes = [];
    String? postConstruct;
    FactoryMethodNode? _factoryMethodNode;
    DisposeMethodNode? _disposeMethodNode;
    for (var method in element.methods) {
      if (disposeMethodChecker.firstAnnotationOf(method) != null) {
        _disposeMethodNode = DisposeMethodNode(method.displayName);
        continue;
      } else if (_postConstructChecker.firstAnnotationOf(method) != null) {
        postConstruct = method.displayName;
        continue;
      }
      if (!method.isStatic) {
        continue;
      }
      if (_factoryMethodChecker.firstAnnotationOf(method) == null) {
        continue;
      }
      Map<String, String> parameters = {};
      for (var pe in method.parameters) {
        Element? pTypeEle;
        if (pe.type.isDartAsyncFuture || pe.type.isDartAsyncFutureOr) {
          final type = pe.type as InterfaceType;
          pTypeEle = type.typeArguments.first.element;
        } else {
          pTypeEle = pe.type.element;
        }
        if (pTypeEle == null || pTypeEle is! ClassElement) {
          continue;
        }
        String? alias = _getParameterAlias(pe);
        if (alias == null) {
          _checkInstanceAnnotation(pTypeEle);
        }
        final owner = _nodes.firstWhereOrNull(
            (element) => element.clsName == pTypeEle!.displayName);
        if (owner != null) {
          owner.order++;
        }
        final me = pTypeEle.methods.firstWhereOrNull((element) =>
            _factoryMethodChecker.firstAnnotationOf(element) != null);
        dependencyNodes.add(DependencyNode(
          name: pTypeEle.displayName,
          isAsync: me != null &&
              (me.returnType.isDartAsyncFuture ||
                  me.returnType.isDartAsyncFutureOr),
          alias: alias,
        ));
        if (pe.isRequiredNamed) {
          parameters[pTypeEle.displayName] = pe.displayName;
        }
      }
      _factoryMethodNode = FactoryMethodNode(
        name: method.displayName,
        parameters: parameters,
        isAsync: method.returnType.isDartAsyncFuture ||
            method.returnType.isDartAsyncFutureOr,
      );
    }
    _nodes.add(InstanceNode(
      clsName: element.displayName,
      tag: annotation.peek('tag')?.stringValue,
      as: annotation.peek('as')?.typeValue.element?.displayName,
      singleton: annotation.peek('singleton')?.boolValue ?? false,
      isLazy: annotation.peek('isLazy')?.boolValue ?? false,
      importUri: element.source.uri.toString(),
      dependencies: dependencyNodes,
      factoryMethod: _factoryMethodNode,
      disposeMethod: _disposeMethodNode,
      postConstruct: postConstruct,
    ));
  }

  String? _getParameterAlias(Element element) {
    final aliasObj = _aliasChecker.firstAnnotationOf(element);
    if (aliasObj == null) {
      return null;
    }
    String? alias = aliasObj.getField('name')?.toStringValue();
    if (alias == null) {
      final refEle = aliasObj.getField('type')?.toTypeValue()?.element;
      if (refEle != null) {
        DartObject? refObj = _checkInstanceAnnotation(refEle);
        if (refObj != null) {
          alias = ConstantReader(refObj).peek('tag')?.stringValue;
        }
      }
    }
    return alias;
  }

  DartObject? _checkInstanceAnnotation(Element element) {
    DartObject? obj;
    for (var checker in instanceCheckers) {
      obj = checker.firstAnnotationOf(element);
      if (obj != null) {
        break;
      }
    }
    if (obj == null) {
      throw ArgumentError(
          '`${element.displayName}` no annotation [`Singleton`,`LazySingleton`, `Mutable`]');
    }
    return obj;
  }
}
