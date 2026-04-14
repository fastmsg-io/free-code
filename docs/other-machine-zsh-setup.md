# إعداد free-code على جهاز آخر (مستخرج من `~/.zshrc`)

هذا الملف يلخص **الإعدادات الخاصة بمشروع free-code** من صدفة zsh لنسخها على جهاز جديد. المسارات مُعمّمة؛ **لا تُلصق مفاتيح حقيقية في مستودع Git**.

## المتطلبات

- [Bun](https://bun.sh) ≥ 1.3.11 (مثلاً: `curl -fsSL https://bun.sh/install | bash`)
- بناء المشروع على الجهاز الجديد: من جذر المستودع نفّذ `bun install` ثم `bun run build:dev` (أو `bun run build`) حسب ما تستخدم
- الملف التنفيذي: غالبًا `./cli-dev` بعد `build:dev`، أو `./cli` بعد `build` — عدّل المسار في الدوال أدناه ليطابق موقع استنساخك (مثلاً `$HOME/projects/free-code/cli-dev`)

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
| `FREE_LOCAL_MODEL` | اختياري — افتراضي الدالة: `glm-5.1:cloud` |
| `FREE_LOCAL_OLLAMA_MODELS` | اختياري — قائمة النماذج مفصولة بفواصل لاستخدامها داخل الجلسة |

**مثال قالب (استبدل الأسرار يدويًا على الجهاز الآخر):**

```bash
export FREE_LOCAL_FASTMSG_TOKEN='<YOUR_FASTMSG_PATH_TOKEN>'
# أو: export FREE_LOCAL_ANTHROPIC_BASE_URL='https://...'
# export FREE_LOCAL_API_KEY='sk-local'
```

### دالة `free-local`

انسخ الدالة وعدّل المسار المطلق إلى الثنائي ليطابق جهازك:

```bash
free-local() {
  local model="${FREE_LOCAL_MODEL:-glm-5.1:cloud}"
  local base
  if [[ -n "${FREE_LOCAL_ANTHROPIC_BASE_URL}" ]]; then
    base="${FREE_LOCAL_ANTHROPIC_BASE_URL}"
  elif [[ -n "${FREE_LOCAL_FASTMSG_TOKEN}" ]]; then
    local t="${FREE_LOCAL_FASTMSG_TOKEN#/}"
    base="https://ollama.fastmsg.io/${t}"
  else
    echo 'free-local: عرّف FREE_LOCAL_FASTMSG_TOKEN أو FREE_LOCAL_ANTHROPIC_BASE_URL.' >&2
    return 1
  fi
  local key="${FREE_LOCAL_API_KEY:-sk-local}"
  local ollama_models="${FREE_LOCAL_OLLAMA_MODELS:-glm-5.1:cloud,gemma4:31b-cloud,minimax-m2.7:cloud,qwen3.5:cloud,qwen3-coder-next:cloud}"
  env -u ANTHROPIC_API_KEY -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN \
    ANTHROPIC_API_KEY="$key" \
    ANTHROPIC_AUTH_TOKEN="${FREE_LOCAL_ANTHROPIC_AUTH_TOKEN:-ollama}" \
    ANTHROPIC_BASE_URL="$base" \
    FREE_LOCAL_OLLAMA_MODELS="$ollama_models" \
    CLAUDE_CONFIG_DIR="$HOME/.free-code" \
    "$HOME/path/to/free-code/cli-dev" --bare --model "$model" "$@"
}
```

**ملاحظات:**

- التشغيل المحلي لـ Ollama: يمكنك استدعاء `FREE_LOCAL_ANTHROPIC_BASE_URL=http://localhost:11434 free-local` (حسب إعداد الخادم لديك).
- داخل الجلسة: `/model` لقائمة النماذج أو `/model <اسم_النموذج>`.

## free-code + OpenRouter (`samer-coder`)

**الفكرة:** توجيه الطلبات عبر `https://openrouter.ai/api` باستخدام مفتاح OpenRouter، مع `CLAUDE_CONFIG_DIR="$HOME/.samer-coder"`.

### متغير مطلوب على الجهاز الجديد

```bash
export OPENROUTER_API_KEY='<YOUR_OPENROUTER_API_KEY>'
```

(احصل على المفتاح من [OpenRouter Keys](https://openrouter.ai/keys) — **لا تُرفع القيمة للمستودع**.)

### دالة `samer-coder`

```bash
samer-coder() {
  [[ -n "${OPENROUTER_API_KEY}" ]] || {
    echo 'samer-coder: عرّف OPENROUTER_API_KEY أولاً.' >&2
    return 1
  }
  local model="${SAMER_CODER_MODEL:-minimax/minimax-m2.7}"
  env -u ANTHROPIC_API_KEY -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN \
    ANTHROPIC_BASE_URL="https://openrouter.ai/api" \
    ANTHROPIC_API_KEY="$OPENROUTER_API_KEY" \
    ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY" \
    CLAUDE_CONFIG_DIR="$HOME/.samer-coder" \
    "$HOME/path/to/free-code/cli-dev" --bare --model "$model" "$@"
}
```

**اختياري:** `export SAMER_CODER_MODEL=anthropic/claude-sonnet-4` (أو أي معرّف نموذج مدعوم على OpenRouter).

## فصل الإعدادات عن Claude Code الرسمي

كلا الدالتين تضبطان `CLAUDE_CONFIG_DIR` إلى مجلد مخصص (`~/.free-code` أو `~/.samer-coder`) حتى لا تتداخل مع تكوين Claude Code الافتراضي.

## ما لم يُوثَّق هنا

ملف `~/.zshrc` الأصلي يحتوي أيضًا على إعدادات عامة (Oh My Zsh، Android SDK، Homebrew، pyenv، مسارات أدوات أخرى) **لا علاقة لها بـ free-code**. انسخ فقط الأقسام أعلاه إن أردت إعادة نفس سلوك free-code على جهاز آخر.

---

**أمان:** راجع أن الملفات السرية غير مضمّنة في Git (`.env` محلي، `~/.zshrc` لا يُرفع عادةً). استبدل كل `<...>` بقيم من لوحات التحكم أو من جهازك الآمن.
