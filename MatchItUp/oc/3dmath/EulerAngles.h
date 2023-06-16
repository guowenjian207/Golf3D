/**
 * @file EulerAngles.h
 * @brief 欧拉角类定义
 *
 * 更多信息，参考 EulerAngles.cpp
 */

#ifndef __EULERANGLES_H_INCLUDED__
#define __EULERANGLES_H_INCLUDED__

// 预声明
class Quaternion;
class Matrix4x3;
class RotationMatrix;

/**
 * @brief 该类用于表示 heading-pitch-bank 欧拉角系统
 *
 * 更多的设计决策请参考第 11 章
 * 欧拉角请参考 10.3 节
 */
class EulerAngles {
 public:
  //--------------- Public data -----------------//
  /* 直接的表示方式，弧度保存三个角度*/
  /** @brief 绕 Y 轴旋转量 */
  float	heading; 
  /** @brief 绕 X 轴旋转量 */
  float	pitch;
  /** @brief 绕 Z 轴旋转量 */
  float	bank;

  //------------ Public operations----------------//
  /** @brief 缺省构造函数 */
  EulerAngles() {}

  /** @brief 三个参数的构造函数 */
  EulerAngles(float h, float p, float b) :
      heading(h), pitch(p), bank(b) {}

  /** @brief 将欧拉角单位化，三个角全部设置为零 */
  void identity() { pitch = bank = heading = 0.0f; }

  /** @brief 变换为 “限制集” 欧拉角 */
  void canonize();

  /**
   * @brief 将四元数转化为欧拉角。
   *
   * 输入的四元数假设为物体-->惯性坐标系，如函数名所示      
   */
  void fromObjectToInertialQuaternion(const Quaternion &q);
  
  /**
   * @brief 将四元数转化为欧拉角。
   *
   * 输入的四元数假设为惯性-->物体坐标系，如函数名所示
   */
  void fromInertialToObjectQuaternion(const Quaternion &q);

  /**
   * @brief 矩阵转换到欧拉角
   *
   * 输入矩阵假设为物体-->世界转换矩阵
   * 平移部分被省略，并且假设矩阵是正交的
   */
  void fromObjectToWorldMatrix(const Matrix4x3 &m);

  /**
   * @brief 矩阵转换到欧拉角
   *
   * 输入矩阵假设为世界-->物体坐转换矩阵
   * 平移部分被省略，并且假设矩阵是正交的
   */
  void fromWorldToObjectMatrix(const Matrix4x3 &m);

  /** @brief 从旋转矩阵转换到欧拉角 */
  void fromRotationMatrix(const RotationMatrix &m);
};

/** @brief 全局的 “单位” 欧拉角常量 */
extern const EulerAngles kEulerAnglesIdentity;

/////////////////////////////////////////////////////////////////////////////
#endif // #ifndef __EULERANGLES_H_INCLUDED__
