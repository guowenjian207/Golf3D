/*----------------------------------------
 *
 * pred3d Project by Li Yichen -add by wl
 *
 *
 ---------------------------------------*/
#include "oc/samples/oc.hpp"
#include <string>
#include <iomanip>
#include <iostream>
#include <fstream>
#include "./oc/biovision/Bvh.h"
#include <vector>
#include <iterator>
#include <sstream>
#include <stdlib.h>
#include <map>
//#include "./oc/biovision/BioUtil.h"
#include "./oc/3dmath/Vector3.h"
#include "./oc/3dmath/math3d.h"
#include"math.h"
#include<fstream>
#include <set>

#define PI 3.1415926535857
//#define _KEYFRAME_MODE

using namespace std;



vector<vector<double>> translation;
vector<vector<double>> getClubTranslation();
float angle=0;
string player;
bool write_func;
int number;
/**
 * 初始化OpenGL绘制的基础设置
 */
int mark = 0;
int qugan = 0;
int getPre3dOrder_mode = 1;

Bvh bvhs;

int add(int a,int b){
    return a + b;
}


/*
 * 初始化参数，在初始化模型中被调用
 */
static inline float cmtoinch(float f) {
  return f*0.3937008;
}

void inputParam(float &h,float &w, float &wg,map<string,float> &length,map<string,float> &girth)
{
    h=180;
    w=70;
    wg=1;
    if(wg){
        float l60=cmtoinch(60);
        float l50=cmtoinch(50);
        float l40=cmtoinch(40);
        float l35=cmtoinch(35);
        float l30=cmtoinch(30);
        float l25=cmtoinch(25);
        cout<<"l40:"<<l40;
//        length["h_left_up_leg"]=length["h_right_up_leg"]=l60;
//        length["h_left_low_leg"]=length["h_right_low_leg"]=l40;
//        length["h_left_up_arm"]=length["h_right_up_arm"]=l30;
//        length["h_left_low_arm"]=length["h_right_low_arm"]=l30;
//        length["h_left_up_leg"]=length["h_right_up_leg"]=cmtoinch(39);
//        length["h_left_low_leg"]=length["h_right_low_leg"]=cmtoinch(39);
//        length["h_left_up_arm"]=length["h_right_up_arm"]=l30;
//        length["h_left_low_arm"]=length["h_right_low_arm"]=l25;
    }
}


int cnt=0;
void InitModel()
{
    cout<<"asd:"<<bvhs.bodyName["h_right_up_leg"]->gmotion[1].tx<<endl;
    float t=cmtoinch(30);
    float h,w,wg;
    map<string,float> length,girth;
    bvhs.computeHeight(); //感觉是计算人体高度
    if(true){
//        inputParam(h,w,wg,length,girth); //初始化左右腿和胳膊的长度
//        cout<<bvhs.bodyName["h_right_up_leg"]->height<<endl;
//        t=cmtoinch(60);
//        cout<<"30/60cm:"<<t<<endl;
//        bvhs.computePartSize(); //计算所有节点们物体长宽高
//        bvhs.paramBodySize(h,w,wg,length,girth);
//        bvhs.recurSetFamilyGlobalMatrix();
//        bvhs.resetOriginPoint();
//        bvhs.recurSetFamilyGlobalMatrix();
//        cnt++;
    }
    bvhs.computeHeight();
    bvhs.computeFaceNormal();
    bvhs.computeVexNormal();
}


std::vector<std::string> getTransOrder() {
    std::vector<std::string> visionOrder;
    
    visionOrder.push_back("h_left_wrist");
    visionOrder.push_back("h_left_hand");
    visionOrder.push_back("h_left_up_fing_1");
    visionOrder.push_back("h_left_mid_fing_1");
    visionOrder.push_back("h_left_low_fing_1");
    visionOrder.push_back("h_left_mcarpal_2");
    visionOrder.push_back("h_left_up_fing_2");
    visionOrder.push_back("h_left_mid_fing_2");
    visionOrder.push_back("h_left_low_fing_2");
    visionOrder.push_back("h_left_mcarpal_3");
    visionOrder.push_back("h_left_up_fing_3");
    visionOrder.push_back("h_left_mid_fing_3");
    visionOrder.push_back("h_left_low_fing_3");
    visionOrder.push_back("h_left_mcarpal_4");
    visionOrder.push_back("h_left_up_fing_4");
    visionOrder.push_back("h_left_mid_fing_4");
    visionOrder.push_back("h_left_low_fing_4");
    visionOrder.push_back("h_left_mcarpal_5");
    visionOrder.push_back("h_left_up_fing_5");
    visionOrder.push_back("h_left_mid_fing_5");
    visionOrder.push_back("h_left_low_fing_5");
    visionOrder.push_back("h_right_wrist");
    visionOrder.push_back("h_right_hand");
    visionOrder.push_back("h_right_up_fing_1");
    visionOrder.push_back("h_right_mid_fing_1");
    visionOrder.push_back("h_right_low_fing_1");
    visionOrder.push_back("h_right_mcarpal_2");
    visionOrder.push_back("h_right_up_fing_2");
    visionOrder.push_back("h_right_mid_fing_2");
    visionOrder.push_back("h_right_low_fing_2");
    visionOrder.push_back("h_right_mcarpal_3");
    visionOrder.push_back("h_right_up_fing_3");
    visionOrder.push_back("h_right_mid_fing_3");
    visionOrder.push_back("h_right_low_fing_3");
    visionOrder.push_back("h_right_mcarpal_4");
    visionOrder.push_back("h_right_up_fing_4");
    visionOrder.push_back("h_right_mid_fing_4");
    visionOrder.push_back("h_right_low_fing_4");
    visionOrder.push_back("h_right_mcarpal_5");
    visionOrder.push_back("h_right_up_fing_5");
    visionOrder.push_back("h_right_mid_fing_5");
    visionOrder.push_back("h_right_low_fing_5");

    visionOrder.push_back("club");
    
    
    //visionOrder.push_back("ball");
    return visionOrder;
}
//给string的vector中添加元素
std::vector<std::string> getPre3dOrder() {
    std::vector<std::string> visionOrder;
    if(getPre3dOrder_mode == 2){
        visionOrder.push_back("h_waist");
        visionOrder.push_back("h_torso_2");
        visionOrder.push_back("h_torso_3");
        visionOrder.push_back("h_torso_4");
        visionOrder.push_back("h_torso_5");
        visionOrder.push_back("h_torso_6");
        visionOrder.push_back("h_torso_7");
        visionOrder.push_back("h_neck_1");
        visionOrder.push_back("h_neck_2");
        visionOrder.push_back("h_head");
        visionOrder.push_back("h_left_shoulder");
        visionOrder.push_back("h_left_up_arm");
        visionOrder.push_back("h_left_low_arm");
        visionOrder.push_back("h_left_wrist");
        visionOrder.push_back("h_left_hand");
        visionOrder.push_back("h_left_up_fing_1");
        visionOrder.push_back("h_left_mid_fing_1");
        visionOrder.push_back("h_left_low_fing_1");
        //visionOrder.push_back("h_left_mcarpal_2");
        visionOrder.push_back("h_left_up_fing_2");
        visionOrder.push_back("h_left_mid_fing_2");
        visionOrder.push_back("h_left_low_fing_2");
        //visionOrder.push_back("h_left_mcarpal_3");
        visionOrder.push_back("h_left_up_fing_3");
        visionOrder.push_back("h_left_mid_fing_3");
        visionOrder.push_back("h_left_low_fing_3");
        //visionOrder.push_back("h_left_mcarpal_4");
        visionOrder.push_back("h_left_up_fing_4");
        visionOrder.push_back("h_left_mid_fing_4");
        visionOrder.push_back("h_left_low_fing_4");
        //visionOrder.push_back("h_left_mcarpal_5");
        visionOrder.push_back("h_left_up_fing_5");
        visionOrder.push_back("h_left_mid_fing_5");
        visionOrder.push_back("h_left_low_fing_5");
        visionOrder.push_back("h_left_club");
        //visionOrder.push_back("h_left_grip");
        visionOrder.push_back("h_left_up_leg");
        visionOrder.push_back("h_left_low_leg");
        visionOrder.push_back("h_left_foot");
        visionOrder.push_back("h_left_toes");
        visionOrder.push_back("h_right_shoulder");
        visionOrder.push_back("h_right_up_arm");
        visionOrder.push_back("h_right_low_arm");
        visionOrder.push_back("h_right_wrist");
        visionOrder.push_back("h_right_hand");
        visionOrder.push_back("h_right_up_fing_1");
        visionOrder.push_back("h_right_mid_fing_1");
        visionOrder.push_back("h_right_low_fing_1");
        //visionOrder.push_back("h_right_mcarpal_2");
        visionOrder.push_back("h_right_up_fing_2");
        visionOrder.push_back("h_right_mid_fing_2");
        visionOrder.push_back("h_right_low_fing_2");
        //visionOrder.push_back("h_right_mcarpal_3");
        visionOrder.push_back("h_right_up_fing_3");
        visionOrder.push_back("h_right_mid_fing_3");
        visionOrder.push_back("h_right_low_fing_3");
        //visionOrder.push_back("h_right_mcarpal_4");
        visionOrder.push_back("h_right_up_fing_4");
        visionOrder.push_back("h_right_mid_fing_4");
        visionOrder.push_back("h_right_low_fing_4");
        //visionOrder.push_back("h_right_mcarpal_5");
        visionOrder.push_back("h_right_up_fing_5");
        visionOrder.push_back("h_right_mid_fing_5");
        visionOrder.push_back("h_right_low_fing_5");
        visionOrder.push_back("h_right_club");
        //visionOrder.push_back("h_right_grip");
        visionOrder.push_back("h_right_up_leg");
        visionOrder.push_back("h_right_low_leg");
        visionOrder.push_back("h_right_foot");
        visionOrder.push_back("h_right_toes");
        visionOrder.push_back("club");
        visionOrder.push_back("shaft_1");
        visionOrder.push_back("shaft_2");
        visionOrder.push_back("shaft_3");
        visionOrder.push_back("shaft_4");
        visionOrder.push_back("shaft_5");
        visionOrder.push_back("shaft_6");
        visionOrder.push_back("shaft_7");
        visionOrder.push_back("shaft_8");
        visionOrder.push_back("length");
        visionOrder.push_back("shafttemp_1");
        visionOrder.push_back("shafttemp_2");
        visionOrder.push_back("clubfacetemp_1");
        visionOrder.push_back("clubfacetemp_2");
        visionOrder.push_back("hosel");
        visionOrder.push_back("lie");
        visionOrder.push_back("loft");
        visionOrder.push_back("clubface");
//        visionOrder.push_back("ball");
    }
    else if (getPre3dOrder_mode == 3){
        visionOrder.push_back("h_waist");
        visionOrder.push_back("h_torso_2");
        visionOrder.push_back("h_torso_3");
        visionOrder.push_back("h_torso_4");
        visionOrder.push_back("h_torso_5");
        visionOrder.push_back("h_torso_6");
        visionOrder.push_back("h_torso_7");
        visionOrder.push_back("h_neck_1");
        visionOrder.push_back("h_neck_2");
        visionOrder.push_back("h_head");
        visionOrder.push_back("h_left_shoulder");
        visionOrder.push_back("h_left_up_arm");
        visionOrder.push_back("h_left_low_arm");
        visionOrder.push_back("h_left_wrist");
        visionOrder.push_back("h_left_hand");
        visionOrder.push_back("h_left_up_fing_1");
        visionOrder.push_back("h_left_mid_fing_1");
        visionOrder.push_back("h_left_low_fing_1");
        visionOrder.push_back("h_left_mcarpal_2");
        visionOrder.push_back("h_left_up_fing_2");
        visionOrder.push_back("h_left_mid_fing_2");
        visionOrder.push_back("h_left_low_fing_2");
        visionOrder.push_back("h_left_mcarpal_3");
        visionOrder.push_back("h_left_up_fing_3");
        visionOrder.push_back("h_left_mid_fing_3");
        visionOrder.push_back("h_left_low_fing_3");
        visionOrder.push_back("h_left_mcarpal_4");
        visionOrder.push_back("h_left_up_fing_4");
        visionOrder.push_back("h_left_mid_fing_4");
        visionOrder.push_back("h_left_low_fing_4");
        visionOrder.push_back("h_left_mcarpal_5");
        visionOrder.push_back("h_left_up_fing_5");
        visionOrder.push_back("h_left_mid_fing_5");
        visionOrder.push_back("h_left_low_fing_5");
        visionOrder.push_back("h_left_club");
        //visionOrder.push_back("h_left_grip");
        visionOrder.push_back("h_left_up_leg");
        visionOrder.push_back("h_left_low_leg");
        visionOrder.push_back("h_left_foot");
        visionOrder.push_back("h_left_toes");
        visionOrder.push_back("h_right_shoulder");
        visionOrder.push_back("h_right_up_arm");
        visionOrder.push_back("h_right_low_arm");
        visionOrder.push_back("h_right_wrist");
        visionOrder.push_back("h_right_hand");
        visionOrder.push_back("h_right_up_fing_1");
        visionOrder.push_back("h_right_mid_fing_1");
        visionOrder.push_back("h_right_low_fing_1");
        visionOrder.push_back("h_right_mcarpal_2");
        visionOrder.push_back("h_right_up_fing_2");
        visionOrder.push_back("h_right_mid_fing_2");
        visionOrder.push_back("h_right_low_fing_2");
        visionOrder.push_back("h_right_mcarpal_3");
        visionOrder.push_back("h_right_up_fing_3");
        visionOrder.push_back("h_right_mid_fing_3");
        visionOrder.push_back("h_right_low_fing_3");
        visionOrder.push_back("h_right_mcarpal_4");
        visionOrder.push_back("h_right_up_fing_4");
        visionOrder.push_back("h_right_mid_fing_4");
        visionOrder.push_back("h_right_low_fing_4");
        visionOrder.push_back("h_right_mcarpal_5");
        visionOrder.push_back("h_right_up_fing_5");
        visionOrder.push_back("h_right_mid_fing_5");
        visionOrder.push_back("h_right_low_fing_5");
        visionOrder.push_back("h_right_club");
        //visionOrder.push_back("h_right_grip");
        visionOrder.push_back("h_right_up_leg");
        visionOrder.push_back("h_right_low_leg");
        visionOrder.push_back("h_right_foot");
        visionOrder.push_back("h_right_toes");
        visionOrder.push_back("club");
        visionOrder.push_back("shaft_1");
        visionOrder.push_back("shaft_2");
        visionOrder.push_back("shaft_3");
        visionOrder.push_back("shaft_4");
        visionOrder.push_back("shaft_5");
        visionOrder.push_back("shaft_6");
        visionOrder.push_back("shaft_7");
        visionOrder.push_back("shaft_8");
        visionOrder.push_back("length");
        visionOrder.push_back("shafttemp_1");
        visionOrder.push_back("shafttemp_2");
        visionOrder.push_back("clubfacetemp_1");
        visionOrder.push_back("clubfacetemp_2");
        visionOrder.push_back("hosel");
        visionOrder.push_back("lie");
        visionOrder.push_back("loft");
        visionOrder.push_back("clubface");
//        visionOrder.push_back("ball");
    }
    else{
        visionOrder.push_back("h_waist");
        visionOrder.push_back("h_torso_2");
        visionOrder.push_back("h_torso_3");
        visionOrder.push_back("h_torso_4");
        visionOrder.push_back("h_torso_5");
        visionOrder.push_back("h_torso_6");
        visionOrder.push_back("h_torso_7");
        visionOrder.push_back("h_neck_1");
        visionOrder.push_back("h_neck_2");
        visionOrder.push_back("h_head");
        visionOrder.push_back("h_left_shoulder");
        visionOrder.push_back("h_left_up_arm");
        visionOrder.push_back("h_left_low_arm");
        visionOrder.push_back("h_left_wrist");
        visionOrder.push_back("h_left_hand");
        visionOrder.push_back("h_left_up_fing_1");
        visionOrder.push_back("h_left_mid_fing_1");
        visionOrder.push_back("h_left_low_fing_1");
        visionOrder.push_back("h_left_mcarpal_2");
        visionOrder.push_back("h_left_up_fing_2");
        visionOrder.push_back("h_left_mid_fing_2");
        visionOrder.push_back("h_left_low_fing_2");
        visionOrder.push_back("h_left_mcarpal_3");
        visionOrder.push_back("h_left_up_fing_3");
        visionOrder.push_back("h_left_mid_fing_3");
        visionOrder.push_back("h_left_low_fing_3");
        visionOrder.push_back("h_left_mcarpal_4");
        visionOrder.push_back("h_left_up_fing_4");
        visionOrder.push_back("h_left_mid_fing_4");
        visionOrder.push_back("h_left_low_fing_4");
        visionOrder.push_back("h_left_mcarpal_5");
        visionOrder.push_back("h_left_up_fing_5");
        visionOrder.push_back("h_left_mid_fing_5");
        visionOrder.push_back("h_left_low_fing_5");
        visionOrder.push_back("h_left_club");
        visionOrder.push_back("h_left_grip");
        visionOrder.push_back("h_left_up_leg");
        visionOrder.push_back("h_left_low_leg");
        visionOrder.push_back("h_left_foot");
        visionOrder.push_back("h_left_toes");
        visionOrder.push_back("h_right_shoulder");
        visionOrder.push_back("h_right_up_arm");
        visionOrder.push_back("h_right_low_arm");
        visionOrder.push_back("h_right_wrist");
        visionOrder.push_back("h_right_hand");
        visionOrder.push_back("h_right_up_fing_1");
        visionOrder.push_back("h_right_mid_fing_1");
        visionOrder.push_back("h_right_low_fing_1");
        visionOrder.push_back("h_right_mcarpal_2");
        visionOrder.push_back("h_right_up_fing_2");
        visionOrder.push_back("h_right_mid_fing_2");
        visionOrder.push_back("h_right_low_fing_2");
        visionOrder.push_back("h_right_mcarpal_3");
        visionOrder.push_back("h_right_up_fing_3");
        visionOrder.push_back("h_right_mid_fing_3");
        visionOrder.push_back("h_right_low_fing_3");
        visionOrder.push_back("h_right_mcarpal_4");
        visionOrder.push_back("h_right_up_fing_4");
        visionOrder.push_back("h_right_mid_fing_4");
        visionOrder.push_back("h_right_low_fing_4");
        visionOrder.push_back("h_right_mcarpal_5");
        visionOrder.push_back("h_right_up_fing_5");
        visionOrder.push_back("h_right_mid_fing_5");
        visionOrder.push_back("h_right_low_fing_5");
        visionOrder.push_back("h_right_club");
        visionOrder.push_back("h_right_grip");
        visionOrder.push_back("h_right_up_leg");
        visionOrder.push_back("h_right_low_leg");
        visionOrder.push_back("h_right_foot");
        visionOrder.push_back("h_right_toes");
        visionOrder.push_back("club");
        visionOrder.push_back("shaft_1");
        visionOrder.push_back("shaft_2");
        visionOrder.push_back("shaft_3");
        visionOrder.push_back("shaft_4");
        visionOrder.push_back("shaft_5");
        visionOrder.push_back("shaft_6");
        visionOrder.push_back("shaft_7");
        visionOrder.push_back("shaft_8");
        visionOrder.push_back("length");
        visionOrder.push_back("shafttemp_1");
        visionOrder.push_back("shafttemp_2");
        visionOrder.push_back("clubfacetemp_1");
        visionOrder.push_back("clubfacetemp_2");
        visionOrder.push_back("hosel");
        visionOrder.push_back("lie");
        visionOrder.push_back("loft");
        visionOrder.push_back("clubface");
//        visionOrder.push_back("ball");
    }
    
    //visionOrder.push_back("ball");
    return visionOrder;
}

std::vector<std::string> getLeftHandOrder(){
    std::vector<std::string> visionOrder;
    
    visionOrder.push_back("h_left_wrist");
    visionOrder.push_back("h_left_hand");
    visionOrder.push_back("h_left_up_fing_1");
    visionOrder.push_back("h_left_mid_fing_1");
    visionOrder.push_back("h_left_low_fing_1");
    visionOrder.push_back("h_left_mcarpal_2");
    visionOrder.push_back("h_left_up_fing_2");
    visionOrder.push_back("h_left_mid_fing_2");
    visionOrder.push_back("h_left_low_fing_2");
    visionOrder.push_back("h_left_mcarpal_3");
    visionOrder.push_back("h_left_up_fing_3");
    visionOrder.push_back("h_left_mid_fing_3");
    visionOrder.push_back("h_left_low_fing_3");
    visionOrder.push_back("h_left_mcarpal_4");
    visionOrder.push_back("h_left_up_fing_4");
    visionOrder.push_back("h_left_mid_fing_4");
    visionOrder.push_back("h_left_low_fing_4");
    visionOrder.push_back("h_left_mcarpal_5");
    visionOrder.push_back("h_left_up_fing_5");
    visionOrder.push_back("h_left_mid_fing_5");
    visionOrder.push_back("h_left_low_fing_5");
    visionOrder.push_back("h_right_wrist");
    visionOrder.push_back("h_right_hand");
    visionOrder.push_back("h_right_up_fing_1");
    visionOrder.push_back("h_right_mid_fing_1");
    visionOrder.push_back("h_right_low_fing_1");
    visionOrder.push_back("h_right_mcarpal_2");
    visionOrder.push_back("h_right_up_fing_2");
    visionOrder.push_back("h_right_mid_fing_2");
    visionOrder.push_back("h_right_low_fing_2");
    visionOrder.push_back("h_right_mcarpal_3");
    visionOrder.push_back("h_right_up_fing_3");
    visionOrder.push_back("h_right_mid_fing_3");
    visionOrder.push_back("h_right_low_fing_3");
    visionOrder.push_back("h_right_mcarpal_4");
    visionOrder.push_back("h_right_up_fing_4");
    visionOrder.push_back("h_right_mid_fing_4");
    visionOrder.push_back("h_right_low_fing_4");
    visionOrder.push_back("h_right_mcarpal_5");
    visionOrder.push_back("h_right_up_fing_5");
    visionOrder.push_back("h_right_mid_fing_5");
    visionOrder.push_back("h_right_low_fing_5");
    return visionOrder;
}

std::vector<std::string> getClubOrder(){
    std::vector<std::string> visionOrder;
    visionOrder.push_back("club");
    visionOrder.push_back("shaft_1");
    visionOrder.push_back("shaft_2");
    visionOrder.push_back("shaft_3");
    visionOrder.push_back("shaft_4");
    visionOrder.push_back("shaft_5");
    visionOrder.push_back("shaft_6");
    visionOrder.push_back("shaft_7");
    visionOrder.push_back("shaft_8");
    visionOrder.push_back("length");
    visionOrder.push_back("shafttemp_1");
    visionOrder.push_back("shafttemp_2");
    visionOrder.push_back("clubfacetemp_1");
    visionOrder.push_back("clubfacetemp_2");
    visionOrder.push_back("hosel");
    visionOrder.push_back("lie");
    visionOrder.push_back("loft");
    visionOrder.push_back("clubface");
    return visionOrder;
}

int fr=0;
int mode=1;//0表示绘制骨架，1表示绘制肢体
int times;
int k=0;


Matrix4x3 rotmat;
float avg_x=0;float avg_y=0;float avg_z=0;
int avg_count=0;





int blocks[50000];
double prev_vect[500000];
int quant(double dis, double s, float z){
    return  int(round(dis / s + z));
}

// by wl every frame
#include <vector>
vector<vector<double>> recursivedrawFace_wl(Bvh &bvhs){
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
#if true
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    //for mike
                    if(player == "mike_weir"){
                        vw.x=-vw.x+35;
                        vw.z=-vw.z;
                    }
                    if(i<70){
                        avg_x+=vw.x;
                        avg_y+=vw.y;
                        avg_z+=vw.z;
                    }
                    //glVertex3f(vw.x, vw.y, vw.z); //描出多边形中的点
                    vector<double> pos;
                    pos.push_back(vw.x);
                    pos.push_back(vw.y);
                    pos.push_back(vw.z);
                    result.push_back(pos);
                    all_count++;
                }
            }
            blocks[block_index]=block_count;
            block_index++;//在里面是每一小块，外面是每一块躯干

        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    printf("allcount:%d\n",all_count);
#endif
    cout<<"prev_pos[0][0]:"<<result[0][0]<<endl;
    return result;
}

string cur_player;

vector<vector<double>> test_Lower_Body_Position_lcy(Bvh &bvhs){
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    translation = getClubTranslation();
    
    vector<double> lower_body_pos;
    double up_x_l,up_x_r,up_y,down_x_l,down_x_r,down_y,z_gwj,z1,z2,z3,z4;
    up_x_l = DBL_MAX;
    up_x_r = -DBL_MAX;
    up_y = - DBL_MAX;
    down_x_l = DBL_MAX;
    down_x_r =  -DBL_MAX;
    down_y = DBL_MAX;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(part->name != "h_waist" && part->name != "h_right_toes" && part->name != "h_left_toes" && part->name != "h_left_up_leg" && part->name != "h_right_up_leg"
           && part->name != "h_right_foot" && part->name != "h_left_foot"){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
//                    if(part->name == "h_left_up_leg" && vw.x < up_x_l){
//                        up_x_l = vw.x;
//                        z1 = vw.z;
//                    }
//                    else if(part->name == "h_waist" && vw.x > up_x_r){
//                        up_x_r = vw.x;
//                        z2 = vw.z;
//                    }
//                    else
                    if (part->name == "h_waist" && up_x_l >= vw.x){
                                            if(up_y < vw.y) up_y  = vw.y;
                                            z1 = vw.z;
                                            z2 = vw.z;
                                            up_x_l=vw.x;
                    //                        up_y = vw.y;
                                        }
                    else if((part->name == "h_right_toes"|| part->name == "h_right_foot") && vw.x < down_x_l){
                        down_x_l = vw.x;
                        z3 = vw.z;
                    }
                    else if ((part->name == "h_left_toes" || part->name == "h_left_foot") && vw.x > down_x_r){
                        down_x_r = vw.x;
                        z4 = vw.z;
                    }
                    
                    if ((part->name == "h_right_toes" || part->name == "h_right_foot" || part->name == "h_left_toes" || part->name == "h_left_foot")  && vw.y < down_y){
                        down_y = vw.y;
                    }
                    
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    z_gwj = (z1+z2+z3+z4)/4;
    // 左上
    lower_body_pos.push_back(up_x_l);
    lower_body_pos.push_back(up_y);
    lower_body_pos.push_back(z_gwj);
    vector<vector<double>> lower_body_result;
    lower_body_result.push_back(lower_body_pos);
    // 右上
//    lower_body_pos[0] = up_x_r;
    lower_body_pos[0] = down_x_r + down_x_l - up_x_l;
    lower_body_result.push_back(lower_body_pos);
    // 右下
    lower_body_pos[0] = down_x_r;
    lower_body_pos[1] = down_y;
    lower_body_result.push_back(lower_body_pos);
    // 左下
    lower_body_pos[0] = down_x_l;
    lower_body_result.push_back(lower_body_pos);
    return lower_body_result;
}




vector<vector<double>> test_feet_width(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> golf_head,golf_tail;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_toes" && part->name != "h_right_toes"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_toes"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_right_toes"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
        }
        
        
    }
    y1 = y1 / 2 + y2 / 2 + 5;
    y2 = y1;
    //杆头杆尾
    
    golf_tail.push_back(x1);
    golf_tail.push_back(y1);
    golf_tail.push_back(z1);
    golf_head.push_back(x2);
    golf_head.push_back(y2);
    golf_head.push_back(z2);
//    head_line[0] -= 50;
    vector<vector<double>> shaft_line_result;
    shaft_line_result.push_back(golf_tail);
    shaft_line_result.push_back(golf_head);
    golf_head[1] -= 8;
    golf_tail[1] -= 8;
    shaft_line_result.push_back(golf_head);
    shaft_line_result.push_back(golf_tail);
    
    return shaft_line_result;
}

vector<vector<double>> test_shoulder_angle_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> l_shoulder,r_shoulder;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_up_arm" && part->name != "h_right_up_arm"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_up_arm"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_right_up_arm"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    l_shoulder.push_back(x1 + 0*(x1 - x2));
    l_shoulder.push_back(y1 + 0*(y1 - y2));
    l_shoulder.push_back(z1 + 0*(z1 - z2));
    r_shoulder.push_back(x2 + 0*(x2 - x1));
    r_shoulder.push_back(y2 + 0*(y2 - y1));
    r_shoulder.push_back(z2 + 0*(z2 - z1));
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(l_shoulder);
    shoulder_result.push_back(r_shoulder);
    return shoulder_result;
}

vector<vector<double>> test_spine_tilt_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> l_shoulder,r_shoulder;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_torso_3" && part->name != "h_neck_1"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_torso_3"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_neck_1"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    l_shoulder.push_back(x1 + 1.5*(x1 - x2));
    l_shoulder.push_back(y1 + 1.5*(y1 - y2));
    l_shoulder.push_back(z1 + 1.5*(z1 - z2));
    r_shoulder.push_back(x2 + 2*(x2 - x1));
    r_shoulder.push_back(y2 + 2*(y2 - y1));
    r_shoulder.push_back(z2 + 2*(z2 - z1));
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(l_shoulder);
    shoulder_result.push_back(r_shoulder);
    return shoulder_result;
}

vector<vector<double>> test_leadarm_line_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> l_shoulder,r_shoulder;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_up_arm" && part->name != "h_left_hand"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_up_arm"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_left_hand"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    l_shoulder.push_back(x1 + 0.5*(x1 - x2));
    l_shoulder.push_back(y1 + 0.5*(y1 - y2));
    l_shoulder.push_back(z1 + 0.5*(z1 - z2));
    r_shoulder.push_back(x2 + 0.5*(x2 - x1));
    r_shoulder.push_back(y2 + 0.5*(y2 - y1));
    r_shoulder.push_back(z2 + 0.5*(z2 - z1));
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(l_shoulder);
    shoulder_result.push_back(r_shoulder);
    return shoulder_result;
}

vector<vector<double>> test_knee_width(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> golf_head,golf_tail;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_low_leg" && part->name != "h_right_low_leg"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_low_leg"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_right_low_leg"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
        }
        
        
    }
//    y1 = y1 / 2 + y2 / 2 + 5;
    y2 = y1;
    y2 += 8;
    y1 += 8;
    //杆头杆尾

    golf_tail.push_back(x1);
    golf_tail.push_back(y1);
    golf_tail.push_back(z1);
    golf_head.push_back(x2);
    golf_head.push_back(y2);
    golf_head.push_back(z2);
//    head_line[0] -= 50;
    vector<vector<double>> shaft_line_result;
    shaft_line_result.push_back(golf_tail);
    shaft_line_result.push_back(golf_head);
    golf_head[1] -= 16;
    golf_tail[1] -= 16;
    shaft_line_result.push_back(golf_head);
    shaft_line_result.push_back(golf_tail);
    
    return shaft_line_result;
}

vector<vector<double>> test_knee_width_beside(Bvh &bvhs){ //侧面头高线
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    
    translation = getClubTranslation();
    
    vector<double> left_p,right_p;

    double x1,x2,y1,y2,z1,z2 = 0;
    y2 = 0;
    z2 =-DBL_MAX;
    z1 = -DBL_MAX;
    double y_store;
    BvhPart *tmp_part;
    tmp_part = bvhs.getBvhPart("h_left_low_leg");
    Matrix4x3 m = tmp_part->gmotion[fr];
    y_store = m.ty;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(part->name != "h_right_up_leg" && part->name != "h_left_up_leg" ){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    
                    if(part->name == "h_right_up_leg" && vw.z > z1 ){
                        x1 = vw.x;
                        y1 = vw.y;
                        z1 = vw.z;
                    }
                    else if (part->name == "h_left_up_leg" && vw.z > z2 && vw.y < y_store +2){
                        x2 = vw.x;
                        y2 = vw.y;
                        z2 = vw.z;
                    }
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    // 左上
    z1 -= 4;
    z2 -= 4;
    printf("store: %f",y_store);
    printf("y2: %f",y2);
    y2 = y1;
    y2 += 8;
    y1 += 8;
    
    right_p.push_back(x1);
    right_p.push_back(y1);
    right_p.push_back(z1);
    left_p.push_back(x2);
    left_p.push_back(y2);
    left_p.push_back(z2);
//    head_line[0] -= 50;
    vector<vector<double>> head_result;
    head_result.push_back(left_p);//左上-右上-右下-左下
    head_result.push_back(right_p);
    right_p[1] -= 16;
    head_result.push_back(right_p);
    
    

    left_p[1] -= 16;

    head_result.push_back(left_p);
    return head_result;
}
vector<vector<double>> test_lead_forearm_line_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> l_shoulder,r_shoulder;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_low_arm" && part->name != "h_left_hand"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_low_arm"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_left_hand"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
        }
        

    }
    //左肩右肩
    l_shoulder.push_back(x1 + 0.0*(x1 - x2));
    l_shoulder.push_back(y1 + 0.0*(y1 - y2));
    l_shoulder.push_back(z1 + 0.0*(z1 - z2));
    r_shoulder.push_back(x2 + 0.0*(x2 - x1));
    r_shoulder.push_back(y2 + 0.0*(y2 - y1));
    r_shoulder.push_back(z2 + 0.0*(z2 - z1));
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(l_shoulder);
    shoulder_result.push_back(r_shoulder);
    return shoulder_result;
}

vector<vector<double>> test_lead_elbow_angle_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> up_arm,low_arm,hand;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_low_arm" && part->name != "h_left_hand" && part->name != "h_left_up_arm"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_up_arm"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_left_low_arm"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
            else if(part->name == "h_left_hand"){
                x3 = m.tx;
                y3 = m.ty;
                z3 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    up_arm.push_back(x1 );
    up_arm.push_back(y1 );
    up_arm.push_back(z1 );
    low_arm.push_back(x2);
    low_arm.push_back(y2);
    low_arm.push_back(z2);
    hand.push_back(x3 );
    hand.push_back(y3 );
    hand.push_back(z3 );
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(up_arm);
    shoulder_result.push_back(low_arm);
    shoulder_result.push_back(hand);
    return shoulder_result;
}

vector<vector<double>> test_trail_elbow_angle_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> up_arm,low_arm,hand;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_right_low_arm" && part->name != "h_right_hand" && part->name != "h_right_up_arm"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_right_up_arm"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_right_low_arm"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
            else if(part->name == "h_right_hand"){
                x3 = m.tx;
                y3 = m.ty;
                z3 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    up_arm.push_back(x1 );
    up_arm.push_back(y1 );
    up_arm.push_back(z1 );
    low_arm.push_back(x2);
    low_arm.push_back(y2);
    low_arm.push_back(z2 );
    hand.push_back(x3 );
    hand.push_back(y3 );
    hand.push_back(z3 );
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(up_arm);
    shoulder_result.push_back(low_arm);
    shoulder_result.push_back(hand);
    return shoulder_result;
}

vector<vector<double>> test_elbow_line_lcy_beside(Bvh &bvhs){ //右肩-右肘延长线
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> up_arm,low_arm,hand;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_right_low_arm" && part->name != "h_right_hand" && part->name != "h_right_up_arm"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_right_up_arm"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_right_low_arm"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
            else if(part->name == "h_right_hand"){
                x3 = m.tx;
                y3 = m.ty;
                z3 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    up_arm.push_back(x1 );
    up_arm.push_back(y1 );
    up_arm.push_back(z1 );
    low_arm.push_back(x2);
    low_arm.push_back(y2);
    low_arm.push_back(z2 );
    hand.push_back(x3 );
    hand.push_back(y3 );
    hand.push_back(z3 );
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(up_arm);
    shoulder_result.push_back(low_arm);
//    shoulder_result.push_back(hand);
    return shoulder_result;
}

vector<vector<double>> test_grip_end_height_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> up_arm,low_arm,hand;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_wrist" && part->name != "h_right_wrist" && part->name != "club"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_wrist"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_right_wrist"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
            else if(part->name == "club"){
                x3 = m.tx;
                y3 = m.ty;
                z3 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    double y = y1 / 2 + y2 /2;
    y = y/2 + y3/2;
    up_arm.push_back(x1 - 10);
    up_arm.push_back(y);
    up_arm.push_back(z3 );
    low_arm.push_back(x2 + 10);
    low_arm.push_back(y);
    low_arm.push_back(z3 );
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(up_arm);
    shoulder_result.push_back(low_arm);
    return shoulder_result;
}

vector<vector<double>> test_head_line_lcy(Bvh &bvhs){
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    
    translation = getClubTranslation();
    
    vector<double> head_line;
    double head_x, head_y, head_z;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(part->name != "h_head"){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    if(part->name == "h_head" && vw.y > head_y){
                        head_x = vw.x;
                        head_y = vw.y;
                        head_z = vw.z;
                    }
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    // 一个点就够了
    head_line.push_back(head_x);
    head_line.push_back(head_y);
    head_line.push_back(head_z);
//    head_line[0] -= 50;
    vector<vector<double>> head_result;
    head_result.push_back(head_line);
    head_line[0] -= 50;
    head_result.push_back(head_line);
    head_line[0] += 100;
    head_result.push_back(head_line);
    return head_result;
}

vector<vector<double>> test_hip_depth_lcy(Bvh &bvhs){
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    
    translation = getClubTranslation();
    
    vector<double> head_line;
    double head_x, head_y, head_z;
    head_z = DBL_MAX;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(part->name != "h_waist"){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    if(part->name == "h_waist" && vw.z < head_z){
                        head_x = vw.x;
                        head_y = vw.y;
                        head_z = vw.z;
                    }
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    // 一个点就够了
    head_z -= 1.0;
    head_line.push_back(head_x);
    head_line.push_back(head_y);
    head_line.push_back(head_z);
//    head_line[0] -= 50;
    vector<vector<double>> head_result;
    head_result.push_back(head_line);
//    head_line[1] -= 50;
//    head_result.push_back(head_line);
//    head_line[1] += 100;
//    head_result.push_back(head_line);
    return head_result;
}

vector<vector<double>> test_head_line_lcy_app(Bvh &bvhs){ // 给文坚de
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    
    translation = getClubTranslation();
    
    vector<double> head_line;
    double head_x, head_y, head_z;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(part->name != "h_head"){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    if(part->name == "h_head" && vw.y > head_y){
                        head_x = vw.x;
                        head_y = vw.y;
                        head_z = vw.z;
                    }
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    // 一个点就够了
    head_line.push_back(head_x);
    head_line.push_back(head_y);
    head_line.push_back(head_z);
//    head_line[0] -= 50;
    vector<vector<double>> head_result;
    head_result.push_back(head_line);
//    head_line[0] -= 50;
//    head_result.push_back(head_line);
//    head_line[0] += 100;
//    head_result.push_back(head_line);
    return head_result;
}

vector<vector<double>> test_head_position_lcy(Bvh &bvhs){
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    
    translation = getClubTranslation();
    
    vector<double> head_pos;
    double left, right, up, down;
    left = DBL_MAX;
    right = - DBL_MAX;
    up = -DBL_MAX;
    down =  DBL_MAX;
    double z_gwj = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(part->name != "h_head"){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    if(part->name == "h_head" && vw.y > up){
                        up = vw.y;
                        z_gwj = vw.z;
                    }
                    else if (part->name == "h_head" && vw.y < down){
                        down = vw.y;
                    }
                    else if(part->name == "h_head" && vw.x < left){
                        left = vw.x;
                    }
                    else if (part->name == "h_head" && vw.x > right){
                        right = vw.x;
                    }
                    
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    // 左上
    head_pos.push_back(left);
    head_pos.push_back(up);
    head_pos.push_back(z_gwj);
//    head_line[0] -= 50;
    vector<vector<double>> head_result;
    head_result.push_back(head_pos);
    // 右上
    head_pos[0] = right;
    head_result.push_back(head_pos);
    // 右下
    head_pos[1] = down;
    head_result.push_back(head_pos);
    // 左下
    head_pos[0] = left;
    head_result.push_back(head_pos);
    return head_result;
}

vector<vector<double>> test_hand_position_lcy(Bvh &bvhs){
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    std::vector<std::string> handOrder = getLeftHandOrder();
//    std::vector<std::string> rightOrder = getRightHandOrder();
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    
    translation = getClubTranslation();
    
    vector<double> head_pos;
    double left, right, up, down;
    left = DBL_MAX;
    right = - DBL_MAX;
    up = -DBL_MAX;
    down =  DBL_MAX;
    double x_gwj = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(!count(handOrder.begin(),handOrder.end(),part->name)){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    if(std::count(handOrder.begin(),handOrder.end(),part->name) && vw.y > up){
                        up = vw.y;
                        x_gwj = vw.x;
                    }
                    else if (std::count(handOrder.begin(),handOrder.end(),part->name) && vw.y < down){
                        down = vw.y;
                    }
                    else if(std::count(handOrder.begin(),handOrder.end(),part->name) && vw.z < left){
                        left = vw.z;
                    }
                    else if (std::count(handOrder.begin(),handOrder.end(),part->name) && vw.z > right){
                        right = vw.z;
                    }
                    
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    left -= 1;
    right -= 1;
    // 左上
    head_pos.push_back(x_gwj);
    head_pos.push_back(up);
    head_pos.push_back(left);
//    head_line[0] -= 50;
    vector<vector<double>> head_result;
    head_result.push_back(head_pos);
    // 右上
    head_pos[2] = right;
    head_result.push_back(head_pos);
    // 右下
    head_pos[1] = down;
    head_result.push_back(head_pos);
    // 左下
    head_pos[2] = left;
    head_result.push_back(head_pos);
    return head_result;
}

vector<vector<double>> test_head_position_lcy_beside(Bvh &bvhs){ //侧面头高线
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    
    translation = getClubTranslation();
    
    vector<double> head_pos;
    double left, right, up, down;
    left = DBL_MAX;
    right = - DBL_MAX;
    up = -DBL_MAX;
    down =  DBL_MAX;
    double x_gwj = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        if(part->name != "h_head"){
            continue;
        }
        //printf("fr:%d",fr);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
                count++;
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
#endif
                    Matrix4x3 R0j = (it_part->gm);
                    Matrix4x3 R0ji = inverse(R0j);
                    vw += wij * (v0 * part->gm * R0ji * Rj);
                    wk -= wij;
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
#endif
                vw *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                //draw model;
                //if draw proj commment out
                normal = part->vexnormals[vexidint];
                normal *= rotmat; //rotmote为键盘设置的旋转角度Matrix4x3
                normal.normalize();

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    if(part->name == "h_head" && vw.y > up){
                        up = vw.y;
                        x_gwj = vw.x;
                    }
                    else if (part->name == "h_head" && vw.y < down){
                        down = vw.y;
                    }
                    else if(part->name == "h_head" && vw.z < left){
                        left = vw.z;
                    }
                    else if (part->name == "h_head" && vw.z > right){
                        right = vw.z;
                    }
                    
                }
            }
        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    // 左上
    left -= 1;
    right -= 1;
    head_pos.push_back(x_gwj);
    head_pos.push_back(up);
    head_pos.push_back(left);
//    head_line[0] -= 50;
    vector<vector<double>> head_result;
    head_result.push_back(head_pos);
    // 右上
    head_pos[2] = right;
    head_result.push_back(head_pos);
    // 右下
    head_pos[1] = down;
    head_result.push_back(head_pos);
    // 左下
    head_pos[2] = left;
    head_result.push_back(head_pos);
    return head_result;
}


vector<int> test_key_frames(string player_name){ // 保存关键帧，从0开始的！
    
    if(player_name == "dustin_johnson1"){
        int arr[13]= {0,25,44,59,91,110,118,121,123,126,129,138,198};
        vector<int> vc(arr, arr+13);
        return vc;
    }
    else if (player_name == "dustin_johnson2"){
        int arr[13]= {0,25,41,55,89,105,113,116,117,120,123,131,183};
        vector<int> vc(arr, arr+13);
        return vc;
    }
    else if (player_name == "justin_rose1"){
        int arr[13]= {0,32,45,63,91,112,120,123,125,128,132,144,192};
        vector<int> vc(arr, arr+13);
        return vc;
    }
    else if (player_name == "justin_rose2"){
        int arr[13]= {0,31,45,61,89,110,119,122,123,126,130,140,202};
        vector<int> vc(arr, arr+13);
        return vc;
    }
    else if (player_name == "sergio_garcia1"){
        int arr[13]= {0,30,47,63,101,114,122,125,127,129,133,139,188};
        vector<int> vc(arr, arr+13);
        return vc;
    }
    else if (player_name == "sergio_garcia2"){
        int arr[13]= {0,28,51,66,104,118,127,130,131,134,138,146,202};
        vector<int> vc(arr, arr+13);
        return vc;
    }
    else{
        int arr[13]= {0,0,0,0,0,0,0,0,0,0,0,0,0};
        vector<int> vc(arr, arr+13);
        return vc;
    }
    
}

vector<vector<double>> test_shaft_line_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> golf_head,golf_tail;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "club" && part->name != "lie"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "club"){
                x1 = m.tx+translation[0][0];
                y1 = m.ty+translation[0][1];
                z1 = m.tz+translation[0][2];
            }
            else if(part->name == "lie"){
                x2 = m.tx+translation[0][0];
                y2 = m.ty+translation[0][1];
                z2 = m.tz+translation[0][2];
            }
        }
        
        
    }
    //杆头杆尾
    golf_tail.push_back(x1);
    golf_tail.push_back(y1);
    golf_tail.push_back(z1);
    golf_head.push_back(x2);
    golf_head.push_back(y2);
    golf_head.push_back(z2);
//    head_line[0] -= 50;
    vector<vector<double>> shaft_line_result;
    shaft_line_result.push_back(golf_tail);
    shaft_line_result.push_back(golf_head);
    return shaft_line_result;
}

vector<vector<double>> test_shaft_line_toArmpit_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> golf_head,golf_tail;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "club" && part->name != "lie" && part->name != "h_right_up_arm"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "club"){
                x1 = m.tx+translation[0][0];
                y1 = m.ty+translation[0][1];
                z1 = m.tz+translation[0][2];
            }
            else if(part->name == "lie"){
                x2 = m.tx+translation[0][0];
                y2 = m.ty+translation[0][1];
                z2 = m.tz+translation[0][2];
            }
            else if(part->name == "h_right_up_arm"){
                x3 = m.tx;
                y3 = m.ty;
                z3 = m.tz;
            }
        }
        
        
    }
    //杆头杆尾

    double kx = x2 - x1;
    double ky = y2 - y1;
    double kz = z2 - z1;
    double xishu1 = 2;
    double xishu2 = -0.5;
    golf_tail.push_back(x3 + kx * xishu1);
    golf_tail.push_back(y3 + ky * xishu1);
    golf_tail.push_back(z3 + kz * xishu1);
    golf_head.push_back(x3 + kx * xishu2);
    golf_head.push_back(y3 + ky * xishu2);
    golf_head.push_back(z3 + kz * xishu2);
//    head_line[0] -= 50;
    vector<vector<double>> shaft_line_result;
    shaft_line_result.push_back(golf_tail);
    shaft_line_result.push_back(golf_head);
    return shaft_line_result;
}


vector<vector<double>> test_elbow_hosel_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> golf_head,golf_tail;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "lie" && part->name != "h_right_low_arm"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "lie"){
                x1 = m.tx+translation[0][0];
                y1 = m.ty+translation[0][1];
                z1 = m.tz+translation[0][2];
            }
            else if(part->name == "h_right_low_arm"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
        }
        
        
    }
    //杆头杆尾
    golf_tail.push_back(x1);
    golf_tail.push_back(y1);
    golf_tail.push_back(z1);
    golf_head.push_back(x2);
    golf_head.push_back(y2);
    golf_head.push_back(z2);
//    head_line[0] -= 50;
    vector<vector<double>> shaft_line_result;
    shaft_line_result.push_back(golf_tail);
    shaft_line_result.push_back(golf_head);
    return shaft_line_result;
}

vector<vector<double>> test_trail_leg_angle_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> up_arm,low_arm,hand;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_right_up_leg" && part->name != "h_right_low_leg" && part->name != "h_right_foot"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_right_up_leg"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_right_low_leg"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
            else if(part->name == "h_right_foot"){
                x3 = m.tx;
                y3 = m.ty;
                z3 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    up_arm.push_back(x1 );
    up_arm.push_back(y1 );
    up_arm.push_back(z1 );
    low_arm.push_back(x2);
    low_arm.push_back(y2);
    low_arm.push_back(z2);
    hand.push_back(x3 );
    hand.push_back(y3 );
    hand.push_back(z3 );
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(up_arm);
    shoulder_result.push_back(low_arm);
    shoulder_result.push_back(hand);
    return shoulder_result;
}

vector<vector<double>> test_lead_leg_angle_lcy(Bvh &bvhs){
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    translation = getClubTranslation();
    
    vector<double> up_arm,low_arm,hand;
    double x1 = 0;
    double y1 = 0;
    double z1 = 0;
    double x2 = 0;
    double y2 = 0;
    double z2 = 0;
    double x3 = 0;
    double y3 = 0;
    double z3 = 0;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        cout<< part->name <<endl;
        if(part->name != "h_left_up_leg" && part->name != "h_left_low_leg" && part->name != "h_left_foot"){ // 画啥用啥
            continue;
        }
        else{
            Matrix4x3 m = part->gmotion[fr];
            if(part->name == "h_left_up_leg"){
                x1 = m.tx;
                y1 = m.ty;
                z1 = m.tz;
            }
            else if(part->name == "h_left_low_leg"){
                x2 = m.tx;
                y2 = m.ty;
                z2 = m.tz;
            }
            else if(part->name == "h_left_foot"){
                x3 = m.tx;
                y3 = m.ty;
                z3 = m.tz;
            }
        }
        
        
    }
    //左肩右肩
    up_arm.push_back(x1 );
    up_arm.push_back(y1 );
    up_arm.push_back(z1 );
    low_arm.push_back(x2);
    low_arm.push_back(y2);
    low_arm.push_back(z2);
    hand.push_back(x3 );
    hand.push_back(y3 );
    hand.push_back(z3 );
//    head_line[0] -= 50;
    vector<vector<double>> shoulder_result;
    shoulder_result.push_back(up_arm);
    shoulder_result.push_back(low_arm);
    shoulder_result.push_back(hand);
    return shoulder_result;
}

vector<vector<vector<double>>> recursivedrawFace_wj_order(Bvh &bvhs){
    vector<vector<vector<double>>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    vector<vector<double>> _position;
    vector<vector<double>> _normal;
    vector<vector<double>> _texture;
    translation=getClubTranslation();
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
#if true
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            count++;
            for (auto vexid:faceit)
            {
                block_count++;
                
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                Vector3 normal0= part->vexnormals[vexidint];
                
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
                    
//                    if(visionOrder[i]=="length"){//shaft_8
//                        cout<<it_part->name<<" "<<it->second<<endl;
//                    }
                    
#ifdef _KEYFRAME_MODE
                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
#else
                    Matrix4x3 Rj = it_part->gmotion[fr];
//                    if(visionOrder[i]=="length"){
//                        cout<<"gmotion:"<<Rj.tx<<endl;
//                    }
                    
#endif
//                    if(it_part->name.find("fing")!=string::npos||it_part->name.find("mcarpal")!=string::npos||it_part->name.find("wrist")!=string::npos||it_part->name.find("hand")!=string::npos){
                        Matrix4x3 R0j = (it_part->gmatrix);
                        Matrix4x3 R0ji = inverse(R0j);
                        vw += wij * (v0 * part->gmatrix * R0ji * Rj);
                        normal+=wij*(normal0*part->gmatrix * R0ji * Rj);
                        wk -= wij;
//                        cout<<it_part->name<<endl;
//                    }else{
//                        Matrix4x3 R0j = (it_part->gmatrix);
//                        Matrix4x3 R0ji = inverse(R0j);
//                        vw += wij * (v0 * part->gmatrix * R0ji * Rj);
//                        normal+=wij*(normal0*part->gmatrix * R0ji * Rj);
//                        wk -= wij;
//                    }
                    
//                    if(visionOrder[i]=="length"){
//                        cout<<vw.x<<" "<<vw.y<<" "<<vw.z<<" "<<endl;
//                    }
                }
#ifdef _KEYFRAME_MODE
                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
#else
                vw += wk * (v0 * part->gmotion[fr]);
//                vw=v0 * part->gmatrix;//Tpose mdl
//                vw=v0 * part->gm;//Tpose bdf
//                vw=v0 * part->gmotion[fr];//无 线性蒙皮
#endif
                //draw model;
                //if draw proj commment out
//                normal+=wk *(normal0 * part->motion[fr]);
                normal=normal0;
                normal.normalize();
//                if(visionOrder[i]=="h_waist"&&vexidint==1){
////                    cout<<"00001:"<<v0.x<<" "<<v0.y<<" "<<v0.z<<" "<<endl;
//                    cout<<"99999:"<<normal.x<<" "<<normal.y<<" "<<normal.z<<endl;
//                }

//                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
                if(i<100){
                    //for mike
                    if(player == "mike_weir"){
                        vw.x=-vw.x+35;
                        vw.z=-vw.z;
                    }
                    if(i<70){
                        avg_x+=vw.x;
                        avg_y+=vw.y;
                        avg_z+=vw.z;
                    }
                    //glVertex3f(vw.x, vw.y, vw.z); //描出多边形中的点
                    vector<double> pos;
//                    pos.push_back(vw.x);
//                    pos.push_back(vw.y);
//                    pos.push_back(vw.z);
                    if(1 && (getPre3dOrder_mode == 1 && i >= 70) || (getPre3dOrder_mode == 2 && i>= 60) || (getPre3dOrder_mode == 3 && i>= 68)){
                                            if(player == "mike_weir"){
                                                pos.push_back(vw.x+translation[1][0]);
                                                pos.push_back(vw.y+translation[1][1]);
                                                pos.push_back(vw.z+translation[1][2]);
                                            }
                                            else{
                                                pos.push_back(vw.x+translation[0][0]);
                                                pos.push_back(vw.y+translation[0][1]);
                                                pos.push_back(vw.z+translation[0][2]);
                                            }
                                        }
                                        else{
                                            pos.push_back(vw.x);
                                            pos.push_back(vw.y);
                                            pos.push_back(vw.z);
                                        }
                    _position.push_back(pos);
                    vector<double> pos2;
                    pos2.push_back(normal.x);
                    pos2.push_back(normal.y);
                    pos2.push_back(normal.z);
                    _normal.push_back(pos2);
                    vector<double> pos3;
                    pos3.push_back(part->texture[part->face_texture[count-1][block_count-1]][0]);
                    pos3.push_back(part->texture[part->face_texture[count-1][block_count-1]][1]);
                    _texture.push_back(pos3);
                    all_count++;
                }
            }
            blocks[block_index]=block_count;
            block_index++;//在里面是每一小块，外面是每一块躯干

        }
        //blocks[block_index]=block_count;
        //block_index++;//在里面是每一小块，外面是每一块躯干
    }
    
    result.push_back(_position);
    result.push_back(_normal);
    result.push_back(_texture);
//    }
#endif
    return result;
}

//vector<vector<vector<double>>> recursivedrawFace_wj_order(Bvh &bvhs){
//    vector<vector<vector<double>>> result;
//    vector<vector<float>> vwaist;  //二维数组
//    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
//#ifdef _KEYFRAME_MODE
//    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;
//
//#else
//    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
//#endif
//    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
//    avg_count = 0;
//    int all_count = 0;
//    int block_index = 0;
//    vector<vector<double>> _position;
//    vector<vector<double>> _normal;
//    translation=getClubTranslation();
//    for (unsigned int i=0 ; i< visionOrder.size();i++)
//    {
//        //遍历vision数组,其中是不同的关节
//        BvhPart *part;
//        part = bvhs.getBvhPart(visionOrder[i]);
//        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
//#if true
//        //针对每一个关节做二维int数组的二层循环
//        int count = 0;
//        //int block_count = 0;
//        for(auto faceit:part->faces)
//        {
//            int block_count = 0;
//            for (auto vexid:faceit)
//            {
//                block_count++;
//                count++;
//                // vexid的类型是int,每一个faceit由k个int数组成
//                int vexidint = vexid;
//                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
//                float wk = 1;
//                Vector3 v0(xx, yy, zz);
//                Vector3 vw(0, 0, 0);
//                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
//                Vector3 normal0= part->vexnormals[vexidint];
//
//
//                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
//                for (auto it = part->Jweight[vexidint].begin();
//                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
//                    float wij = it->second;
//                    BvhPart *it_part = bvhs.getBvhPart(it->first);
//
////                    if(visionOrder[i]=="length"){//shaft_8
////                        cout<<it_part->name<<" "<<it->second<<endl;
////                    }
//
//#ifdef _KEYFRAME_MODE
//                    Matrix4x3 Rj = it_part->gmotion[keyframe_id[fr] - 1];
//#else
//                    Matrix4x3 Rj = it_part->gmotion[fr];
////                    if(visionOrder[i]=="length"){
////                        cout<<"gmotion:"<<Rj.tx<<endl;
////                    }
//
//#endif
////                    if(it_part->name.find("fing")!=string::npos||it_part->name.find("mcarpal")!=string::npos||it_part->name.find("wrist")!=string::npos||it_part->name.find("hand")!=string::npos){
//                        Matrix4x3 R0j = (it_part->gm);
//                        Matrix4x3 R0ji = inverse(R0j);
//                        vw += wij * (v0 * part->gm * R0ji * Rj);
//                        normal+=wij*(normal0*part->gm * R0ji * Rj);
//                        wk -= wij;
////                        cout<<it_part->name<<endl;
////                    }else{
////                        Matrix4x3 R0j = (it_part->gmatrix);
////                        Matrix4x3 R0ji = inverse(R0j);
////                        vw += wij * (v0 * part->gmatrix * R0ji * Rj);
////                        normal+=wij*(normal0*part->gmatrix * R0ji * Rj);
////                        wk -= wij;
////                    }
//
////                    if(visionOrder[i]=="length"){
////                        cout<<vw.x<<" "<<vw.y<<" "<<vw.z<<" "<<endl;
////                    }
//                }
//#ifdef _KEYFRAME_MODE
//                vw += wk * (v0 * part->gmotion[keyframe_id[fr] - 1]);
//#else
//                vw += wk * (v0 * part->gmotion[fr]);
////                vw=v0 * part->gmatrix;//Tpose mdl
////                vw=v0 * part->gm;//Tpose bdf
////                vw=v0 * part->gmotion[fr];//无 线性蒙皮
//#endif
//                //draw model;
//                //if draw proj commment out
////                normal+=wk *(normal0 * part->motion[fr]);
//                normal=normal0;
//                normal.normalize();
////                if(visionOrder[i]=="h_waist"&&vexidint==1){
//////                    cout<<"00001:"<<v0.x<<" "<<v0.y<<" "<<v0.z<<" "<<endl;
////                    cout<<"99999:"<<normal.x<<" "<<normal.y<<" "<<normal.z<<endl;
////                }
//
////                glVertex3f((v0*part->gm*part->gmotion[fr]).x, (v0*part->gm*part->gmotion[fr]).y, (v0*part->gm*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
////                 glVertex3f((v0*part->gmotion[fr]).x, (v0*part->gmotion[fr]).y, (v0*part->gmotion[fr]).z); //描出多边形中的点 其中，v0是直接读取的皮肤顶点，未做其他计算
//                if(i<100){
//                    //for mike
//                    if(player == "mike_weir"){
//                        vw.x=-vw.x+35;
//                        vw.z=-vw.z;
//                    }
//                    if(i<70){
//                        avg_x+=vw.x;
//                        avg_y+=vw.y;
//                        avg_z+=vw.z;
//                    }
//                    //glVertex3f(vw.x, vw.y, vw.z); //描出多边形中的点
//                    vector<double> pos;
////                    pos.push_back(vw.x);
////                    pos.push_back(vw.y);
////                    pos.push_back(vw.z);
//                    if(1 && (getPre3dOrder_mode == 1 && i >= 70) || (getPre3dOrder_mode == 2 && i>= 60) || (getPre3dOrder_mode == 3 && i>= 68)){
//                                            if(player == "mike_weir"){
//                                                pos.push_back(vw.x+translation[1][0]);
//                                                pos.push_back(vw.y+translation[1][1]);
//                                                pos.push_back(vw.z+translation[1][2]);
//                                            }
//                                            else{
//                                                pos.push_back(vw.x+translation[0][0]);
//                                                pos.push_back(vw.y+translation[0][1]);
//                                                pos.push_back(vw.z+translation[0][2]);
//                                            }
//                                        }
//                                        else{
//                                            pos.push_back(vw.x);
//                                            pos.push_back(vw.y);
//                                            pos.push_back(vw.z);
//                                        }
//                    _position.push_back(pos);
//                    vector<double> pos2;
//                    pos2.push_back(normal.x);
//                    pos2.push_back(normal.y);
//                    pos2.push_back(normal.z);
//                    _normal.push_back(pos2);
//                    all_count++;
//                }
//            }
//            blocks[block_index]=block_count;
//            block_index++;//在里面是每一小块，外面是每一块躯干
//
//        }
//        //blocks[block_index]=block_count;
//        //block_index++;//在里面是每一小块，外面是每一块躯干
//    }
//
//    result.push_back(_position);
//    result.push_back(_normal);
////    }
//#endif
//    return result;
//}
vector<vector<double>> getClubTranslation(){
    vector<vector<double>> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getTransOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    
    set<string> left_joints;
    set<string> right_joints;
    set<string> club_joints;
//    left_joints.insert("h_left_mid_fing_2");
//    right_joints.insert("h_right_mid_fing_2");right_joints.insert("h_right_low_fing_1");
    left_joints.insert("h_left_low_fing_2");left_joints.insert("h_left_hand");left_joints.insert("h_right_low_fing_3");
    //left_joints.insert("h_left_hand");
    right_joints.insert("h_right_low_fing_2");right_joints.insert("h_right_hand");right_joints.insert("h_left_low_fing_4");
    //right_joints.insert("h_right_low_fing_2");
    //right_joints.insert("h_right_hand");
    club_joints.insert("club");
    double lx=0,ly=0,lz=0,rx=0,ry=0,rz=0;
    double std_x = 0, std_y = 0, std_z = 0;
    int l_count=0,r_count=0;
    vector<double> left_hand;
    vector<double> right_hand;
    
    BvhPart *part_club;
    part_club = bvhs.getBvhPart("club");
    Matrix4x3 m = part_club->gmotion[fr];
    std_x += m.tx; std_y += m.ty; std_z += m.tz;
    
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        
        if(left_joints.count(visionOrder[i])){//h_left_mid_fing_2 h_left_hand
            BvhPart *part;
            part = bvhs.getBvhPart(visionOrder[i]);
            Matrix4x3 m = part->gmotion[fr];
            lx += m.tx; ly += m.ty; lz += m.tz;
            l_count++;
            if(l_count == left_joints.size()){
                left_hand.push_back(lx/(left_joints.size()*1.0)-std_x);
                left_hand.push_back(ly/(left_joints.size()*1.0)-std_y);
                left_hand.push_back(lz/(left_joints.size()*1.0)-std_z);
//                printf("左手标记：%d，%f,%f,%f\n",i,left_hand[0],left_hand[1],left_hand[2]);
            }
        }
        else if(right_joints.count(visionOrder[i])){
            BvhPart *part;
            part = bvhs.getBvhPart(visionOrder[i]);
            Matrix4x3 m = part->gmotion[fr];
            rx += m.tx; ry += m.ty; rz += m.tz;
            r_count++;
            if(r_count == right_joints.size()){
                right_hand.push_back(-rx/(right_joints.size()*1.0)+std_x);
                right_hand.push_back(ry/(right_joints.size()*1.0)-std_y);
                right_hand.push_back(-rz/(right_joints.size()*1.0)+std_z);
//                printf("右手标记：%d\n",i);
            }
        }
    }
    
    //lcy test 添加球杆线用的
    result.push_back(left_hand);
    result.push_back(right_hand);
    
    
    return result;
}
vector<vector<vector<double>>> Display2(int frame){
    fr = frame;
    
    vector<vector<vector<double>>> result = recursivedrawFace_wj_order(bvhs);
    vector<int> test = test_key_frames(cur_player);
//    for(int i = 0; i < test.size(); i++)
//        {
//            cout<<test[i]<<endl;
//        }
    //测试头高线用
//    vector<vector<double>> head_result = test_head_line_lcy(bvhs);
//    result[0].push_back(head_result[0]);
//    vector<vector<double>> head_position = test_head_position_lcy(bvhs);
//    result[0].push_back(head_position[0]);
//    result[0].push_back(head_position[1]);
//    result[0].push_back(head_position[2]);
//    result[0].push_back(head_result[1]);
//    result[0].push_back(head_result[2]);
    
    return result;
}

vector<vector<vector<double>>> front_lines(){
    
    vector<int> key_frame = test_key_frames(cur_player);
   
    vector<vector<vector<double>>> result;
    result.push_back(test_head_line_lcy_app(bvhs)); // 1个点 横线
    result.push_back(test_head_position_lcy(bvhs)); // 4个点 左上-右上-右下-左下
    result.push_back(test_Lower_Body_Position_lcy(bvhs)); // 4个点 左上-右上-右下-左下
    result.push_back(test_spine_tilt_lcy(bvhs)); // 2个点
    result.push_back(test_leadarm_line_lcy(bvhs)); // 2个点
    result.push_back(test_shoulder_angle_lcy(bvhs));// 2个点
    result.push_back(test_shaft_line_lcy(bvhs)); // 2个点
    result.push_back(test_grip_end_height_lcy(bvhs)); // 2个点
    result.push_back(test_lead_forearm_line_lcy(bvhs)); // 2个点
    result.push_back(test_feet_width(bvhs)); // 4个点 左上-右上-右下-左下
    result.push_back(test_trail_elbow_angle_lcy(bvhs)); // 3个点 上-中-下
    result.push_back(test_lead_elbow_angle_lcy(bvhs)); // 3个点 上-中-下
    result.push_back(test_knee_width(bvhs)); // 4个点 左上-右上-右下-左下
    result.push_back(test_trail_leg_angle_lcy(bvhs));// 3个点 上-中-下
    result.push_back(test_lead_leg_angle_lcy(bvhs));// 3个点 上-中-下
    
    return result;
}

vector<vector<vector<double>>> beside_lines(){
    
    vector<int> key_frame = test_key_frames(cur_player);
   
    vector<vector<vector<double>>> result;

    result.push_back(test_elbow_hosel_lcy(bvhs)); // 2个点
    result.push_back(test_hip_depth_lcy(bvhs)); // 1个点 竖线
    result.push_back(test_head_position_lcy_beside(bvhs)); // 4个点 左上-右上-右下-左下
    result.push_back(test_shaft_line_toArmpit_lcy(bvhs)); // 2个点
    result.push_back(test_hand_position_lcy(bvhs)); // 4个点 左上-右上-右下-左下
    result.push_back(test_knee_width_beside(bvhs));// 4个点 左上-右上-右下-左下
    result.push_back(test_elbow_line_lcy_beside(bvhs));// 2个点 右肩-右肘
    
    return result;
}

vector<int> getClubCount(){ // left是这part的第一个index right是最后一个，left左边都是身体了 left到right是杆
    vector<int> result;
    vector<int> res;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    std::vector<std::string> clubOrder = getClubOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    int all = 0;
    int left = 0;
    int right = 0;
    int left_indice = 0;
    int right_indice = 0;
    int flag = 0;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                if(count(clubOrder.begin(),clubOrder.end(),part->name) &&flag == 0){
                    left = all;
                    flag = 1;
                    left_indice = result.size();
                }
                else if (count(clubOrder.begin(),clubOrder.end(),part->name)){
                    right = all;
                    right_indice = result.size();
                }
                block_count++;
                all ++;
                
            }
            result.push_back(block_count);
//            all += 1;
        }
    }
    
    cout<<"all!:"<<all<<endl;
    res.push_back(left);
    res.push_back(right);
    res.push_back(left_indice);
    res.push_back(right_indice);
    return res;
}

vector<int> getHeadCount(){ // left是这part的第一个index right是最后一个
    vector<int> result;
    vector<int> res;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    int all = 0;
    int left = 0;
    int right = 0;
    int left_indice = 0;
    int right_indice = 0;
    int flag = 0;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                if(part->name == "h_head" &&flag == 0){
                    left = all;
                    flag = 1;
                    left_indice = result.size();
                }
                else if (part->name == "h_head"){
                    right = all;
                    right_indice = result.size();
                }
                block_count++;
                all ++;
                
            }
            result.push_back(block_count);
//            all += 1;
        }
    }
    
//    result.push_back(3);//头高线
    
//    result.push_back(2);//杆线
    result.push_back(4);//梯形
    result.push_back(4);//肩膀
    result.push_back(2);//杆线
    cout<<"all!:"<<all<<endl;
    res.push_back(left);
    res.push_back(right);
    res.push_back(left_indice);
    res.push_back(right_indice);
    return res;
}


vector<int> getBodyCount(){
    vector<int> result;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序 要写三种！
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    int all = 0;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        for(auto faceit:part->faces)
        {
            int block_count = 0;
            for (auto vexid:faceit)
            {
                block_count++;
            }
            result.push_back(block_count);
            all += 1;
        }
    }
    cout<<"all!:"<<all<<endl;
    return result;
}

string mdlFile;
string bdfFile;
string dofFile;
string varFile;
string initPlayer;

void fileName(string path, string player_name){
    string club_parent = "h_left_low_fing_1";
    cout<<player<<endl;
    string file = path  + "/oc/samples/zhiye/taylormade_archive/";
    string tmp = player_name;
    tmp.erase(tmp.end() - 1);
    file += tmp;
    cur_player = player_name;
    if(player_name == "dustin_johnson1"){
        club_parent = "h_left_low_fing_1";
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_004.var";
    }
    else if(player_name == "dustin_johnson2"){
        club_parent = "h_left_low_fing_1";
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_005.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_006.var";
    }
    else if(player_name == "justin_rose1"){
        club_parent = "h_left_low_fing_2";
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_001.var";
    }
    else if(player_name == "justin_rose2"){
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_004.var";
    }
    else if(player_name == "mike_weir1"){
        club_parent = "h_right_up_fing_2";
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_005.var";
    }
    else if(player_name == "mike_weir2"){
        club_parent = "h_right_up_fing_2";
        getPre3dOrder_mode = 3;
        cout<<file<<endl;
        mdlFile = file+"/swing_009.mdl";
        dofFile = file+"/swing_009.dof";
        bdfFile = file+"/swing_009.bdf";
        varFile = file+"/swing_009.var";
    }
    else if(player_name == "mike_weir3"){
        club_parent = "h_right_up_fing_2";
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_006.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_031.var";
    }
    else if(player_name == "darren_clarke1"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_003.var";
    }
    else if(player_name == "darren_clarke2"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_004.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_004.bdf";
        varFile = file+"/swing_005.var";
    }
    else if(player_name == "gary_mccord1"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_004.mdl";
        dofFile = file+"/swing_004.dof";
        bdfFile = file+"/golfer.club.ball.bdf";
        varFile = file+"/swing_004.var";
    }
    else if(player_name == "graeme_mcdowell1"){
        getPre3dOrder_mode = 3;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_003.var";
    }
    else if(player_name == "hank_kuehne1"){
        getPre3dOrder_mode = 3;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_003.var";
    }
    else if(player_name == "hidemichi_tanaka1"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_005_FB_540PMK_SFlexSTD_RIGHT_FLEX.mdl";
        dofFile = file+"/swing_005_FB_540PMK_SFlexSTD_RIGHT_FLEX.dof";
        bdfFile = file+"/golfer.club.ball.bdf";
        varFile = file+"/swing_005_FB_540PMK_SFlexSTD_RIGHT_FLEX.var";
    }
    else if(player_name == "natalie_gulbis1"){
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_002.var";
    }
    else if(player_name == "natalie_gulbis2"){
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_006.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_006.bdf";
        varFile = file+"/swing_006.var";
    }
    else if(player_name == "sergio_garcia1"){
        getPre3dOrder_mode = 3;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf";
        varFile = file+"/swing_003.var";
    }
    else if(player_name == "sergio_garcia2"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_005_FB_540PMK_SFlexSTD_RIGHT_FLEX.mdl";
        dofFile = file+"/swing_005_FB_540PMK_SFlexSTD_RIGHT_FLEX.dof";
        bdfFile = file+"/golfer.club.ball.bdf";
        varFile = file+"/swing_005_FB_540PMK_SFlexSTD_RIGHT_FLEX.var";
    }
    else if(player_name == "tom_lehman1"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_004_FB_540PMK_SFlexSTD_RIGHT_FLEX.mdl";
        dofFile = file+"/swing_004_FB_540PMK_SFlexSTD_RIGHT_FLEX.dof";
        bdfFile = file+"/golfer.club.ball.bdf";
        varFile = file+"/swing_004_FB_540PMK_SFlexSTD_RIGHT_FLEX.var";
    }
    else if(player_name == "fred_funk1"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_012.dof";
        bdfFile = file+"/swing_012.bdf";
        varFile = file+"/swing_012.var";
    }
    else if(player_name == "fred_funk2"){
        getPre3dOrder_mode = 2;
        cout<<file<<endl;
        mdlFile = file+"/swing_018.mdl";
        dofFile = file+"/swing_019.dof";
        bdfFile = file+"/swing_019.bdf";
        varFile = file+"/swing_019.var";
    }else if(player_name == "sean_ohair1"){
        getPre3dOrder_mode = 1;
        cout<<file<<endl;
        mdlFile = file+"/swing_001.mdl";
        dofFile = file+"/swing_001.dof";
        bdfFile = file+"/swing_001.bdf"; // 不存在
        varFile = file+"/swing_002.var";
    }
    
    player_name.erase(player_name.end() - 1);
    player = player_name;
    
    Bvh bvh_new;
    bvhs = bvh_new;
    
    bvhs.mdlParse(mdlFile, club_parent);
    cout<<"mdlParse"<<endl;
    bvhs.dofParse(dofFile);
    cout<<"dofParse"<<endl;
    bvhs.bdfParse(bdfFile);
    cout<<"bdfParse"<<endl;
    bvhs.varParse(varFile);
    cout<<"varParse"<<endl;
    cout<<"loadFiles"<<endl;
//    cout<<bvhs.getBvhPart("length")->motion_tran[1].x<<endl;
    InitModel();
    cout<<"InitModel"<<endl;
}

#include <time.h>
vector<vector<double>> Display(int frame) {
//    clock_t start, finish;
//    double  duration;
//    printf("Time to do parse is ");
//    start = clock();
    //times = time;
//    if(initPlayer == "" || initPlayer != file_name){
//    //if(times == 0){
//        printf("hello2\n");
//        //write_func = true;
//
//
//        initPlayer = file_name;
//        fileName(path, file_name);
//
//
//
////                number = 2;
////                player = "natalie_gulbis";//dustin_johnson mike_weir sergio_garcia hank_kuehne graeme_mcdowell
////                //printf(getenv("HOME"));
////                string file = path  + "/oc/samples/zhiye/taylormade_archive/" + player;
////                //string file = "D:\\golf\\3dModel-gcy\\3dModel/samples/tombak/aiping_sun/session_2011-06-10"+player;
////        bvhs.mdlParse(file+"/swing_006.mdl");
////        cout<<"mdlParse"<<endl;
////        bvhs.dofParse(file+"/swing_001.dof");
////        cout<<"dofParse"<<endl;
////        bvhs.bdfParse(file+"/swing_006.bdf");
////        cout<<"bdfParse"<<endl;
////        bvhs.varParse(file+"/swing_006.var");
////        cout<<"varParse"<<endl;
////
////        bvhs.mdlParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_001.mdl");
////        cout<<"mdlParse"<<endl;
////        bvhs.dofParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_001.dof");
////        cout<<"dofParse"<<endl;
////        bvhs.bdfParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_001.bdf");
////        cout<<"bdfParse"<<endl;
////        bvhs.varParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_004.var");
//
//
//    }
//    times++;  //通过times值的控制，仅在第一次的时候解析数据文件
//    cout<<"recursivedrawFace_wl:times:"<<times<<endl;
    fr = frame;
    //recursivedrawFace_wl(bvhs);
//    finish   = clock();
//    duration = (double)(finish - start) / CLOCKS_PER_SEC;
//    printf("%f seconds\n", duration);
    return recursivedrawFace_wl(bvhs);   //coordinate and people every Frame
}



void timeFunc() {
    while(fr!=bvhs.framesNum-1){
        cout<<"frame"<<fr<<endl;
        //Display();
        fr++;
        if(fr==bvhs.framesNum-1){
            fr=0;
            break;
            //exit(0);
        }
    }
}

int getFrameCount( string path, string file_name){
    if(initPlayer == "" || initPlayer != file_name){
        printf("hello2\n");
        initPlayer = file_name;
        fileName(path, file_name);
    }
    return bvhs.framesNum;
}

//int main(int argc, char** argv) {
//
//    printf("hello\n");
//    cout<<Display()<<endl;
//    return 0;
//}
