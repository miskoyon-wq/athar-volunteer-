# ─────────────────────────────────────────────────────────────────────────────
#  أثر — تشغيل الموقع محليًا (للمعاينة قبل الرفع)
#  Athar site — local preview
# ─────────────────────────────────────────────────────────────────────────────
#  التشغيل:   bash serve.sh
#  بعدها افتح: http://localhost:8000/
# ─────────────────────────────────────────────────────────────────────────────
set -e
PORT="${1:-8000}"
cd "$(dirname "$0")"
echo ""
echo "  تشغيل موقع أثر على:  http://localhost:$PORT/"
echo "  التطبيق:            http://localhost:$PORT/app/"
echo "  تحميل APK:          http://localhost:$PORT/download/"
echo ""
echo "  (أوقف التشغيل بـ Ctrl+C)"
echo ""
exec python3 -m http.server "$PORT" --bind 0.0.0.0
