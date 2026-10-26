# Week 2 Reflection – GitOps with FluxCD

This week, I set up GitOps in my cluster using **FluxCD**. I bootstrapped my own repository, created a Git source and a Kustomization, and learned how declarative workflows can automate and standardize Kubernetes operations.

---

## ✅ What I Learned

- Flux's anatomy: a **GitRepository** source (source-controller clones it, SSH key from a Secret) feeds a **Kustomization** (kustomize-controller runs `kustomize build`, then server-side-applies). Each is just a CRD + controller — the same pattern as everything else in Kubernetes.
- The pull model is the security model: the cluster pulls Git; humans never `kubectl apply`. Deploy keys are read-only for the cluster.
- **Drift correction**: I scaled a Deployment to 8 replicas manually; Flux reverted it to Git's declared 2 within one 15s poll cycle. No error, no prompt — Git just wins.
- Fix-by-commit: a broken manifest (missing `namespace:`) was fixed by committing, and the cluster converged ≤20s later. Nothing was typed "at the cluster".

---

## ❓ What Was Challenging

- `flux create kustomization` **hangs forever** if the reconciliation fails (it watches for Ready). Diagnose separately with `kubectl describe kustomization nginx-app -n flux-system`.
- Namespace defaulting: a manifest without `namespace:` was looked up in `flux-system` (the Kustomization's namespace), not `default`. The lab guide's example manifest has this same latent bug.
- Flux 2.9 dropped support for raw `git://` URLs (only `ssh`/`http`/`https`) — the guide's flow predates this. I replicated `flux bootstrap`'s real behavior instead: `flux install` + SSH deploy key + `flux create source git --secret-ref=...`.

---

## 🧪 Commands I Practiced

```bash
flux install
flux create secret git git-auth --url=ssh://... --private-key-file=...
flux create source git grow-ops --url=ssh://... --secret-ref=git-auth --branch=main --interval=15s
flux create kustomization nginx-app --source=GitRepository/grow-ops --path=./apps --interval=15s --prune=true
flux get sources git && flux get kustomizations
kubectl describe kustomization nginx-app -n flux-system      # when the watch hangs
kubectl scale deployment nginx-deployment --replicas=8       # ...watch Flux revert it
```

---

## 🔁 GitOps Impact

- Audit trail = `git log`. "Who changed the cluster" is answered by history, not memory.
- Disaster recovery = clone the repo into a new cluster. The cluster state is reproducible.
- Manual `kubectl` changes are now *temporary by design* — drift is reverted, which forces the good habit: change Git, not the cluster.

---

## 📝 Questions I Still Have

- How do GitOps workflows handle **secrets** (they must not sit in plain Git)? Looking at SOPS/sealed-secrets next.
- How does `prune: true` decide what to delete when a manifest is removed?

---

## 📎 Related Files

- `~/Downloads/flux-ops/apps/` (local GitOps repo: `deployment.yaml`, `kustomization.yaml`)
- Bootstrap settings used: `flux install`, source `grow-ops`, kustomization `nginx-app` (in a real setup: `flux bootstrap github --owner=... --path=clusters/dev --personal`)

---

## 🚀 Looking Ahead

I'm curious to explore how GitOps handles secrets, multi-cluster environments, and policy-based validations using tools like SOPS, Kyverno, or Vault.
