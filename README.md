# أثر — بوابة التطوع الذكية (موقع الويب)

موقع وتطبيق **أثر** الرسمي — يعمل مباشرة على **GitHub Pages** بدون أي خادم أو خبرة برمجية.

> **Athar — smart volunteering portal.** Static site + Flutter web app + Android APK download page, ready to deploy on GitHub Pages.

---

## 🗂️ محتوى المستودع

| المسار | الوصف |
|---|---|
| `index.html` | الصفحة الرئيسية (صفحة هبوط عربية RTL) |
| `app/` | تطبيق أثر (Flutter Web) — يفتح مباشرة: `app/` |
| `download/` | صفحة تحميل تطبيق الأندرويد (زر + رمز QR + خطوات التثبيت) |
| `apk/athar-1.3.0.apk` | ملف التثبيت للأندرويد (v1.3.0+4) |
| `privacy.html` | سياسة الخصوصية (المطلوبة لمتجر Google Play) |
| `support.html` | صفحة الدعم والتواصل |
| `assets/` | الأيقونات والشعارات |
| `vendor/qrcode.js` | مكتبة توليد رمز QR (محلية — بدون إنترنت) |
| `404.html` | صفحة الخطأ (ترجعك للرئيسية تلقائيًا) |
| `.nojekyll` | يمنع GitHub من معالجة الملفات ❗ **مهم جدًا** |

---

## 🚀 طريقة النشر على GitHub Pages (5 دقائق)

### 1) إنشاء المستودع
- افتح: <https://github.com/new>
- **Repository name:** `athar-site`
- **Visibility:** اختر **Public** (شرط لعمل Pages المجاني)
- **Initialize with README:** اتركها **بدون** علامة صح
- اضغط **Create repository**

### 2) رفع الملفات
في الصفحة الجديدة اضغط رابط **uploading an existing file**، ثم:
- اسحب **كل الملفات والمجلدات من داخل** هذا الفولدر (وليس الفولدر نفسه).
- تأكد أن الملفات الناتجة داخل القائمة **بدون** أي فولدر في الأعلى.

> **مهم:** ارسم الملفات كالتالي من الجذر مباشرة:
> `index.html` · `404.html` · `.nojekyll` · `app/` · `download/` · `apk/` · `assets/` · `privacy.html` · `support.html` · `vendor/`

ثم اكتب في الخانة السفلية: `Athar site` واضغط **Commit changes**.

> ⚠️ ملف `.nojekyll` لا يُرفع بالسحب في بعض المتصفحات. لو لم يظهر:
> اضغط **Add file → Create new file**، وسمِّه بالضبط `.nojekyll` (اترك محتواه فارغًا)، ثم Commit.

### 3) تفعيل Pages
- من أعلى المستودع: **Settings**
- من القائمة اليسرى: **Pages**
- تحت **Source** اختر: **Deploy from a branch**
- **Branch:** `main` · **Folder:** `/ (root)`
- اضغط **Save**

### 4) استلام الرابط (انتظر 1–3 دقائق)
```
https://USERNAME.github.io/athar-site/
```
واربط كل صفحة:
| الصفحة | الرابط |
|---|---|
| الرئيسية | `https://USERNAME.github.io/athar-site/` |
| التطبيق | `https://USERNAME.github.io/athar-site/app/` |
| تحميل APK | `https://USERNAME.github.io/athar-site/download/` |
| الخصوصية | `https://USERNAME.github.io/athar-site/privacy.html` |
| الدعم | `https://USERNAME.github.io/athar-site/support.html` |

> استبدل `USERNAME` باسم حسابك على GitHub.

---

## 🔗 روابط مهمة في متجر Play

بعد النشر، الصق هذه الروابط في **Google Play Console → Store listing**:

- **Privacy policy:** `https://USERNAME.github.io/athar-site/privacy.html`
- **Support URL:** `https://USERNAME.github.io/athar-site/support.html`
- **Website:** `https://USERNAME.github.io/athar-site/`

---

## 🔧 حل المشاكل — «الموقع لا يعمل / 404»

### ⚠️ السبب الأول والأشهر: المستودع Private على خطة مجانية

**GitHub Pages المجاني يعمل مع المستودعات العامة (Public) فقط.**
لو المستودع خاص (Private) وأنت على الخطة المجانية → الرابط سيعطي **404 دائماً**.

**الحل:**
1. افتح: `https://github.com/USERNAME/REPO/settings`
2. انزل لآخر الصفحة عند منطقة **Danger Zone**
3. اضغط **Change repository visibility** → **Change to public** → أكّد بالكتابة المطلوبة
4. ارجع لـ **Settings → Pages** وأعد اختيار `main` + `/ (root)` ثم **Save**

> ملاحظة: GitHub يرجّع 404 للمستودعات الخاصة عند فتح الرابط بدون تسجيل دخول، لذلك قد يبدو المستودع «غير موجود» رغم أنه موجود.

### الأسباب الأخرى بالترتيب

| العرض | السبب | الحل |
|---|---|---|
| 404 على كل الصفحات | المستودع Private (خطة مجانية) | اجعله Public |
| 404 على كل الصفحات | Pages غير مفعّل | Settings → Pages → main + / (root) → Save |
| 404 على كل الصفحات | اسم المستودع مكتوب بشكل مختلف | تأكد من التهجئة **حرفياً** كما في الرابط |
| 404 على كل الصفحات | لم تمرّ 1–3 دقائق بعد التفعيل | انتظر وحدّث الصفحة |
| الصفحة تفتح بدون تنسيق | `index.html` داخل مجلد فرعي | انقله لجذر المستودع |
| 404 مع أن المستودع عام | ملف `.nojekyll` ناقص | أنشئه: Add file → Create new file → `.nojekyll` |
| صفحة `/app/` فاضية | مجلد `app/` غير مرفوع كاملاً | تأكد من وجود `app/main.dart.js` و `app/canvaskit/` |
| زر APK لا يعمل | لم تنشر Release بالإصدار v1.3.0 | Releases → Draft a new release → أرفق الـAPK |

### 🔍 كيف تعرف اسم المستودع الصحيح؟

افتح: `https://github.com/USERNAME?tab=repositories`

اسم المستودع هو **الجزء الأخير** من رابطه. مثال:
`https://github.com/miskoyon-wq/athar-volunteer-` → الاسم هو `athar-volunteer-`

ثم رابط موقعك يكون بالضبط:
`https://miskoyon-wq.github.io/athar-volunteer-/`

> ⚠️ **انتبه للشرطة `-` في نهاية الاسم** — لو نُسيت أو زادت، الرابط كله لا يعمل.

---

## 💡 معلومة مهمة: اسم المستودع لا يهم

الحزمة **لا تعتمد** على اسم مستودع معيّن:
- كل الروابط داخل الموقع **نسبية** (`app/` · `download/` · `../assets/`) فتعمل تحت أي اسم وأي نطاق.
- زر تحميل الـAPK **يستنتج** رابط الإصدارات تلقائياً من رابط الصفحة نفسها.

يعني: `athar-volunteer-` أو `athar-site` أو أي اسم آخر — **كله شغّال**.

الاستثناء الوحيد: لو سمّيت المستودع بنفس اسم المستخدم + `.github.io` (موقع شخصي).
في هذه الحالة فقط، افتح `download/index.html` واكتب الرابط في المتغير `APK_URL_OVERRIDE`.

---

## ✅ تحقق سريع بعد النشر

- [ ] الصفحة الرئيسية تفتح ويظهر الشعار بالذهبي والأخضر.
- [ ] زر «افتح التطبيق الآن» ينقلك إلى `/app/` ويحمّل التطبيق.
- [ ] زر «حمّل التطبيق الآن (APK)» يبدأ تنزيل الملف (~53 ميجا).
- [ ] رمز QR يظهر في صفحة التحميل (وفيه الشعار في المنتصف).
- [ ] صفحة الخصوصية وصفحة الدعم تفتحان بدون أخطاء.
- [ ] الصفحة تظهر **بالعربي من اليمين لليسار**.

---

## 🎨 الهوية البصرية

| العنصر | القيمة |
|---|---|
| اللون الأخضر الأساسي | `#0B4A2E` |
| الأخضر الداكن | `#062A1B` |
| الذهبي | `#C9A227` |
| الخط | Segoe UI / Tahoma / system-ui |

---

## 📄 معلومات التطبيق

- **الاسم:** أثر — بوابة التطوع الذكية
- **معرّف الحزمة:** `com.atharvolunteer.portal`
- **الإصدار:** `1.3.0+4`
- **الحد الأدنى:** أندرويد 6.0 (API 23)
- **بصمة SHA-256:** `e3b12f768d2eedb0602a0ec3f3562d4…`

© أثر — بوابة التطوع
