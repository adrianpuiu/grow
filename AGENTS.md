# AGENTS.md

Guidance for AI coding agents working in this repo. (Mirrors `CLAUDE.md`; keep the two in sync.)

## What this repo is

KubeSkills **GROW**: a template students fork to build a public Kubernetes learning portfolio. No app code, no test suite — content is Markdown lab guides, Kubernetes manifests, and reflection templates. This checkout is a fork (`adrianpuiu/grow`) of `kubeskills/grow`; older docs/links still say `kubeskills/student-notebook`.

## Commands

```bash
pip install mkdocs mkdocs-material
mkdocs serve                     # preview at http://localhost:8000
mkdocs build -d site --strict    # use --strict locally to surface broken nav/links; CI builds WITHOUT it

kind create cluster --name grow-lab
kind create cluster --config 04-services-ingress/kind-config.yaml  # Lab 04: maps host ports 80/443 for ingress
kubectl apply -f <NN-topic>/<manifest>.yaml
```

Pushing to `main` triggers `.github/workflows/deploy.yaml`, which builds MkDocs and deploys via GitHub Actions Pages. The README's "Settings > Pages, branch: main, folder: /docs" instructions are stale — that is not how deployment works.

## Structure and conventions

- Labs are numbered folders `NN-topic/` (`00`–`06`), each with a `lab-guide.md` and its manifests alongside it. New labs take the next number. `99-reflections/weekN.md` are fill-in templates, one per lab week.
- Lab guide shape (keep consistent): emoji-prefixed H1 → 🎯 Objectives → 🛠 Prerequisites → `✅ Part N:` steps with `kubectl` commands → 🧠 Reflect in Your Notebook (embedded template) → 📝 Commit → 📣 Share (`#KubeSkillsGROW`) → 🔁 Next Step linking to the following lab.

## Don't pre-solve exercises

- **Some manifests are intentionally incomplete — they are the exercise.** E.g. `01-kubernetes-fundamentals/nginx-pod.yaml` has no `securityContext` because Lab 01 Step 2 has the student add it. Read the lab's `lab-guide.md` before "fixing" any manifest; if a fix is warranted, update the guide to match.
- Known gaps not tied to exercises (leave unless asked): floating image tags (`:stable`), no `resources` blocks, no per-workload NetworkPolicy, plaintext `POSTGRES_PASSWORD` in `05-stateful-deploy/postgres-deployment.yaml`.

## MkDocs gotcha

`mkdocs.yml` has no `docs_dir`, so it defaults to `docs/` — but `nav` points at repo-root paths (`00-getting-started/...`, `99-reflections/...`) plus files that don't exist anywhere (`02-gitops/fluxcd-installation.md`, `03-security/podsecuritypolicy-example.yaml`). Every nav entry except `index.md` is broken, so the deployed site renders only `docs/index.md`; non-strict builds just warn. Adding a lab to `nav` alone won't make it render — the file must resolve relative to `docs/` (or `docs_dir` must be changed).

## Commit / PR conventions (from CONTRIBUTING.md)

Commit messages and PR titles use `<type>: <summary>` with types `lab`, `reflection`, `fix`, `question`, `docs` (e.g. `lab: add Week 6 StatefulSet lab`). Questions go through a PR titled `question: <topic>` or the "Ask a Question" issue template (`.github/ISSUE_TEMPLATE/qna.yml`).
