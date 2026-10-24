# go-demo

Go HTTP 服务 + GitHub Actions 真实 CI/CD（多分支 → 多环境）。

## 分支策略

| 分支 | 作用 | 合并后触发 |
|------|------|------------|
| `test` | 开发日常提交 | 不自动部署（先提 PR 到 `dev`） |
| `dev` | 开发集成分支 | CI 构建镜像 → 更新 `gitops-manifests/envs/dev` → Argo 部署到 namespace `dev` |
| `main` | 生产 | CI 构建镜像 → 更新 `envs/prod` → 部署到 namespace `prod` |

流程：`test` →（PR）→ `dev` →（PR）→ `main`

## 需要的 Secret

在本仓库 Settings → Secrets and variables → Actions 添加：

- `GITOPS_TOKEN`：GitHub PAT（classic 勾选 `repo`，或 fine-grained 对 `gitops-manifests` 开 Contents: Read and write）

`GITHUB_TOKEN` 由 Actions 自动提供，用于推镜像到 GHCR。