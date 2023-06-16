/**
 * @file MathUtil.h
 * @brief 常用的数字常数和实用工具
 *
 * 更多信息，参考 MathUtil.cpp
 */

#ifndef __MATHUTIL_H_INCLUDED__
#define __MATHUTIL_H_INCLUDED__

#include <math.h>

// Declare a global constant for pi and a few multiples.
const float kPi = 3.14159265f; /**< Pi */
const float k2Pi = kPi * 2.0f; /**< 2Pi */
const float kPiOver2 = kPi / 2.0f; /**< Pi 除以 2 */
const float k1OverPi = 1.0f / kPi; /**< 1 除以 Pi */
const float k1Over2Pi = 1.0f / k2Pi; /**< 1 除以 2Pi */
const float kPiOver180 = kPi / 180.0f; /**< Pi 除以 180 */
const float k180OverPi = 180.0f / kPi; /**< 180 除以 Pi */

/** @brief 通过加适当的 2pi 倍数将角度限制在 -pi 到 pi 的区间内 */
extern float wrapPi(float theta);

/** @brief 安全的反三角函数 */
extern float safeAcos(float x);

/** @brief 度转弧度 */
inline float degToRad(float deg) { return deg * kPiOver180; }
/** @brief 弧度转度 */
inline float radToDeg(float rad) { return rad * k180OverPi; }

/**
 * @brief 计算角度的 sin 和 cos 值
 *
 * 在某些平台上，如果需要这两个值，同时计算要比分开计算快
 */
inline void sinCos(float *returnSin, float *returnCos, float theta) {

  // For simplicity, we'll just use the normal trig functions.
  // Note that on some platforms we may be able to do better
  *returnSin = sin(theta);
  *returnCos = cos(theta);
}

/**
 * @brief 视场转缩放，FOV 为弧度
 *
 * 更多信息参考 15.2.4 节
 */
inline float fovToZoom(float fov) { return 1.0f / tan(fov * .5f); }
/**
 * @brief 缩放转视场
 *
 * 更多信息参考 15.2.4 节
 */
inline float zoomToFov(float zoom) { return 2.0f * atan(1.0f / zoom); }

/////////////////////////////////////////////////////////////////////////////
#endif // #ifndef __MATHUTIL_H_INCLUDED__
