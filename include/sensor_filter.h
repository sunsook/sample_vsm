/* sensor_filter.h - 차속 센서 값 필터링 */

#ifndef VSM_SENSOR_FILTER_H
#define VSM_SENSOR_FILTER_H

#include "vsm_types.h"

/*
 * 샘플들의 산술 평균을 반환한다. 소수점 이하는 버린다 (SR-007)
 * count 는 1 이상 VSM_SAMPLE_MAX 이하이다 (SR-008)
 */
int16_t sf_average(int16_t *samples, uint8_t count);

/* 센서 값을 링 버퍼에 적재한다. 최근 VSM_SAMPLE_MAX 개를 유지한다 (SR-004) */
void sf_push(int16_t value);

/* 가장 최근에 sf_push() 로 넣은 센서 값을 반환한다 (SR-009) */
int16_t sf_latest(void);

#endif /* VSM_SENSOR_FILTER_H */
