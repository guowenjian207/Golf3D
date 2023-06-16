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
#include "../biovision/Bvh.h"
#include <vector>
#include <iterator>
#include <sstream>
#include <stdlib.h>
#include <map>
#include <json/json.h>
#include "../biovision/BioUtil.h"
#include "../3dmath/Vector3.h"
#include "../3dmath/math3d.h"
#include"math.h"
#include<fstream>


#define PI 3.1415926535857
//#define _KEYFRAME_MODE

using namespace std;




float angle=0;
string player;
bool write_func;
int number;
/**
 * 初始化OpenGL绘制的基础设置
 */
int mark = 0;
int qugan = 0;

Bvh bvhs;

int add(int a,int b){
    return a + b;
}


/*
 * 初始化参数，在初始化模型中被调用
 */
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
        length["h_left_up_leg"]=length["h_right_up_leg"]=l40;
        length["h_left_low_leg"]=length["h_right_low_leg"]=l40;
        length["h_left_up_arm"]=length["h_right_up_arm"]=l30;
        length["h_left_low_arm"]=length["h_right_low_arm"]=l30;
    }
}


int cnt=0;
void InitModel()
{
    float t=cmtoinch(30);
    float h,w,wg;
    map<string,float> length,girth;
    bvhs.computeHeight(); //感觉是计算人体高度

    if(cnt==0){
        inputParam(h,w,wg,length,girth); //初始化左右腿和胳膊的长度
        cout<<bvhs.bodyName["h_right_up_leg"]->height<<endl;
        t=cmtoinch(60);
        cout<<"30/60cm:"<<t<<endl;
        bvhs.computePartSize(); //计算所有节点们物体长宽高
        bvhs.paramBodySize(h,w,wg,length,girth);
        bvhs.recurSetFamilyGlobalMatrix();
        bvhs.resetOriginPoint();
        bvhs.recurSetFamilyGlobalMatrix();
        cnt++;
    }
    bvhs.computeHeight();
    bvhs.computeFaceNormal();
    bvhs.computeVexNormal();
}



//给string的vector中添加元素
std::vector<std::string> getPre3dOrder() {
    std::vector<std::string> visionOrder;
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
    visionOrder.push_back("hosel");
    visionOrder.push_back("lie");
    visionOrder.push_back("loft");
    visionOrder.push_back("clubface");
    //visionOrder.push_back("ball");
    return visionOrder;
}


int fr=0;
int mode=1;//0表示绘制骨架，1表示绘制肢体
int times=0;
int k=0;


Matrix4x3 rotmat;
float avg_x=0;float avg_y=0;float avg_z=0;
int avg_count=0;




double prev_pos[500000][3];
int blocks[50000];
double prev_vect[500000];
int quant(double dis, double s, float z){
    return  int(round(dis / s + z));
}
#include <io.h>
#include <direct.h>
#include <string>

int write_file (int all_count, int frame)
{
    FILE * fp;
    string file_path = "player/"+player+to_string(number)+"/output/" + to_string(frame) + ".txt";
    string prefix = "player/"+player+to_string(number);
    string prefix2 = "player/"+player+to_string(number)+"/output/";
    if (_access(prefix.c_str(), 0) == -1)	//如果文件夹不存在
        _mkdir(prefix.c_str());				//则创建
    _mkdir(prefix2.c_str());


    if((fp = fopen(file_path.c_str(),"wb"))==NULL){
        printf("cant open the file");
        exit(0);
    }
    fprintf(fp, "%d ", all_count);
    for(int i=0;i<all_count;i++) {
        for (int j = 0; j < 3; j++) {
            fprintf(fp, "%lf ", prev_pos[i][j]);
        }
    }
    fclose(fp);
    return 0;
}


int write_file_blocks (int block_index)
{
    FILE * fp;
    string file_path = "player/"+player+to_string(number)+"/count/count.txt";

    string prefix = "player/"+player+to_string(number);
    string prefix2 = "player/"+player+to_string(number)+"/count/";
    if (_access(prefix.c_str(), 0) == -1)	//如果文件夹不存在
        _mkdir(prefix.c_str());				//则创建
    _mkdir(prefix2.c_str());

    if((fp = fopen(file_path.c_str(),"wb"))==NULL){
        printf("cant open the file");
        exit(0);
    }
    for(int i=0;i<block_index;i++) {
        fprintf(fp, "%d ", blocks[i]);
    }
    fclose(fp);
    return 0;
}

// by wl every frame
int recursivedrawFace_wl(Bvh &bvhs){
    return bvhs.framesNum;
    vector<vector<float>> vwaist;  //二维数组
    std::vector<std::string> visionOrder = getPre3dOrder();  //节点列表顺序
#ifdef _KEYFRAME_MODE
    cout << "begin draw keyframe face, keyframe id:" << keyframe_id[fr] << endl;

#else
    cout << "begin draw face ddyy, frame:" << fr << endl; //fr全局变量代表帧数
#endif
    //按照关节顺序依次画(由getPre3dOrder()定义顺序)
    double dismax=-99999;
    double dismin=99999;
    int id = -1;
    int id2 = -1;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        cout << "cal"<< i << endl; //fr全局变量代表帧数
        //caclulate distance max and min
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        for(auto faceit:part->faces)
        {
            for (auto vexid:faceit)
            {
                // vexid的类型是int,每一个faceit由k个int数组成
                int vexidint = vexid;
                float xx = part->vertices[vexidint].x, yy = part->vertices[vexidint].y, zz = part->vertices[vexidint].z; //v是每一个part的vertex顶点数组part->vertices
                float wk = 1;
                Vector3 v0(xx, yy, zz);
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
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
                //glNormal3f(normal.x, normal.y, normal.z);  //确定每个顶点的法向量 | 注释掉会失去现有的阴影效果
                double dis = 0;
                double velocity = 0;
                if(i<70){
                    dis = (vw.x-prev_pos[avg_count][0])*(vw.x-prev_pos[avg_count][0]) + \
                            (vw.y-prev_pos[avg_count][1])*(vw.y-prev_pos[avg_count][1])+ \
                            (vw.z-prev_pos[avg_count][2])*(vw.z-prev_pos[avg_count][2]);
                    dis = sqrt(dis);
                    velocity = dis - prev_vect[avg_count];
                    avg_count++;
                }
                if (dis < 0){
                    continue;
                }
                if(velocity > dismax){
                    dismax = velocity;
                    id = i;
                }
                if(velocity < dismin){
                    dismin = velocity;
                    id2 = i;
                }
            }
        }
    }
    double s = (dismax - dismin) / 255;
    float z = round(128 - dismax / s);
    printf("vmax:%f,vmin:%f,s:%f,z:%f,i:%d\n",dismax,dismin,s,z,avg_count);
    std::cout<<bvhs.getBvhPart(visionOrder[id])->name<<endl;
    std::cout<<bvhs.getBvhPart(visionOrder[id2])->name<<endl;
    avg_count = 0;
    int all_count = 0;
    int block_index = 0;
    for (unsigned int i=0 ; i< visionOrder.size();i++)
    {
        //add by dragon;test one bones
        //std::cout<<bvhs.getBvhPart(visionOrder[i])->name<<endl;
//       if(bvhs.getBvhPart(visionOrder[i])->name!="h_left_hand"){
//           continue;
//       }
        //遍历vision数组,其中是不同的关节
        BvhPart *part;
        part = bvhs.getBvhPart(visionOrder[i]);
        std::vector<Vector3> vertices=part->vertices;  //针对每一个骨骼，vertices是一个二维数组
        //打印gm
//         cout<<part->gm.m11<<' '<<part->gm.m12<<' '<<part->gm.m13<<std::endl;
//         cout<<part->gm.m21<<' '<<part->gm.m22<<' '<<part->gm.m23<<std::endl;
//         cout<<part->gm.m31<<' '<<part->gm.m32<<' '<<part->gm.m33<<std::endl;
//         cout<<part->gm.tx<<' '<<part->gm.ty<<' '<<part->gm.tz<<std::endl<<std::endl;
        //输出gm到文件夹 by dragon
//         gm<<bvhs.getBvhPart(visionOrder[i])->name<<endl;
//         gm<<std::fixed<<part->gm.m11<<' '<<part->gm.m12<<' '<<part->gm.m13<<std::endl;
//         gm<<std::fixed<<part->gm.m21<<' '<<part->gm.m22<<' '<<part->gm.m23<<std::endl;
//         gm<<std::fixed<<part->gm.m31<<' '<<part->gm.m32<<' '<<part->gm.m33<<std::endl;
//         gm<<std::fixed<<part->gm.tx<<' '<<part->gm.ty<<' '<<part->gm.tz<<std::endl<<std::endl;
//         //输出gmotion[fr]到文件
//         gmotion<<bvhs.getBvhPart(visionOrder[i])->name<< "| frame="<<fr<<endl;
//         gmotion<<part->gmotion[fr].m11<<' '<<part->gmotion[fr].m12<<' '<<part->gmotion[fr].m13<<std::endl;
//         gmotion<<part->gmotion[fr].m21<<' '<<part->gmotion[fr].m22<<' '<<part->gmotion[fr].m23<<std::endl;
//         gmotion<<part->gmotion[fr].m31<<' '<<part->gmotion[fr].m32<<' '<<part->gmotion[fr].m33<<std::endl;
//         gmotion<<part->gmotion[fr].tx<<' '<<part->gmotion[fr].ty<<' '<<part->gmotion[fr].tz<<std::endl<<std::endl;

        //draw coordinates
//         Vector3 op  (0.0f,0.0f,0.0f);
//         Vector3 o = op* part->gmotion[fr];
//         Vector3 xp  (3.0f,0.0f,0.0f);
//         Vector3 x = xp* part->gmotion[fr];
//         Vector3 yp  (0.0f,25.0f,0.0f);
//         Vector3 y = yp* part->gmotion[fr];
//         Vector3 zp  (0.0f,0.0f,3.0f);
//         Vector3 z = zp* part->gmotion[fr];
//         //x
//         glColor3f(1.0f,0.0f,0.0f);
//         glBegin(GL_LINES);
//         glVertex3f(o.x, o.y, o.z);
//         glVertex3f(x.x,x.y,x.z);
//         glEnd();
//         //y
//         glColor3f(1.0f,0.0f,0.0f);
//         glBegin(GL_LINES);
//         glVertex3f(o.x, o.y, o.z);
//         glVertex3f(y.x,y.y,y.z);
//         glEnd();
//         //z
//         glColor3f(1.0f,0.0f,0.0f);
//         glBegin(GL_LINES);
//         glVertex3f(o.x, o.y, o.z);
//         glVertex3f(z.x,z.y,z.z);
//         glEnd();
        // 绘制人物(一定会执行)
#if true
        //针对每一个关节做二维int数组的二层循环
        int count = 0;
        //int block_count = 0;
        for(auto faceit:part->faces)
        {
            if(i==qugan){
                //count++;
                //printf("count:%d\n",count);
            }
            // faceit的类型是vector<int>
            //GL_POINTS
            //glBegin(GL_POINTS);
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
                //被王龙注释 20190105
                //注释该部分代码会让人体的身体部分出现白色环线
//                v0.x *= part->widthscale;
//                v0.y *= part->lenscale;
//                v0.z *= part->depthscale;
                Vector3 vw(0, 0, 0);
                Vector3 normal(0, 0, 0);//compute vexnSormal each frame
                //Jweight是一个数组，数组元素类型是map<std::string,float>  第一个元素是关节名字
                for (auto it = part->Jweight[vexidint].begin();
                     it != part->Jweight[vexidint].end() && part->name.find("toes") == string::npos; it++) {
                    float wij = it->second;
                    BvhPart *it_part = bvhs.getBvhPart(it->first);
//                     Matrix4x3 Rj = bvhs.bodyName[it->first]->gmotion[fr];
//                     Matrix4x3 R0j = (bvhs.bodyName[it->first]->gm);
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
                double dis = 0;
                double velocity = 0;
                /*if(i<70){
                    dis = (vw.x-prev_pos[avg_count][0])*(vw.x-prev_pos[avg_count][0]) + \
                            (vw.y-prev_pos[avg_count][1])*(vw.y-prev_pos[avg_count][1])+ \
                            (vw.z-prev_pos[avg_count][2])*(vw.z-prev_pos[avg_count][2]);
                    dis = sqrt(dis);
                    velocity = dis - prev_vect[avg_count];
                }*/
                //printf("shuzi:%d  dis:%f\n",avg_count,dis);
                //quantization by lcy
                /*if(i<70){
                    printf("%s:%f\n",bvhs.getBvhPart(visionOrder[i])->name,i/70.0);
                    //glColor3f(dis*100, 0, 1);  //设置颜色ldy here!
                    //glColor3f(i/70.0, i/70.0, 0.5);
                    glColor3f(i/10*0.1+0.3, 0, 0.5);
                }
                else {
                    glColor3f(0, 0, 0);  //设置颜色ldy here!
                }
                if(i<70){
                    //printf("num:%d",min(255,max((disnew*10),0)));
                    //glColor3ub(min(255,disnew*100), 0, 0);
                    //glColor3ub(min(255,disnew*10), 100, 100);
                    int color = quant(velocity,s,z);

                    if(dis > 0)
                        //glColor3ub(max(0,min(255, 127+int(velocity*300))), 100, 100);
                        glColor3ub(max(0,min(255, 127+color)), 100, 100);
                    else
                        glColor3ub(127, 100, 100);
                    //glColor3ub(min(255,color), 100, 100);//quant
                }*/
                if(i<70){
                    //avg_x+=vw.x;
                    //avg_y+=vw.y;
                    //avg_z+=vw.z;
                    prev_pos[avg_count][0]=vw.x;
                    prev_pos[avg_count][1]=vw.y;
                    prev_pos[avg_count][2]=vw.z;
                    prev_vect[avg_count] = dis;
                    avg_count++;
                }
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
                    prev_pos[all_count][0]=vw.x;
                    prev_pos[all_count][1]=vw.y;
                    prev_pos[all_count][2]=vw.z;
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
    if(write_func) {
        printf("write begin!\n",all_count);
        //write_file(all_count, fr);
        write_file_blocks(block_index);
    }
#endif
}


int Display(void) {
    if(times==0){
        printf("hello2\n");
        //write_func = true;
        number = 2;
        player = "sergio_garcia";//dustin_johnson mike_weir sergio_garcia hank_kuehne graeme_mcdowell
        string file = "../../samples/zhiye/taylormade_archive/"+player;
        //string file = "D:\\golf\\3dModel-gcy\\3dModel/samples/tombak/aiping_sun/session_2011-06-10"+player;
        bvhs.mdlParse(file+"/swing_001.mdl");
        cout<<"mdlParse"<<endl;
        bvhs.dofParse(file+"/swing_001.dof");
        cout<<"dofParse"<<endl;
        bvhs.bdfParse(file+"/swing_001.bdf");
        cout<<"bdfParse"<<endl;
        bvhs.varParse(file+"/swing_003.var");
        cout<<"varParse"<<endl;

/*
        bvhs.mdlParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_001.mdl");
        cout<<"mdlParse"<<endl;
        bvhs.dofParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_001.dof");
        cout<<"dofParse"<<endl;
        bvhs.bdfParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_001.bdf");
        cout<<"bdfParse"<<endl;
        bvhs.varParse("D:\\golf\\3dModel-gcy\\3dModel/samples/zhiye/taylormade_archive/dustin_johnson/swing_004.var");
        cout<<"varParse"<<endl;
*/
        cout<<"loadFiles"<<endl;
        InitModel();
        cout<<"InitModel"<<endl;
    }

    times++;  //通过times值的控制，仅在第一次的时候解析数据文件

    cout<<endl;
    return recursivedrawFace_wl(bvhs);   //coordinate and people every Frame
}

void timeFunc(int value) {
    Display();
    fr++;
    if(fr==bvhs.framesNum-1){
        fr=0;
        exit(0);
    }
}

int main(int argc, char** argv) {

    printf("hello\n");
    cout<<Display()<<endl;
    return 0;
}
