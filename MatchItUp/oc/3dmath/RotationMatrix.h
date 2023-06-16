/**
 * @file RotationMatrix.h
 * @brief 旋转矩阵的类定义
 *
 * 更多信息，参考 RotatioMatrix.cpp
 */

#ifndef __ROTATIONMATRIX_H_INCLUDED__
#define __ROTATIONMATRIX_H_INCLUDED__

class Vector3;
class EulerAngles;
class Quaternion;
class Matrix4x3;
/**
 * @brief 实现一个简单的 3x3 矩阵，仅用作旋转
 *
 * 矩阵假设为正交的，在变换时指定方向
 *
 * 更多信息参考 11.4 节
 *
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * MATRIX ORGANIZATION
 *
 * 这个类的使用者应该很少需要关心矩阵的组织方式，当然，对类的
 * 设计者来说应该使一切事情显得直观，假设矩阵仅为旋转矩阵，因
 * 此它是正交的。
 *
 * 该矩阵表达的是惯性到物体的变换，如果要执行物体到惯性的变换，
 * 应该乘以它的转置，也就是说
 *
 * 惯性到物体的变换：
 *
 *                  | m11 m12 m13 |
 *     [ ix iy iz ] | m21 m22 m23 | = [ ox oy oz ]
 *                  | m31 m32 m33 |
 *
 * 物体到惯性的变换：
 *
 *                  | m11 m21 m31 |
 *     [ ox oy oz ] | m12 m22 m32 | = [ ix iy iz ]
 *                  | m13 m23 m33 |
 *
 * 或者使用列向量的形式的变换：
 *
 * 惯性到物体：
 *
 *     | m11 m21 m31 | | ix |   | ox |
 *     | m12 m22 m32 | | iy | = | oy |
 *     | m13 m23 m33 | | iz |   | oz |
 *
 * 物体到惯性：
 *
 *     | m11 m12 m13 | | ox |   | ix |
 *     | m21 m22 m23 | | oy | = | iy |
 *     | m31 m32 m33 | | oz |   | iz |
 */
class RotationMatrix {
 public:

  //------------------------- Public data -----------------------//

  // The 9 values of the matrix.  See RotationMatrix.cpp file for
  // the details of the layout
  float	m11,/**< m11 */ m12, /**< m12 */ m13; /**< m13 */
  float	m21,/**< m21 */ m22, /**< m22 */ m23; /**< m23 */
  float	m31,/**< m31 */ m32, /**< m32 */ m33; /**< m33 */

  //------------------------ Public operations ------------------//

  /** @brief 置为单位矩阵 */
  void identity();

  /** @brief 根据指定的方位构造矩阵 */
  void setup(const EulerAngles &orientation);

  void setup(Matrix4x3 &matrix);
  /**
   * @brief 根据四元数构造矩阵
   *
   * 假设该四元数参数代表指定方向的变换，
   * 从惯性空间到物体空间。
   */
  void fromInertialToObjectQuaternion(const Quaternion &q);
  /**
   * @brief 根据四元数构造矩阵
   *
   * 假设该四元数参数代表指定方向的变换，
   * 从惯性空间到物体空间。
   */
  void fromObjectToInertialQuaternion(const Quaternion &q);

  /** @brief 对向量做惯性--> 物体的变换 */
  Vector3 inertialToObject(const Vector3 &v) const;
  /** @brief 对向量做物体--> 惯性的变换 */
  Vector3 objectToInertial(const Vector3 &v) const;
};

/////////////////////////////////////////////////////////////////////////////
#endif // #ifndef __ROTATIONMATRIX_H_INCLUDED__
