#!/usr/bin/env bash
# 把本仓库 backup/ 里的 Typora 配置还原到当前 Mac（含主题与粘贴图片）。
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
BK="$REPO/backup"
THEME_DIR="$HOME/Library/Application Support/abnerworks.Typora/themes"
IMG_DIR="$HOME/Library/Application Support/typora-user-images"
PREFS="$HOME/Library/Preferences/abnerworks.Typora.plist"

echo "==> 还原 Typora 配置"
if pgrep -x Typora >/dev/null; then
  echo "Typora 正在运行。请先完全退出（Cmd+Q），否则偏好设置会被它覆盖。"
  read -r -p "已退出？回车继续，Ctrl+C 取消: " _
fi

echo "==> 主题 → $THEME_DIR"
mkdir -p "$THEME_DIR"
for f in "$REPO/kami-work-notes.css" "$BK"/themes/*.css; do
  [ -f "$f" ] || continue
  cp "$f" "$THEME_DIR/$(basename "$f")"
  echo "    $(basename "$f")"
done

if [ -d "$BK/typora-user-images" ]; then
  echo "==> 粘贴图片 → $IMG_DIR"
  mkdir -p "$IMG_DIR"
  cp "$BK/typora-user-images"/*.png "$IMG_DIR"/ 2>/dev/null || true
  echo "    $(find "$BK/typora-user-images" -name '*.png' | wc -l | tr -d ' ') 张"
fi

if [ -f "$BK/settings/abnerworks.Typora.plist" ]; then
  echo "==> 备份现有偏好设置"
  cp "$PREFS" "$PREFS.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
  echo "==> 导入偏好设置"
  defaults import abnerworks.Typora "$BK/settings/abnerworks.Typora.plist"
  killall cfprefsd 2>/dev/null || true
fi

echo "完成。打开 Typora，在 主题 菜单里选 Kami Work Notes。"
