# DeepSeek Harness

English | [中文](README.zh.md)

DeepSeek Harness (`dsh`) is an open-source agent harness developed by [DeepSeek AI](https://deepseek.com).

It uses an architecture where **everything is a plugin**, and is powered by [Cordis](https://github.com/cordiverse/cordis), whose design is described in [_A Programming Paradigm for Spatiotemporal Composability_](https://github.com/cordiverse/paper).

## Developer preview

DeepSeek Harness is currently in _developer preview_ and is iterating rapidly. **THERE WILL BE COMPATIBILITY-BREAKING CHANGES.**

## Run

### Run from `npm`

Install `Node.js`, then run:

```sh
npx @deepseek-ai/dsh web
```

The command starts the Web UI, served at `http://127.0.0.1:3080` by default. See [Web UI guide](docs/user/guide/index.md).

### Run from source

To run from a repository checkout:

```sh
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

## Community and support

- Feel free to submit feedback or bug reports through [GitHub Discussions](https://github.com/deepseek-ai/deepseek-harness/discussions).
- Add the [`dsh-plugin`](https://github.com/topics/dsh-plugin) topic to your plugin repository for discoverability.
- Join <a href="https://discord.gg/Ycq5dCaS4">DeepSeek Harness Discord community</a>.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Development

Start with the [development guide](docs/development.md) and [architecture documentation](docs/architecture.md).

For agents, follow [AGENTS.md](AGENTS.md).

## License

[MIT](LICENSE)

Third-party dependencies and their licenses are disclosed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Local machine overlay — standalone checkout (2026-08-19)

> **First read [`START_HERE.md`](START_HERE.md)** — it is the single entry point for any
> AI: current local state, how to run, and how to set up a new machine.

This section is **not upstream**; it records local-only changes that make this checkout run standalone on this Windows 11 machine.

- **`.portable/`** (untracked): self-contained toolchain — `node.exe`, `node-v24.12.0-win-x64/`, `pnpm.cmd` (pnpm 11.7.0), corepack shims. Builds and runs do not depend on any global install.
- **`dsh.bat`** (repo root): menu launcher — Web UI / Headless / ACP server / Cordis demo / Rebuild. Self-locating via `%~dp0`; prepends `.portable` to `PATH`; auto-runs `pnpm run build` on first use; `chcp 65001`. Run `dsh.bat` instead of the upstream `pnpm dsh ...` commands on this machine.
- **`.env`** (repo root, gitignored): holds `DEEPSEEK_API_KEY`; loaded automatically by the harness via `process.loadEnvFile` (`packages/boot/app-boot/src/index.ts`). Never read or commit it.
- Build state: `pnpm run build` and `pnpm run typecheck` completed successfully on 2026-08-19 (host lib + client lib + web dist).
- Verified 2026-08-19: launcher boots (`dsh --help`); headless agent run returns answers **OK after fix**. Root cause of the earlier `AUTH: ****3819 is invalid` failure: a stale **User-level Windows environment variable `DEEPSEEK_API_KEY`** (old key ending `****3819`) overrode the correct `.env` key (ending `****a9bc`) — app-boot prefers ambient env over `.env` (`packages/boot/app-boot/src/index.ts`). The stale variable was removed via `[Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $null, 'User')` on 2026-08-19. Any cmd/pwsh window opened BEFORE that removal still carries the old key in its process environment — reopen it.
- Machine notes: system Node v24.12.0 and a global pnpm 11.7.0 exist at `%APPDATA%\npm` from an earlier setup; this checkout prefers `.portable`. The MSYS2 Bash shell here is broken (`ls`/`grep` missing; npm fails under bash) — use PowerShell (`pwsh`) for commands. `native/landlock-run` is Linux-only and not built on Windows.
