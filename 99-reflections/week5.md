# 📓 Week 5 Reflection — Working with Persistent Storage

---

## ✅ What I Learned

- The storage trinity: **StorageClass** (provisions disks on demand) → **PVC** (my request: "1Gi") → **PV** (a real directory on the node's disk, named after the PVC).
- `WaitForFirstConsumer`: the PVC sat `Pending` — *by design* — until the Postgres Pod actually used it, so the volume could be created on the Pod's node. The event text said exactly this.
- **State lives on the volume, not the Pod.** I wrote a row into Postgres, deleted the Pod, and queried the row from its replacement (different pod hash, same data). The PV directory was visible on the node at `/var/local-path-provisioner/pvc-…`.
- `POSTGRES_PASSWORD` is **init-time-only**: Postgres ignores it when the data directory already exists. Changing the env later does nothing without wiping the PVC.
- Secret `data` is **base64, not encryption** — one `kubectl get secret -o jsonpath` + `base64 -d` away from plaintext. The win is git-safety, RBAC separation, and rotation, not confidentiality.

---

## ❌ What Was Challenging

The lab bonus detonated for real: I scaled Postgres to 2 replicas and got **two live database servers on the same data directory** — each running crash-recovery against the other's WAL. Not a crash-loop, not an error: **green checkmarks over silent corruption**. The trap: `ReadWriteOnce` means once per **node**, not once per Pod — and on a single-node kind cluster, both Pods mount it happily. A Deployment coordinates replicas, *not storage*. That's the exact problem StatefulSets solve (stable identity + one volume per replica).

---

## 🔍 Commands I Practiced

```bash
kubectl apply -f postgres-pvc.yaml && kubectl describe pvc postgres-pvc   # watch Pending → Bound
kubectl exec deploy/postgres -- psql -U postgres -c "CREATE TABLE lessons ...; INSERT ..."
kubectl delete pod -l app=postgres && kubectl exec deploy/postgres -- psql -U postgres -c "SELECT * FROM lessons;"
kubectl logs <new-pod>     # "database system was not properly shut down; automatic recovery"
kubectl scale deployment postgres --replicas=2   # ...then back to 1, fast
```

---

## 💡 Real-World Takeaways

- Nearly every stateful workload needs `StatefulSet`, not `Deployment` — now I've seen the failure mode that justifies it.
- Secrets in plain env vars are readable by anyone with `kubectl get` and live in git history forever. The proper fix (homework): `secretKeyRef` + PVC-wipe caveats on rotation.

---

## 📣 What I Shared

Not yet posted — the two-postgres corruption story is the one worth sharing (screenshots of green pods + recovery logs).

---

## 🧠 Questions I Still Have

- How do `volumeClaimTemplates` in a StatefulSet keep one PVC per replica, and what happens on scale-down?
- What does `reclaimPolicy: Delete` vs `Retain` mean when a PVC is removed?
