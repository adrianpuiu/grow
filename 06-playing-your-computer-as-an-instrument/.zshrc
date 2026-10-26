# ══ GROW Lesson 06 — Shell DX starter (.zshrc) — Ubuntu-adapted from the brew guide ══

# ── History (Part 1) ──
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # treat '!' specially during expansion
setopt EXTENDED_HISTORY          # ":start:elapsed;command" format
setopt INC_APPEND_HISTORY        # write history immediately, not at exit
setopt SHARE_HISTORY             # share history across sessions
setopt HIST_EXPIRE_DUPS_FIRST    # trim duplicates first

# ── Completion (Part 3 — load BEFORE plugins/highlighting) ──
autoload -U compinit; compinit
source <(kubectl completion zsh)
compdef _kubectl k

[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
  source /usr/share/doc/fzf/examples/key-bindings.zsh   # Ctrl-R fuzzy history (fzf)

# ── krew plugins (Part 4) ──
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# ── Aliases: cut keystrokes, keep intent (Part 3) ──
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kga='kubectl get all'
alias kgn='kubectl get nodes -o wide'
alias kgp='kubectl get pods -o wide'
alias kl='kubectl logs'
alias kx='kubectl exec -it'
alias kctx='kubectx'
alias kns='kubens'
alias kap='kubectl apply -f'
alias kdry='kubectl -o yaml --dry-run=client'
alias bat='batcat'               # Ubuntu names the binary batcat

# ── Editor for kubectl edit (Part 5) ──
export KUBE_EDITOR="${KUBE_EDITOR:-nano}"

# ── Prompt awareness (Part 2 — shows cluster/namespace, prevents wrong-cluster mistakes) ──
eval "$(${HOME}/.local/bin/starship init zsh)"

# ── Autosuggestions & syntax highlighting (Part 3 — syntax highlighting MUST load LAST) ──
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
