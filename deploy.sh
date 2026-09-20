# ─────────────────────────────────────────────────────────────────────────────
#  أثر — نشر الموقع على GitHub Pages بأمر واحد
#  Athar site — one-command GitHub Pages deploy
# ─────────────────────────────────────────────────────────────────────────────
#
#  المتطلبات:
#    1) حساب GitHub موجود
#    2) git مثبّت على جهازك
#    3) مستودع فاضي اسمه athar-site (Public)
#
#  طريقة الاستخدام:
#    bash deploy.sh <github-username> [repo-name]
#
#  مثال:
#    bash deploy.sh miskoyon-wq
#    bash deploy.sh miskoyon-wq athar-site
#
# ─────────────────────────────────────────────────────────────────────────────
set -e

USER="${1:?اكتب اسم حسابك على GitHub. مثال: bash deploy.sh miskoyon-wq}"
REPO="${2:-athar-site}"
DIR="$(cd "$(dirname "$0")" && pwd)"
DATE="$(date +%Y-%m-%d)"

cd "$DIR"

echo ""
echo "  ┌───────────────────────────────────────────────┐"
echo "  │  أثر — النشر على GitHub Pages                 │"
echo "  └───────────────────────────────────────────────┘"
echo "  الحساب:  $USER"
echo "  المستودع: $REPO"
echo ""

if [ ! -d .git ]; then
  echo "  ◆ تهيئة مستودع git محلي…"
  git init -q
  git branch -M main
fi

echo "  ◆ تجهيز الملفات…"
git add -A

if git diff --cached --quiet; then
  echo "  ℹ️  لا توجد تغييرات جديدة."
else
  git -c user.name="Athar Bot" -c user.email="noreply@athar.app" \
      commit -q -m "Athar site — $DATE" || true
  echo "  ✓ تم عمل Commit"
fi

git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$USER/$REPO.git"

echo "  ◆ جاري الرفع إلى GitHub…"
echo "     (سيُطلب منك اسم المستخدم و Token بدل كلمة المرور)"
echo ""
git push -u origin main --force

echo ""
echo "  ✅ تم الرفع بنجاح!"
echo ""
echo "  ── الخطوة الأخيرة (مرة واحدة) ─────────────────────"
echo "   1) افتح: https://github.com/$USER/$REPO/settings/pages"
echo "   2) Source:   Deploy from a branch"
echo "   3) Branch:   main   |   Folder:  / (root)"
echo "   4) اضغط Save وانتظر 1–3 دقائق"
echo ""
echo "  🔗 روابطك ستكون:"
echo "     الرئيسية : https://$USER.github.io/$REPO/"
echo "     التطبيق  : https://$USER.github.io/$REPO/app/"
echo "     تحميل APK: https://$USER.github.io/$REPO/download/"
echo "     الخصوصية : https://$USER.github.io/$REPO/privacy.html"
echo "     الدعم    : https://$USER.github.io/$REPO/support.html"
echo ""
echo "  ملاحظة: ملف الـAPK كبير (52MB) ولا يُقبل بالرفع من المتصفح."
echo "          لنشره: GitHub → Releases → Draft a new release → v1.3.0 → أرفق athar-1.3.0.apk"
echo ""
