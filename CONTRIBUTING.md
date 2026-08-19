# Contributing

English | [中文](CONTRIBUTING.zh.md)

Thank you for your interest in contributing to DeepSeek Harness!

We deeply believe in the power of open source communities, and that belief has shaped this project from the very beginning.

DeepSeek Harness is still at an early stage and under active development. We are sorry that we cannot accept external pull requests at the moment. However, contributing code to this repository is far from the only way to help. There are many other ways to get involved:

- Identify and report issues or bugs in GitHub Discussions:
  - Upvote discussions that you would like to bring to the team's attention. We are a very small team and may not be able to reply to every post, but we monitor them and consider them when allocating resources.
- Contribute to the ecosystem:
  - Create a plugin that excites you and share it with others:
    - Associate your GitHub project with the `dsh-plugin` topic to help others discover your plugin.
  - Write blog posts and how-to guides about DeepSeek Harness.
  - Answer questions and help other members of the community.

DeepSeek Harness is designed to be deeply customizable. We do not believe that packages in the official repository are inherently more important than packages created by the community. You may consider this repository an idea, an official showcase, and a source of inspiration, but not a mandate from us.

We have already seen exciting projects emerge from the community, and we hope to see the ecosystem continue to grow in its own directions.

Into the unknown.

## Local machine overlay — standalone checkout (2026-08-19)

This section is **not upstream**; it records local-only changes that make this checkout run standalone on this Windows 11 machine.

- **`.portable/`** (untracked): self-contained toolchain — `node.exe`, `node-v24.12.0-win-x64/`, `pnpm.cmd` (pnpm 11.7.0), corepack shims. Builds and runs do not depend on any global install.
- **`dsh.bat`** (repo root): menu launcher — Web UI / Headless / ACP server / Cordis demo / Rebuild. Self-locating via `%~dp0`; prepends `.portable` to `PATH`; auto-runs `pnpm run build` on first use; `chcp 65001`.
- **`.env`** (repo root, gitignored): holds `DEEPSEEK_API_KEY`; loaded automatically by the harness via `process.loadEnvFile` (`packages/boot/app-boot/src/index.ts`). Never read or commit it.
- Build state: `pnpm run build` and `pnpm run typecheck` completed successfully on 2026-08-19 (host lib + client lib + web dist).
- Verified 2026-08-19: launcher boots (`dsh --help`); headless agent run returns answers **OK after fix**. Root cause of the earlier `AUTH: ****3819 is invalid` failure: a stale **User-level Windows environment variable `DEEPSEEK_API_KEY`** (old key ending `****3819`) overrode the correct `.env` key (ending `****a9bc`) — app-boot prefers ambient env over `.env` (`packages/boot/app-boot/src/index.ts`). The stale variable was removed via `[Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $null, 'User')` on 2026-08-19. Any cmd/pwsh window opened BEFORE that removal still carries the old key in its process environment — reopen it.
- Machine notes: system Node v24.12.0 and a global pnpm 11.7.0 exist at `%APPDATA%\npm` from an earlier setup; this checkout prefers `.portable`. The MSYS2 Bash shell here is broken (`ls`/`grep` missing; npm fails under bash) — use PowerShell (`pwsh`) for commands. `native/landlock-run` is Linux-only and not built on Windows.
