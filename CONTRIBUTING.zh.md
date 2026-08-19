# 贡献

[English](CONTRIBUTING.md) | 中文

感谢你愿意为 DeepSeek Harness 作出贡献！

我们深信开源社区的力量，这份信念从项目最初就塑造着 DeepSeek Harness。

DeepSeek Harness 仍处于早期阶段，并在积极开发中。很抱歉，我们目前无法接受外部 PR（Pull Request）。不过，贡献代码远非帮助本仓库建设的唯一途径。你还可以通过许多其他方式参与进来：

- 在 GitHub Discussions 中发现并报告问题或 bug：
  - 为你希望引起团队关注的讨论投票。我们的团队规模很小，可能无法回复每个帖子，但我们会持续关注，并在分配资源时将这些讨论纳入考虑。
- 为生态系统作出贡献：
  - 创建令你感兴趣的插件，并分享给其他人：
    - 为你的 GitHub 项目添加 `dsh-plugin` 话题，让其他人更容易找到你的插件。
  - 撰写有关 DeepSeek Harness 的博客文章和操作指南。
  - 回答问题并帮助其他社区成员。

DeepSeek Harness 的设计支持深度定制。我们并不认为官方仓库中的包天然就比社区开发的包更重要。你可以将本仓库看作一种理念、一份官方示例以及一处灵感来源，而不是我们要求社区遵循的方向。

我们已经看到社区中涌现出令人期待的项目，也希望生态系统继续沿着自己的方向发展。

探索未至之境。

## 本地机器附加说明——独立检出（2026-08-19）

本节**不属于上游代码**，仅记录本机（Windows 11）为让此检出独立运行所做的本地改动：

- `.portable/`（未跟踪）：自包含工具链——`node.exe`、`node-v24.12.0-win-x64/`、`pnpm.cmd`（pnpm 11.7.0）。构建与运行不依赖任何全局安装。
- `dsh.bat`（仓库根目录）：菜单启动器——Web UI / Headless / ACP 服务器 / Cordis 演示 / 重新构建。通过 `%~dp0` 自定位；自动将 `.portable` 加入 `PATH`；首次使用自动执行 `pnpm run build`。
- `.env`（仓库根目录，已被 gitignore）：存放 `DEEPSEEK_API_KEY`，由 harness 自动加载（`packages/boot/app-boot/src/index.ts`）。请勿读取或提交。
- 2026-08-19 已成功执行 `pnpm run build` 与 `pnpm run typecheck`。
- 2026-08-19 验证：启动器可运行（`dsh --help`）；修复后 headless 运行正常（返回 `OK`）。此前 `AUTH: ****3819 is invalid` 的根本原因：Windows **用户级环境变量 `DEEPSEEK_API_KEY`**（旧 key，末尾 `****3819`）覆盖了 `.env` 中的正确 key（末尾 `****a9bc`）——app-boot 优先使用环境变量而非 `.env`（`packages/boot/app-boot/src/index.ts`）。已于 2026-08-19 通过 `[Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $null, 'User')` 删除该变量。在此时间之前打开的 cmd/pwsh 窗口仍带有旧 key，请重新打开。
- 机器说明：系统已有 Node v24.12.0 与全局 pnpm 11.7.0（位于 `%APPDATA%\npm`）；本检出优先使用 `.portable`。本机 MSYS2 Bash 环境损坏（缺少 `ls`/`grep`），请使用 PowerShell（`pwsh`）。`native/landlock-run` 仅支持 Linux，不在 Windows 构建。
