# NUSspli 编译说明（中文）

## 为什么 `.\build.py` 没反应？

在 PowerShell 里直接运行 `.\build.py` 常常**没有任何输出**就结束，常见原因：

1. **未通过 `python` 调用** — 应使用 `python build.py` 或双击 `build.bat`
2. **Windows 不能原生编译** — 官方 `build.py` 依赖 Linux 工具链（`make`、`bash`、`devkitPPC`）

## 正确编译方式（Windows）

### 方法一：Docker（推荐）

1. 安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. 在项目目录打开 PowerShell：

```powershell
cd D:\code\NUSspli_zh
docker build -t nussplibuilder .
docker run --rm -v "${PWD}:/project" nussplibuilder python3 build.py
```

3. 产物在 `zips\` 目录（如 `NUSspli-*-Aroma.wuhb`）

### 方法二：WSL2

1. 启用 WSL：`wsl --install`（需重启）
2. 在 Ubuntu 内安装 devkitPro 环境，或同样在 WSL 里用 Docker 命令

### 本地快速检查

```powershell
python build.py
```

应看到中文提示：**无法在 Windows 下直接编译**（退出码 2）。说明脚本正常，需改用 Docker。

## 仅改了中文语言包时

若只修改了 `data/locale/Chinese.json`，也必须**重新打包 WUHB** 后拷到 SD 卡，主机上才会显示中文。

## 用 GitHub Actions 云端编译（无需本机 Docker）

已将 `.github/workflows/` 改为**仅手动触发**（不再 push 自动编译）。

1. 把代码推送到你的 GitHub 仓库（需包含子模块，checkout 已设 `submodules: recursive`）。
2. 打开仓库 **Actions** 页。
3. 选择工作流：
   - **build** — 完整构建，可勾选「跳过 clang-format」、可选「创建 Release」
   - **build-quick** — 快速 DEBUG 构建（约 20–40 分钟，视缓存而定）
4. 点击 **Run workflow** → 选分支 → **Run workflow**。
5. 完成后在运行记录底部 **Artifacts** 下载：
   - `NUSspli-*-Aroma-DEBUG` 内有 **NUSspli.wuhb** → 拷到 `sd:/wiiu/apps/`

可选：在仓库 Settings → Secrets 添加 `ENC_KEY`（与原项目加密构建一致；没有也能编，可能用空密钥文件）。

### 搜索界面「重影」/ 与官方版表现不一致

**不是汉化翻译问题。** 官方版与汉化版菜单代码相同；差异来自 **编译时链入了错误的 SDL_FontCache（未打补丁的字体渲染库）**。

| 版本 | FontCache |
|------|-----------|
| 官方发布包 | 子模块打补丁后编译（`SDL_RenderCopy` 简化路径） |
| 此前汉化 CI 包 | 曾用**未补丁**子模块覆盖 `src/`，文字叠影、搜索后残影 |

**已修复（需重新跑 Actions 编译）：**

1. `Makefile`：先对子模块打补丁（失败即中止），再同步到 `src/` / `include/`
2. `SDL_FontCache-patches/*.patch`：统一为 LF，避免 Linux 上 `git apply` 静默失败
3. 搜索键盘关闭后**强制重绘**菜单，清除系统键盘残影

请用 **commit 包含上述修复之后** 的 workflow 重新构建，不要用旧 artifact。

### 若 checkout 报 symlink / File name too long

旧仓库里 `src/SDL_FontCache.c` 曾被误存为**符号链接**，已改为普通文件（`100644`）。  
构建时以 **Makefile 打补丁并同步** 的结果为准，不要手动从子模块复制未补丁源码。

当前 workflow **已去掉 clang-format** 和错误的「复制未补丁 FontCache」步骤。
