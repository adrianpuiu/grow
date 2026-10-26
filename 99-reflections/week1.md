# Week 1 Reflection – NGINX Pod and Deployment

This week, I worked through the Kubernetes fundamentals lab where I deployed a basic NGINX web server using both a Pod and a Deployment. I also learned about security contexts and how to scale workloads.

---

## ✅ What I Learned

- A Pod's spec is **immutable**: changing `securityContext` on a live Pod fails with `Forbidden — pod updates may not change fields...`. The only fix is delete + re-create.
- The real ownership chain is **Deployment → ReplicaSet → Pod**. Deployment sets strategy, ReplicaSet owns the replica count, the Pod is just the atom.
- `spec.selector.matchLabels` must match `spec.template.metadata.labels` — that invisible wire is how the ReplicaSet finds its Pods.
- Labels answer *searches* (`-l app=nginx`); `ownerReferences` answer *who fixes me*. My bare `nginx` Pod matched the label query but had no owner — nobody replaces it when it dies.
- Self-healing is real: I deleted a Deployment Pod and a **new** Pod (not a restart) appeared ~10s later, with the `securityContext` baked in from the template.

---

## ❓ What Was Challenging

- The immutable-Pod error message is huge and scary, but it literally lists the only mutable fields (`image`, `activeDeadlineSeconds`, `tolerations`, ...).
- Realizing that a bare Pod deleted in Lesson 00 stayed dead — that's *why* Deployments exist.

---

## 🧪 Commands I Practiced

```bash
kubectl apply -f nginx-pod.yaml
kubectl apply -f nginx-deployment.yaml
kubectl scale deployment nginx-deployment --replicas=3
kubectl get pod nginx -o jsonpath='{.metadata.ownerReferences[*].kind}'   # empty for bare pod, ReplicaSet for managed
kubectl delete pod nginx-deployment-76bc659fc8-7wv2x    # watch the replacement appear
```

---

## 🔐 Security Improvements I Made

- Added `securityContext` (`runAsNonRoot: true`, `allowPrivilegeEscalation: false`) to `nginx-pod.yaml` — verified with `kubectl get pod nginx -o jsonpath='{.spec.containers[0].securityContext}'`.
- Learned the difference between a safe *image* (nginx-unprivileged runs as UID 101) and *enforcement* (the cluster now rejects root for this Pod).

---

## 📝 Questions I Still Have

- During a rolling update, how does the Deployment sequence old/new ReplicaSets and wait for readiness?

---

## 📎 Related YAMLs

- `nginx-pod.yaml`
- `nginx-deployment.yaml`

---

## 🚀 Looking Ahead

I'm excited to explore GitOps in Week 2 and automate deployments using FluxCD.
