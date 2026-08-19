# DeepSeek Harness

[English](README.md) | 中文

DeepSeek Harness（`dsh`）是由 [DeepSeek AI](https://deepseek.com) 开发的开源 agent harness（智能体框架）。

它采用**一切皆插件**的架构，并由 [Cordis](https://github.com/cordiverse/cordis) 驱动，其设计参见论文 [_A Programming Paradigm for Spatiotemporal Composability_](https://github.com/cordiverse/paper)。

## 开发者预览

DeepSeek Harness 目前处于 _开发者预览_ 阶段，正在快速迭代。**未来将出现破坏兼容性的变更。**

## 运行

### 通过 `npm` 运行

安装 `Node.js`，然后运行：

```sh
npx @deepseek-ai/dsh web
```

该命令会启动 Web UI，默认地址为 `http://127.0.0.1:3080`。详见 [Web UI 指南](docs/user/guide/index.md)。

### 从源码运行

如需从仓库源码运行：

```sh
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

## 社区与支持

- 欢迎通过 [GitHub Discussions](https://github.com/deepseek-ai/deepseek-harness/discussions) 提交反馈或 bug 报告。
- 为你的插件仓库添加 [`dsh-plugin`](https://github.com/topics/dsh-plugin) 话题，便于被发现。
- 欢迎加入 DeepSeek Harness 企微群：扫码添加企微小助手并填写入群问卷，完成后小助手会邀请你入群。

<table>
  <thead>
    <tr>
      <th align="center">企微小助手</th>
      <th align="center">入群问卷</th>
      <th align="center">微信公众号</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="assets/community-wecom-assistant.png" alt="DeepSeek Harness 企微小助手二维码" width="180" height="180"></td>
      <td align="center"><a href="https://trtgsjkv6r.feishu.cn/share/base/form/shrcnIt5twSVdLGD52KJBckGCgg"><img src="assets/community-wecom-survey.png" alt="DeepSeek Harness 入群问卷二维码" width="180" height="180"></a></td>
      <td align="center"><img src="assets/community-wechat-official-account.png" alt="DeepSeek Harness 团队微信公众号二维码" width="180" height="180"></td>
    </tr>
  </tbody>
</table>

## 参与贡献

参见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 开发

请先阅读[开发指南](docs/development.md)与[架构文档](docs/architecture.md)。

面向 agent：请遵循 [AGENTS.md](AGENTS.md)。

## 许可证

[MIT](LICENSE)

第三方依赖及其许可证见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## 本地机器附加说明——独立检出（2026-08-19）

本节**不属于上游代码**，仅记录本机（Windows 11）为让此检出独立运行所做的本地改动：

- `.portable/`（未跟踪）：自包含工具链——`node.exe`、`node-v24.12.0-win-x64/`、`pnpm.cmd`（pnpm 11.7.0）。构建与运行不依赖任何全局安装。
- `dsh.bat`（仓库根目录）：菜单启动器——Web UI / Headless / ACP 服务器 / Cordis 演示 / 重新构建。通过 `%~dp0` 自定位；自动将 `.portable` 加入 `PATH`；首次使用自动执行 `pnpm run build`。本机请用 `dsh.bat` 代替上游的 `pnpm dsh ...` 命令。
- `.env`（仓库根目录，已被 gitignore）：存放 `DEEPSEEK_API_KEY`，由 harness 自动加载（`packages/boot/app-boot/src/index.ts`）。请勿读取或提交。
- 2026-08-19 已成功执行 `pnpm run build` 与 `pnpm run typecheck`。
- 2026-08-19 验证：启动器可运行（`dsh --help`）；修复后 headless 运行正常（返回 `OK`）。此前 `AUTH: ****3819 is invalid` 的根本原因：Windows **用户级环境变量 `DEEPSEEK_API_KEY`**（旧 key，末尾 `****3819`）覆盖了 `.env` 中的正确 key（末尾 `****a9bc`）——app-boot 优先使用环境变量而非 `.env`（`packages/boot/app-boot/src/index.ts`）。已于 2026-08-19 通过 `[Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $null, 'User')` 删除该变量。在此时间之前打开的 cmd/pwsh 窗口仍带有旧 key，请重新打开。
- 机器说明：系统已有 Node v24.12.0 与全局 pnpm 11.7.0（位于 `%APPDATA%\npm`）；本检出优先使用 `.portable`。本机 MSYS2 Bash 环境损坏（缺少 `ls`/`grep`），请使用 PowerShell（`pwsh`）。`native/landlock-run` 仅支持 Linux，不在 Windows 构建。
