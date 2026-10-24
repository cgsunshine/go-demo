# 模拟 CI + CD：指定版本号即可
# 用法: powershell -File pipeline.ps1 -Version v2
param(
  [Parameter(Mandatory=$true)][string]$Version
)
$ErrorActionPreference = "Stop"
$AppDir = "C:\cguser\pro\bot_learn\cicd-lab02-go"
$GitOps = "C:\cguser\pro\bot_learn\gitops-manifests"
$Image = "go-demo:$Version"

Write-Host "==> [CI] docker build $Image"
Set-Location "$AppDir\app"
docker build -t $Image .

Write-Host "==> [CI] kind load $Image"
kind load docker-image $Image --name learn

Write-Host "==> [CD] write manifests image/env = $Version"
New-Item -ItemType Directory -Force -Path "$GitOps\apps\go-demo" | Out-Null
$manifest = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-demo
  labels:
    app: go-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: go-demo
  template:
    metadata:
      labels:
        app: go-demo
    spec:
      containers:
        - name: web
          image: go-demo:$Version
          imagePullPolicy: Never
          env:
            - name: APP_VERSION
              value: $Version
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 1
            periodSeconds: 5
          resources:
            requests:
              cpu: 20m
              memory: 32Mi
            limits:
              cpu: 100m
              memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: go-demo
  labels:
    app: go-demo
spec:
  selector:
    app: go-demo
  ports:
    - port: 80
      targetPort: 8080
"@
[System.IO.File]::WriteAllText("$GitOps\apps\go-demo\all.yaml", $manifest)

Set-Location $GitOps
git add apps/go-demo/all.yaml
git -c user.email="chen@local" -c user.name="chen guang" commit -m "ci: release go-demo $Version"
git push

Write-Host "==> pushed. Wait for Argo (or: kubectl -n argocd annotate application go-demo argocd.argoproj.io/refresh=hard --overwrite)"
Write-Host "Then: kubectl port-forward svc/go-demo 8091:80"
Write-Host "curl http://127.0.0.1:8091"