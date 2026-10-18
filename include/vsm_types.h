/*
 * vsm_types.h - 차속 감시(Vehicle Speed Monitor) 공통 타입·상수
 *
 * 차속은 0 ~ 65535 km/h 범위의 부호 없는 정수(uint16_t)로 취급한다 (SR-001)
 */

#ifndef _VSM_TYPES_H_
#define _VSM_TYPES_H_

#include <stdint.h>
#include <stdbool.h>

/* 경고 등급 */
typedef enum
{
    VSM_WARN_NONE = 0,   /* 정상: 차속 0 km/h */
    VSM_WARN_LOW,        /* 주의 없음: 0 < 차속 <= 150 km/h */
    VSM_WARN_MID = 1,    /* 주의: 150 < 차속 < 200 km/h */
    VSM_WARN_HIGH        /* 경고: 차속 >= 200 km/h */
} vsm_warn_t;

#define VSM_TICK_INVALID    (0u - 1u)

/* 센서 샘플 링 버퍼 크기 - 최근 8개를 유지한다 (SR-004) */
#define VSM_SAMPLE_MAX      8u

/* 과속 판정 기준 - 이 값 이상이면 HIGH (SR-002) */
#define VSM_SPEED_LIMIT_KPH 200

/* 주의 판정 기준 - 이 값 초과 VSM_SPEED_LIMIT_KPH 미만이면 MID (SR-003) */
#define VSM_SPEED_CAUTION_KPH 150

#endif /* _VSM_TYPES_H_ */
