/**
 * @file Matrix4x3.h
 * @brief Matrix4x3 矩阵的类定义
 *
 * 更多信息，参考 Matrix4x3.cpp
 */
#ifndef __MATRIX4X3_H_INCLUDED__
#define __MATRIX4X3_H_INCLUDED__

#include <string>

class Vector3;
class EulerAngles;
class Quaternion;
class RotationMatrix;

/**
 * @brief 实现 4x3 转换矩阵，能够表达任何 3D 仿射变换
 *
 * 备注：
 *
 * 关于此类设计决策请参考 11 章
 *
 * 矩阵信息参考 11.5 节
 *
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 * MATRIX ORGANIZATION
 *
 * 本类的设计目的是为了便于使用，用户不用反复改变正负号或转置直到结果
 * "看起来正确"。当然，内部实现的细节是很重要的。
 * 不仅是为了类的实现的正确性，也为了偶然可能发生的对矩阵元素的直接访问，
 * 或者为了优化，因此，在这里描述一下矩阵类所用的约定。
 *
 * 我们使用行向量，所以矩阵乘法形式如下：
 *
 *               | m11 m12 m13 |
 *     [ x y z ] | m21 m22 m23 | = [ x' y' z' ]
 *               | m31 m32 m33 |
 *               | tx  ty  tz  |
 *
 * 根据严格的线性代数法则，这种乘法是不成立的。
 * 我们可以假设，输入和输出向量有第四个分量，都为 1
 *
 * 另外，由于 4x3 矩阵是不能求逆的，因此假设矩阵有第 4 列，为
 * [ 0 0 0 1 ]，如下所示：
 *
 *                 | m11 m12 m13 0 |
 *     [ x y z 1 ] | m21 m22 m23 0 | = [ x' y' z' 1 ]
 *                 | m31 m32 m33 0 |
 *                 | tx  ty  tz  1 |
 *
 * 如果忘了矩阵乘法的线性代数法则（见 7.1.6 节 和 7.1.7 节），参考运算符*的定义。
 */
class Matrix4x3 {
 public:

  //------------------------ Public data ------------------//

  // 矩阵的值
  // 上面 3x3 部分包含线性变换，最后一行包含平移
  // m11 m21 m31 表示 x 轴的旋转
  float	m11,/**< m11 */ m12, /**< m12 */ m13; /**< m13 */
  float	m21,/**< m21 */ m22, /**< m22 */ m23; /**< m23 */
  float	m31,/**< m31 */ m32, /**< m32 */ m33; /**< m33 */
  float	tx, /**< tx  */ ty,  /**< ty  */ tz;  /**< tz  */

  //---------------------- Public operations --------------//


  Matrix4x3() {
  m11 = 1.0f; m12 = 0.0f; m13 = 0.0f;
  m21 = 0.0f; m22 = 1.0f; m23 = 0.0f;
  m31 = 0.0f; m32 = 0.0f; m33 = 1.0f;
  tx  = 0.0f; ty  = 0.0f; tz  = 1.0f;
  }
  /** @brief 置为单位矩阵 */
  void identity();

  /** @brief 平移部分置零 */
  void zeroTranslation();

  /** @brief Initialize rotation part */
  void zeroRotation();

  /** @brief 将矩阵的平移部分设为指定值，不改变 3x3 部分 */
  void setTranslation(const Vector3 &d);
  /**
   * @brief 设置矩阵来执行平移， 3x3 部分设置单位阵，
   * 平移部分为指定向量
   */
  void setupTranslation(const Vector3 &d);
  void setupRotation(const Matrix4x3 &m);

  /**
   * @brief 创建一个矩阵能将点从局部坐标系变换到父坐标空间
   *
   * 需要给出局部坐标空间在父坐标空间中的位置和方向。
   * 最常用到该方法的可能是将点从物体坐标系变换到世界
   * 坐标系的时候。局部坐标空间的方位用欧拉角定义。
   */
  void setupLocalToParent(const Vector3 &pos, const EulerAngles &orient);
  /**
   * @brief 创建一个矩阵能将点从局部坐标系变换到父坐标空间
   *
   * 需要给出局部坐标空间在父坐标空间中的位置和方向。
   * 最常用到该方法的可能是将点从物体坐标系变换到世界
   * 坐标系的时候。局部坐标空间的方位用旋转矩阵定义。
   * 用旋转矩阵比欧拉角更快一些，因为它没有实数运算，
   * 只有矩阵元素的复制。
   */
  void setupLocalToParent(const Vector3 &pos, const RotationMatrix &orient);
  /**
   * @brief 创建一个矩阵能将点从父坐标空间变换到局部坐标空间
   *
   * 设置用来执行与 setupLocalToParent 相反变换的矩阵
   */
  void setupParentToLocal(const Vector3 &pos, const EulerAngles &orient);
  /**
   * @brief 创建一个矩阵能将点从父坐标空间变换到局部坐标空间
   *
   * 设置用来执行与 setupLocalToParent 相反变换的矩阵
   */
  void setupParentToLocal(const Vector3 &pos, const RotationMatrix &orient);

  // Setup the matrix to perform a rotation about a cardinal axis
  /**
   * @brief 构造绕坐标轴旋转的矩阵
   *
   * 用左手法则定义 “正方向”
   */
  void setupRotate(int axis, float theta);

  /** @brief 以右手法则构造绕坐标轴旋转的矩阵 */
  void setupRotateRightHand(int axis, float theta);

  /** @brief 构造绕任意轴旋转的矩阵 */
  void setupRotate(const Vector3 &axis, float theta);

  /** @brief 构造旋转矩阵，角位移由四元数形势给出 */
  void fromQuaternion(const Quaternion &q);

  /** @brief 构造沿坐标轴缩放的矩阵 */
  void setupScale(const Vector3 &s);

  /** @brief 构造沿任意轴缩放的矩阵 */
  void setupScaleAlongAxis(const Vector3 &axis, float k);

  /** @brief 构造切变矩阵 */
  void setupShear(int axis, float s, float t);

  /** @brief 构造投影矩阵 */
  void setupProject(const Vector3 &n);

  /** @brief 构造反射矩阵 */
  void setupReflect(int axis, float k = 0.0f);

  /** @brief 构造沿任意平面反射的矩阵 */
  void setupReflect(const Vector3 &n);
};

/** @brief 将给定点变换到给定矩阵的空间坐标系中 */
Vector3	operator*(const Vector3 &p, const Matrix4x3 &m);
/** @brief 两个矩阵连接运算 */
Matrix4x3 operator*(const Matrix4x3 &a, const Matrix4x3 &b);

/** @brief 运算符 *= ，保持和 c++ 标准语法一致 */
Vector3	&operator*=(Vector3 &p, const Matrix4x3 &m);
/** @brief 运算符 *= ，保持和 c++ 标准语法一致 */
Matrix4x3 &operator*=(const Matrix4x3 &a, const Matrix4x3 &m);

/** @brief 计算矩阵 3x3 部分行列式的值 */
float determinant(const Matrix4x3 &m);

/** @brief 计算矩阵的逆 */
Matrix4x3 inverse(const Matrix4x3 &m);

/** @brief 提取矩阵的平移部分 */
Vector3	getTranslation(const Matrix4x3 &m);

/** @brief 从父坐标空间提取局部坐标空间位置 */
Vector3	getPositionFromParentToLocalMatrix(const Matrix4x3 &m);
/** @brief 从局部空间坐标提取父坐标空间位置 */
Vector3	getPositionFromLocalToParentMatrix(const Matrix4x3 &m);

/** @brief 计算两个向量之间的旋转矩阵 */
Matrix4x3 fromVectors(const Vector3 &from, const Vector3 &dest);
/** @brief 将旋转矩阵转化为四元数 */
void matrix4x3toQuaternion(const Matrix4x3 &matrix, Quaternion &q);

void printMatrix(Matrix4x3 &matrix);
void fprintMatrix(Matrix4x3 &matrix,std::string path);
/////////////////////////////////////////////////////////////////////////////
#endif // #ifndef __ROTATIONMATRIX_H_INCLUDED__
