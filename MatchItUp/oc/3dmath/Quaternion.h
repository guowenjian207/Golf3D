/**
 * @file Quaternion.h
 * @brief 四元数类定义
 *
 *
 * 更多信息参考 Quaternion.cpp
 */

#ifndef __QUATERNION_H_INCLUDED__
#define __QUATERNION_H_INCLUDED__

class Vector3;
class EulerAngles;

/**
 * @brief 实现在 3D 中表示角位移的四元数
 *
 * 更多信息参考 11.3 节
 */
class Quaternion {
 public:

  //---------------------- Public data ------------------//

  // 四元数的四个值，通常是不需要直接处理它们的
  // 然而仍然把它们设置为 public ，这是为了不给某些操作（如文件 I/O）
  // 带来不必要的复杂性
  float	w,/**< w */ x,/**< x */ y,/**< y */ z; /**< z */

  //-------------------- Public operations -------------//
  /** @brief 置为单位四元数 */
  void identity() { w = 1.0f; x = y = z = 0.0f; }

  /** @brief 构造绕 X 轴旋转的四元数 */
  void setToRotateAboutX(float theta);
  /** @brief 构造绕 Y 轴旋转的四元数 */
  void setToRotateAboutY(float theta);
  /** @brief 构造绕 Z 轴旋转的四元数 */
  void setToRotateAboutZ(float theta);
  /** @brief 构造绕指定轴旋转的四元数 */
  void setToRotateAboutAxis(const Vector3 &axis, float theta);

  /**
   * @brief 构造物体-->惯性旋转的四元数
   *
   * 方位参数用欧拉角形式给出
   */
  void setToRotateObjectToInertial(const EulerAngles &orientation);
  /**
   * @brief 构造惯性-->物体旋转的四元数
   *
   * 方位参数用欧拉角形式给出
   */
  void setToRotateInertialToObject(const EulerAngles &orientation);

  /** @brief 叉乘 */
  Quaternion operator *(const Quaternion &a) const;

  /** @brief 赋值叉乘，符合 C++ 习惯的写法 */
  Quaternion &operator *=(const Quaternion &a);

  /** @brief 将四元数正则化 */
  void normalize();

  /** @brief 提取旋转角 */
  float	getRotationAngle() const;
  /** @brief 提取旋转轴 */
  Vector3 getRotationAxis() const;
};

/** @brief 全局“单位”四元数 */
extern const Quaternion kQuaternionIdentity;

/** @brief 四元数点乘 */
extern float dotProduct(const Quaternion &a, const Quaternion &b);

/** @brief 球面线性插值 */
extern Quaternion slerp(const Quaternion &p, const Quaternion &q, float t);

/** @brief 四元数共轭 */
extern Quaternion conjugate(const Quaternion &q);

/** @brief 四元数幂 */
extern Quaternion pow(const Quaternion &q, float exponent);

/** @brief 得到两个向量旋转的四元数 */
extern Quaternion getRotationBetween(const Vector3 &from, const Vector3 &to);

/////////////////////////////////////////////////////////////////////////////
#endif // #ifndef __QUATERNION_H_INCLUDED__
