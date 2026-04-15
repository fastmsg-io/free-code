# إعداد free-code على جهاز آخر (مستخرج من `~/.zshrc`)

هذا الملف يلخص **الإعدادات الخاصة بمشروع free-code** من صدفة zsh لنسخها على جهاز جديد. المسارات مُعمّمة؛ **لا تُلصق مفاتيح حقيقية في مستودع Git**.

## المتطلبات

- [Bun](https://bun.sh) ≥ 1.3.11 (مثلاً: `curl -fsSL https://bun.sh/install | bash`)
- بناء المشروع على الجهاز الجديد: من جذر المستودع نفّذ `bun install` ثم `bun run build:dev` (أو `bun run build`) حسب ما تستخدم
- الملف التنفيذي: غالبًا `./cli-dev` بعد `build:dev`، أو `./cli` بعد `build`

## نقطة دخول واحدة في `~/.zshrc`

بدل وضع كل الدوال في `~/.zshrc`، اجعل الملف يحوي فقط سطر التحميل:

```bash
source "$HOME/path/to/free-code/scripts/free-code-shell.zsh"
```

ولكي تبقى متغيرات `free-local` داخل المشروع أيضًا، أنشئ ملفًا محليًا:

`$HOME/path/to/free-code/.env`

مثال:

```bash
FREE_LOCAL_FASTMSG_TOKEN=<YOUR_FASTMSG_PATH_TOKEN>
```

اختياري (لتجاوز المسار أو اختيار ثنائي مختلف مثل `cli` بدل `cli-dev`):

```bash
export FREE_CODE_ROOT="$HOME/path/to/free-code"
# export FREE_CODE_BIN="$FREE_CODE_ROOT/cli"
```

## متغيرات Bun (اختياري لكن مفيد)

يضيف Bun نفسه عادةً هذه الأسطر عند التثبيت:

```bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# إكمال الأوامر (إن وُجد الملف):
# [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
```

## free-code + Ollama / Fastmsg (`free-local`)

**الفكرة:** جلسة `free-code` تستخدم `ANTHROPIC_BASE_URL` نحو خادم متوافق مع واجهة Anthropic (مثل Ollama محليًا أو سحابة Fastmsg)، مع مجلد إعدادات منفصل `~/.free-code` حتى لا تختلط مع Claude Code الرسمي.

### متغيرات بيئة (ضع القيم السرية على الجهاز الجديد فقط — لا تُرفع للمستودع)

| المتغير | الوصف |
|---------|--------|
| `FREE_LOCAL_FASTMSG_TOKEN` | **سرّ** — جزء المسار لـ Fastmsg. بديل: تعريف `FREE_LOCAL_ANTHROPIC_BASE_URL` كاملًا |
| `FREE_LOCAL_ANTHROPIC_BASE_URL` | اختياري — إن عرّفته، يتجاوز بناء الرابط من التوكن |
| `FREE_LOCAL_API_KEY` | اختياري — المفتاح الذي يرسله العميل (الافتراضي في الدالة: `sk-local`) |
| `FREE_LOCAL_ANTHROPIC_AUTH_TOKEN` | اختياري — افتراضي الدالة: `ollama` |
| `FREE_LOCAL_MODEL` | اختياري — افتراضي الدالة: `minimax-m2.7:cloud` |
| `FREE_LOCAL_OLLAMA_MODELS` | اختياري — قائمة النماذج مفصولة بفواصل لاستخدامها داخل الجلسة |

**مثال قالب (استبدل الأسرار يدويًا على الجهاز الآخر):**

```bash
FREE_LOCAL_FASTMSG_TOKEN=<YOUR_FASTMSG_PATH_TOKEN>
# أو: FREE_LOCAL_ANTHROPIC_BASE_URL=https://...
# FREE_LOCAL_API_KEY=sk-local
```

### دالة `free-local`

الدالة أصبحت موجودة داخل المشروع في:

`scripts/free-code-shell.zsh`

بعد إضافة سطر `source` أعلاه، يصبح الأمر `free-local` متاحًا مباشرة.

**ملاحظات:**

- التشغيل المحلي لـ Ollama: يمكنك استدعاء `FREE_LOCAL_ANTHROPIC_BASE_URL=http://localhost:11434 free-local` (حسب إعداد الخادم لديك).
- داخل الجلسة: `/model` لقائمة النماذج أو `/model <اسم_النموذج>`.

## فصل الإعدادات عن Claude Code الرسمي

الدالة `free-local` تضبط `CLAUDE_CONFIG_DIR="$HOME/.free-code"` حتى لا تتداخل مع تكوين Claude Code الافتراضي.

## ما لم يُوثَّق هنا

ملف `~/.zshrc` الأصلي يحتوي أيضًا على إعدادات عامة (Oh My Zsh، Android SDK، Homebrew، pyenv، مسارات أدوات أخرى) **لا علاقة لها بـ free-code**. انسخ فقط الأقسام أعلاه إن أردت إعادة نفس سلوك free-code على جهاز آخر.

---

**أمان:** راجع أن الملفات السرية غير مضمّنة في Git (`.env` محلي، `~/.zshrc` لا يُرفع عادةً). استبدل كل `<...>` بقيم من لوحات التحكم أو من جهازك الآمن.
