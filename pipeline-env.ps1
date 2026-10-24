# 模拟「合并后触发」的 CI/CD
# 用法:
#   powershell -ExecutionPolicy Bypass -File pipeline-env.ps1 -Env dev  -Version dev-2
#   powershell -ExecutionPolicy Bypass -File pipeline-env.ps1 -Env prod -Version prod-2
# 含义:
#   -Env dev  = 模拟 test 合并进 dev 之后
#   -Env prod = 模拟 dev 合并进 main 之后
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("dev","prod")]
  [string]$Env,
  [Parameter(Mandatory=$true)]
  [string]$Version
)
$ErrorActionPreference = "Stop"
$AppDir = "C:\cguser\pro\bot_learn\cicd-lab02-go"
$GitOps = "C:\cguser\pro\bot_learn\gitops-manifests"
$Image = "go-demo:$Version"
$Replicas = if ($Env -eq "prod") { 2 } else { 1 }

Write-Host "==> 模拟合并触发: env=$Env version=$Version"
Write-Host "==> [CI] docker build $Image"
Set-Location "$AppDir\app"
docker build -t $Image .

Write-Host "==> [CI] kind load $Image"
kind load docker-image $Image --name learn

Write-Host "==> [CD] write envs/$Env/go-demo (GitOps)"
New-Item -ItemType Directory -Force -Path "$GitOps\envs\$Env\go-demo" | Out-Null
$manifest = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-demo
  labels:
    app: go-demo
    env: $Env
spec:
  replicas: $Replicas
  selector:
    matchLabels:
      app: go-demo
  template:
    metadata:
      labels:
        app: go-demo
        env: $Env
    spec:
      containers:
        - name: web
          image: go-demo:$Version
          imagePullPolicy: Never
          env:
            - name: APP_VERSION
              value: "$Version"
            - name: APP_ENV
              value: "$Env"
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
[System.IO.File]::WriteAllText("$GitOps\envs\$Env\go-demo\all.yaml", $manifest)

Set-Location $GitOps
git add "envs/$Env/go-demo/all.yaml"
git -c user.email="chen@local" -c user.name="chen guang" commit -m "ci($Env): release go-demo $Version"
git push

Write-Host "==> pushed. Argo app: go-demo-$Env"
Write-Host "验证: kubectl -n $Env port-forward svc/go-demo 8091:80"
Write-Host "     curl http://127.0.0.1:8091"