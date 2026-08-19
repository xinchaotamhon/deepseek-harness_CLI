# Running benchmarks

Follow [Get started with the Python SDK](docs/user/guide/python-sdk.md) to install the SDK and run the `jsonrpc-agent` minimal variant. Use separate workspaces and session IDs for independent benchmark tasks.

## Local machine overlay — standalone checkout (2026-08-19)

This section is **not upstream**; it records local-only changes that make this checkout run standalone on this Windows 11 machine.

- **`.portable/`** (untracked): self-contained toolchain — `node.exe`, `node-v24.12.0-win-x64/`, `pnpm.cmd` (pnpm 11.7.0), corepack shims. Builds and runs do not depend on any global install.
- **`dsh.bat`** (repo root): menu launcher — Web UI / Headless / ACP server / Cordis demo / Rebuild. Self-locating via `%~dp0`; prepends `.portable` to `PATH`; auto-runs `pnpm run build` on first use; `chcp 65001`.
- **`.env`** (repo root, gitignored): holds `DEEPSEEK_API_KEY`; loaded automatically by the harness via `process.loadEnvFile` (`packages/boot/app-boot/src/index.ts`). Never read or commit it.
- Build state: `pnpm run build` and `pnpm run typecheck` completed successfully on 2026-08-19 (host lib + client lib + web dist).
- Verified 2026-08-19: launcher boots (`dsh --help`); headless agent run returns answers **OK after fix**. Root cause of the earlier `AUTH: ****3819 is invalid` failure: a stale **User-level Windows environment variable `DEEPSEEK_API_KEY`** (old key ending `****3819`) overrode the correct `.env` key (ending `****a9bc`) — app-boot prefers ambient env over `.env` (`packages/boot/app-boot/src/index.ts`). The stale variable was removed via `[Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $null, 'User')` on 2026-08-19. Any cmd/pwsh window opened BEFORE that removal still carries the old key in its process environment — reopen it.
- Machine notes: system Node v24.12.0 and a global pnpm 11.7.0 exist at `%APPDATA%\npm` from an earlier setup; this checkout prefers `.portable`. The MSYS2 Bash shell here is broken (`ls`/`grep` missing; npm fails under bash) — use PowerShell (`pwsh`) for commands. `native/landlock-run` is Linux-only and not built on Windows.
