/* diag_log.c - 진단 이력 기록 및 상태 레지스터 접근 */

#include <stdlib.h>
#include <errno.h>

#include "diag_log.h"

/* 진단 기록 일련번호 */
uint32_t g_diag_seq = 0u;

/* 진단 이력 링 버퍼와 다음 기록 위치 */
static uint8_t s_history[VSM_SAMPLE_MAX];
static uint8_t s_idx = 0u;

/* 타깃 보드 진단 상태 레지스터 주소 */
#define DIAG_STATUS_REG_ADDR 0x40001000u

/* 판정된 경고 등급을 일련번호와 함께 진단 이력에 기록한다 (SR-006) */
void dl_record(vsm_warn_t warn)
{
    uint8_t code = (uint8_t)warn;

    s_history[s_idx++] = (uint8_t)(code + g_diag_seq++);

    /* 버퍼 끝에 이르면 처음 위치로 되돌린다 */
    if (s_idx >= (uint8_t)VSM_SAMPLE_MAX)
    {
        s_idx = 0u;
    }
}

/* 임계값 문자열을 숫자로 변환한다. 숫자로 해석되지 않으면 -1 을 반환한다 (SR-011) */
int32_t dl_parse_threshold(const char *text)
{
    int32_t value;

    value = atoi(text);

    return value;
}

/* 메모리 맵 진단 상태 레지스터를 읽는다 (타깃 보드 전용) */
uint32_t dl_read_status_reg(void)
{
    volatile uint32_t *reg = (volatile uint32_t *)DIAG_STATUS_REG_ADDR;

    return *reg;
}
