class InstanceNode {
  final String clsName;
  final String? tag;
  final String? as;
  final bool singleton;
  final bool isLazy;
  final String importUri;
  final List<DependencyNode> dependencies;
  final FactoryMethodNode? factoryMethod;
  final DisposeMethodNode? disposeMethod;
  final String? postConstruct;
  int order = 0;

  InstanceNode(
      {required this.clsName,
      this.tag,
      this.as,
      this.singleton = false,
      this.isLazy = false,
      required this.importUri,
      this.dependencies = const [],
      this.factoryMethod,
      this.disposeMethod,
      this.postConstruct});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstanceNode &&
          runtimeType == other.runtimeType &&
          clsName == other.clsName &&
          tag == other.tag &&
          as == other.as;

  @override
  int get hashCode => clsName.hashCode ^ tag.hashCode ^ as.hashCode;
}

class DependencyNode {
  final String name;
  final bool isAsync;
  final String? alias;

  DependencyNode({required this.name, this.isAsync = false, this.alias});
}

class FactoryMethodNode {
  final String name;
  final bool isAsync;
  final Map<String, String> parameters;

  FactoryMethodNode(
      {required this.name, this.isAsync = false, required this.parameters});
}

class DisposeMethodNode {
  final String name;

  DisposeMethodNode(this.name);
}
