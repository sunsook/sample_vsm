# sample_vsm - Claude 작업 안내

정적 검증 실습용 C 예제다. MISRA C:2023 위배와 요구사항(docs/요구사항.md) 불일치가 **의도적으로** 들어 있다.

## 빌드 요청을 받으면

1. 저장소 루트에서 `build.bat` 을 실행한다 - PowerShell 이면 `.\build.bat`, Git Bash 면 `cmd //c '.\build.bat'`.
   Claude Code 는 현재 폴더 실행 파일 검색을 끄므로(`NoDefaultCurrentDirectoryInExePath=1`) `.\` 없이 `build.bat` 만 쓰면 찾지 못한다.
   - GCC 가 없으면 `C:\vsm-tools\gcc` 에 WinLibs GCC 10.5.0(i686)을 내려받아 설치한다. 첫 실행은 다운로드 때문에 몇 분 걸린다.
   - 사용자가 다른 설치 경로를 말하면 `build.bat <경로>` 로 넘긴다.
2. 결과를 보고한다: 빌드 성공 여부 · `vsm_demo.exe` 마지막 줄(`over_count=…`) · 컴파일 경고 개수.
3. 실패하면 `setup.ps1` 이 출력한 오류를 그대로 보여 주고 원인을 설명한다 (네트워크 차단 · 해시 불일치 · 경로 권한 등).

## 하지 말 것

- 코드 수정 금지 - 컴파일 경고(`-Wswitch` · `-Wunused-parameter` · `-Wimplicit-fallthrough` · `-Wtype-limits`)는 실습 소재다.
- 다른 컴파일러를 임의로 설치하거나 `Makefile` 의 `CC` 를 바꾸지 않는다 - 경로는 `setup.ps1` 이 `local.mk` 에 기록한다.
- `Makefile.static` 은 STATIC SE 래퍼용 원본이다. 사용자가 STATIC 으로 빌드하라고 할 때만 쓴다.
