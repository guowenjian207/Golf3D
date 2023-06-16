/**
 * @file Vector3.h
 * @brief 向量类定义
 *
 * 更多信息参考第六章
 */

#ifndef __VECTOR3_H_INCLUDED__
#define __VECTOR3_H_INCLUDED__

#include <math.h>

/**
 * @brief 一个简单的 3D 向量类
 */
class Vector3 {
 public:

  // Public representation:  Not many options here.
  float x,/**< x */ y,/**< y */ z;/**< z */

  // Constructors

  /** @brief 默认构造函数，不执行任何操作 */
  Vector3() {}

  /** @brief 复制构造函数 */
  Vector3(const Vector3 &a) : x(a.x), y(a.y), z(a.z) {}

  /** @brief 带参数的构造函数，用三个值完成初始化 */
  Vector3(float nx, float ny, float nz) : x(nx), y(ny), z(nz) {}

  // Standard object maintenance

  /**
   * @brief 重载赋值运算符
   *
   * 坚持 C 语言习惯，重载赋值运算符，并返回引用，以实现左值
   */
  Vector3 &operator =(const Vector3 &a) {
    x = a.x; y = a.y; z = a.z;
    return *this;
  }

  /** @brief 重载 "==" 运算符 */
  bool operator ==(const Vector3 &a) const {
    return x==a.x && y==a.y && z==a.z;
  }

  /** @brief 重载 "!=" 运算符 */
  bool operator !=(const Vector3 &a) const {
    return x!=a.x || y!=a.y || z!=a.z;
  }


  // Vector operations

  /** @brief 置为零向量 */
  void zero() { x = y = z = 0.0f; }

  /** @brief 重载一元 "-" 运算符 */
  Vector3 operator -() const { return Vector3(-x,-y,-z); }

  // Binary + and - add and subtract vectors
  /** @brief 重载二元 "+" 运算符 */
  Vector3 operator +(const Vector3 &a) const {
    return Vector3(x + a.x, y + a.y, z + a.z);
  }
  /** @brief 重载二元 "-” 运算符 */
  Vector3 operator -(const Vector3 &a) const {
    return Vector3(x - a.x, y - a.y, z - a.z);
  }

  /** @brief 与标量的乘法 */
  Vector3 operator *(float a) const {
    return Vector3(x*a, y*a, z*a);
  }
  /** @brief 与标量的除法 */
  Vector3 operator /(float a) const {
    float	oneOverA = 1.0f / a; // NOTE: no check for divide by zero here
    return Vector3(x*oneOverA, y*oneOverA, z*oneOverA);
  }

  /** @brief 重载自反运算符 "+=" */
  Vector3 &operator +=(const Vector3 &a) {
    x += a.x; y += a.y; z += a.z;
    return *this;
  }

  /** @brief 重载自反运算符 "-=" */
  Vector3 &operator -=(const Vector3 &a) {
    x -= a.x; y -= a.y; z -= a.z;
    return *this;
  }

  /** @brief 重载自反运算符 "*=" */
  Vector3 &operator *=(float a) {
    x *= a; y *= a; z *= a;
    return *this;
  }

  /** @brief 重载自反运算符 "/=" */
  Vector3 &operator /=(float a) {
    float oneOverA = 1.0f / a;
    x *= oneOverA; y *= oneOverA; z *= oneOverA;
    return *this;
  }

  /** @brief 向量的标准化 */
  void normalize() {
    float magSq = x*x + y*y + z*z;
    if (magSq > 0.0f) { // check for divide-by-zero
      float oneOverMag = 1.0f / sqrt(magSq);
      x *= oneOverMag;
      y *= oneOverMag;
      z *= oneOverMag;
    }
  }

  /** @brief 向量点乘，重载标准的乘法运算符 */
  float operator *(const Vector3 &a) const {
    return x*a.x + y*a.y + z*a.z;
  }
};

/////////////////////////////////////////////////////////////////////////////
//
// 非成员函数
//
/////////////////////////////////////////////////////////////////////////////

/** @brief 求向量的模 */
inline float vectorMag(const Vector3 &a) {
  return sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
}

/** @brief 计算两个向量的叉乘 */
inline Vector3 crossProduct(const Vector3 &a, const Vector3 &b) {
  return Vector3(
      a.y*b.z - a.z*b.y,
      a.z*b.x - a.x*b.z,
      a.x*b.y - a.y*b.x
                 );
}

/** @brief 实现标量左乘 */
inline Vector3 operator *(float k, const Vector3 &v) {
  return Vector3(k*v.x, k*v.y, k*v.z);
}

/** @brief 计算两点间的距离 */
inline float distance(const Vector3 &a, const Vector3 &b) {
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  float dz = a.z - b.z;
  return sqrt(dx*dx + dy*dy + dz*dz);
}

/**
 * @brief 计算两点间距离的平方
 *
 * 通常用于比较距离，因为求平方根比较慢
 */
inline float distanceSquared(const Vector3 &a, const Vector3 &b) {
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  float dz = a.z - b.z;
  return dx*dx + dy*dy + dz*dz;
}

/////////////////////////////////////////////////////////////////////////////
//
// 全局变量
//
/////////////////////////////////////////////////////////////////////////////

/** @brief 提供一个全局零向量 */
extern const Vector3 kZeroVector;

/////////////////////////////////////////////////////////////////////////////
#endif // #ifndef __VECTOR3_H_INCLUDED__
