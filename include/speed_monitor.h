/* speed_monitor.h - 차속 기반 경고 등급 판정 */

#ifndef VSM_SPEED_MONITOR_H
#define VSM_SPEED_MONITOR_H

#include "vsm_types.h"

/*
 * 현재 차속과 제동 상태로 경고 등급을 판정한다
 *   - 차속 200 km/h 이상: HIGH (SR-002)
 *   - 차속 150 km/h 초과 200 km/h 미만: MID (SR-003)
 * HIGH 로 판정할 때마다 과속 카운터를 1 늘린다 (SR-010)
 */
vsm_warn_t sm_evaluate(uint16_t speed_kph, bool brake_on);

/* 과속 카운터를 초기화한다. 대상 ECU 는 인자로 지정한다 (SR-005) */
void sm_reset(uint16_t ecu_id);

/* 누적 과속 횟수를 반환한다 (SR-010) */
uint32_t sm_over_count(void);

#endif /* VSM_SPEED_MONITOR_H */
