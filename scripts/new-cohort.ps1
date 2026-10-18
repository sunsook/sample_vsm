# new-cohort.ps1 - 차수 브랜치와 실습생 브랜치를 main 에서 만든다 (저장소 소유자 전용)
#
# 사용법:
#   .\scripts\new-cohort.ps1 -Cohort 20261026 -Ids hong,kim,lee
#   .\scripts\new-cohort.ps1 -Cohort 20261026 -IdsFile ids.txt -Invite
#
# -Ids / -IdsFile : 실습생 GitHub ID (파일은 한 줄에 하나, # 은 주석)
# -Invite         : 실습생을 협업자(Write)로 초대한다 - 초대 메일이 발송되고, 본인이 수락해야 push 할 수 있다
# 이미 있는 브랜치 · 이미 협업자인 사람은 건너뛴다. 몇 번 다시 돌려도 된다.

param(
    [Parameter(Mandatory = $true)][string]$Cohort,
    [string[]]$Ids = @(),
    [string]$IdsFile,
    [switch]$Invite,
    [string]$Repo = 'sunsook/sample_vsm'
)

$ErrorActionPreference = 'Stop'

if ($Cohort -notmatch '^\d{8}$') { throw "차수는 교육 시작일 8자리여야 합니다 (예: 20261026): $Cohort" }

if ($IdsFile) {
    $Ids += Get-Content -Encoding UTF8 $IdsFile | ForEach-Object { ($_ -split '#')[0].Trim() } | Where-Object { $_ }
}
$Ids = @($Ids | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique)

function Invoke-Gh {
    param([string[]]$GhArgs)
    # Windows PowerShell 5.1 은 Stop 상태에서 네이티브 stderr 를 예외로 바꾼다 - 여기서는 종료 코드로 판정한다
    $ErrorActionPreference = 'Continue'
    $out = & gh @GhArgs 2>&1
    return [pscustomobject]@{ Ok = ($LASTEXITCODE -eq 0); Out = ($out | Out-String).Trim() }
}

function New-Branch([string]$Name, [string]$Sha) {
    $r = Invoke-Gh @('api', '-X', 'POST', "repos/$Repo/git/refs", '-f', "ref=refs/heads/$Name", '-f', "sha=$Sha")
    if ($r.Ok) { return '생성' }
    if ($r.Out -match 'Reference already exists') { return '이미 있음' }
    throw "브랜치 생성 실패 ($Name): $($r.Out)"
}

$me = (Invoke-Gh @('api', 'user', '-q', '.login')).Out
$perm = (Invoke-Gh @('api', "repos/$Repo", '-q', '.permissions.admin')).Out
if ($perm -ne 'true') { throw "저장소 관리자만 실행할 수 있습니다 (현재 gh 로그인: $me)" }

$main = Invoke-Gh @('api', "repos/$Repo/git/ref/heads/main", '-q', '.object.sha')
if (-not $main.Ok) { throw "main 을 읽지 못했습니다: $($main.Out)" }
$sha = $main.Out

$rows = @()
$rows += [pscustomobject]@{ 브랜치 = "cohort/$Cohort"; 결과 = (New-Branch "cohort/$Cohort" $sha); 초대 = '-' }

foreach ($id in $Ids) {
    # GitHub 에 있는 계정인지 확인하고, 브랜치 이름은 GitHub 이 돌려준 표기(login)를 쓴다
    $u = Invoke-Gh @('api', "users/$id", '-q', '.login')
    if (-not $u.Ok) {
        $rows += [pscustomobject]@{ 브랜치 = "class/$Cohort/$id"; 결과 = '계정 없음 - 건너뜀'; 초대 = '-' }
        continue
    }
    $login = $u.Out
    $result = New-Branch "class/$Cohort/$login" $sha

    $inv = '-'
    if ($Invite) {
        $c = Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/collaborators/$login", '-f', 'permission=push')
        if (-not $c.Ok) { $inv = "실패: $($c.Out)" }
        elseif ($c.Out) { $inv = '초대 발송' }
        else { $inv = '이미 협업자' }
    }
    $rows += [pscustomobject]@{ 브랜치 = "class/$Cohort/$login"; 결과 = $result; 초대 = $inv }
}

$rows | Format-Table -AutoSize
Write-Host "기준 커밋: main $($sha.Substring(0, 7))"
