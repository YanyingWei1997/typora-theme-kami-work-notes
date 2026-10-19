# backup · 本机 Typora 配置备份

这里是我自己机器上的 Typora 配置备份，**和主题无关**，安装 [Kami Work Notes](../kami-work-notes.css) 不需要这部分内容。

## 内容

```
settings/abnerworks.Typora.plist   清洗后的偏好设置（可直接导入）
settings/Typora-Settings.md        设置项可读清单
themes/                            另外三个在用主题（animal-island ×2、spring）
install.sh                         一键还原到本机
sync.sh                            把本机当前设置重新导出并提交推送
```

**不含 `typora-user-images`**：文档里粘贴的图片属于文档资产，可能包含未发表稿件，因此不进入公开仓库，只留在本机 `~/Library/Application Support/typora-user-images/`。

## 已剔除的字段

偏好设置导出时会去掉机器相关与隐私字段，共 12 项：

- 最近打开的文件/文件夹列表（`recentFolder` / `savedLastOpen` / `NSOSPLastRootDirectory`）
- 窗口位置（`NSWindow Frame *`、`NSNavPanel*`、`NSSpellChecker*`）
- 安装标识 `uuid`、主题目录绝对路径、应用授权相关字段

## 还原

```bash
./install.sh
```

会提示先退出 Typora，然后拷主题到主题目录、`defaults import` 偏好设置并重启 `cfprefsd`。

## 更新

```bash
./sync.sh
```

重新读取本机设置、清洗后写回本目录，再提交推送。
