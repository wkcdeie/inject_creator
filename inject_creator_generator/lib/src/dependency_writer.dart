import 'package:build/build.dart' show BuildStep;
import 'package:collection/collection.dart';
import 'instance_collector.dart';
import 'component_collector.dart';

class DependencyWriter {
  final String entryPoint;
  final bool allReady;
  final InstanceCollector instance;
  final ComponentCollector component;

  DependencyWriter(
      {required this.entryPoint,
      required this.allReady,
      required this.instance,
      required this.component});

  String write(BuildStep buildStep) {
    // 将被依赖的实例优先注册
    final nodes = instance.nodes.sorted((a, b) {
      if (a.order == b.order) {
        return a.clsName.compareTo(b.clsName);
      }
      return a.order < b.order ? 1 : -1;
    });
    StringBuffer code = StringBuffer();
    _generateImportPackages().forEach((uri) {
      code.writeln("import '$uri';");
    });
    code.writeln("${allReady ? 'Future<void>' : 'void'} $entryPoint() {");
    code.writeln("final it = GetIt.instance;");
    List<String> getterMethods = [];
    for (var node in nodes) {
      String instanceName = '';
      if (node.tag != null && node.tag!.isNotEmpty) {
        instanceName = "instanceName: '${node.tag}'";
      }
      String createMethod = "${node.clsName}()";
      bool isAsync = node.factoryMethod?.isAsync ?? false;
      if (node.factoryMethod != null) {
        List<String> dependencies = [];
        for (var dependency in node.dependencies) {
          String depNamed =
              node.factoryMethod!.parameters[dependency.name] ?? '';
          if (depNamed.isNotEmpty) {
            depNamed = '$depNamed:';
          }
          if (dependency.alias != null) {
            dependencies
                .add("${depNamed}get${dependency.name}('${dependency.alias}')");
          } else {
            dependencies.add("${depNamed}get${dependency.name}()");
          }
        }
        createMethod =
            "${node.clsName}.${node.factoryMethod!.name}(${dependencies.join(',')})";
      }
      if (isAsync || !node.singleton || node.isLazy) {
        createMethod = '() => $createMethod';
      }
      if (node.postConstruct != null) {
        createMethod = '${createMethod}..${node.postConstruct}()';
      }
      if (instanceName.isNotEmpty) {
        createMethod = '$createMethod, ';
      }
      code.write(
          "it.${_makeRegisterMethod(isAsync, node.singleton, node.isLazy)}<${node.as ?? node.clsName}>($createMethod$instanceName");
      if (node.singleton && node.disposeMethod != null) {
        code.write(
            ", dispose: (instance) => instance.${node.disposeMethod?.name}()");
      }
      code.write(");\n");
      getterMethods.add(_makeInstanceGetter(node.clsName, isAsync,
          asName: node.as, tag: node.tag));
    }
    final cpn =
        component.nodes.sorted((a, b) => a.clsName.compareTo(b.clsName));
    for (var node in cpn) {
      String refPrefix =
          '_${node.clsName.substring(0, 1).toLowerCase()}${node.clsName.substring(1)}';
      if (node.disposeMethod != null) {
        code.write(
            "it.${_makeRegisterMethod(false, true, false)}<${node.clsName}>(${node.clsName}()");
        code.write(", dispose: (instance) => instance.${node.disposeMethod}()");
        code.write(");\n");
        refPrefix = 'get${node.clsName}()';
      } else {
        code.writeln("final $refPrefix = ${node.clsName}();");
      }
      for (var field in node.fields) {
        code.write(
            "it.${_makeRegisterMethod(field.isAsync, field.singleton, field.isLazy)}<${field.as ?? field.clsName}>(() => $refPrefix.${field.name}");
        if (field.tag != null) {
          code.write(", instanceName: '${field.tag}'");
        }
        code.write(");\n");
        getterMethods.add(_makeInstanceGetter(field.clsName, field.isAsync,
            asName: field.as, tag: field.tag));
      }
      getterMethods.add(_makeInstanceGetter(node.clsName, false));
    }
    if (allReady) {
      code.writeln("return it.allReady();");
    }
    code.writeln("}");
    code.writeln(getterMethods.toSet().join('\n\n'));
    return code.toString();
  }

  List<String> _generateImportPackages() {
    Set<String> packages = {'package:get_it/get_it.dart'};
    for (var node in component.nodes) {
      packages.add(node.importUri);
      packages.addAll(node.fields.map((e) => e.importUri));
    }
    packages.addAll(instance.nodes.map((e) => e.importUri));
    return packages.sorted((a, b) => a.compareTo(b));
  }

  String _makeRegisterMethod(bool isAsync, bool singleton, bool isLazy) {
    String registerMethod;
    if (singleton) {
      if (isLazy) {
        registerMethod =
            isAsync ? 'registerLazySingletonAsync' : 'registerLazySingleton';
      } else {
        registerMethod =
            isAsync ? 'registerSingletonAsync' : 'registerSingleton';
      }
    } else {
      registerMethod = isAsync ? 'registerFactoryAsync' : 'registerFactory';
    }
    return registerMethod;
  }

  String _makeInstanceGetter(String clsName, bool isAsync,
      {String? asName, String? tag}) {
    StringBuffer sb = StringBuffer();
    if (isAsync) {
      sb.write("Future<");
      if (asName != null) {
        sb.write(asName);
      } else {
        sb.write(clsName);
      }
      sb.write(">");
    } else if (asName != null) {
      sb.write(asName);
    } else {
      sb.write(clsName);
    }
    sb.write(" get");
    if (asName != null) {
      sb.write(asName);
      sb.write("<T extends $asName>");
    } else {
      sb.write(clsName);
    }
    if (asName != null && tag != null) {
      sb.write("([String? tag])");
    } else {
      sb.write("()");
    }
    sb.write(" => GetIt.instance.get");
    if (isAsync) {
      sb.write("Async");
    }
    sb.write("<");
    if (asName != null) {
      sb.write("T");
    } else {
      sb.write(clsName);
    }
    sb.write(">(");
    if (tag != null && tag.trim().isNotEmpty) {
      sb.write("instanceName: ");
      if (asName != null) {
        sb.write("tag");
      } else {
        sb.write("'$tag'");
      }
    }
    sb.write(");");
    return sb.toString();
  }
}
