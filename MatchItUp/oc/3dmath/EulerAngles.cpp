#include <math.h>

#include "EulerAngles.h"
#include "Quaternion.h"
#include "MathUtil.h"
#include "Matrix4x3.h"
#include "RotationMatrix.h"

/////////////////////////////////////////////////////////////////////////////
//
// 全局数据
//
/////////////////////////////////////////////////////////////////////////////

/**
 * 现在我们还不知道构造它的确切时机，这要取决于其它对象，
 * 因此可能在该对象被初始化之前就引用它。不过在大多数实
 * 现中，它将在程序开始时被初始化为 0，即发生在其它对象
 * 被构造之前。
 */
const EulerAngles kEulerAnglesIdentity(0.0f, 0.0f, 0.0f);

/////////////////////////////////////////////////////////////////////////////
//
// 欧拉角类实现
//
/////////////////////////////////////////////////////////////////////////////

/**
 * 就表示 3D 方位的目的而言，它不会改变欧拉角的值，
 * 但对于其它表示对象如角速度等，则会产生影响
 *
 * 更多信息参见 10.3 节
 */
void EulerAngles::canonize() {

  // First, wrap pitch in range -pi ... pi
  pitch = wrapPi(pitch);

  // Now, check for "the back side" of the matrix, pitch outside
  // the canonical range of -pi/2 ... pi/2
  if (pitch < -kPiOver2) {
    pitch = -kPi - pitch;
    heading += kPi;
    bank += kPi;
  } else if (pitch > kPiOver2) {
    pitch = kPi - pitch;
    heading += kPi;
    bank += kPi;
  }

  // OK, now check for the gimbel lock case (within a slight
  // tolerance)
  if (fabs(pitch) > kPiOver2 - 1e-4) {
    // We are in gimbel lock.  Assign all rotation
    // about the vertical axis to heading
    heading += bank;
    bank = 0.0f;

  } else {

    // Not in gimbel lock.  Wrap the bank angle in
    // canonical range 

    bank = wrapPi(bank);
  }

  // Wrap heading in canonical range

  heading = wrapPi(heading);
}

/**
 * 更多信息参见 10.6.6 节
 */
void EulerAngles::fromObjectToInertialQuaternion(const Quaternion &q) {

  // Extract sin(pitch)
  float sp = -2.0f * (q.y*q.z - q.w*q.x);

  // Check for Gimbel lock, giving slight tolerance for numerical imprecision
  if (fabs(sp) > 0.9999f) {
    // Looking straight up or down
    pitch = kPiOver2 * sp;

    // Compute heading, slam bank to zero
    heading = atan2(-q.x*q.z + q.w*q.y, 0.5f - q.y*q.y - q.z*q.z);
    bank = 0.0f;

  } else {
    // Compute angles.  We don't have to use the "safe" asin
    // function because we already checked for range errors when
    // checking for Gimbel lock
    pitch	= asin(sp);
    heading	= atan2(q.x*q.z + q.w*q.y, 0.5f - q.x*q.x - q.y*q.y);
    bank	= atan2(q.x*q.y + q.w*q.z, 0.5f - q.x*q.x - q.z*q.z);
  }
}

/**
 * 更多信息参见 10.6.6 节
 */
void EulerAngles::fromInertialToObjectQuaternion(const Quaternion &q) {

  // Extract sin(pitch)
  float sp = -2.0f * (q.y*q.z + q.w*q.x);

  // Check for Gimbel lock, giving slight tolerance for numerical imprecision
  if (fabs(sp) > 0.9999f) {
    // Looking straight up or down
    pitch = kPiOver2 * sp;

    // Compute heading, slam bank to zero
    heading = atan2(-q.x*q.z - q.w*q.y, 0.5f - q.y*q.y - q.z*q.z);
    bank = 0.0f;

  } else {
    // Compute angles.  We don't have to use the "safe" asin
    // function because we already checked for range errors when
    // checking for Gimbel lock
    pitch	= asin(sp);
    heading	= atan2(q.x*q.z - q.w*q.y, 0.5f - q.x*q.x - q.y*q.y);
    bank	= atan2(q.x*q.y - q.w*q.z, 0.5f - q.x*q.x - q.z*q.z);
  }
}

/**
 * 更多信息参见 10.6.2 节
 */
void EulerAngles::fromObjectToWorldMatrix(const Matrix4x3 &m) {

  // Extract sin(pitch) from m32.
  float	sp = -m.m32;

  // Check for Gimbel lock
  if (fabs(sp) > 9.99999f) {
    // Looking straight up or down
    pitch = kPiOver2 * sp;

    // Compute heading, slam bank to zero
    heading = atan2(-m.m23, m.m11);
    bank = 0.0f;

  } else {
    // Compute angles.  We don't have to use the "safe" asin
    // function because we already checked for range errors when
    // checking for Gimbel lock
    heading = atan2(m.m31, m.m33);
    pitch = asin(sp);
    bank = atan2(m.m12, m.m22);
  }
}

/**
 * 更多信息参见 10.6.2 节
 */
void EulerAngles::fromWorldToObjectMatrix(const Matrix4x3 &m) {

  // Extract sin(pitch) from m23.
  float	sp = -m.m23;

  // Check for Gimbel lock
  if (fabs(sp) > 9.99999f) {

    // Looking straight up or down
    pitch = kPiOver2 * sp;

    // Compute heading, slam bank to zero
    heading = atan2(-m.m31, m.m11);
    bank = 0.0f;

  } else {
    // Compute angles.  We don't have to use the "safe" asin
    // function because we already checked for range errors when
    // checking for Gimbel lock
    heading = atan2(m.m13, m.m33);
    pitch = asin(sp);
    bank = atan2(m.m21, m.m22);
  }
}

/**
 * 更多信息参见 10.6.2 节
 */
void EulerAngles::fromRotationMatrix(const RotationMatrix &m) {

  // Extract sin(pitch) from m23.
  float	sp = -m.m23;

  // Check for Gimbel lock
  if (fabs(sp) > 9.99999f) {

    // Looking straight up or down
    pitch = kPiOver2 * sp;

    // Compute heading, slam bank to zero
    heading = atan2(-m.m31, m.m11);
    bank = 0.0f;

  } else {
    // Compute angles.  We don't have to use the "safe" asin
    // function because we already checked for range errors when
    // checking for Gimbel lock
    heading = atan2(m.m13, m.m33);
    pitch = asin(sp);
    bank = atan2(m.m21, m.m22);
  }
}
