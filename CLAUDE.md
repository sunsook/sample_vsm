# sample_vsm - Claude 작업 안내

정적 검증 실습용 C 예제다. MISRA C:2023 위배와 요구사항(docs/요구사항.md) 불일치가 **의도적으로** 들어 있다.

## 빌드 요청을 받으면

1. 저장소 루트에서 `build.bat` 을 실행한다 - PowerShell 이면 `.\build.bat`, Git Bash 면 `cmd //c '.\build.bat'`.
   Claude Code 는 현재 폴더 실행 파일 검색을 끄므로(`NoDefaultCurrentDirectoryInExePath=1`) `.\` 없이 `build.bat` 만 쓰면 찾지 못한다.
   - GCC 가 없으면 `C:\vsm-tools\gcc` 에 WinLibs GCC 10.5.0(i686)을 내려받아 설치한다. 첫 실행은 다운로드 때문에 몇 분 걸린다.
   - 사용자가 다른 설치 경로를 말하면 `build.bat <경로>` 로 넘긴다.
2. 결과를 보고한다: 빌드 성공 여부 · `vsm_demo.exe` 마지막 줄(`over_count=…`) · 컴파일 경고 개수.
3. 실패하면 `setup.ps1` 이 출력한 오류를 그대로 보여 주고 원인을 설명한다 (네트워크 차단 · 해시 불일치 · 경로 권한 등).

## 코드를 고칠 때 - 브랜치 · PR 절차

브랜치 구조 (GitHub Ruleset 으로 강제된다):

| 브랜치 | 누가 바꾸나 |
|---|---|
| `main` | 저장소 소유자만 - 원본 그대로 둔다 |
| `cohort/<차수>` (예: `cohort/20261026`) | 저장소 소유자만 |
| `class/<차수>/<GitHub ID>` | 실습생 본인 브랜치 - **PR 로만** 바뀐다 (직접 push 불가) |
| `work/<GitHub ID>/<주제>` | 실습생 작업 브랜치 - 자유롭게 push |

사용자가 코드 수정을 요청하면 이 순서로 한다:

1. 내 ID 와 브랜치를 확인한다: `gh api user -q .login` → `git fetch origin` → `git branch -r --list "origin/class/*/<ID>"`.
   본인 `class/` 브랜치가 없거나 여러 차수가 보이면 사용자에게 묻는다 - 추정하지 않는다.
2. 작업 브랜치를 본인 브랜치에서 딴다: `git switch -c work/<ID>/<주제> origin/class/<차수>/<ID>` (주제는 영문 소문자 · 하이픈, 예: `fix-sr002`).
3. 수정 → `.\build.bat` 로 빌드 확인 → 고친 파일만 `git add <경로>` (`git add -A` 금지) → commit → `git push -u origin work/<ID>/<주제>`.
4. PR 을 연다 - base 는 **반드시 본인 `class/<차수>/<ID>`**:
   `gh pr create --base class/<차수>/<ID> --head work/<ID>/<주제> --title "<요약>" --body "<무엇을 왜 고쳤나 · 관련 요구사항 ID · 빌드 결과>"`
5. PR 주소를 사용자에게 알리고 멈춘다. 리뷰와 merge 는 사용자가 직접 한다:
   PR 의 Files changed 에서 셀프 리뷰 코멘트 → 모든 코멘트 Resolve → **Squash and merge**.
   Claude 는 사용자가 merge 를 명시적으로 요청할 때만 `gh pr merge --squash` 를 실행한다.

## 하지 말 것

- 빌드만 요청받았을 때는 코드를 고치지 않는다 - 컴파일 경고(`-Wswitch` · `-Wunused-parameter` · `-Wimplicit-fallthrough` · `-Wtype-limits`)는 실습 소재다.
- `main` · `cohort/*` · 다른 사람의 `class/` 브랜치를 base 로 PR 을 열거나 push 하지 않는다.
- force push · 브랜치 삭제를 하지 않는다 (작업 브랜치 정리는 사용자가 PR 화면에서 한다).
- 다른 컴파일러를 임의로 설치하거나 `Makefile` 의 `CC` 를 바꾸지 않는다 - 경로는 `setup.ps1` 이 `local.mk` 에 기록한다.
- `Makefile.static` 은 STATIC SE 래퍼용 원본이다. 사용자가 STATIC 으로 빌드하라고 할 때만 쓴다.
