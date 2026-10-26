# Week 4 Reflection – Services and Ingress

---

## ✅ What I Learned

- A **Service** is a stable virtual IP (never changes) plus a live "phone book" of Pod IPs (`kubectl get endpoints`) maintained by watching labels. Pod dies → phone book updates → nobody notices.
- `kubectl port-forward` is a dev-loop tunnel, not production plumbing — perfect for verifying the Service before adding Ingress.
- The Ingress Controller is just a Pod running nginx that *watches* Ingress resources and rewrites its config. I proved routing is by **Host header**: `curl web.example.com` → 200, same port without the hostname → 404.
- The full traffic chain on kind: hosts file → host port 80 → node container (extraPortMappings) → controller pod (hostPort) → Ingress rule → Service VIP → Pod.
- One `~/.kube/config` can hold **multiple clusters** (contexts). I ran two clusters this week and switched between them — the "address book" from Lesson 00, made real.

---

## ❓ What Was Challenging

- The controller sat `Pending` for 5 minutes: the kind-provider manifest pins it with `nodeSelector: ingress-ready=true`, and nobody labels the node. **The FailedScheduling event told me exactly that** — read scheduler errors first.
- Empty Ingress `ADDRESS` on kind is cosmetic; test the actual path instead of trusting status fields.

---

## 🧪 Commands I Practiced

```bash
kubectl apply -f web-pod.yaml -f web-service.yaml -f web-ingress.yaml
kubectl get svc web && kubectl get endpoints web
kubectl port-forward svc/web 8080:80
kubectl label node grow-ingress-control-plane ingress-ready=true
curl -H "Host: wrong.example.com" http://127.0.0.1    # 404 proves Host-based routing
kubectl config get-contexts
```

---

## 🌐 Concepts I Better Understand Now

- ClusterIP vs NodePort vs LoadBalancer vs Ingress — a spectrum from "stable internal VIP" to "one gateway that routes many hostnames/paths over the same entrypoint".
- Why the guide's objectives mention NodePort but the manifests never use it: Cloud LoadBalancers are out of scope on kind.

---

## 💡 How I Might Use This in the Real World

One Ingress Controller per cluster, dozens of Ingress rules by hostname/path — that's how a single entrypoint serves a whole company. And the `ingress-ready` label debugging is exactly the kind of scheduler-event reading real on-calls do daily.

---

## 📝 Questions I Still Have

- TLS termination: where does the certificate live, and who renews it (cert-manager)?
- How do gateways like Envoy/KGateway compare to ingress-nginx?

---

## 📎 Related YAMLs

- `web-pod.yaml`, `web-service.yaml`, `web-ingress.yaml`, `kind-config.yaml`

---

## 🚀 What's Next

Persistent storage — making an app that survives pod death.
