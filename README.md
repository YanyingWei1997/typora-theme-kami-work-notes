# Typora 配置备份

这台 Mac 上 Typora 的个人配置：自定义主题 CSS + 偏好设置。用于换机、重装或同步时一键还原。

## 内容

```
themes/                     自定义主题（4 个）
  animal-island.css         动物森友会风 · 浅色
  animal-island-dark.css    动物森友会风 · 深色
  kami-work-notes.css       Kami Work Notes · 当前在用主题
  spring.css                Spring
settings/
  abnerworks.Typora.plist   清洗后的偏好设置（可直接导入）
  Typora-Settings.md        设置项可读清单
install.sh                  还原脚本
sync.sh                     把当前设置重新导出并提交推送
```

## 还原

```bash
./install.sh
```

脚本会：
1. 提示先退出 Typora（改偏好设置前必须退出，否则会被覆盖）
2. 把 `themes/*.css` 复制到 `~/Library/Application Support/abnerworks.Typora/themes/`
3. 用 `defaults import` 写入偏好设置，然后重启 `cfprefsd` 使其生效

只想要主题就手动复制 CSS 到上面的 themes 目录，Typora 里重新选一次主题即可。

## 更新备份

```bash
./sync.sh
```

重新读取本机当前的偏好设置，清洗掉隐私字段后写回仓库并推送。

## 未纳入版本管理

- **最近打开的文件/文件夹列表、窗口位置**：纯本机状态，且会暴露本地目录结构，已剔除
- **`typora-user-images`**：文档里粘贴的图片资源（约 4.3 MB），属于文档资产而非配置
- **Typora 自带主题**（github / gothic / newsprint / night / pixyll / whitey）：安装包自带，无需备份
- **安装标识 / 授权相关字段**：已剔除

## 设置要点

- 默认主题 `Kami Work Notes`，深色主题 `Night`
- Markdown 复制默认开启、严格模式开启、代码块不显示行号
- 行内公式、上下标、`==高亮==` 全部开启，行间公式自动编号
- 无自动换行、无缝窗口、大纲侧栏

完整清单见 [settings/Typora-Settings.md](settings/Typora-Settings.md)。
