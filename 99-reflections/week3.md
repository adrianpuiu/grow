# Week 3 Reflection – Kubernetes Security

---

## ✅ What I Learned

- A `securityContext` in a manifest is a **promise, not a law**: I removed the run-as settings and the cluster accepted a root Pod (`uid=0`) without a single warning. Enforcement needs **Pod Security Admission** (labels on the namespace).
- `baseline` does **not** block root — it blocks privileged mode, host namespaces, hostPath. Blocking root needs `restricted`.
- The layered settings I verified live: `runAsUser: 1000` (via `id`), `capabilities.drop: ALL` (`CapEff: 0000000000000000`), `readOnlyRootFilesystem` (`touch /` → `Read-only file system`), plus pod-level `runAsNonRoot`.
- `restricted` also requires `seccompProfile: RuntimeDefault` — the lab's own "hardened" Pod failed until I added it (pod-level).
- Networking is **default-allow**: any Pod can reach any Pod until a NetworkPolicy denies it. `podSelector: {}` + `policyTypes: [Ingress]` denied ingress for the entire namespace, instantly.
- Labeling a namespace to `restricted` prints warnings listing every existing Pod that violates the new level — admission audits on transition.

---

## ❓ What Was Challenging

- Which level owns which field: pod-level `securityContext` vs container-level (container wins on conflicts).
- My own two mistakes, logged for posterity: `kubectl exec` before the container was ready (`container not found`), and piping cleanup errors to `/dev/null` — a failed NetworkPolicy delete *looked* successful until traffic stayed blocked.
- Leaving `restricted` enabled would break later labs (postgres image runs as root): PSA profiles are applied per-namespace, deliberately, when workloads are ready.

---

## 🧪 Commands I Practiced

```bash
kubectl exec secure-pod -- id                                   # uid=1000
kubectl exec secure-pod -- sh -c 'grep CapEff /proc/self/status'
kubectl label namespace default pod-security.kubernetes.io/enforce=baseline
kubectl label namespace default pod-security.kubernetes.io/enforce=restricted --overwrite
kubectl apply -f network-policy.yaml                            # deny-all-ingress
kubectl exec netpol-client -- wget -T 5 -qO- http://<podIP>:8080
```

---

## 🔐 Security Awareness Gained

- Defense in depth: safe image + explicit securityContext + PSA enforcement + NetworkPolicy — each layer catches what the previous misses.
- Verification beats hope: every setting should be *proven* from inside the container (`exec`, `/proc/self/status`).

---

## 🧠 Real-World Relevance

Nearly every production incident story I've read started with "it ran as root" or "everything could talk to everything". These two controls are cheap to add and eliminate entire attack classes.

---

## 📎 Related Files

- `secure-pod.yaml` (hardened; seccompProfile added this week)
- `network-policy.yaml`
- `/tmp` test Pods: `root-pod.yaml` (the "breaking it" exercise)

---

## 📝 Questions I Still Have

- What does a per-workload NetworkPolicy look like in practice (default-deny namespace + explicit allows per app)?
- How do teams roll out `restricted` across existing namespaces without breaking everything?

---

## 🧠 Bonus Reflection

Falco/Kyverno exploration is still open (bonus badge material).

---

## 🚀 What's Next

Services and Ingress — giving the app a real front door.
