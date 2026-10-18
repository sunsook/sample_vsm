/* speed_monitor.c - 차속 기반 경고 등급 판정 */

#include "speed_monitor.h"

/* 과속 카운터 - HIGH 판정 횟수 (SR-010) */
static uint32_t s_over_count = 0u;

/*
 * 차속과 제동 상태로 경고 등급을 판정한다
 *   - 차속 200 km/h 이상: HIGH (SR-002)
 *   - 차속 150 km/h 초과 200 km/h 미만: MID (SR-003)
 * HIGH 로 판정할 때마다 과속 카운터를 1 늘린다 (SR-010)
 */
vsm_warn_t sm_evaluate(uint16_t speed_kph, bool brake_on)
{
    int32_t level;
    vsm_warn_t warn;

    /* 과속 판정 (SR-002) - 과속 카운터 증가 (SR-010) */
    if (speed_kph > VSM_SPEED_LIMIT_KPH)
    {
        level = 3;
        s_over_count++;
    }
    /* 주의 판정 (SR-003) */
    else if (speed_kph > VSM_SPEED_CAUTION_KPH)
    {
        level = 2;
    }
    else
    {
        level = 1;
    }

    /* 제동 중이면 등급을 한 단계 올린다 */
    level = level + brake_on;

    warn = (vsm_warn_t)level;

    switch (warn)
    {
        case VSM_WARN_NONE:
            warn = VSM_WARN_LOW;
        case VSM_WARN_HIGH:
            warn = VSM_WARN_HIGH;
            break;
    }

    return warn;
}

/* 과속 카운터를 초기화한다. 대상 ECU 는 인자로 지정한다 (SR-005) */
void sm_reset(uint16_t ecu_id)
{
    s_over_count = 0u;
}

/* 누적 과속 횟수를 반환한다 (SR-010) */
uint32_t sm_over_count(void)
{
    return s_over_count;
}
