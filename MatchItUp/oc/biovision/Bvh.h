/**
 * @file Bvh.h
 * @brief bvh 文件结构类定义
 */
#ifndef __BVH_H_INCLUDED__
#define __BVH_H_INCLUDED__

#include <string>
#include <vector>
#include <map>
#include <cfloat> 

#include "../3dmath/Vector3.h"
#include "../3dmath/Matrix4x3.h"
#include "../3dmath/Quaternion.h"
/**
 * @brief  实现了BVH 结构中的一个节点结构
 */
#define MaxFramesNum 500
#define MaxchildrenNum 10

typedef struct slope
{
  float x;
  float y;
  float z;
}Slope;


class BvhPart {
 public:
  /** @brief BVH 肢体名称 */
  std::string name;
  /** @brief BVH 肢体ID */
  int id{};
  std::vector<Vector3> motion_tran; //3维向量的序列,代表某一个局部坐标系的平移过程
  std::vector<Matrix4x3> motion_rot; //4x3维旋转矩阵的序列,代表某一个局部坐标系的旋转过程
  /** @brief BVH 肢体局部坐标系的运动矩阵 */
  std::vector<Matrix4x3> motion;    //any differences?
  //std::vector<Quaternion> motion_q;
  /** @brief BVH 肢体全局坐标系的运动矩阵 */
  std::vector<Matrix4x3> gmotion;  //any differences?
  //std::vector<Quaternion> gmotion_q;
  Slope slope[MaxchildrenNum][MaxFramesNum]{};

  /** @brief BVH 肢体位移旋转的顺序 */
  std::vector<int> orders;

  /** @brief BVH 肢体的父节点 */
  BvhPart *parent{};

  /** @brief BVH 肢体的孩子节点 */
  std::vector<BvhPart*> child;

  /** @brief BVH 肢体对应的数据 ID */
  std::vector<int> mapids;
  std::vector<Vector3> vertices;  //从mdl中获取的顶点物体坐标,每个关节的顶点数目不一样
  std::vector<std::vector<int>> faces;
  std::vector<Vector3> vexnormals;
  std::vector<Vector3> facenormals;
  std::vector<std::vector<Vector3>> bones;
  std::vector<std::vector<float>> texture;
  std::vector<std::vector<int>> face_texture;
  std::vector<std::string> flexname;
  std::vector<std::map<std::string,float>> Jweight; //动态数组,数组中的元素为map,每一个map中可以有多个键值对
  std::vector<float> tpose_trans;
  std::vector<float> tpose_rotAngle;
  std::vector<std::string> tpose_rotOrder;

  /** @brief BVH 肢体的初始运动矩阵 */
  std::vector<float> tpose_gtrans;
  std::vector<float> tpose_grotAngle;

  float maxy=FLT_MIN,miny=FLT_MAX;
  float maxyi,minyi;
  float skinlen{},skindepth,skinwidth;
  float lenscale,widthscale,depthscale;
  Matrix4x3 matrix;//某个组件的物体坐标系(mdl文件产生的)。 旋转
  Matrix4x3 gmatrix;
  Matrix4x3 m;//某个组件的物体坐标系(bdf文件产生的)(实际使用？)  位移
  Matrix4x3 gm;
  Quaternion q{};
  float depth;
  float width;
  float height;
  std::vector<float> length;

  // create by fjh 2020.6
  std::vector<float> euler_angle;  //Direct Obtain from var. Order:xzy


  BvhPart(){
    lenscale=widthscale=depthscale=1;
    depth=width=height=1;
    skindepth=skinwidth=0;
  }
};


/**
 * @brief 实现了 BVH 结构
 *
 * 此类主要是将 Mri 和 Swingc 的数据解析并保存到相关
 * 数据结构中。
 */
class Bvh {
 public:
  //--------------- Public data -----------------//
  /** @brief 运动模型中人体的根节点 */
  BvhPart *bodyRoot;
  /** @brief 运动模型中杆的根节点 */
  BvhPart *clubRoot;
  /** @brief 运动模型中球的根节点 */
  BvhPart *ballRoot;
  /** @brief 运动的总帧数 */
  signed int framesNum;
  float ty[MaxFramesNum]={0}; //猜测是根节点的世界坐标?
  //float ty=0;
  float tx[MaxFramesNum]={0};
  //float tx=0;
  float tz[MaxFramesNum]={0};
  float height=178;
  std::map<std::string,BvhPart*> bodyName; //用string检索bvh节点
 private:
  /** @brief 运动模型当前节点 */
  BvhPart *current;
  /** @brief 运动模型的自由度总数 */
  signed int freedomNum;

  signed int keypointNum;
  std::vector<int> bvhPartIdVec;

  /** @brief 递归计算并设置当前家族节点的世界坐标系 */
  void recurSetFamilyGlobalMatrix(BvhPart *some);
  // 递归计算得到给定节点当前帧的世界坐标系 */
  Matrix4x3 recurGetGlobalMatrix(BvhPart *part,int frame);


  Matrix4x3 recurGetGlobalMatrix(BvhPart *part);
  Matrix4x3 recurGetGM(BvhPart *part);
  Vector3 recurGetGlobalTrans(BvhPart *part);
  Vector3 recurGetGlobalRot(BvhPart *part);
  void mdlProcess(std::string name,std::string value, std::string club_parent);
  void varProcess(std::vector<float> datas, BvhPart *part);

    //qxshen
    Vector3 recurGetGlobalTransAfterAdjustTrans(BvhPart *part,float_t proportion);

    bool writeBdf(std::string bdfFile);


 public:
  void recurGetMotionMatrix(BvhPart *part);
  /** @brief mri 系统的 mdl 文件解析 */
  void mdlParse(std::string mdlFile, std::string club_parent);
  /** @brief mri 系统的 dof 文件解析 */
  void dofParse(std::string dofFile);
  /** @brief mri 系统的 bdf 文件解析 */
  void bdfParse(std::string bdfFile);
  /** @brief mri 系统的 var 文件解析 */
  void varParse(std::string varFile);

  void computeFaceNormal(BvhPart* part);
  void computeFaceNormal();
  void computeVexNormal(BvhPart* part);
  void computeVexNormal();
  void normalization(float h);
  void computePartSize();
  void computeHeight();
  void resetOriginPoint();
  void recurSetFamilyGlobalMatrix();
  void setPartLen(std::string name,float length,float prop);
  void setPartSize(std::string name,float width,float depth);
  void setPartSize(std::string name,float prop);
  void setHeight(float h);
  void printGlobalMatrix();
  void computeGlobalVertices();
  void computeSlope();
  void printSlope();
  void computeTranslation(float height=180,float weight=75,float waistgirth=1,int bmi=1);
  void setCommonBodySize(float height,float weight,float waistgirth);
  void setDetailBodySize(float height,float weight,float waistgirth,std::map<std::string,float> lengthmap,std::map<std::string,float> girthmap);
  void paramBodySize(float height,float weight,float waistgirth,std::map<std::string,float> length,std::map<std::string,float> girth);
  void paramBodySize(float height,float weight,float waistgirth,int bmi);
  void b();//breakpoint

    //qxshen
    void recurGetGlobalMatrixAfterAdjustTrans(BvhPart* part,float proportion);
  /** 
   * @brief 给定父节点下，通过节点名得到节点 
   *
   * 这是会以递归的方式遍历给定节点的所有字节点，包括节点自身，
   * 直到匹配到给定的节点名称。
   */
  BvhPart * getBvhPart(BvhPart *part, std::string name) { //传入由bvhpart节点形成的树的根节点地址，和要寻找到的节点名字
    BvhPart *ret = nullptr; //通过递归广度优先搜索找到该节点
    if(part && part->name != name) {
      for (auto &i : part->child) {
        ret = getBvhPart(i, name);
        if (ret != nullptr)
          return ret;
      }
    } else {
      ret = part;
    }
    return ret;
  }
  /** 
   * @brief 依次遍历所有节点树，通过节点名得到节点 
   *
   * 依次遍历 body, club, ball 三个节点树，
   * 直到匹配到给定的节点名称。
   */
  BvhPart * getBvhPart(std::string name) {
    BvhPart *ret=NULL;
    ret = getBvhPart(bodyRoot, name);
    if (ret != NULL) return ret;

    ret = getBvhPart(clubRoot, name);
    if (ret != NULL) return ret;
      
    return getBvhPart(ballRoot, name);

  }

  /** 
   * @brief 给定父节点下，通过节点 id 得到节点 
   *
   * 这是会以递归的方式遍历给定节点的所有字节点，包括节点自身，
   * 直到匹配到给定的节点 ID。
   */
  BvhPart * getBvhPart(BvhPart *part, int partId) {
    BvhPart *ret=NULL;
    if(part->id != partId) {
      for (unsigned int i = 0; i < part->child.size(); i++) {
        ret = getBvhPart(part->child[i], partId);
        if (ret != NULL)
          return ret;
      }
    } else {
      ret = part;
    }
    return ret;
  }

  /** 
   * @brief 依次遍历所有节点树，得到给定节点 id 的对应节点 
   *
   * 分别依次遍历 body, club, ball 这三个节点树，
   * 直到匹配到给定的节点 ID。
   */
  BvhPart * getBvhPart(int partId) {
    BvhPart *ret;
    ret = getBvhPart(bodyRoot, partId);
    if (ret != NULL) return ret;

    ret = getBvhPart(clubRoot, partId);
    if (ret != NULL) return ret;
      
    return getBvhPart(ballRoot, partId);
  }

  void Draw();
};

void adjustTrans(BvhPart * part, float_t proportion);

/////////////////////////////////////////////////////////////
#endif // #ifndef __BVH_H_INCLUDED__
