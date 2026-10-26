# 📓 Week 6 Reflection — Playing your computer like an instrument

In Week 6 of the GROW program, I tuned the shell that drives everything else: zsh with completions, shared history, syntax highlighting, a cluster-aware prompt, and kubectl plugins.

---

## ✅ What I Learned

- **The prompt is a safety feature.** `starship`'s Kubernetes module shows `⛵ cluster (namespace)` before every command — I ran two clusters this week, and "which cluster am I mutating?" stopped being a guess.
- `kubectx`/`kubens` (and krew's `ctx`/`ns`) flip contexts/namespace in one keystroke; the kubeconfig is just an address book I can switch.
- `krew` is to kubectl what apt is to the OS: `kubectl krew install ctx ns neat` in seconds.
- The **generate → inspect → apply** habit: `k create deploy ... --dry-run=client -o yaml | kubectl neat` — never hand-write what you can render.
- The lab guide is written for macOS (`brew`); the whole thing translates to Ubuntu (`apt install zsh fzf bat jq kubectx zsh-autosuggestions zsh-syntax-highlighting`, starship via script, `bat` → `batcat`).

---

## ❌ What Was Challenging

- Loading order in `.zshrc` matters: completions before plugins, **syntax highlighting last**.
- Translating brew paths (`/opt/homebrew/share/...`) to apt paths (`/usr/share/...`) — the guide's non-Ubuntu paths silently fail if you copy-paste.

---

## 🔍 Commands I Practiced

```bash
kubectl krew install ctx ns neat
kubectx                       # lists kind-grow-lab, kind-grow-ingress; one keypress to switch
k create deploy demo-app --image=nginxinc/nginx-unprivileged:stable --dry-run=client -o yaml | kubectl neat
k get deploy -o json | kubectl neat | bat -l yaml
```

---

## 💡 Real-World Takeaways

Absolutely — the wrong-cluster mistake is the #1 self-inflicted Kubernetes incident, and a prompt-level reminder costs nothing. Sharing history across terminals means closing a window no longer loses the fix I just typed. Version-controlling my dotfiles (`.zshrc`, `starship.toml`) is next so the whole instrument is reproducible — same idea as GitOps, for the operator.

---

## 📣 What I Shared

Not yet posted.

---

## 🧠 Questions I Still Have

- Is `atuin` (searchable, synced shell history) worth the extra moving part?
- Do teams standardize aliases/dotfiles (a shared "starter .zshrc"), or is that personal territory?
