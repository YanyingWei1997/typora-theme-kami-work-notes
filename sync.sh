#!/usr/bin/env bash
# 把当前 Mac 上的 Typora 配置重新导出到本仓库，并提交推送。
set -euo pipefail
cd "$(dirname "$0")"

APP_SUPPORT="$HOME/Library/Application Support/abnerworks.Typora"
PREFS="$HOME/Library/Preferences/abnerworks.Typora.plist"
CUSTOM_THEMES=(animal-island.css animal-island-dark.css kami-work-notes.css spring.css)

echo "==> 同步自定义主题"
for f in "${CUSTOM_THEMES[@]}"; do
  if [ -f "$APP_SUPPORT/themes/$f" ]; then
    cp "$APP_SUPPORT/themes/$f" "themes/$f"
    echo "    $f"
  else
    echo "    跳过（本机不存在）: $f"
  fi
done

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

with open("settings/abnerworks.Typora.plist", "wb") as f:
    plistlib.dump(d, f, fmt=plistlib.FMT_XML, sort_keys=True)
print(f"    保留 {len(d)} 项，剔除 {len(drop)} 项隐私/机器相关字段")
PY

echo "==> 提交"
if git diff --quiet && git diff --cached --quiet; then
  echo "    没有变化，跳过"
  exit 0
fi
git add -A
git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
git push
