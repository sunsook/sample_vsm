# vsm_STATIC — VSM(Vehicle Speed Monitor) 예제 원본

차속 센서 값을 받아 잡음을 거르고, 차속에 따라 경고 등급을 판정해 진단 이력에 남기는 C 모듈입니다.
MISRA C:2023 위배가 일부러 들어 있습니다. 코드 주석에는 로직 설명과 요구사항 ID(`docs/요구사항.md` SR-001 ~ SR-011)만 남기고 위배 표시는 달지 않았습니다.

## 구성

```
vsm_STATIC/
  build.bat          GCC 설치(필요할 때만) → 빌드 → vsm_demo.exe 실행
  setup.ps1          GCC(WinLibs 10.5.0 i686)를 C:\vsm-tools\gcc 에 설치 · local.mk 작성
  Makefile           일반 GCC 빌드 — CC 는 local.mk(없으면 PATH 의 gcc) · 산출물 vsm_demo.exe
  Makefile.static    STATIC SE 래퍼(GCC9.5) 빌드용 원본 Makefile
  config.bat         (STATIC 용) CT 동봉 gcc 9.5.0 을 PATH 에 · chcp 65001
  make.cmd           (STATIC 용) mingw32-make 호출
  CLAUDE.md          Claude Code 빌드 · 브랜치 · PR 안내
  scripts/
    new-cohort.ps1   (소유자 전용) 차수 · 실습생 브랜치 생성, 협업자 초대
  docs/요구사항.md    요구사항 SR-001 ~ SR-011
  include/
    vsm_types.h      경고 등급 enum(vsm_warn_t) · 차속 한계값 · 샘플 수
    speed_monitor.h  차속 판정
    sensor_filter.h  센서 필터
    diag_log.h       진단 이력
  src/
    main.c           데모 진입점 — 차속 0 ~ 220 을 20 씩 올리며 판정 결과를 출력
    speed_monitor.c  sm_evaluate() · sm_reset() · sm_over_count()
    sensor_filter.c  sf_push() · sf_latest() · sf_average() — 8칸 링 버퍼
    diag_log.c       dl_record() · dl_parse_threshold() · dl_read_status_reg()
```

## 함수

| 함수 | 하는 일 |
|---|---|
| `sm_evaluate(speed_kph, brake_on)` | 차속으로 경고 등급(NONE · LOW · MID · HIGH)을 판정하고 과속 횟수를 센다 |
| `sm_reset(ecu_id)` | 과속 카운터 초기화 |
| `sm_over_count()` | 과속 횟수 |
| `sf_push(value)` · `sf_latest()` | 링 버퍼에 센서 값을 넣고 · 최근 값을 꺼낸다 |
| `sf_average(samples, count)` | 샘플 평균 |
| `dl_record(warn)` | 경고 등급을 진단 이력에 기록 |
| `dl_parse_threshold(text)` | 임계값 문자열을 숫자로 — 해석 못 하면 -1 |
| `dl_read_status_reg()` | 하드웨어 상태 레지스터(`0x40001000`) 읽기 — PC 에서는 호출하지 않는다 |

## 빌드 · 실행

준비물은 Windows 10 이상 · Git · 인터넷 연결입니다. 컴파일러는 첫 실행 때 자동으로 받습니다(약 190MB, 해시 검증 후 설치).

```
git clone https://github.com/sunsook/sample_vsm
cd sample_vsm
.\build.bat                  # 설치 경로를 바꾸려면 .\build.bat D:\tools\gcc
```

Claude Code 에서는 이 폴더를 열고 「빌드해줘」라고 하면 `CLAUDE.md` 안내대로 같은 과정을 실행합니다.

정상이면 마지막 줄에 `over_count=1` 이 나옵니다. 컴파일 경고 5건(`-Wswitch` 등)은 의도된 위배에서 나오는 것입니다.

## 브랜치 · PR 규칙

| 브랜치 | 누가 바꾸나 |
|---|---|
| `main` | 저장소 소유자만 — 원본 그대로 둡니다 |
| `cohort/<교육 시작일>` (예: `cohort/20261026`) | 저장소 소유자만 |
| `class/<교육 시작일>/<GitHub ID>` | 실습생 본인 브랜치 — PR 로만 바뀝니다 |
| `work/<GitHub ID>/<주제>` | 실습생 작업 브랜치 — 자유롭게 push |

실습생은 본인 `class/` 브랜치에서 `work/` 브랜치를 따서 고치고, 본인 `class/` 브랜치로 PR 을 엽니다.
PR 은 승인 0건으로 merge 할 수 있지만, 리뷰 코멘트가 있으면 모두 Resolve 해야 하고 merge 방식은 Squash 만 됩니다.
Claude Code 에서 「SR-002 고쳐서 PR 올려줘」처럼 요청하면 `CLAUDE.md` 절차대로 브랜치 · PR 을 만듭니다(GitHub CLI `gh` 로그인 필요).

### STATIC SE 래퍼로 빌드할 때

CT · STATIC SE 가 설치된 PC 에서만 씁니다.

```
config.bat
make.cmd -f Makefile.static clean
make.cmd -f Makefile.static
vsm_demo.exe
```
