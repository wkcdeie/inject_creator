/// 开启依赖注入，扫描注解
class EnableInjector {
  /// 配置的方法名称，默认`configDependencies`
  final String? entryPoint;

  /// 是否等待所有实例初始化完成
  final bool allReady;

  const EnableInjector(
      {this.entryPoint = 'configDependencies', this.allReady = false});
}
