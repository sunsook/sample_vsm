/* diag_log.h - 진단 이력 기록 및 상태 레지스터 접근 */

#ifndef VSM_DIAG_LOG_H
#define VSM_DIAG_LOG_H

#include "vsm_types.h"

/* 판정된 경고 등급을 매 주기 진단 이력에 기록한다 (SR-006) */
void dl_record(vsm_warn_t warn);

/* 임계값 문자열을 숫자로 변환한다. 숫자로 해석되지 않으면 -1 을 반환한다 (SR-011) */
int32_t dl_parse_threshold(const char *text);

/* 진단 상태 레지스터를 읽는다 (타깃 보드 전용) */
uint32_t dl_read_status_reg(void);

#endif /* VSM_DIAG_LOG_H */
