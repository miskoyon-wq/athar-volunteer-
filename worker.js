// إيثار — Cloudflare Worker entry point
// يقدّم موقع سياسة الخصوصية وصفحة حذف الحساب كملفات ثابتة.
export default {
  async fetch(request, env) {
    return env.ASSETS.fetch(request);
  },
};
