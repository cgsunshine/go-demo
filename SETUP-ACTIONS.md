# 建好 GitHub 空仓库 go-demo 之后

1. 把本目录推上去（陪练会帮你做）
2. 创建 PAT：https://github.com/settings/tokens
   - classic: 勾选 repo
   - 或 fine-grained: 只授权 cgsunshine/gitops-manifests → Contents Read/Write
3. 在 go-demo 仓库添加 Secret 名：GITOPS_TOKEN
4. 建分支并推送后，合并 test→dev 就会跑流水线