---
name: GROW Labs Playbook
description: Operational playbook for running the KubeSkills GROW Kubernetes labs (00-06) on this Ubuntu machine — tooling setup, snap-docker kind quirks, two-cluster strategy, Flux GitOps without GitHub tokens, ingress node label, PSA and storage gotchas. Use when setting up the lab environment, creating/deleting kind clusters, running Flux demos, or walking a student through the labs in this repo.
---

# GROW Labs Playbook

Companion to `AGENTS.md` (repo conventions, exercise-preservation rules). This skill is the *how to run it on this machine* part.

## Environment facts (this machine)

- Ubuntu; Docker is the **snap** package → there is **no `docker` group**. `kind`/`docker` commands need sudo, and root's PATH misses both `~/.local/bin` and `/snap/bin`.
- `kubectl` and `kind` are installed in `~/.local/bin`.
- Never put the sudo password in any file. Ask the user to run sudo commands themselves, or have them provide it for `sudo -S` stdin use.
- After a sudo-run `kind create cluster`, fix kubeconfig ownership: `sudo chown -R $USER ~/.kube`.
- Git identity: repo-local `user.name=adrianpuiu`, `user.email=adrianpuiu@users.noreply.github.com` (user may change it).
- MkDocs runs from the repo's `.venv/` (PEP 668 blocks user-wide pip): `.venv/bin/mkdocs serve`.

## Kind command pattern (snap docker)

```bash
echo '<sudo-password>' | sudo -S env HOME="$HOME" \
  PATH="$HOME/.local/bin:/snap/bin:/usr/bin:/bin" \
  "$HOME/.local/bin/kind" create cluster --name <name> [--config <config.yaml>]
sudo chown -R "$USER" ~/.kube
```

Plain `kind ...` fails with "permission denied ... docker.sock"; sudo without PATH fix fails with `kind: No such file or directory`.

## Two-cluster strategy

- **`grow-lab`** — Flux/GitOps demo cluster (Lab 02). Keep it; it shows Flux self-healing (`flux-system` ns).
- **`grow-ingress`** — created with `04-services-ingress/kind-config.yaml` (maps host 80/443). kind cannot add port mappings to an existing cluster; a second cluster beats recreating.
- Switch contexts with `kubectl config use-context` or `kubectx`; check with `kubectl config get-contexts`.

## Flux GitOps without GitHub tokens (Lab 02 pattern)

`flux bootstrap github` needs a PAT; this local pattern teaches the same concepts:

1. `flux install` (CLI at `~/.local/bin/flux`).
2. Ops repo at `~/Downloads/flux-ops` (`apps/deployment.yaml` + `apps/kustomization.yaml` entrypoint — kustomize-controller requires a `kustomization.yaml` in the target dir).
3. Serve it: `git daemon --base-path=~/Downloads --export-all --reuseaddr --port=9418` (background; symlink `flux-ops.git` → `flux-ops` because git-daemon appends `.git`).
4. **Flux ≥2.9 rejects `git://` URLs** (ssh/http/https only). Use SSH: generate a keypair, append the pub key to `~/.ssh/authorized_keys`, then:
   `flux create secret git git-auth -n flux-system --url=ssh://agp@<kind-bridge-gateway-IP>/home/agp/Downloads/flux-ops --private-key-file=<key>`
5. `flux create source git ... --secret-ref=git-auth --interval=15s` and `flux create kustomization ... --prune=true`.
- Kind bridge gateway IP: `sudo docker network inspect kind --format '{{range .IPAM.Config}}{{.Gateway}} {{end}}'` (IPv6 and IPv4 both exist; prefer IPv4, e.g. 172.20.0.1). sshd must be reachable from the bridge (test `/dev/tcp/<ip>/22`).

## Lab-specific gotchas

- **Lab 02**: `flux create kustomization` **hangs forever** when reconciliation fails (it waits for Ready). Diagnose with `kubectl describe kustomization <name> -n flux-system`. Manifests without `namespace:` are looked up in the Kustomization's namespace (flux-system), not `default`.
- **Lab 03**: `baseline` PSA does NOT block root; `restricted` also requires `seccompProfile` (our `secure-pod.yaml` now passes). Revert PSA labels after demos — Lab 05's postgres runs as root and would break. NetworkPolicy `deny-all-ingress` must be deleted before Lab 04 (it blocks the ingress test).
- **Lab 04**: the kind-provider ingress-nginx manifest pins `nodeSelector: ingress-ready=true` — **label the node** (`kubectl label node <cluster>-control-plane ingress-ready=true`) or the controller sits Pending with "didn't match Pod's node affinity/selector". Empty Ingress `ADDRESS` on kind is cosmetic. `/etc/hosts` gets `127.0.0.1 web.example.com` (sudo; line persists after labs).
- **Lab 05**: PVC `Pending` with event `WaitForFirstConsumer` is normal until a Pod consumes it. `POSTGRES_PASSWORD` is **init-time-only** (ignored when the data dir exists). **Never scale postgres Deployment to 2**: RWO is per-*node*, so both Pods mount the same volume → two live postgres servers doing crash-recovery against each other = silent corruption with green status.
- **Lab 06**: `~/.zshrc` and `~/.config/starship.toml` are written (Ubuntu paths: `/usr/share/zsh-*`, `bat`→`batcat`); zsh is NOT the default shell — user must run `chsh -s $(which zsh)` themselves.

## Habits to keep applying

- Verify after every mutate: `kubectl exec … id`, `kubectl get endpoints`, `--show-labels`, describe events.
- Read scheduler/admission error text verbatim — it names the fix.
- Don't pipe cleanup errors to `/dev/null`; confirm deletes (`kubectl get` after).
- Preserve intentional exercise gaps in manifests (see `AGENTS.md` — "Don't pre-solve exercises").
