#include <assert.h>
#include <math.h>
#include <iostream>
#include <string>
#include <fstream>

#include "./oc/3dmath/Vector3.h"
#include "./oc/3dmath/EulerAngles.h"
#include "./oc/3dmath/Quaternion.h"
#include "./oc/3dmath/RotationMatrix.h"
#include "./oc/3dmath/Matrix4x3.h"
#include "./oc/3dmath/MathUtil.h"

/////////////////////////////////////////////////////////////////////////////
//
// Matrix4x3 类成员
//
/////////////////////////////////////////////////////////////////////////////
/**
 * 如下所示:
 *
 *       | 1  0  0  |
 *       | 0  1  0  |
 *       | 0  0  1  |
 *       | 0  0  1  |
 */
void Matrix4x3::identity() {
  m11 = 1.0f; m12 = 0.0f; m13 = 0.0f;
  m21 = 0.0f; m22 = 1.0f; m23 = 0.0f;
  m31 = 0.0f; m32 = 0.0f; m33 = 1.0f;
  tx  = 0.0f; ty  = 0.0f; tz  = 1.0f;
}

/**
 * 如下所示：
 *
 *       | m11  m12  m13 |
 *       | m21  m22  m23 |
 *       | m31  m32  m33 |
 *       | 0    0    0   |
 */
void Matrix4x3::zeroTranslation() {
  tx = ty = tz = 0.0f;
}

/**
 * 如下所示：
 *
 *       | 1    0    0   |
 *       | 0    1    0   |
 *       | 0    0    1   |
 *       | d.x  d.y  d.z |
 */
void Matrix4x3::zeroRotation() {
  m11 = 1.0f; m12 = 0.0f; m13 = 0.0f;
  m21 = 0.0f; m22 = 1.0f; m23 = 0.0f;
  m31 = 0.0f; m32 = 0.0f; m33 = 1.0f;
}

/**
 * 如下所示：
 *
 *       | m11  m12  m13 |
 *       | m21  m22  m23 |
 *       | m31  m32  m33 |
 *       | d.x  d.y  d.z |
 */
void Matrix4x3::setTranslation(const Vector3 &d) {
  tx = d.x; ty = d.y; tz = d.z;
}

/**
 * 如下所示：
 *
 *       | 1    0    0   |
 *       | 0    1    0   |
 *       | 0    0    1   |
 *       | d.x  d.y  d.z |
 */
void Matrix4x3::setupTranslation(const Vector3 &d) {
  // Set the linear transformation portion to identity
  m11 = 1.0f; m12 = 0.0f; m13 = 0.0f;
  m21 = 0.0f; m22 = 1.0f; m23 = 0.0f;
  m31 = 0.0f; m32 = 0.0f; m33 = 1.0f;

  // Set the translation portion
  tx = d.x; ty = d.y; tz = d.z;
}

void Matrix4x3::setupRotation(const Matrix4x3 &m) {
  // Set the  rotation  to identity
  m11 = m.m11; m12 = m.m12; m13 = m.m13;
  m21 = m.m21; m22 = m.m22; m23 = m.m23;
  m31 = m.m31; m32 = m.m32; m33 = m.m33;

}

/**
 * 首先从物体空间变换到惯性空间，接着变换到世界空间。
 */
void Matrix4x3::setupLocalToParent(const Vector3 &pos, const EulerAngles &orient) {

  // Create a rotation matrix.
  RotationMatrix orientMatrix;
  orientMatrix.setup(orient);

  // Setup the 4x3 matrix.  Note: if we were really concerned with
  // speed, we could create the matrix directly into these variables,
  // without using the temporary RotationMatrix object.  This would
  // save us a function call and a few copy operations.
  setupLocalToParent(pos, orientMatrix);
}

void Matrix4x3::setupLocalToParent(const Vector3 &pos, const RotationMatrix &orient) {
  // Copy the rotation portion of the matrix.  According to
  // the comments in RotationMatrix.cpp, the rotation matrix
  // is "normally" an inertial->object matrix, which is
  // parent->local.  We want a local->parent rotation, so we
  // must transpose while copying
  m11 = orient.m11; m12 = orient.m21; m13 = orient.m31;
  m21 = orient.m12; m22 = orient.m22; m23 = orient.m32;
  m31 = orient.m13; m32 = orient.m23; m33 = orient.m33;

  // Now set the translation portion.  Translation happens "after"
  // the 3x3 portion, so we can simply copy the position
  // field directly
  tx = pos.x; ty = pos.y; tz = pos.z;
}

/**
 * 局部空间的位置和方位在父空间中描述
 *
 * 该方法最常见的用途是构造世界 --> 物体的变换矩阵，通常这个变换
 * 首先从世界空间转换到惯性空间，接着转换到物体空间。
 *
 * 4x3 矩阵可以完成后一个转换。所以我们想构造两个矩阵 T 和 R，
 * 再连接 M=TR ，方位可以由欧拉角或旋转矩阵指定。
 */
void Matrix4x3::setupParentToLocal(const Vector3 &pos, const EulerAngles &orient) {

  // Create a rotation matrix.
  RotationMatrix orientMatrix;
  orientMatrix.setup(orient);

  // Setup the 4x3 matrix.
  setupParentToLocal(pos, orientMatrix);
}

void Matrix4x3::setupParentToLocal(const Vector3 &pos, const RotationMatrix &orient) {
  // Copy the rotation portion of the matrix.  We can copy the
  // elements directly (without transposing) according
  // to the layout as commented in RotationMatrix.cpp
  m11 = orient.m11; m12 = orient.m12; m13 = orient.m13;
  m21 = orient.m21; m22 = orient.m22; m23 = orient.m23;
  m31 = orient.m31; m32 = orient.m32; m33 = orient.m33;

  // Now set the translation portion.  Normally, we would
  // translate by the negative of the position to translate
  // from world to inertial space.  However, we must correct
  // for the fact that the rotation occurs "first."  So we
  // must rotate the translation portion.  This is the same
  // as create a translation matrix T to translate by -pos,
  // and a rotation matrix R, and then creating the matrix
  // as the concatenation of TR
  tx = -(pos.x*m11 + pos.y*m21 + pos.z*m31);
  ty = -(pos.x*m12 + pos.y*m22 + pos.z*m32);
  tz = -(pos.x*m13 + pos.y*m23 + pos.z*m33);
}

/**
 * 旋转轴由一个从 1 开始的索引指定
 *      1 => 绕 x 轴旋转
 *      2 => 绕 y 轴旋转
 *      3 => 绕 z 轴旋转
 *
 * theta 是旋转量，以弧度表示，平移部分置零
 *
 * 更多信息参考 8.2.2 节
 */
void Matrix4x3::setupRotate(int axis, float theta) {
  // Get sin and cosine of rotation angle
  // left hand coordinate system
  float	s, c;
  sinCos(&s, &c, theta);

  // Check which axis they are rotating about
  switch (axis) {
    case 1: // Rotate about the x-axis
      m11 = 1.0f; m12 = 0.0f; m13 = 0.0f;
      m21 = 0.0f; m22 = c;    m23 = s;
      m31 = 0.0f; m32 = -s;   m33 = c;
      break;
    case 2: // Rotate about the y-axis
      m11 = c;    m12 = 0.0f; m13 = -s;
      m21 = 0.0f; m22 = 1.0f; m23 = 0.0f;
      m31 = s;    m32 = 0.0f; m33 = c;
      break;
    case 3: // Rotate about the z-axis
      m11 = c;    m12 = s;    m13 = 0.0f;
      m21 = -s;   m22 = c;    m23 = 0.0f;
      m31 = 0.0f; m32 = 0.0f; m33 = 1.0f;
      break;
    default:

      // bogus axis index
      assert(false);
  }

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

void Matrix4x3::setupRotateRightHand(int axis, float theta) {
  // Get sin and cosine of rotation angle
  float	s, c;
  sinCos(&s, &c, theta);

  // Check which axis they are rotating about
  switch (axis) {
    case 1: // Rotate about the x-axis
      m11 = 1.0f; m12 = 0.0f;  m13 = 0.0f;
      m21 = 0.0f; m22 = c;     m23 = -s;
      m31 = 0.0f; m32 = s;     m33 = c;
      break;
    case 2: // Rotate about the y-axis
      m11 = c;    m12 = 0.0f;  m13 = s;
      m21 = 0.0f; m22 = 1.0f;  m23 = 0.0f;
      m31 = -s;   m32 = 0.0f;  m33 = c;
      break;
    case 3: // Rotate about the z-axis
      m11 = c;    m12 = -s;    m13 = 0.0f;
      m21 = s;    m22 = c;     m23 = 0.0f;
      m31 = 0.0f; m32 = 0.0f;  m33 = 1.0f;
      break;
    default:

      // bogus axis index
      assert(false);
  }

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 旋转轴通过原点，旋转轴为单位向量
 *
 * theta 是旋转向量，以弧度表示，用左手法则来定义“正方向”
 *
 * 平移部分置零
 *
 * 更多信息参见 8.2.3 节
 */
void Matrix4x3::setupRotate(const Vector3 &axis, float theta) {
  // Quick sanity check to make sure they passed in a unit vector
  // to specify the axis
  assert(fabs(axis*axis - 1.0f) < .01f);

  // Get sin and cosine of rotation angle
  float	s, c;
  sinCos(&s, &c, theta);

  // Compute 1 - cos(theta) and some common subexpressions
  float	a = 1.0f - c;
  float	ax = a * axis.x;
  float	ay = a * axis.y;
  float	az = a * axis.z;

  // Set the matrix elements.  There is still a little more
  // opportunity for optimization due to the many common
  // subexpressions.  We'll let the compiler handle that...
  m11 = ax*axis.x + c;
  m12 = ax*axis.y + axis.z*s;
  m13 = ax*axis.z - axis.y*s;

  m21 = ay*axis.x - axis.z*s;
  m22 = ay*axis.y + c;
  m23 = ay*axis.z + axis.x*s;

  m31 = az*axis.x + axis.y*s;
  m32 = az*axis.y - axis.x*s;
  m33 = az*axis.z + c;

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 平移部分置零
 *
 * 更多信息参考 10.6.3 节
 */
void Matrix4x3::fromQuaternion(const Quaternion &q) {
  // Compute a few values to optimize common subexpressions
  float	ww = 2.0f * q.w;
  float	xx = 2.0f * q.x;
  float	yy = 2.0f * q.y;
  float	zz = 2.0f * q.z;

  // Set the matrix elements.  There is still a little more
  // opportunity for optimization due to the many common
  // subexpressions.  We'll let the compiler handle that...
  m11 = 1.0f - yy*q.y - zz*q.z;
  m12 = xx*q.y + ww*q.z;
  m13 = xx*q.z - ww*q.y;

  m21 = xx*q.y - ww*q.z;
  m22 = 1.0f - xx*q.x - zz*q.z;
  m23 = yy*q.z + ww*q.x;

  m31 = xx*q.z + ww*q.y;
  m32 = yy*q.z - ww*q.x;
  m33 = 1.0f - xx*q.x - yy*q.y;

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 对于缩放因子 k，使用向量 Vector3(k,k,k) 表示
 *
 * 平移部分置零
 * 如下所示：
 *
 *       | s.x  0    0   |
 *       | 0    s.y  0   |
 *       | 0    0    s.z |
 *       | 0    0    0   |
 *
 * 更多信息参考 8.3.1 节
 */
void Matrix4x3::setupScale(const Vector3 &s) {
  // Set the matrix elements.  Pretty straightforward
  m11 = s.x;  m12 = 0.0f; m13 = 0.0f;
  m21 = 0.0f; m22 = s.y;  m23 = 0.0f;
  m31 = 0.0f; m32 = 0.0f; m33 = s.z;

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 旋转轴为单位向量，平移部分置零
 *
 * 更多信息参见 8.3.2 节
 */
void Matrix4x3::setupScaleAlongAxis(const Vector3 &axis, float k) {
  // Quick sanity check to make sure they passed in a unit vector
  // to specify the axis
  assert(fabs(axis*axis - 1.0f) < .01f);

  // Compute k-1 and some common subexpressions
  float	a = k - 1.0f;
  float	ax = a * axis.x;
  float	ay = a * axis.y;
  float	az = a * axis.z;

  // Fill in the matrix elements.  We'll do the common
  // subexpression optimization ourselves here, since diagonally
  // opposite matrix elements are equal
  m11 = ax*axis.x + 1.0f;
  m22 = ay*axis.y + 1.0f;
  m32 = az*axis.z + 1.0f;

  m12 = m21 = ax*axis.y;
  m13 = m31 = ax*axis.z;
  m23 = m32 = ay*axis.z;

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 切变类型有一个索引指定，变换效果如下伪代码所示：
 *
 *      axis == 1  =>  y += s*x, z += t*x
 *      axis == 2  =>  x += s*y, z += t*y
 *      axis == 3  =>  x += s*z, y += t*z
 *
 * 平移部分置零
 *
 * 更多信息参见 8.6 节
 */
void Matrix4x3::setupShear(int axis, float s, float t) {

  // Check which type of shear they want
  switch (axis) {
    case 1: // Shear y and z using x
      m11 = 1.0f; m12 = s;    m13 = t;
      m21 = 0.0f; m22 = 1.0f; m23 = 0.0f;
      m31 = 0.0f; m32 = 0.0f; m33 = 1.0f;
      break;
    case 2: // Shear x and z using y
      m11 = 1.0f; m12 = 0.0f; m13 = 0.0f;
      m21 = s;    m22 = 1.0f; m23 = t;
      m31 = 0.0f; m32 = 0.0f; m33 = 1.0f;
      break;
    case 3: // Shear x and y using z
      m11 = 1.0f; m12 = 0.0f; m13 = 0.0f;
      m21 = 0.0f; m22 = 1.0f; m23 = 0.0f;
      m31 = s;    m32 = t;    m33 = 1.0f;
      break;
    default:

      // bogus axis index
      assert(false);
  }

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 投影平面过原点，且垂直于单位向量 n
 *
 * 更多信息参考 8.4 节
 */
void Matrix4x3::setupProject(const Vector3 &n) {
  // Quick sanity check to make sure they passed in a unit vector
  // to specify the axis
  assert(fabs(n*n - 1.0f) < .01f);

  // Fill in the matrix elements.  We'll do the common
  // subexpression optimization ourselves here, since diagonally
  // opposite matrix elements are equal
  m11 = 1.0f - n.x*n.x;
  m22 = 1.0f - n.y*n.y;
  m33 = 1.0f - n.z*n.z;

  m12 = m21 = -n.x*n.y;
  m13 = m31 = -n.x*n.z;
  m23 = m32 = -n.y*n.z;

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 反射平面平行于坐标平面，反射平面有一个索引指定
 *
 *      1 => 沿 x=k 平面反射
 *      2 => 沿 y=k 平面反射
 *      3 => 沿 z=k 平面反射
 *
 * 平移部分置为合适的值，因为 k != 0 时平移是一定会发生的。
 *
 * 更多信息参考 8.5 节 
 */
void Matrix4x3::setupReflect(int axis, float k) {
  // Check which plane they want to reflect about
  switch (axis) {
    case 1: // Reflect about the plane x=k
      m11 = -1.0f; m12 =  0.0f; m13 =  0.0f;
      m21 =  0.0f; m22 =  1.0f; m23 =  0.0f;
      m31 =  0.0f; m32 =  0.0f; m33 =  1.0f;

      tx = 2.0f * k;
      ty = 0.0f;
      tz = 0.0f;
      break;
    case 2: // Reflect about the plane y=k
      m11 =  1.0f; m12 =  0.0f; m13 =  0.0f;
      m21 =  0.0f; m22 = -1.0f; m23 =  0.0f;
      m31 =  0.0f; m32 =  0.0f; m33 =  1.0f;

      tx = 0.0f;
      ty = 2.0f * k;
      tz = 0.0f;
      break;
    case 3: // Reflect about the plane z=k
      m11 =  1.0f; m12 =  0.0f; m13 =  0.0f;
      m21 =  0.0f; m22 =  1.0f; m23 =  0.0f;
      m31 =  0.0f; m32 =  0.0f; m33 = -1.0f;

      tx = 0.0f;
      ty = 0.0f;
      tz = 2.0f * k;
      break;
    default:

      // bogus axis index
      assert(false);
  }
}

/**
 * 反射平面为通过原点的任意平面，且垂直于单位向量 n，
 * 平移部分置零
 *
 * 更多信息参考 8.5 节
 */
void Matrix4x3::setupReflect(const Vector3 &n) {
  // Quick sanity check to make sure they passed in a unit vector
  // to specify the axis
  assert(fabs(n*n - 1.0f) < .01f);

  // Compute common subexpressions
  float	ax = -2.0f * n.x;
  float	ay = -2.0f * n.y;
  float	az = -2.0f * n.z;

  // Fill in the matrix elements.  We'll do the common
  // subexpression optimization ourselves here, since diagonally
  // opposite matrix elements are equal
  m11 = 1.0f + ax*n.x;
  m22 = 1.0f + ay*n.y;
  m32 = 1.0f + az*n.z;

  m12 = m21 = ax*n.y;
  m13 = m31 = ax*n.z;
  m23 = m32 = ay*n.z;

  // Reset the translation portion
  tx = ty = tz = 0.0f;
}

/**
 * 使的向量类就像在纸上做线性代数一样直观，
 * 乘法的顺序从左向右沿变换的顺序进行。
 *
 * 更多信息参考 7.1.7 节
 */
Vector3	operator*(const Vector3 &p, const Matrix4x3 &m) {
  // Grind through the linear algebra.
  return Vector3(
      p.x*m.m11 + p.y*m.m21 + p.z*m.m31 + m.tx,
      p.x*m.m12 + p.y*m.m22 + p.z*m.m32 + m.ty,
      p.x*m.m13 + p.y*m.m23 + p.z*m.m33 + m.tz
                 );
}

Vector3 &operator*=(Vector3 &p, const Matrix4x3 &m) {
  p = p * m;
  return p;
}

/**
 * 使得使用矩阵类就像在纸上做线性代数一样直观，
 * 乘法的顺序从左向右沿变换的顺序进行。
 *
 * 更多信息参考 7.1.6 节
 */
Matrix4x3 operator*(const Matrix4x3 &a, const Matrix4x3 &b) {
  Matrix4x3 r;

  // Compute the upper 3x3 (linear transformation) portion
  r.m11 = a.m11*b.m11 + a.m12*b.m21 + a.m13*b.m31;
  r.m12 = a.m11*b.m12 + a.m12*b.m22 + a.m13*b.m32;
  r.m13 = a.m11*b.m13 + a.m12*b.m23 + a.m13*b.m33;

  r.m21 = a.m21*b.m11 + a.m22*b.m21 + a.m23*b.m31;
  r.m22 = a.m21*b.m12 + a.m22*b.m22 + a.m23*b.m32;
  r.m23 = a.m21*b.m13 + a.m22*b.m23 + a.m23*b.m33;

  r.m31 = a.m31*b.m11 + a.m32*b.m21 + a.m33*b.m31;
  r.m32 = a.m31*b.m12 + a.m32*b.m22 + a.m33*b.m32;
  r.m33 = a.m31*b.m13 + a.m32*b.m23 + a.m33*b.m33;

  // Compute the translation portion
  r.tx = a.tx*b.m11 + a.ty*b.m21 + a.tz*b.m31 + b.tx;
  r.ty = a.tx*b.m12 + a.ty*b.m22 + a.tz*b.m32 + b.ty;
  r.tz = a.tx*b.m13 + a.ty*b.m23 + a.tz*b.m33 + b.tz;

  // Return it.  Ouch - involves a copy constructor call.  If speed
  // is critical, we may need a seperate function which places the
  // result where we want it...
  return r;
}

Matrix4x3 &operator*=(Matrix4x3 &a, const Matrix4x3 &b) {
  a = a * b;
  return a;
}

/** 更多信息参考 9.1.1 节 */
float determinant(const Matrix4x3 &m) {
  return
      m.m11 * (m.m22*m.m33 - m.m23*m.m32)
      + m.m12 * (m.m23*m.m31 - m.m21*m.m33)
      + m.m13 * (m.m21*m.m32 - m.m22*m.m31);
}

/**
 * 使用经典的伴随矩阵除以行列式的方法
 *
 * 更多信息参考 9.2.1 节
 */
Matrix4x3 inverse(const Matrix4x3 &m) {
  // Compute the determinant
  double	det = determinant(m);

  // If we're singular, then the determinant is zero and there's
  // no inverse
  assert(fabs(det) > 0.000001f);

  // Compute one over the determinant, so we divide once and
  // can *multiply* per element
  double	oneOverDet = 1.0f / det;

  // Compute the 3x3 portion of the inverse, by
  // dividing the adjoint by the determinant
  Matrix4x3 r;

  r.m11 = (m.m22*m.m33 - m.m23*m.m32) * oneOverDet;
  r.m12 = (m.m13*m.m32 - m.m12*m.m33) * oneOverDet;
  r.m13 = (m.m12*m.m23 - m.m13*m.m22) * oneOverDet;

  r.m21 = (m.m23*m.m31 - m.m21*m.m33) * oneOverDet;
  r.m22 = (m.m11*m.m33 - m.m13*m.m31) * oneOverDet;
  r.m23 = (m.m13*m.m21 - m.m11*m.m23) * oneOverDet;

  r.m31 = (m.m21*m.m32 - m.m22*m.m31) * oneOverDet;
  r.m32 = (m.m12*m.m31 - m.m11*m.m32) * oneOverDet;
  r.m33 = (m.m11*m.m22 - m.m12*m.m21) * oneOverDet;

  // Compute the translation portion of the inverse
  r.tx = -(m.tx*r.m11 + m.ty*r.m21 + m.tz*r.m31);
  r.ty = -(m.tx*r.m12 + m.ty*r.m22 + m.tz*r.m32);
  r.tz = -(m.tx*r.m13 + m.ty*r.m23 + m.tz*r.m33);

  // Return it.  Ouch - involves a copy constructor call.  If speed
  // is critical, we may need a seperate function which places the
  // result where we want it...
  return r;
}

//---------------------------------------------------------------------------
// getTranslation
//
// Return the translation row of the matrix in vector form
Vector3	getTranslation(const Matrix4x3 &m) {
  return Vector3(m.tx, m.ty, m.tz);
}

/**
 * 我们假设矩阵代表刚体变换。（没有缩放，倾斜，反射）
 */
Vector3	getPositionFromParentToLocalMatrix(const Matrix4x3 &m) {
  // Multiply negative translation value by the
  // transpose of the 3x3 portion.  By using the transpose,
  // we assume that the matrix is orthogonal.  (This function
  // doesn't really make sense for non-rigid transformations...)
  return Vector3(
      -(m.tx*m.m11 + m.ty*m.m12 + m.tz*m.m13),
      -(m.tx*m.m21 + m.ty*m.m22 + m.tz*m.m23),
      -(m.tx*m.m31 + m.ty*m.m32 + m.tz*m.m33)
                 );
}

//---------------------------------------------------------------------------
// getPositionFromLocalToParentMatrix
//
// Extract the position of an object given a local -> parent transformation
// matrix (such as an object -> world matrix)
Vector3	getPositionFromLocalToParentMatrix(const Matrix4x3 &m) {
  // Position is simply the translation portion
  return Vector3(m.tx, m.ty, m.tz);
}

Matrix4x3 fromVectors(const Vector3 &from, const Vector3 &dest) {
  Vector3 v0 = from;
  Vector3 v1 = dest;

  v0.normalize();
  v1.normalize();
  Matrix4x3 matrix;
  float angle = acos(v0 * v1);
  Vector3 axis = crossProduct(v0,v1);
  axis.normalize();
  matrix.setupRotate(axis, angle);
  return matrix;
}

void matrix4x3toQuaternion(const Matrix4x3 &matrix, Quaternion &q) {
  float w, x, y, z;
  
  float fourWSquaredMinus1 = matrix.m11 + matrix.m22 + matrix.m33;
  float fourXSquaredMinus1 = matrix.m11 - matrix.m22 - matrix.m33;
  float fourYSquaredMinus1 = matrix.m22 - matrix.m11 - matrix.m33;
  float fourZSquaredMinus1 = matrix.m33 - matrix.m11 - matrix.m22;

  int biggestIndex = 0;
  
  float fourBiggestSquaredMinus1 = fourWSquaredMinus1;

  // 探测 w, x, y, z 中的最大值
  if (fourXSquaredMinus1 > fourBiggestSquaredMinus1) {
    fourBiggestSquaredMinus1 = fourXSquaredMinus1;
    biggestIndex = 1;
  }

  if (fourYSquaredMinus1 > fourBiggestSquaredMinus1) {
    fourBiggestSquaredMinus1 = fourYSquaredMinus1;
    biggestIndex = 2;
  }

  if (fourZSquaredMinus1 > fourBiggestSquaredMinus1) {
    fourBiggestSquaredMinus1 = fourZSquaredMinus1;
    biggestIndex = 3;
  }

  // 计算平方根和除法
  float biggestVal = sqrt(fourBiggestSquaredMinus1 + 1.0f) * 0.5f;
  float mult = 0.25f / biggestVal;

  // 计算四元数的值
  switch (biggestIndex) {
    case 0:
      w = biggestVal;
      x = (matrix.m23 - matrix.m32) * mult;
      y = (matrix.m31 - matrix.m13) * mult;
      z = (matrix.m12 - matrix.m21) * mult;
      break;
    case 1:
      x = biggestVal;
      w = (matrix.m23 - matrix.m32) * mult;
      y = (matrix.m12 + matrix.m21) * mult;
      z = (matrix.m31 + matrix.m13) * mult;
      break;
    case 2:
      y = biggestVal;
      w = (matrix.m31 - matrix.m13) * mult;
      x = (matrix.m12 + matrix.m21) * mult;
      z = (matrix.m23 + matrix.m32) * mult;
      break;
    case 3:
      z = biggestVal;
      w = (matrix.m12 - matrix.m21) * mult;
      x = (matrix.m31 + matrix.m13) * mult;
      y = (matrix.m23 + matrix.m32) * mult;
      break;
  }

  q.w = w;
  q.x = x;
  q.y = y;
  q.z = z;
}

void printMatrix(Matrix4x3 &matrix)
{
  std::cout<<matrix.m11<<" "<<matrix.m12<<" "<<matrix.m13<<std::endl
           <<matrix.m21<<" "<<matrix.m22<<" "<<matrix.m23<<std::endl
           <<matrix.m31<<" "<<matrix.m32<<" "<<matrix.m33<<std::endl
           <<matrix.tx<<" "<<matrix.ty<<" "<<matrix.tz<<std::endl;
}

void fprintMatrix(Matrix4x3 &matrix,std::string path)
{
  std::ofstream out(path.c_str(),std::ofstream::out|std::ofstream::app);
  out<<matrix.m11<<" "<<matrix.m12<<" "<<matrix.m13<<std::endl
           <<matrix.m21<<" "<<matrix.m22<<" "<<matrix.m23<<std::endl
           <<matrix.m31<<" "<<matrix.m32<<" "<<matrix.m33<<std::endl
           <<matrix.tx<<" "<<matrix.ty<<" "<<matrix.tz<<std::endl;
  out.close();
}
