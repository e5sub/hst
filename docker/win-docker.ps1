# 定义配置文件路径和下载地址
$composeFile = ".\docker-compose.yml"
$composeUrl = "https://fastly.jsdelivr.net/gh/e5sub/hst@master/docker/docker-compose.yml"

# 检查文件是否存在
if (Test-Path $composeFile) {
    Write-Host "检测到已有 docker-compose.yml 文件，跳过下载" -ForegroundColor Yellow
}
else {
    # 下载文件
    Write-Host "正在下载 docker-compose.yml 文件..." -ForegroundColor Blue
    try {
        Invoke-WebRequest -Uri $composeUrl -OutFile $composeFile
        Write-Host "下载成功" -ForegroundColor Green
    }
    catch {
        Write-Host "下载失败，请检查网络或 URL 地址" -ForegroundColor Red
        exit 1
    }
}

# 创建临时文件用于后续处理
$tempComposeFile = ".\docker-compose.temp.yml"
Copy-Item $composeFile $tempComposeFile
Write-Host "已创建临时配置文件" -ForegroundColor Blue

# 提取服务描述
$serviceDescriptions = @()
$services = @()
$prevLine = ""
$lines = Get-Content $composeFile
foreach ($line in $lines) {
    if ($line -match '^\s+[a-zA-Z0-9_-]+:') {
        $service = ($line -split '\s+')[1] -replace ':', ''
        $description = $prevLine -replace '^\s*#\s*', ''
        $services += $service
        $serviceDescriptions += $description
    }
    $prevLine = $line
}

# 打印美化标题
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         Docker 服务安装菜单                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "请选择要安装的服务（用空格分隔多个选项，输入 all 选择所有服务）：" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Yellow

# 按原始顺序打印服务列表
$maxWidth = $services.Count.ToString().Length
for ($i = 0; $i -lt $services.Count; $i++) {
    "{0,$maxWidth}. {1,-25} {2}" -f ($i + 1), $services[$i], $serviceDescriptions[$i] | Write-Host -ForegroundColor White
}

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Yellow
$choices = Read-Host "选择"

# 处理用户选择
Write-Host "正在处理你的选择..." -ForegroundColor Cyan
if ($choices -eq "all") {
    $selectedServices = $services
    Write-Host "已选择安装所有服务" -ForegroundColor Green
}
else {
    $selectedServices = @()
    $validChoice = $false
    foreach ($choice in $choices -split ' ') {
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $services.Count) {
            $selectedServices += $services[$index]
            $validChoice = $true
        }
        else {
            Write-Host "无效的选择: $choice" -ForegroundColor Red
        }
    }

    if (-not $validChoice) {
        Write-Host "没有选择任何有效服务，退出安装" -ForegroundColor Red
        exit 1
    }
}

# 显示用户选择的服务
Write-Host "你选择安装的服务：" -ForegroundColor Cyan
for ($i = 0; $i -lt $selectedServices.Count; $i++) {
    $service = $selectedServices[$i]
    for ($j = 0; $j -lt $services.Count; $j++) {
        if ($services[$j] -eq $service) {
            "{0,$maxWidth}. {1,-25} {2}" -f ($j + 1), $service, $serviceDescriptions[$j] | Write-Host -ForegroundColor White
            break
        }
    }
}

# 参数注入
Write-Host "正在配置所选服务..." -ForegroundColor Cyan
if ($selectedServices -contains "tailscaled") {
    $tsAuthkey = Read-Host "请输入你的 Tailscale Auth Key"
    (Get-Content $tempComposeFile) -replace 'TS_AUTHKEY=.*# 替换为你的 Tailscale Auth Key', "TS_AUTHKEY=$tsAuthkey" | Set-Content $tempComposeFile
    Write-Host "Tailscale Auth Key 已配置" -ForegroundColor Green
}

if ($selectedServices -contains "rustdesk") {
    $relayServer = Read-Host "请输入你的中继服务器地址"
    $idServer = Read-Host "请输入你的 ID 服务器地址"
    $apiServer = Read-Host "请输入你的 API 服务器地址"

    (Get-Content $tempComposeFile) -replace 'RELAY=.*# 替换为你的中继服务器地址（21117端口）', "RELAY=$relayServer" | Set-Content $tempComposeFile
    (Get-Content $tempComposeFile) -replace 'RUSTDESK_API_RUSTDESK_ID_SERVER=.*# 替换为你的ID服务器地址（21116端口）', "RUSTDESK_API_RUSTDESK_ID_SERVER=$idServer" | Set-Content $tempComposeFile
    (Get-Content $tempComposeFile) -replace 'RUSTDESK_API_RUSTDESK_RELAY_SERVER=.*# 替换为你的中继服务器地址（21117端口）', "RUSTDESK_API_RUSTDESK_RELAY_SERVER=$relayServer" | Set-Content $tempComposeFile
    (Get-Content $tempComposeFile) -replace 'RUSTDESK_API_RUSTDESK_API_SERVER=.*# 替换为你的API服务器地址', "RUSTDESK_API_RUSTDESK_API_SERVER=$apiServer" | Set-Content $tempComposeFile

    Write-Host "RustDesk 服务器地址已配置" -ForegroundColor Green
}

if ($selectedServices -contains "nginx") {
    Write-Host "配置 Nginx 服务..." -ForegroundColor Cyan
    # 拉取最新 nginx 镜像
    Write-Host "拉取 nginx:latest 镜像..." -ForegroundColor Cyan
    docker pull nginx:latest
    # 创建临时容器提取配置
    $containerId = docker create nginx:latest
    Write-Host "创建临时容器: $containerId" -ForegroundColor Cyan
    $tempDir = New-TemporaryFile | ForEach-Object { $_.DirectoryName }
    Write-Host "使用临时目录: $tempDir" -ForegroundColor Cyan
    # 提取配置文件
    docker cp "$containerId:/etc/nginx" "$tempDir/"
    docker cp "$containerId:/usr/share/nginx/html" "$tempDir/"
    docker rm $containerId | Out-Null
    # 定义挂载映射
    $mountMap = @{
        "/usr/share/nginx/html" = "D:\docker\nginx\html"
        "/etc/nginx"           = "D:\docker\nginx\conf"
        "/var/log/nginx"       = "D:\docker\nginx\log"
    }
    foreach ($containerPath in $mountMap.Keys) {
        $hostPath = $mountMap[$containerPath]
        Write-Host "处理挂载: $hostPath -> $containerPath" -ForegroundColor Cyan
        New-Item -ItemType Directory -Force -Path $hostPath | Out-Null
        switch ($containerPath) {
            "/usr/share/nginx/html" {
                if (-not (Get-ChildItem $hostPath)) {
                    Write-Host "复制默认网页内容..." -ForegroundColor Cyan
                    Copy-Item -Recurse -Force "$tempDir\html\." $hostPath
                    Write-Host "网页内容复制完成" -ForegroundColor Green
                }
                else {
                    Write-Host "网页目录非空，跳过复制" -ForegroundColor Green
                }
            }
            "/etc/nginx" {
                $missingMainConf = 0
                if (-not (Test-Path "$hostPath\nginx.conf")) { $missingMainConf = 1 }
                if (-not (Test-Path "$hostPath\conf.d")) { $missingMainConf = 1 }

                if (-not (Get-ChildItem $hostPath) -or $missingMainConf -eq 1) {
                    Write-Host "配置目录为空或缺失关键文件，初始化默认配置..." -ForegroundColor Yellow
                    Copy-Item -Recurse -Force "$tempDir\nginx\." $hostPath
                    # 检查并生成 default.conf
                    if (-not (Test-Path "$hostPath\conf.d\default.conf")) {
                        Write-Host "default.conf 不存在，生成默认虚拟主机配置..." -ForegroundColor Yellow
                        New-Item -ItemType Directory -Force -Path "$hostPath\conf.d" | Out-Null
                        $defaultConf = @"
server {
    listen       80;
    server_name  localhost;
    return       301 https://`$host`$request_uri;
}

server {
    listen       443 ssl;
    server_name  localhost;

    ssl_certificate      /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key  /etc/nginx/ssl/nginx.key;

    ssl_protocols        TLSv1.2 TLSv1.3;
    ssl_ciphers          HIGH:!aNULL:!MD5;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
"@
                        $defaultConf | Out-File -FilePath "$hostPath\conf.d\default.conf" -Encoding UTF8
                        Write-Host "default.conf 已生成" -ForegroundColor Green
                    }
                    Write-Host "Nginx 配置初始化完成" -ForegroundColor Green
                }
                else {
                    Write-Host "配置目录存在且完整，跳过复制" -ForegroundColor Green
                }
            }
            "/var/log/nginx" {
                Write-Host "日志目录已准备好" -ForegroundColor Green
            }
            default {
                Write-Host "未知路径 $containerPath，跳过" -ForegroundColor Yellow
            }
        }
    }

    # 清理临时目录
    Write-Host "清理临时目录..." -ForegroundColor Cyan
    Remove-Item -Recurse -Force $tempDir
    Write-Host "Nginx 配置完成" -ForegroundColor Green
}

if ($selectedServices -contains "n8n") {
    $n8nDir = "D:\docker\n8n"
    New-Item -ItemType Directory -Force -Path $n8nDir | Out-Null
    Write-Host "已创建并设置 $n8nDir 文件夹权限" -ForegroundColor Green
}

if ($selectedServices -contains "redis") {
    $redisConfUrl = "https://gh-proxy.com/https://raw.githubusercontent.com/redis/redis/8.0/redis.conf"
    $redisConfDir = "D:\docker\redis\conf"
    New-Item -ItemType Directory -Force -Path $redisConfDir | Out-Null
    Write-Host "正在下载 Redis 配置文件..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $redisConfUrl -OutFile "$redisConfDir\redis.conf"
        Write-Host "Redis 配置文件下载成功" -ForegroundColor Green
    }
    catch {
        Write-Host "Redis 配置文件下载失败，请检查网络或 URL 地址" -ForegroundColor Red
    }
}

if ($selectedServices -contains "minio") {
    $minioConfFile = "D:\docker\minio\minio"
    New-Item -ItemType Directory -Force -Path (Split-Path $minioConfFile) | Out-Null
    @"
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_VOLUMES="/mnt/data"
MINIO_OPTS="--console-address :9001"
"@ | Out-File -FilePath $minioConfFile -Encoding UTF8
    Write-Host "MinIO 配置文件已生成" -ForegroundColor Green
}

if ($selectedServices -contains "moneyprinterturbo") {
    $moneyprinterturboDir = "D:\docker\MoneyPrinterTurbo"
    New-Item -ItemType Directory -Force -Path $moneyprinterturboDir | Out-Null
    $gitRepo = "https://gh-proxy.com/https://github.com/harry0703/MoneyPrinterTurbo.git"
    Write-Host "正在下载 MoneyPrinterTurbo 代码..." -ForegroundColor Cyan
    try {
        git clone $gitRepo $moneyprinterturboDir
        Write-Host "代码下载成功" -ForegroundColor Green
    }
    catch {
        Write-Host "代码下载失败，请检查网络或 URL 地址" -ForegroundColor Red
        exit 1
    }
}

if ($selectedServices -contains "mysql") {
    $mysqlRootPassword = Read-Host "请输入 MySQL root 密码"
    $mysqlDatabase = Read-Host "请输入 MySQL 数据库名称"
    (Get-Content $tempComposeFile) -replace 'MYSQL_ROOT_PASSWORD=.*# 替换为你的 MySQL root 密码', "MYSQL_ROOT_PASSWORD=$mysqlRootPassword" | Set-Content $tempComposeFile
    (Get-Content $tempComposeFile) -replace 'MYSQL_DATABASE=.*# 替换为你的数据库名称', "MYSQL_DATABASE=$mysqlDatabase" | Set-Content $tempComposeFile
    Write-Host "MySQL 配置已完成" -ForegroundColor Green
}

if ($selectedServices -contains "mongodb") {
    $mongoRootUsername = Read-Host "请输入 MongoDB root 用户名"
    $mongoRootPassword = Read-Host "请输入 MongoDB root 密码"
    (Get-Content $tempComposeFile) -replace 'MONGO_INITDB_ROOT_USERNAME=.*# 替换为你的 MongoDB root 用户名', "MONGO_INITDB_ROOT_USERNAME=$mongoRootUsername" | Set-Content $tempComposeFile
    (Get-Content $tempComposeFile) -replace 'MONGO_INITDB_ROOT_PASSWORD=.*# 替换为你的 MongoDB root 密码', "MONGO_INITDB_ROOT_PASSWORD=$mongoRootPassword" | Set-Content $tempComposeFile
    Write-Host "MongoDB 配置已完成" -ForegroundColor Green
}

if ($selectedServices -contains "postgresql") {
    $postgresUser = Read-Host "请输入 PostgreSQL 用户名"
    $postgresPassword = Read-Host "请输入 PostgreSQL 密码"
    $postgresDatabase = Read-Host "请输入 PostgreSQL 数据库名称"
    (Get-Content $tempComposeFile) -replace 'POSTGRES_USER=.*# 替换为你的 PostgreSQL 用户名', "POSTGRES_USER=$postgresUser" | Set-Content $tempComposeFile
    (Get-Content $tempComposeFile) -replace 'POSTGRES_PASSWORD=.*# 替换为你的 PostgreSQL 密码', "POSTGRES_PASSWORD=$postgresPassword" | Set-Content $tempComposeFile
    (Get-Content $tempComposeFile) -replace 'POSTGRES_DB=.*# 替换为你的数据库名称', "POSTGRES_DB=$postgresDatabase" | Set-Content $tempComposeFile
    Write-Host "PostgreSQL 配置已完成" -ForegroundColor Green
}

# 修改 docker-compose.yml 中挂载路径为 D:\docker
(Get-Content $tempComposeFile) -replace '/opt/([^:]+):', "D:\docker\`$1:" | Set-Content $tempComposeFile

# 启动所选服务
Write-Host "正在启动所选服务..." -ForegroundColor Cyan
docker compose -f $tempComposeFile up -d $selectedServices

Remove-Item $tempComposeFile

# 显示安装结果
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                          服务安装完成                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "已成功安装以下服务：" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Yellow
foreach ($service in $selectedServices) {
    for ($i = 0; $i -lt $services.Count; $i++) {
        if ($services[$i] -eq $service) {
            "{0,$maxWidth}. {1,-25} {2}" -f ($i + 1), $service, $serviceDescriptions[$i] | Write-Host -ForegroundColor White
            break
        }
    }
}
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Yellow
