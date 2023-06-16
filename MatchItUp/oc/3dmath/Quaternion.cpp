#include <assert.h>
#include <math.h>

#include "Quaternion.h"
#include "MathUtil.h"
#include "Vector3.h"
#include "EulerAngles.h"

/////////////////////////////////////////////////////////////////////////////
//
// 全局数据
//
/////////////////////////////////////////////////////////////////////////////

/** 注意 Quaternion 类没有构造函数，因为我们不需要 */
const Quaternion kQuaternionIdentity = {
  1.0f, 0.0f, 0.0f, 0.0f
};

/////////////////////////////////////////////////////////////////////////////
//
// Quaternion 类成员
//
/////////////////////////////////////////////////////////////////////////////

void Quaternion::setToRotateAboutX(float theta) {

  // 计算半角
  float	thetaOver2 = theta * .5f;

  // 赋值
  w = cos(thetaOver2);
  x = sin(thetaOver2);
  y = 0.0f;
  z = 0.0f;
}

void Quaternion::setToRotateAboutY(float theta) {

  // 计算半角
  float	thetaOver2 = theta * .5f;

  // 赋值
  w = cos(thetaOver2);
  x = 0.0f;
  y = sin(thetaOver2);
  z = 0.0f;
}

void Quaternion::setToRotateAboutZ(float theta) {

  // 计算半角
  float	thetaOver2 = theta * .5f;

  // 赋值
  w = cos(thetaOver2);
  x = 0.0f;
  y = 0.0f;
  z = sin(thetaOver2);
}

void Quaternion::setToRotateAboutAxis(const Vector3 &axis, float theta) {

  // 旋转轴必须被标准化
  assert(fabs(vectorMag(axis) - 1.0f) < .01f);

  // 计算半角和 sin 值 
  float	thetaOver2 = theta * .5f;
  float	sinThetaOver2 = sin(thetaOver2);

  // 赋值
  w = cos(thetaOver2);
  x = axis.x * sinThetaOver2;
  y = axis.y * sinThetaOver2;
  z = axis.z * sinThetaOver2;
}

/** 更多信息参考 10.6.5 节 */
void Quaternion::setToRotateObjectToInertial(const EulerAngles &orientation) {

  // Compute sine and cosine of the half angles
  float	sp, sb, sh;
  float	cp, cb, ch;
  sinCos(&sp, &cp, orientation.pitch * 0.5f);
  sinCos(&sb, &cb, orientation.bank * 0.5f);
  sinCos(&sh, &ch, orientation.heading * 0.5f);

  // Compute values
  w =  ch*cp*cb + sh*sp*sb;
  x =  ch*sp*cb + sh*cp*sb;
  y = -ch*sp*sb + sh*cp*cb;
  z = -sh*sp*cb + ch*cp*sb;
}

/** 更多信息参考 10.6.5 节 */
void Quaternion::setToRotateInertialToObject(const EulerAngles &orientation) {
  // Compute sine and cosine of the half angles
  float	sp, sb, sh;
  float	cp, cb, ch;
  sinCos(&sp, &cp, orientation.pitch * 0.5f);
  sinCos(&sb, &cb, orientation.bank * 0.5f);
  sinCos(&sh, &ch, orientation.heading * 0.5f);

  // Compute values
  w =  ch*cp*cb + sh*sp*sb;
  x = -ch*sp*cb - sh*cp*sb;
  y =  ch*sp*sb - sh*cb*cp;
  z =  sh*sp*cb - ch*cp*sb;
}

/**
 * 用以连接多个角位移，乘的顺序是从左向右
 *
 * 这和四元数叉乘的“标准”定义相反
 *
 * 更多信息参考 10.4.8 节
 */
Quaternion Quaternion::operator *(const Quaternion &a) const {
  Quaternion result;

  result.w = w*a.w - x*a.x - y*a.y - z*a.z;
  result.x = w*a.x + x*a.w + z*a.y - y*a.z;
  result.y = w*a.y + y*a.w + x*a.z - z*a.x;
  result.z = w*a.z + z*a.w + y*a.x - x*a.y;

  return result;
}

Quaternion &Quaternion::operator *=(const Quaternion &a) {
  // Multuiply and assign
  *this = *this * a;

  // Return reference to l-value
  return *this;
}

/**
 * 通常四元数都是正则化的，参考 10.4.6 节
 *
 * 提供这和函数主要是为了防止误差扩大，连续多个四元数
 * 操作可能导致误差扩大
 */
void Quaternion::normalize() {
  // Compute magnitude of the quaternion
  float	mag = (float)sqrt(w*w + x*x + y*y + z*z);

  // Check for bogus length, to protect against divide by zero
  if (mag > 0.0f) {
    // Normalize it
    float oneOverMag = 1.0f / mag;
    w *= oneOverMag;
    x *= oneOverMag;
    y *= oneOverMag;
    z *= oneOverMag;
  } else {
    // Houston, we have a problem
    assert(false);
    // In a release build, just slam it to something
    identity();
  }
}

float Quaternion::getRotationAngle() const {
  // Compute the half angle.  Remember that w = cos(theta / 2)
  float thetaOver2 = safeAcos(w);

  // Return the rotation angle
  return thetaOver2 * 2.0f;
}

Vector3	Quaternion::getRotationAxis() const {
  // Compute sin^2(theta/2).  Remember that w = cos(theta/2),
  // and sin^2(x) + cos^2(x) = 1
  float sinThetaOver2Sq = 1.0f - w*w;

  // Protect against numerical imprecision
  if (sinThetaOver2Sq <= 0.0f) {
    // Identity quaternion, or numerical imprecision.  Just
    // return any valid vector, since it doesn't matter
    return Vector3(1.0f, 0.0f, 0.0f);
  }

  // Compute 1 / sin(theta/2)
  float	oneOverSinThetaOver2 = 1.0f / sqrt(sinThetaOver2Sq);

  // Return axis of rotation
  return Vector3(
      x * oneOverSinThetaOver2,
      y * oneOverSinThetaOver2,
      z * oneOverSinThetaOver2
                 );
}

/////////////////////////////////////////////////////////////////////////////
//
// Nonmember functions
//
/////////////////////////////////////////////////////////////////////////////

/**
 * 用非成员函数实现四元数点乘以避免在表达式中使用时
 * 出现 “怪异语法”
 *
 * 更多信息参考 10.4.10 节 */
float dotProduct(const Quaternion &a, const Quaternion &b) {
  return a.w*b.w + a.x*b.x + a.y*b.y + a.z*b.z;
}

/** 更多信息参考 10.4.13 节 */
Quaternion slerp(const Quaternion &q0, const Quaternion &q1, float t) {
  // Check for out-of range parameter and return edge points if so
  if (t <= 0.0f) return q0;
  if (t >= 1.0f) return q1;

  // Compute "cosine of angle between quaternions" using dot product
  float cosOmega = dotProduct(q0, q1);

  // If negative dot, use -q1.  Two quaternions q and -q
  // represent the same rotation, but may produce
  // different slerp.  We chose q or -q to rotate using
  // the acute angle.
  float q1w = q1.w;
  float q1x = q1.x;
  float q1y = q1.y;
  float q1z = q1.z;
  if (cosOmega < 0.0f) {
    q1w = -q1w;
    q1x = -q1x;
    q1y = -q1y;
    q1z = -q1z;
    cosOmega = -cosOmega;
  }

  // We should have two unit quaternions, so dot should be <= 1.0
  assert(cosOmega < 1.1f);

  // Compute interpolation fraction, checking for quaternions
  // almost exactly the same
  float k0, k1;
  if (cosOmega > 0.9999f) {
    // Very close - just use linear interpolation,
    // which will protect againt a divide by zero
    k0 = 1.0f-t;
    k1 = t;
  } else {
    // Compute the sin of the angle using the
    // trig identity sin^2(omega) + cos^2(omega) = 1
    float sinOmega = sqrt(1.0f - cosOmega*cosOmega);

    // Compute the angle from its sin and cosine
    float omega = atan2(sinOmega, cosOmega);

    // Compute inverse of denominator, so we only have
    // to divide once
    float oneOverSinOmega = 1.0f / sinOmega;

    // Compute interpolation parameters
    k0 = sin((1.0f - t) * omega) * oneOverSinOmega;
    k1 = sin(t * omega) * oneOverSinOmega;
  }

  // Interpolate
  Quaternion result;
  result.x = k0*q0.x + k1*q1x;
  result.y = k0*q0.y + k1*q1y;
  result.z = k0*q0.z + k1*q1z;
  result.w = k0*q0.w + k1*q1w;

  // Return it
  return result;
}

/**
 * 即与原四元数旋转方向相反的四元数
 *
 * 更多信息参考 10.4.7 节
 */
Quaternion conjugate(const Quaternion &q) {
  Quaternion result;

  // Same rotation amount
  result.w = q.w;

  // Opposite axis of rotation
  result.x = -q.x;
  result.y = -q.y;
  result.z = -q.z;

  // Return it
  return result;
}

/** 更多信息参考 10.4.12 节 */
Quaternion pow(const Quaternion &q, float exponent) {

  // Check for the case of an identity quaternion.
  // This will protect against divide by zero
  if (fabs(q.w) > .9999f) {
    return q;
  }

  // Extract the half angle alpha (alpha = theta/2)
  float	alpha = acos(q.w);

  // Compute new alpha value
  float	newAlpha = alpha * exponent;

  // Compute new w value
  Quaternion result;
  result.w = cos(newAlpha);

  // Compute new xyz values
  float	mult = sin(newAlpha) / sin(alpha);
  result.x = q.x * mult;
  result.y = q.y * mult;
  result.z = q.z * mult;

  // Return it
  return result;
}

/** 此函数转出的四元数，通过转化为旋转矩阵不正交 */
Quaternion getRotationBetween(const Vector3 &from, const Vector3 &to) {
  float d = from * to;
  float k = sqrt((from * from) * (to * to));
  Vector3 v3;
  Quaternion result;
  
  if((d+k) < 0.0001f) {
    result.w = 0.0f;
    result.x = -from.z;
    result.y = from.y;
    result.z = from.x;
  }else{
    result.w = d + k;
    v3 = crossProduct(from,to);
    result.x = v3.x;
    result.y = v3.y;
    result.z = v3.z;
  }
  result.normalize();
  return result;
}

