#!/usr/bin/env bash
# 把本仓库里的 Typora 配置还原到当前 Mac。
set -euo pipefail
cd "$(dirname "$0")"

THEME_DIR="$HOME/Library/Application Support/abnerworks.Typora/themes"
PREFS="$HOME/Library/Preferences/abnerworks.Typora.plist"

echo "==> 还原 Typora 配置"
if pgrep -x Typora >/dev/null; then
  echo "Typora 正在运行。请先完全退出（Cmd+Q），否则偏好设置会被它覆盖。"
  read -r -p "已退出？回车继续，Ctrl+C 取消: " _
fi

echo "==> 复制主题到 $THEME_DIR"
mkdir -p "$THEME_DIR"
for f in themes/*.css; do
  cp "$f" "$THEME_DIR/$(basename "$f")"
  echo "    $(basename "$f")"
done

if [ -f settings/abnerworks.Typora.plist ]; then
  echo "==> 备份现有偏好设置"
  cp "$PREFS" "$PREFS.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
  echo "==> 导入偏好设置"
  defaults import abnerworks.Typora settings/abnerworks.Typora.plist
  killall cfprefsd 2>/dev/null || true
fi

echo "完成。打开 Typora，在 主题 菜单里选 Kami Work Notes。"
