# setup.ps1 - 빌드용 GCC(WinLibs 10.5.0 i686)를 설치하고 local.mk / local.cmd 를 만든다
#
# 사용법: powershell -ExecutionPolicy Bypass -File setup.ps1 [-InstallDir <경로>]
# 이미 설치돼 있으면 다운로드를 건너뛴다.

param(
    [string]$InstallDir = 'C:\vsm-tools\gcc'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Url    = 'https://github.com/brechtsanders/winlibs_mingw/releases/download/10.5.0-11.0.1-msvcrt-r2/winlibs-i686-posix-dwarf-gcc-10.5.0-mingw-w64msvcrt-11.0.1-r2.zip'
$Sha256 = '1f7b6eb332e100055df03ae4c02cf78a0111cd59a02c16e1e352cfa937a56a87'

$Bin = Join-Path $InstallDir 'bin'
$Gcc = Join-Path $Bin 'gcc.exe'

if (Test-Path $Gcc) {
    Write-Host "[setup] GCC 가 이미 설치돼 있습니다: $Gcc"
}
else {
    $Work = Join-Path $env:TEMP ('vsm-gcc-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force $Work | Out-Null
    $Zip = Join-Path $Work 'gcc.zip'

    try {
        Write-Host "[setup] GCC 다운로드 중 (약 190MB) ..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $Url -OutFile $Zip -UseBasicParsing

        # 받은 파일이 고정해 둔 해시와 다르면 설치하지 않는다
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $fs = [System.IO.File]::OpenRead($Zip)
        try { $actual = -join ($sha.ComputeHash($fs) | ForEach-Object { $_.ToString('x2') }) }
        finally { $fs.Dispose() }
        if ($actual -ne $Sha256) {
            throw "다운로드 파일 해시가 다릅니다 (기대 $Sha256 / 실제 $actual)"
        }

        Write-Host "[setup] 압축 해제 중 ..."
        $tar = Join-Path $env:SystemRoot 'System32\tar.exe'
        if (Test-Path $tar) {
            & $tar -xf $Zip -C $Work
            if ($LASTEXITCODE -ne 0) { throw "tar 압축 해제 실패 (exit $LASTEXITCODE)" }
        }
        else {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($Zip, $Work)
        }

        # zip 안의 mingw32 폴더를 설치 경로로 옮긴다
        $parent = Split-Path $InstallDir -Parent
        if ($parent) { New-Item -ItemType Directory -Force $parent | Out-Null }
        Move-Item -Path (Join-Path $Work 'mingw32') -Destination $InstallDir
    }
    finally {
        Remove-Item -Recurse -Force $Work -ErrorAction SilentlyContinue
    }

    if (-not (Test-Path $Gcc)) {
        throw "설치 후에도 gcc.exe 가 없습니다: $Gcc"
    }
    Write-Host "[setup] GCC 설치 완료: $InstallDir"
}

# make 가 읽을 컴파일러 경로와, build.bat 이 읽을 PATH 를 기록한다 (둘 다 저장소에 올리지 않는다)
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ccPath = $Gcc -replace '\\', '/'
Set-Content -Path (Join-Path $here 'local.mk') -Encoding ASCII -Value "CC = $ccPath"
Set-Content -Path (Join-Path $here 'local.cmd') -Encoding ASCII -Value "@set `"PATH=$Bin;%PATH%`""

& $Gcc --version | Select-Object -First 1
