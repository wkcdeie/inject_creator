/// 服务类
class _Instance {
  /// 实例名称
  final String? tag;

  /// 是否单例
  final bool singleton;

  /// 是否延迟加载
  final bool isLazy;

  /// 关联的实例类型；例如抽象类或父类类型
  final Type? as;

  const _Instance(
      {this.tag, this.singleton = true, this.isLazy = false, this.as});
}

/// 单例
class Singleton extends _Instance {
  const Singleton({String? tag, bool isLazy = false, Type? as})
      : super(tag: tag, singleton: true, isLazy: isLazy, as: as);
}

/// 延迟加载单例
class LazySingleton extends Singleton {
  const LazySingleton({String? tag, Type? as})
      : super(tag: tag, isLazy: true, as: as);
}

/// 每次调用都创建新实例
class Mutable extends _Instance {
  const Mutable({String? tag, Type? as})
      : super(tag: tag, singleton: false, isLazy: false, as: as);
}
