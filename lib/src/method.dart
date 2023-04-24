/// 工厂构造函数
class FactoryMethod {
  const FactoryMethod();
}

/// 资源释放
class DisposeMethod {
  const DisposeMethod();
}

/// 构造方法之后调用
class PostConstruct {
  const PostConstruct();
}

/// 别名，表示获取指定名称实例
class Alias {
  final String? name;
  final Type? type;

  const Alias(String name)
      : this.name = name,
        type = null;

  const Alias.by(Type type)
      : this.type = type,
        name = null;
}
