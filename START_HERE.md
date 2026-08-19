# START HERE — DeepSeek Harness local checkout

> **Read this file first.** It describes what this folder is, what was changed on this
> machine (standalone local setup), how to run it, and the exact current state as of
> **2026-08-19**. Any AI or person reading this file should be able to work with this
> folder without reading the whole repository.
>
> Owner: vhiep (Vietnamese speaker). For deeper context read, in order:
> [AGENTS.md](AGENTS.md) → [docs/development.md](docs/development.md) →
> [docs/architecture.md](docs/architecture.md).

---

## 1. What this repository is

**DeepSeek Harness (`dsh`)** — an open-source agent harness by DeepSeek AI.
Architecture: **everything is a plugin**, powered by a vendored copy of Cordis
(framework lives in `vendor/`, republished as `@deepseek-ai/*` packages).
Monorepo managed with **pnpm workspaces** (pnpm 11.7.0). Currently in developer
preview — breaking changes expected.

Main entry points:
- **Web UI** — browser-based agent UI (default `http://127.0.0.1:3080`)
- **Headless** — one-shot agent: run a task, print the final answer, exit
- **ACP server** — automation server over JSON-RPC stdio (`pnpm run demo:acp`)
- **Cordis demo** — self-referential agent demo (`pnpm run demo:cordis`)

## 2. IMPORTANT: local changes vs upstream

This checkout has **local-only modifications** (documented in detail in the
"Local machine overlay" sections appended to the repo docs). Nothing below is
upstream:

| Item | Purpose | Git status |
|---|---|---|
| `.portable/` | Self-contained toolchain: `node.exe`, `node-v24.12.0-win-x64/`, `pnpm.cmd` (11.7.0), corepack shims | **ignored** (never commit; re-create per section "Setup on a new machine") |
| `dsh.bat` | Menu launcher (Web UI / Headless / ACP / Cordis / Rebuild) | tracked in owner's GitHub fork |
| `.env` | Holds `DEEPSEEK_API_KEY` (user-managed, gitignored — **never read or commit**) | ignored |
| `START_HERE.md` | This file — the entry point for any AI | tracked in owner's GitHub fork |
| `AGENTS.md`, `BENCHMARK.md`, `CLAUDE.md`, `CONTRIBUTING.md`(+zh), `README.md`(+zh), `THIRD_PARTY_NOTICES.md` | Appended "Local machine overlay" sections | modified (M) |

Why this exists: the owner wants this folder to run **fully standalone** — no
global installs required. Everything needed to build and run lives inside the
folder (`.portable/` + `node_modules/` + built artifacts).

## 3. Current state (verified 2026-08-19)

- **Build:** `pnpm run build` ✅ (host lib + client lib + web dist). `pnpm run typecheck` ✅.
- **API:** working. Headless run returns answers (tested: `Reply with exactly: OK` → `OK`).
- **Auth history (do not repeat the mistake):** a stale **User-level Windows env var
  `DEEPSEEK_API_KEY`** (old key ending `****3819`) used to override the correct `.env`
  key (ending `****a9bc`) — `app-boot` prefers ambient environment over `.env`
  (`packages/boot/app-boot/src/index.ts`). The stale variable was **removed** on
  2026-08-19 via `[Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $null, 'User')`.
  → If credentials seem wrong, check `[Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY','User')`
  is NOT set; windows opened before that removal still carry the old key in process env — reopen them.
- **Portable pnpm** works from any directory via `.portable\pnpm.cmd` (uses `.portable\node.exe`).

## 4. How to run (owner's normal workflow)

**Double-click `dsh.bat`** in the repo root. It:
1. Locates itself via `%~dp0` (folder is movable — works from any path)
2. Prepends `.portable\` + portable node dir to `PATH`
3. Auto-runs `pnpm run build` on first use if `apps\web\dist` is missing
4. Shows a menu: `1` Web UI · `2` Headless · `3` ACP server · `4` Cordis demo · `5` Rebuild

Equivalent manual commands (run from repo root, use `.portable\pnpm.cmd`):

```sh
.portable\pnpm.cmd dsh --profile web                    # Web UI → http://127.0.0.1:3080
.portable\pnpm.cmd dsh --profile headless "your task"   # one-shot agent
.portable\pnpm.cmd run demo:acp                          # ACP server
.portable\pnpm.cmd run demo:cordis                       # cordis demo
.portable\pnpm.cmd run build                             # full build
.portable\pnpm.cmd run typecheck                         # typecheck
.portable\pnpm.cmd test                                  # vitest unit tests
```

## Setup on a NEW machine (reproduce this standalone state)

Steps for an AI or person to bring a fresh machine to the same state as this
folder (prereqs: internet, git; adjust paths per OS):

1. **Get the code:** clone this fork (`git clone <owner-repo-url>`). The upstream
   origin is `https://github.com/deepseek-ai/deepseek-harness.git`; this repo is a
   fork/derivative of it.
2. **Node.js:** install Node.js >= 24 (https://nodejs.org), or download the portable
   zip `https://nodejs.org/dist/v24.12.0/node-v24.12.0-win-x64.zip`, extract to
   `.portable\`, and copy `node.exe` to `.portable\`.
3. **pnpm 11.7.0:** global `npm install -g pnpm@11.7.0`
   (or `corepack enable && corepack prepare pnpm@11.7.0 --activate`),
   or portable: run the portable node's `npm install -g pnpm@11.7.0 --prefix .portable`
   and use `.portable\pnpm.cmd` (the committed `dsh.bat` documents the pattern).
4. **Install deps:** from repo root: `pnpm install` (installs workspaces + lefthook hooks).
5. **Build:** `pnpm run build` (host lib + client lib + web dist). Required before
   running the demos/web UI from source.
6. **Credentials:** create `.env` at repo root with `DEEPSEEK_API_KEY=sk-...`
   (create the key at https://platform.deepseek.com). **Critical:** the harness prefers
   ambient environment variables over `.env` — if `DEEPSEEK_API_KEY` is set at Windows
   User level (`[Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY','User')`),
   remove it, or it silently overrides `.env` (this bit us once — see section 3).
7. **Verify:** `pnpm run typecheck` exits 0, then
   `pnpm dsh --profile headless "Reply with exactly: OK"` returns `OK`.
8. **Optional launcher:** run `dsh.bat` (menu). It self-locates via `%~dp0`,
   prepends `.portable` to `PATH`, and auto-builds on first use.
9. **Machine notes:** `native/landlock-run` is Linux-only (not built on Windows);
   on Windows prefer PowerShell (`pwsh`) — the MSYS2 bash on the owner's machine is broken.

## 5. Configuration & credentials

- **`.env`** at repo root: `DEEPSEEK_API_KEY=sk-...` (+ optional `DEEPSEEK_BASE_URL`).
  Auto-loaded by the harness via `process.loadEnvFile` (`packages/boot/app-boot/src/index.ts`).
  Precedence: **ambient env var > repo-root `.env` > harness-home `.env`**.
- **Harness home:** `C:\Users\vhiep\.dsh` (`$DSH_HOME`) — contains `profiles/<name>/`
  (web and headless profiles auto-initialize on first use from shipped templates),
  plus user-level patch layers.
- **DeepSeek API:** default provider; base URL defaults to the public API.

## 6. Environment & machine facts

- **Local path:** `D:\mydata\new-git-3\deepseek-harness_CLI` — owner renamed the folder
  from `deepseek-harness` to `deepseek-harness_CLI` on 2026-08-19 (git content unchanged).
- **Git remotes:** `origin` = upstream `https://github.com/deepseek-ai/deepseek-harness.git`
  (read-only for the owner; **never push to it**). Local branch: `master`. Owner's own
  GitHub fork/repo is the push target (see section 10 "Pushing to GitHub").
- **OS:** Windows 11; user `vhiep`.
- **Shell rule:** the MSYS2 Bash on this machine is BROKEN (`ls`, `grep` missing; npm
  fails under bash). **Use PowerShell 7 (`pwsh -NoProfile`) for all commands.** In this
  bash tool, `$` inside `pwsh -Command "..."` gets eaten — use `-File script.ps1` instead.
- **Node:** system v24.12.0 also installed; global pnpm 11.7.0 exists at
  `%APPDATA%\npm` (from earlier setup) — the checkout **prefers `.portable`**.
- **`native/landlock-run`** is Linux-only (Landlock security module) — not built on Windows; safe to ignore.
- **Python:** 3.14.5 available; the `python/` SDK is present in the workspace but its
  virtualenv/uv runtime is **not** set up — only needed for Python SDK work, not for `dsh`.
- Leefhook hooks installed at `pnpm install` (pre-commit/pre-push run typecheck etc.).
  `git status` currently shows the 8 modified docs + 2 untracked local files — do not
  treat them as accidental changes.

## 7. Repository layout (condensed)

```
vendor/            Vendored Cordis source (pinned, manifest in vendor/README.md)
packages/          @deepseek-ai/dsh-* workspaces at packages/<group>/<pkg>/
  core/              product API spine: session, system-prompt, tools, agent, agent-loop
  api/               Remote BFF assembly and Typert RPC gateway
  typert/            type graph generator, loader, runtime registry
  llm/               LLM capability + DeepSeek providers
  e2b/               E2B sandbox POC
  shell/             bash capability (local/pwsh providers)
  subprocess/        subprocess capability
  terminal/          persistent sessions
  fs/                filesystem capability + policy
  lsp/               language-server capability
  skill/             skill provider registry + loader
  web/               web capability: search/fetch providers
  compaction/        compaction capability
  context/           request-context plugins
  subagent/          subagent capability
  bundle/            installable dsh --profile patch-layer bundles
  workflow/          workflow capability
  todo/, plan/, preset/, guard/, self-modification/, hooks/
  session/, identity/, settings/, credentials/, client/* (web UI)
apps/              product assemblies; apps/cli owns the `dsh` bin
website/           docs site (VitePress)
python/            Python SDK + runtime (optional; not set up locally)
native/landlock-run  Linux-only launcher (not built on Windows)
examples/          runnable demos
scripts/           repo tooling + gates
```

## 8. Rules for any AI working in this folder

1. **Never read or commit `.env`** (API secrets). Use it only through the harness's env loading.
2. **Use `.portable\pnpm.cmd`**, not the global pnpm, for consistency.
3. **Use PowerShell**, not the broken MSYS2 bash.
4. **Do not commit** `.portable/` or `.env` (gitignored; `.portable` is re-created per the
   new-machine guide). `dsh.bat` and `START_HERE.md` ARE committed to the owner's fork.
   The 8 modified docs keep their overlay sections intentionally.
5. `THIRD_PARTY_NOTICES.md` is **generated** — the "Local machine appendix" at its end is
   manual and will be dropped if `scripts/gen-third-party-notices.ts` runs; re-add it if needed.
6. `dsh.bat` uses `chcp 65001` — keep it UTF-8.
7. Before changing code, read [AGENTS.md](AGENTS.md) rules and
   [docs/development.md](docs/development.md); package structure contracts live in docs/.

## 9. Useful references

- [docs/development.md](docs/development.md) — setup tutorial + contributor reference
- [docs/architecture.md](docs/architecture.md) — architecture
- [docs/user/guide/index.md](docs/user/guide/index.md) — Web UI user guide
- [apps/cli/README.md](apps/cli/README.md) — `dsh` CLI grammar and profiles
- [AGENTS.md](AGENTS.md) — repository rules for agents (contains the full overlay section)

## 10. Pushing to GitHub (owner's fork)

- `origin` points to **upstream DeepSeek** (`deepseek-ai/deepseek-harness`) — the owner
  does not have write access and must **never push there**.
- The owner pushes to their **own GitHub repository** (fork or new repo). Procedure:
  1. Create the repo on GitHub (fork of `deepseek-ai/deepseek-harness`, or empty repo).
  2. `git remote add mine https://github.com/<owner>/<repo>.git`
  3. `git push -u mine master`  (branch `master`, local — do NOT push to origin)
- What gets pushed: the 8 modified docs (overlay sections), `dsh.bat`, `START_HERE.md`.
  What stays local: `.env` and `.portable/` (both gitignored — never pushed).
- After pushing, clone `mine` on new machines and follow "Setup on a new machine" (section 4).
