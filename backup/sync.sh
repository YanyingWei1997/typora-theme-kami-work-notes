#!/usr/bin/env bash
# 把当前 Mac 上的 Typora 配置重新导出到本仓库 backup/，并提交推送。
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"   # 后面的相对路径都基于仓库根目录
BK="$REPO/backup"
APP_SUPPORT="$HOME/Library/Application Support/abnerworks.Typora"
IMG_DIR="$HOME/Library/Application Support/typora-user-images"
PREFS="$HOME/Library/Preferences/abnerworks.Typora.plist"

echo "==> 同步主题"
# 主题本体放仓库根目录，其余在用主题进 backup/themes/
if [ -f "$APP_SUPPORT/themes/kami-work-notes.css" ]; then
  cp "$APP_SUPPORT/themes/kami-work-notes.css" "$REPO/kami-work-notes.css"
  echo "    kami-work-notes.css → 仓库根目录"
fi
for f in animal-island.css animal-island-dark.css spring.css; do
  if [ -f "$APP_SUPPORT/themes/$f" ]; then
    cp "$APP_SUPPORT/themes/$f" "$BK/themes/$f"
    echo "    $f"
  else
    echo "    跳过（本机不存在）: $f"
  fi
done

echo "==> 同步粘贴图片"
mkdir -p "$BK/typora-user-images"
if compgen -G "$IMG_DIR/*.png" >/dev/null; then
  cp "$IMG_DIR"/*.png "$BK/typora-user-images/"
  echo "    $(find "$BK/typora-user-images" -name '*.png' | wc -l | tr -d ' ') 张"
fi

echo "==> 导出并清洗偏好设置"
python3 - <<'PY'
import plistlib, pathlib, subprocess

prefs = pathlib.Path.home() / "Library/Preferences/abnerworks.Typora.plist"
xml = subprocess.run(["plutil", "-convert", "xml1", "-o", "-", str(prefs)],
                     capture_output=True, check=True).stdout
d = plistlib.loads(xml)

drop = [k for k in d if k.startswith("NSWindow Frame") or k.startswith("NSNavPanel")
        or k.startswith("NSSpellChecker")
        or k in {"recentFolder", "savedLastOpen", "NSOSPLastRootDirectory",
                 "Release Group", "currentThemeFolder", "uuid"}]
for k in drop:
    d.pop(k, None)

out = pathlib.Path("backup/settings/abnerworks.Typora.plist")
with out.open("wb") as f:
    plistlib.dump(d, f, fmt=plistlib.FMT_XML, sort_keys=True)
print(f"    保留 {len(d)} 项，剔除 {len(drop)} 项隐私/机器相关字段")
PY

echo "==> 提交"
cd "$REPO"
if git diff --quiet && git diff --cached --quiet; then
  echo "    没有变化，跳过"
  exit 0
fi
git add -A
git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
git push
