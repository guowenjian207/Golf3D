#include <iostream>
#include <iostream>
#include <fstream>
#include <iterator>
#include <string>
#include <sstream>
#include <stack>
#include <ostream>
#include <cmath>
#include <cstdlib>

#include "../3dmath/Matrix4x3.h"
#include "BioUtil.h"
#include "Bvh.h"
#define PI 3.1415
using namespace std;

void Bvh::b(){
    int a;
    int b=1;
    a=b;
    a+=b;
    return;
}

void Bvh::recurSetFamilyGlobalMatrix(BvhPart *some) {


    Vector3 v = recurGetGlobalTrans(some);
    some->tpose_gtrans.push_back(v.x);
    some->tpose_gtrans.push_back(v.y);
    some->tpose_gtrans.push_back(v.z);
    v = recurGetGlobalRot(some);
    some->tpose_grotAngle.push_back(v.x);
    some->tpose_grotAngle.push_back(v.y);
    some->tpose_grotAngle.push_back(v.z);
    some->gmatrix=recurGetGlobalMatrix(some); //gmatrix属性就是一个4x3矩阵，不是每一帧的4x3矩阵数组，含义不明
    some->gm=recurGetGM(some); //gm属性就是一个4x3矩阵，不是每一帧的4x3矩阵数组，含义不明


    for (int i = 0; i < framesNum; i++) {
        Matrix4x3 matrix = recurGetGlobalMatrix(some,i); //获取当前帧的运动矩阵(节点matrix属性)
        if(some->gmotion.size()<framesNum){
            some->gmotion.push_back(matrix);
        }
        else{
            some->gmotion[i]=matrix;
        }
    }

    for (unsigned int i = 0; i < some->child.size(); i++) {
        recurSetFamilyGlobalMatrix(some->child[i]);
    }
}
void Bvh::recurSetFamilyGlobalMatrix(){
    recurSetFamilyGlobalMatrix(bodyRoot);
//  recurSetFamilyGlobalMatrix(clubRoot);
    recurSetFamilyGlobalMatrix(ballRoot);
    return;
}

void Bvh::recurGetGlobalMatrixAfterAdjustTrans(BvhPart* some,float proportion){
    Vector3 v = recurGetGlobalTransAfterAdjustTrans(some,proportion);
    some->tpose_gtrans[0] = v.x;
    some->tpose_gtrans[1] = v.y;
    some->tpose_gtrans[2] = v.z;
    some->gmatrix = recurGetGlobalMatrix(some);
    some->gm=recurGetGM(some);

    for (int i = 0; i < framesNum; i++) {
        Matrix4x3 matrix = recurGetGlobalMatrix(some,i);
        if(some->gmotion.size()<framesNum){
            some->gmotion.push_back(matrix);
        }
        else{
            some->gmotion[i]=matrix;
        }
    }

    for (unsigned int i = 0; i < some->child.size(); i++) {
        recurGetGlobalMatrixAfterAdjustTrans(some->child[i],proportion);
    }
}

Vector3 Bvh::recurGetGlobalTransAfterAdjustTrans(BvhPart *part, float proportion) {
    Vector3 ret;
    Vector3 v(part->tpose_trans[0] * proportion, part->tpose_trans[1] * proportion, part->tpose_trans[2] * proportion);
    //Vector3 vrot(part->tpose_rotAngle[0],part->tpose_rotAngle[1],part->tpose_rotAngle[2]);
    if (part->parent != NULL) {
        ret = recurGetGlobalTransAfterAdjustTrans(part->parent,proportion);
        ret = v + ret;
    } else {
        ret = v;
    }
    return ret;
}

void Bvh::mdlProcess(std::string name, std::string value) {
    name = trim(name); //字符串去除两端空格
    value = trim(value);
    std::string start("h_");

    if (name == "NAME") {

        BvhPart *temp = new BvhPart;
        //memory leak!!!!!!!!

        current = temp;
        current->name = value;
        if(value.find("h_")!=std::string::npos){ //判断value中是否存在h_
            //bodyName.insert(std::pair<std::string,BvhPart*>(value,current));
            bodyName[value]=current; //把当前节点按名称value添加到bodyname这个map
            if(value=="h_waist"){
                //cout<<"current:"<<current<<endl;
            }
            //std::cout<<value<<bodyName[value]<<"insert success"<<std::endl;
        }
    }

    if (name == "ID") {
        int id = ::atof(value.c_str()); //ascII to float
        current->id = id;
    }

    if(name == "TRANSLATION"){
        vector<string> v=splitString(value); //按空格分隔从string得到string的vector
        current->tpose_trans.push_back(stof(v[0])); //将字符串向量中一个元素转成float只有添加到tpose_trans尾部
        current->tpose_trans.push_back(stof(v[1]));
        current->tpose_trans.push_back(stof(v[2]));
        //cout<<current->name<<" TRANSLATION "<<current->tpose_trans[0]<<" "<<current->tpose_trans[1]<<" "<<current->tpose_trans[2]<<endl;
        Vector3 vex(current->tpose_trans[0],current->tpose_trans[1],current->tpose_trans[2]);
        current->matrix.setupTranslation(vex); //4x3矩阵的第四行幅值
    }
    if(name == "ROTATION"){
        vector<string> v=splitString(value);
        current->tpose_rotAngle.push_back(stof(v[0])); //将字符串向量中一个元素转成float只有添加到tpose_rotAngle尾部
        current->tpose_rotAngle.push_back(stof(v[1]));
        current->tpose_rotAngle.push_back(stof(v[2]));
        current->tpose_rotOrder.push_back(v[3]);
        current->tpose_rotOrder.push_back(v[4]);
        current->tpose_rotOrder.push_back(v[5]);
        //cout<<current->name<<" ROTATION "<<current->tpose_rotAngle[0]<<" "<<current->tpose_rotAngle[1]<<" "<<current->tpose_rotAngle[2]
        //<<" "<<current->tpose_rotOrder[0]<<" "<<current->tpose_rotOrder[1]<<" "<<current->tpose_rotOrder[2]<<endl;
        Matrix4x3 I,Rx,Ry,Rz;
        I.identity();
//    Rx.setupRotate(1,current->tpose_rotAngle[0]); //输入欧拉角对应转轴和角度，得出其旋转矩阵
//    Ry.setupRotate(2,current->tpose_rotAngle[1]);
//    Rz.setupRotate(3,current->tpose_rotAngle[2]);
        Rx.setupRotateRightHand(1,current->tpose_rotAngle[0]); //输入欧拉角对应转轴和角度，得出其旋转矩阵
        Ry.setupRotateRightHand(2,current->tpose_rotAngle[1]);
        Rz.setupRotateRightHand(3,current->tpose_rotAngle[2]);
        Matrix4x3 R=Rz*Ry*Rx*current->matrix; //平移加旋转的4x3矩阵累乘得到一个总的旋转矩阵
        current->matrix=R; //matrix的含义就应该是某个局部坐标系到Tpose所需要的总的一个旋转矩阵

    }


    if (name == "PARENT_NAME") {
        if (isStartWith(current->name, start)) {
            // 所有 name 以 h_ 开头的节点 即所有的身体节点
            if (value == "GLOBAL") {
                bodyRoot = current;
                bodyRoot->parent = NULL;
            } else {
                current->parent = getBvhPart(bodyRoot, value); //给自己的parent属性赋值成自己的父亲节点
                current->parent->child.push_back(current); //给自己parent的child属性赋值中添加自己进去（一个父亲可能多个孩子）
            }
        } else if (current->name == "ball") {
            // 球只有一个节点
            if (value == "GLOBAL") {
                ballRoot = current;
                ballRoot->parent = NULL;
            }
        } else {
            // 除此之外的所有节点都是杆的节点
            if (value == "GLOBAL" && current->name == "club") {
                clubRoot = current;
//        clubRoot->parent = NULL;
                // To fix the club and hand position bug, change the parent of "club" from "global" to "h_left_hand"
                clubRoot->parent = getBvhPart(bodyRoot, "h_left_mcarpal_3");
                current->parent->child.push_back(current);
            } else {
//        current->parent = getBvhPart(clubRoot, value);
                current->parent = getBvhPart(value);
                if(current->parent != NULL) {
                    current->parent->child.push_back(current);
                }
            }
        }
    }
}

/**
 * mri 系统的 mdl 文件每人每天产生一个，当日不同的挥杆共用。
 * 主要记录各个节点的父子关系及初始姿态
 */
void Bvh::mdlParse(std::string mdlFile) {

    std::string line;
    // 控制只处理 BODY 段内的数据，即大扩号内的7行
    int step = 0;
    std::ifstream infile(mdlFile.c_str());
    if (infile.is_open()) {
        while (infile.good()) { //表示文件正常，没有读写错误，也不是坏的，也没有结束
            std::getline(infile,line);
            // 每个 BODY 段都重置 step
            if(line == "BODY {")
                step = 0;

            unsigned found = line.find_first_of(":");
            if ((signed int)found != -1
                && step < 8) {
                mdlProcess(line.substr(0,found),
                           line.substr(found+1));
            }
            step ++;
        }
        infile.close();
    }
    else
        std::cout << "File first" << mdlFile << " not found.\n";

    infile.open(mdlFile);
    if (infile.is_open()){
        int rows=0;
        while(infile.good()){
            infile>>line;
            if(line=="VERTICES"){
                infile>>line;//"{" //每次执行infile>>line都会向下移动一行（以空格为标识）
                //cout<<line<<endl;
                infile>>line;//"NAME:"
                std::string name;
                infile>>line; //这里移动了3个空格到了关节名称
                name=line;
                std::size_t pos=name.find("_vertices");
                name=name.substr(0,pos);
                infile>>line;
                while(line!="}"){ //从coordinate后的{开始一直到}结束中间都是顶点三维坐标
                    BvhPart *part = getBvhPart(name);
//            if(bodyName.find(name)!=bodyName.end()){ //当前元素不是bodyname这个map中最后一个元素
                    if(part) {
                        if(line=="COORDINATES"){
                            infile>>line;
                            infile>>line;
                            while(line!="}"){
                                Vector3 v;
                                v.x=(std::stof(line));
                                infile>>line;
                                v.y=(std::stof(line));
                                infile>>line;
                                v.z=(std::stof(line));
                                if(v.y>(part->maxy)) //更新关节相关顶点的坐标在三个维度上的最大最小值
                                {
//                    bodyName[name]->maxy=v.y;
//                    bodyName[name]->maxyi=bodyName[name]->vertices.size(); //更新顶点个数吗？
                                    part->maxy=v.y;
                                    part->maxyi=part->vertices.size();
                                }
                                if(v.y<(part->miny))
                                {
                                    part->miny=v.y;
                                    part->minyi=part->vertices.size();
                                }
                                part->skinlen=(part->maxy)-(part->miny); //关节长度？
                                part->vertices.push_back(v); //添加到顶点数组里
                                infile>>line;
                                std::map<std::string,float> m;
                                part->Jweight.push_back(m); //push进了一个空的map？
                            }
                        }
                        if(line=="EFFECTS"){ //读完coordinate之后接着就是effects
                            infile>>line;
                            infile>>line;
                            while(line!="}"){
                                if(line=="FLEX"){
                                    infile>>line;
                                    infile>>line;
                                    while(line!="}"){
                                        if(line=="BODY:"){      // position of "live" in str
                                            std::string flexname;
                                            infile>>flexname; //把关节名字赋值给新变量flexname
                                            part->flexname.push_back(flexname); //节点flexname属性添加值
                                            infile>>line;
                                            if(line=="WEIGHTS"){
                                                infile>>line;//"{"
                                                infile>>line;
                                                while(line!="}"){
                                                    float weight=std::stof(line);
                                                    infile>>line;
                                                    int vexid=std::stoi(line);
                                                    part->Jweight[vexid-1].insert(std::pair<std::string,float>(flexname,weight));
                                                    infile>>line;
                                                }
                                            }
                                        }
                                        infile>>line;
                                    }
                                }
                                infile>>line;
                            }
                        }
                    }
                    infile>>line;
                }
            }
            if (line=="GEOMETRY"){
                b();
                //cout<<"GEOMETRY"<<endl;
                infile>>line;//"{"
                infile>>line;//"BODY:"
                infile>>line;
                string name=line;
                BvhPart *part = getBvhPart(name);
//        if(bodyName.find(name)!=bodyName.end()){
                if(part){
                    while(line!="}"){
                        if(line=="TEXTURE_COORDINATES")
                        {
                            infile>>line;//"{"
                            infile>>line;
                            while(line!="}"){
                                vector<float> v;
                                float coord=std::stof(line);
                                v.push_back(coord);
                                infile>>line;
                                coord=std::stof(line);
                                v.push_back(coord);
//                bodyName[name]->texture.push_back(v); //赋值给bvhpart节点的texture属性（二维向量）
                                part->texture.push_back(v);
                                infile>>line;
                            }
                        }
                        if(line=="MATERIAL_GROUP")
                        {
                            infile>>line;//"{"
                            infile>>line;//"MATERIAL:"
                            infile>>line;
                            infile>>line;//"BONES"
                            if (line=="BONES")
                            {
                                infile>>line;//"{"
                                infile>>line;
                                while(line!="}"){ //一行中前三个是bone起点坐标，后三个是终点坐标
                                    Vector3 begin;
                                    begin.x=stof(line);
                                    infile>>line;
                                    begin.y=stof(line);
                                    infile>>line;
                                    begin.z=stof(line);
                                    std::vector<Vector3> bone; //是个Nx3矩阵
                                    bone.push_back(begin);
                                    Vector3 end;
                                    infile>>line;
                                    end.x=stof(line);
                                    infile>>line;
                                    end.y=stof(line);
                                    infile>>line;
                                    end.z=stof(line);
                                    bone.push_back(end);
//                  bodyName[name]->bones.push_back(bone);
                                    part->bones.push_back(bone);
                                    infile>>line;
                                }
                                infile>>line;
                            }
                            //cout<<line<<endl;
                            if(line.find("TEXTURED")!=string::npos){
                                b();
                                //cout<<name<<endl;
                                getline(infile,line);//"{"
                                getline(infile,line);
                                trim(line);
                                while(line!="}"){
                                    std::vector<string> v;
                                    splitWithMultiDelimiters(line," /",v); //按/和空格同时分割
                                    std::vector<int> faceid,textureid;
                                    for(auto i=0;i<v.size();i+=2){
                                        faceid.push_back(std::stoi(v[i])-1);
                                        textureid.push_back(std::stoi(v[i+1])-1);
                                    }
                                    /*if(faceid.empty()){
                                      getline(infile,line);
                                      trim(line);
                                      continue;
                                    }*/
//                  bodyName[name]->faces.push_back(faceid);
//                  bodyName[name]->face_texture.push_back(textureid);
                                    part->faces.push_back(faceid);
                                    part->face_texture.push_back(textureid);

                                    getline(infile,line);
                                    trim(line);
                                }
                            }

                        }
                        infile>>line;
                    }
                }
            }
        }
        infile.close();
    }
    else
        std::cout << "File second" << mdlFile << " not found.\n";
}

/**
 * mri 的 dof 文件每人每天一个，当日所有挥杆共用。
 * 主要记录每一个节点6个自由度的运算顺序，
 * 以及各节点的自由度在 var 数据文件对应的 id
 */
void Bvh::dofParse(std::string dofFile) {
    std::string line;
    int ln = 1;
    std::ifstream infile(dofFile.c_str());
    if (infile.is_open()) {
        while (infile.good()) {
            std::getline(infile,line);
            // 从第 5 行开始处理
            if(ln == 4) {
                keypointNum = atoi(line.c_str());
                bvhPartIdVec.reserve(keypointNum);
            }
            if (ln > 4) {
                // 每 8 行一组，所以按 8 取模
                int m = (ln - 5) % 8;
                line = trim(line);
                // 取到要操作的节点
                if (m==0) {
                    int partId = ::atof(line.c_str());
                    current = getBvhPart(partId);
                    bvhPartIdVec.push_back(partId);
                }
                // 处理 orders
                if (m==1 && current != NULL) {
                    std::vector<std::string> vec = splitString(line);
                    for (unsigned int i =0; i<vec.size(); i++) {
                        int order = ::atof(vec[i].c_str()); //把vector里的每一个string转成float
                        current->orders.push_back(order);   //一个一个添加进当前bvhpart节点的orders属性里
                    }
                    //std::cout << current->name <<"---" << current->orders[0] << "-----" << current->orders[5] << std::endl;
                }

                if (m>1 && m < 8 && current != NULL) {
                    int dataId = ::atof(line.c_str());
                    current->mapids.push_back(dataId); //真实数据索引值
                }
            }
            ln ++;
        }
        infile.close();
    } else
        std::cout << "File " << dofFile << " not found.\n";
}

bool Bvh::writeBdf(std::string bdfFile) {
    ofstream outBdfFile(bdfFile.c_str());
    if(outBdfFile.is_open()) {
        outBdfFile << "Bio Model File\n" << "v1.00\n" << "-1\n" << keypointNum << "\n";
        Matrix4x3 m;
        for (int partId : bvhPartIdVec) {
            current = getBvhPart(partId);
            if(current) {
                outBdfFile << current->name << "\n";
                m = current->matrix;
                outBdfFile << m.m11 << " " << m.m12 << " " << m.m13 << "\n";
                outBdfFile << m.m21 << " " << m.m22 << " " << m.m23 << "\n";
                outBdfFile << m.m31 << " " << m.m32 << " " << m.m33 << "\n";
                outBdfFile << m.tx << " " << m.ty << " " << m.tz << "\n";
            }
        }
        outBdfFile.close();
    }

}

/**
 * mri 系统的 bdf 文件每人每天生成一个，当日所有挥杆共用。
 * 此文件实际记录了初始姿态，矩阵表示物体坐标系，此数据
 * 由 mdl 记录的旋转和位移计算得到的。
 * 备注：由 mdl 的旋转计算能完全匹配，但位移不能匹配。
 * mri 实际的初始姿态是用的此文件的值。
 *
 * bdf 中的格式实际对应与 Matrix4x3 的结构如下：
 *
 *       | m11  m21  m31 |
 *       | m12  m22  m32 |
 *       | m13  m23  m33 |
 *       | tx   ty   tz  |
 */
void Bvh::bdfParse(std::string bdfFile) {
    std::string line;
    int ln = 1;
    int step = 5; // Sign whether the bdf file is generated by self.
    // If generated by self(true), it is not need to handle abnormal part data.
    bool isSelfGenerate;
    std::ifstream infile(bdfFile.c_str());
    if(!infile.is_open()) { // If the bdf file is not exist, generate bdf file.
        writeBdf(bdfFile);
        infile.open(bdfFile.c_str());
    }
    if (infile.is_open()) {
        while (infile.good()) {
            std::getline(infile,line);
            if(ln == 3) {
                int flag = atoi(line.c_str());
                isSelfGenerate = (flag == -1) ? true: false;
            }
            // 从第 5 行开始处理
            if (ln > 4) {
                // 每 5 行一组，所以按 5 取模
                int m = (ln - 5) % step;
                line = trim(line);
                // 取到要操作的节点
                if (m==0) { //通过bvhpart节点名字来找出节点并赋值给current
                    ln = 5;
                    current = getBvhPart(line);
                }
                // 处理 orders
                if (m==1 && current != NULL) {
                    std::vector<std::string> vec = splitString(line); //4x3矩阵的第一行数据（按空格分割成1x3字符串向量）
                    current->m.m11 = ::atof(vec[0].c_str());
                    current->m.m21 = ::atof(vec[1].c_str());
                    current->m.m31 = ::atof(vec[2].c_str());
                }

                if (m==2 && current != NULL) {
                    std::vector<std::string> vec = splitString(line); //4x3矩阵的第二行数据（按空格分割成1x3字符串向量）
                    current->m.m12 = ::atof(vec[0].c_str());
                    current->m.m22 = ::atof(vec[1].c_str());
                    current->m.m32 = ::atof(vec[2].c_str());
                }

                if (m==3 && current != NULL) {
                    std::vector<std::string> vec = splitString(line); //4x3矩阵的第三行数据（按空格分割成1x3字符串向量）
                    current->m.m13 = ::atof(vec[0].c_str());
                    current->m.m23 = ::atof(vec[1].c_str());
                    current->m.m33 = ::atof(vec[2].c_str());
                }

                if (m==4 && current != NULL) {
                    std::vector<std::string> vec = splitString(line); //4x3矩阵的第四行数据（按空格分割成1x3字符串向量）
                    current->m.tx = ::atof(vec[0].c_str());
                    current->m.ty = ::atof(vec[1].c_str());
                    current->m.tz = ::atof(vec[2].c_str());
                    /*current->m.tx = current->m.tx / 10.0f;
                    current->m.ty = current->m.ty / 10.0f;
                    current->m.tz = current->m.tz / 10.0f;*/
                }

                // 由于 bdf 文件在下面两个节点数据有异常
                // 所以需要临时调整步长来处理
                if(!isSelfGenerate) {
                    if (current != NULL
                        && (current->name == "h_left_low_arm"
                            || current->name == "h_right_low_arm"))
                        step = 7;
                    if (current != NULL
                        && current->name != "h_left_low_arm"
                        && current->name != "h_right_low_arm")
                        step = 5;
                }
            }
            ln ++;
        }
        infile.close();
    } else
        std::cout << "File " << bdfFile << " not found.\n";
}

Matrix4x3 Bvh::recurGetGlobalMatrix(BvhPart *part, int frame) {
    Matrix4x3 m;
    if(part->name == "club") {
        m = recurGetGlobalMatrix(part->parent,frame);
        m.zeroRotation();
        m = part->motion[frame] * m;
    }
    else if(part->parent != NULL) {
        m = recurGetGlobalMatrix(part->parent,frame);
        m = part->motion[frame] * m;
        //m=temp*m;
    } else {
        m = part->motion[frame];
        /*m.tx*=1;
        m.ty*=1;
        m.tz*=1;*/
        /*m.identity();
        m.tx=part->motion[frame].tx;
        m.ty=part->motion[frame].ty;
        m.tz=part->motion[frame].tz;*/
    }
    return m;
}

Matrix4x3 Bvh::recurGetGlobalMatrix(BvhPart *part) {
    Matrix4x3 matrix;
    if(part->name == "club") {
        matrix = recurGetGlobalMatrix(part->parent);
        matrix.zeroRotation();
        matrix = part->matrix * matrix;
    }
    else if(part->parent != NULL) {
        matrix = recurGetGlobalMatrix(part->parent);
        matrix = part->matrix * matrix;
    } else {
        matrix = part->matrix;
    }
    return matrix;
}

void Bvh::recurGetMotionMatrix(BvhPart *part){
    Matrix4x3 m;
    //cout<<part->name<<" motion size:"<<part->motion_rot.size()<<endl;
    std::ofstream out("new_motion_det");
    //printMatrix(m);
    for(auto i=0;i<part->motion.size();i++){


        Matrix4x3 tran_mat;
        tran_mat.setupTranslation(part->motion_tran[i]);
        //fprintMatrix(part->motion_rot[i],"motion_rot");
        m=part->motion_rot[i]*part->m*tran_mat;
        Vector3 v(part->motion[i].tx,part->motion[i].ty,part->motion[i].tz);
        //cout<<i<<" "<<vectorMag(v)<<" ";
        part->motion[i]=m;
        //out<<determinant(part->motion[i])<<endl;
        v.x=part->motion[i].tx;v.y=part->motion[i].ty;v.z=part->motion[i].tz;
        //fprintMatrix(part->motion[i],"new_motion");
        //cout<<vectorMag(v)<<endl;
    }
    out.close();
    return;
}

Matrix4x3 Bvh::recurGetGM(BvhPart *part) {
    Matrix4x3 m;
    /*if(part->name=="h_right_low_leg"){
      cout<<"h_right_low_leg "<<part->m;
    }*/
    if(part->parent != NULL) {
        m = recurGetGM(part->parent);
        m = part->m * m;
    } else {
        m = part->m;
    }
    return m;
}

Vector3 Bvh::recurGetGlobalTrans(BvhPart *part)
{
    Vector3 ret;
    Vector3 v(part->tpose_trans[0] * 2,part->tpose_trans[1] * 2,part->tpose_trans[2] * 2);
    //Vector3 vrot(part->tpose_rotAngle[0],part->tpose_rotAngle[1],part->tpose_rotAngle[2]);
    if(part->parent != NULL) {
        ret = recurGetGlobalTrans(part->parent);
        ret = v + ret;
    } else {
        ret = v;
    }
    return ret;
}
Vector3 Bvh::recurGetGlobalRot(BvhPart *part)
{
    Vector3 ret;
    Vector3 v(part->tpose_rotAngle[0],part->tpose_rotAngle[1],part->tpose_rotAngle[2]);
    //Vector3 vrot(part->tpose_rotAngle[0],part->tpose_rotAngle[1],part->tpose_rotAngle[2]);
    if(part->parent != NULL) {
        ret = recurGetGlobalRot(part->parent);
        ret = v + ret;
    } else {
        ret = v;
    }
    return ret;
}

void Bvh:: varProcess(std::vector<float> datas, BvhPart *part) {
    Matrix4x3 matrix,rotm,trans;
    Vector3 v;
    Matrix4x3 rot;
    rot.identity();
    rot.zeroTranslation();
    matrix.identity();
    matrix.zeroTranslation();
    // 节点的 6 各自由度，按顺序运算
    for (unsigned int i = 0; i < part->orders.size(); i++) {
        int order = part->orders[i];
        int dataId = part->mapids[order-1];
        float value = datas[dataId-1];
        //std::cout << order << "----" << dataId << "=====" << value << std::endl;
        if (dataId == 0)
            value = 0.0f;

        if(order == 1 ){
            //matrix.tx = value;
            v.x=value;
        }
        if(order == 2 ){
            //matrix.ty = value;
            v.y=value;
        }
        if(order == 3 ) {
            //matrix.tz = value;
            //matrix = part->m * matrix;
            v.z=value;
        }
        if(order >= 4) {
            part->euler_angle.emplace_back(value);  // get euler angle message
            rotm.setupRotate(order -3, value); //此处使用的LeftHand的计算公式，相当于右手系下的逆矩阵
            rot=rotm*rot;  //连乘的顺序与旋转顺序相反（后旋转量左乘在前面）
            //matrix = rotm * matrix;

        }
        //if(part->name == "h_left_up_arm")
        //      printf("%d, %f \n",order,value);
    }

    // To fix the club and hand position bug, the "club" translation set 0
    if(part->name != "club") {
        if(part->name == "ball"){
            v.y-=1;
        }
        trans.setupTranslation(v);
    }
    else{
        v.x=0.2;
        v.y=-0.5;
        v.z=-0.2;
        trans.setupTranslation(v);
    }
    matrix=rot*part->m*trans; //part->m是由bdf文件得到的当前局部坐标系的初始姿态（Tpose？） 可以猜测每一帧动作都是有Tpose开始计算的
    part->motion_tran.push_back(v);
    part->motion_rot.push_back(rot);
    if(part->name=="h_right_up_leg"){
        //printMatrix(part->m);
    }
    part->motion.push_back(matrix);
    for (unsigned int i = 0; i < part->child.size(); i++) {
        varProcess(datas,part->child[i]);
    }
}


/**
 * mri 的 var 文件每次挥杆产生一个。
 * 记录了每一帧，不同节点在6各自由度的值。
 * 通过和初始姿态运算，就是当前帧的物体坐标
 * 系的值。
 */
void Bvh::varParse(std::string varFile) {
    std::string line;
    int ln = 1;
    std::vector<float> datas;
    std::ifstream infile(varFile.c_str());
    if (infile.is_open()) {
        while (infile.good()) {
            std::getline(infile,line);
            line = trim(line);

            // 取总的帧数
            if (ln == 3)
                framesNum = ::atof(line.c_str());

            // 取总的自由度数
            if (ln == 4)
                freedomNum = ::atof(line.c_str());

            //std::count<< framesNum << "-----" << freedomNum << std::endl;
            // 从第 6 行开始处理
            if (ln > 5) {
                // 每 freedomNum 一组，由于头两行要跳过
                // 所以按 freedomNum + 2 取模
                int m = (ln - 6) % (freedomNum + 2);

                // 取到要操作的节点
                if (m > 1) {
                    std::vector<std::string> vec = splitString(line);
                    float data = ::atof(vec[0].c_str());
                    datas.push_back(data);

                    // 最后一个自由度数据装入后，开始数据处理
                    if (m == freedomNum + 1) {
                        varProcess(datas,bodyRoot);
//            varProcess(datas,clubRoot);
                        varProcess(datas,ballRoot);
                        // 新的一帧数据开始前，清空老帧的数据
                        datas.clear();
                    }
                }
            }
            ln ++;
        }
        // 数据全部载入后，来一次完整遍历，运算得到
        // 每个节点，每一帧的世界坐标系的值
        recurSetFamilyGlobalMatrix();
        /*recurSetFamilyGlobalMatrix(bodyRoot);
        recurSetFamilyGlobalMatrix(clubRoot);
        recurSetFamilyGlobalMatrix(ballRoot);*/
        infile.close();
    } else
        std::cout << "File " << varFile << " not found.\n";
}

void Bvh::computeGlobalVertices()
{
    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();
        for(unsigned int j=0;j<current->child.size();j++){
            BvhStack.push(current->child[j]);
        }
    }
}

void Bvh::printGlobalMatrix()
{
    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    std::ofstream out("out.txt");
    unsigned int max=0;
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();
        out<<current->name<<std::endl;
        for(int i=0;i<framesNum;i++){
            out<<i<<std::endl;
            out<<current->gmotion[i].m11<<' '<<current->gmotion[i].m12<<' '<<current->gmotion[i].m13<<std::endl;
            out<<current->gmotion[i].m21<<' '<<current->gmotion[i].m22<<' '<<current->gmotion[i].m23<<std::endl;
            out<<current->gmotion[i].m31<<' '<<current->gmotion[i].m32<<' '<<current->gmotion[i].m33<<std::endl;
            out<<current->gmotion[i].tx<<' '<<current->gmotion[i].ty<<' '<<current->gmotion[i].tz<<std::endl<<std::endl;
        }
        if(current->child.size()>max)max=current->child.size();
        for(unsigned int i=0;i<current->child.size();i++){
            BvhStack.push(current->child[i]);
        }
    }
    //std::cout<<max<<std::endl;
}



void Bvh::setPartLen(string name,float length,float prop=0)
{
    current=bodyName[name];
    /*for(unsigned int j=0;j<current->child.size();j++)
        current->child[j];
    }*/
    if(prop){
        if(current->child.size()==1){
            float tx=current->child[0]->matrix.tx,ty=current->child[0]->matrix.ty,tz=current->child[0]->matrix.tz;
            Vector3 t(tx,ty,tz);
            float tmag=vectorMag(t);
            //cout<<current->child[0]->name<<" "<<tmag;
            current->child[0]->matrix.tx*=prop;
            current->child[0]->matrix.ty*=prop;
            current->child[0]->matrix.tz*=prop;

            tx=current->child[0]->m.tx,ty=current->child[0]->m.ty,tz=current->child[0]->m.tz;
            Vector3 t0(tx,ty,tz);
            tmag=vectorMag(t0);
            //cout<<" "<<tmag<<" "<<current->skinlen<<endl;
            //cout<<" "<<tx<<" "<<ty<<" "<<tz<<endl;
            current->child[0]->m.tx*=prop;
            current->child[0]->m.ty*=prop;
            current->child[0]->m.tz*=prop;
            tx=current->child[0]->m.tx,ty=current->child[0]->m.ty,tz=current->child[0]->m.tz;
            Vector3 t1(tx,ty,tz);
            tmag=vectorMag(t1);
            //cout<<" "<<tmag<<" "<<tx<<" "<<ty<<" "<<tz<<endl;
            //current->lenscale*=length/tmag;
            //cout<<name<<" skinlen:"<<current->skinlen<<endl;
            current->lenscale*=prop;
            recurGetMotionMatrix(current->child[0]);
        }
    }
    else{
        if(current->child.size()==1){
            float tx=current->child[0]->matrix.tx,ty=current->child[0]->matrix.ty,tz=current->child[0]->matrix.tz;
            Vector3 t(tx,ty,tz);
            float tmag=vectorMag(t);
            //cout<<current->child[0]->name<<" "<<tmag;
            current->child[0]->matrix.tx*=length/tmag;
            current->child[0]->matrix.ty*=length/tmag;
            current->child[0]->matrix.tz*=length/tmag;

            tx=current->child[0]->m.tx,ty=current->child[0]->m.ty,tz=current->child[0]->m.tz;
            Vector3 t0(tx,ty,tz);
            tmag=vectorMag(t0);
            //cout<<" "<<tmag<<" "<<current->skinlen<<endl;
            //cout<<" "<<tx<<" "<<ty<<" "<<tz<<endl;
            current->child[0]->m.tx*=length/tmag;
            current->child[0]->m.ty*=length/tmag;
            current->child[0]->m.tz*=length/tmag;
            tx=current->child[0]->m.tx,ty=current->child[0]->m.ty,tz=current->child[0]->m.tz;
            Vector3 t1(tx,ty,tz);
            tmag=vectorMag(t1);
            //cout<<" "<<tmag<<" "<<tx<<" "<<ty<<" "<<tz<<endl;
            //current->lenscale*=length/tmag;
            //cout<<name<<" skinlen:"<<current->skinlen<<endl;
            current->lenscale*=length/current->skinlen;
            recurGetMotionMatrix(current->child[0]);
        }
        else if(name=="h_head"){
            float l=(current->maxy)-(current->miny);
            current->lenscale*=length/l;
        }
        else if(name=="h_right_wrist"||name=="h_left_wrist"){

        }
    }
}

void Bvh::setPartSize(string name,float width,float depth)
{
    current=bodyName[name];
    cout<<name<<" width:"<<width<<" "<<current->width<<endl;
    current->widthscale*=width/(current->width);
    current->width=width;
    cout<<name<<" depth:"<<depth<<" "<<current->depth<<endl;
    current->depthscale*=depth/(current->depth);
    current->depth=depth;
}

void Bvh::setPartSize(std::string name,float prop)
{
    current=bodyName[name];
    current->widthscale*=prop;
    current->width*=prop;

    current->depthscale*=prop;
    current->depth*=prop;
}

void Bvh::computePartSize()
{
    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    while(!BvhStack.empty()){
        current=BvhStack.top();
        BvhStack.pop();
        float max_x,max_y,max_z,min_x,min_y,min_z;
        max_x=max_z=max_y=FLT_MIN;
        min_x=min_z=min_y=FLT_MAX;
        for(auto vi:current->vertices){ //遍历当前节点的所有vertical
            if(vi.x>max_x)max_x=vi.x; //xyz三个维度的极值
            if(vi.z>max_z)max_z=vi.z;
            if(vi.y>max_y)max_y=vi.y;
            if(vi.x<min_x)min_x=vi.x;
            if(vi.z<min_z)min_z=vi.z;
            if(vi.y<min_y)min_y=vi.y;
        }
        if(!current->vertices.empty()){ //vertical非空则进入if语句
            current->skindepth=max_z-min_z;
            current->skinwidth=max_x-min_x;
            current->skinlen=max_y-min_y;
            current->depth=current->skindepth;
            current->width=current->skinwidth;
            //current->length.push_back(current->skinlen);
        }
        for(unsigned int j=0;j<current->child.size();j++)
            BvhStack.push(current->child[j]);  //把current的所有子节点都进入栈内，计算子节点们物体长宽高
    }
}

void Bvh::normalization(float h)
{
    cout<<height<<endl;
    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    float temp;
    //float height=
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();
        //setPartLen(current->name,h);
        float tx=current->matrix.tx,ty=current->matrix.ty,tz=current->matrix.tz;
        Vector3 t(tx,ty,tz);
        float tmag=vectorMag(t);
        //current->matrix.tx=tx*h/178;
        current->matrix.tx=tx*h/height;
        current->matrix.ty=ty*h/height;
        current->matrix.tz=tz*h/height;
        current->width*=h/height;
        current->depth*=h/height;
        current->height*=h/height;
        current->lenscale*=h/height;
        current->widthscale*=h/height;
        current->depthscale*=h/height;
        current->skinlen*=h/height;
        //current->matrix.tz=tz*h/178;
        //current->matrix.tz=tz*h/178;
        //current->height=h/height;
        for(unsigned int j=0;j<current->child.size();j++)
            BvhStack.push(current->child[j]);
    }
    height=h;
}
void Bvh::setHeight(float h)
{
    cout<<height<<endl;
    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    float temp;
    //float height=
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();
        //setPartLen(current->name,h);
        float tx=current->matrix.tx,ty=current->matrix.ty,tz=current->matrix.tz;
        Vector3 t(tx,ty,tz);
        float tmag=vectorMag(t);
        //current->matrix.tx=tx*h/178;
        current->matrix.tx=tx*h/height;
        current->matrix.ty=ty*h/height;
        current->matrix.tz=tz*h/height;
        current->lenscale*=h/height;
        current->skinlen*=h/height;
        //current->matrix.tz=tz*h/178;
        //current->matrix.tz=tz*h/178;
        //current->height=h/height;
        for(unsigned int j=0;j<current->child.size();j++)
            BvhStack.push(current->child[j]);
    }
    height=h;
}

void Bvh::computeHeight()
{
    current=bodyName["h_waist"]; //当前节点设置髋骨为根节点
    Matrix4x3 mathead=bodyName["h_head"]->gmatrix; //bodyName是bvhpart构成的map
    Matrix4x3 matrfoot=bodyName["h_right_foot"]->gmatrix;
    Matrix4x3 matlfoot=bodyName["h_left_foot"]->gmatrix;
    Vector3 vlfoot(bodyName["h_left_foot"]->vertices[32].x,bodyName["h_left_foot"]->vertices[32].y,bodyName["h_left_foot"]->vertices[32].z);
    Vector3 vrfoot(bodyName["h_right_foot"]->vertices[32].x,bodyName["h_right_foot"]->vertices[32].y,bodyName["h_right_foot"]->vertices[32].z);
    Vector3 vhead(bodyName["h_head"]->vertices[294].x,bodyName["h_head"]->vertices[294].y,bodyName["h_head"]->vertices[294].z);
    vlfoot*=matlfoot; //等价于vlfoot=vlfoot*matlfoot
    vrfoot*=matrfoot;
    vhead*=mathead;
    height=vhead.y-min(vrfoot.y,vlfoot.y);
    cout<<"height:"<<height<<endl;
}


void Bvh::resetOriginPoint()
{
    current=bodyName["h_waist"];
    Matrix4x3 matlfoot=bodyName["h_left_foot"]->gmatrix;
    Matrix4x3 matrfoot=bodyName["h_right_foot"]->gmatrix;
    Vector3 vlfoot(bodyName["h_left_foot"]->vertices[32].x,bodyName["h_left_foot"]->vertices[32].y,bodyName["h_left_foot"]->vertices[32].z);
    Vector3 vrfoot(bodyName["h_right_foot"]->vertices[32].x,bodyName["h_right_foot"]->vertices[32].y,bodyName["h_right_foot"]->vertices[32].z);
    vlfoot*=matlfoot;
    vrfoot*=matrfoot;
    current->matrix.ty-=min(vrfoot.y,vlfoot.y);
    current->m.ty-=min(vrfoot.y,vlfoot.y);

}

void Bvh::computeFaceNormal(BvhPart* part)
{
    vector<Vector3> v(part->faces.size(),Vector3(0,0,0));
    part->facenormals=v;
    vector<int> face_id;
    int vid0, vid1, vid2, vid3;
    Vector3 v0, v1, v2, v3, normal;
    for(int i=0,zpos=0;i<part->faces.size();i++,zpos=0){
        face_id = part->faces[i];
        vid0 = face_id[0];
        vid1 = face_id[1];
        vid2 = face_id[2];
        v0 = part->vertices[vid0];
        v1 = part->vertices[vid1];
        v2 = part->vertices[vid2];

        // face have 3 id or 4 id
        if(face_id.size() == 3) {
            if (v0.z > 0 || v1.z > 0 || v2.z > 0) zpos++;
            normal = crossProduct((v0 - v1), (v0 - v2));
        } else if (face_id.size() == 4) {
            vid3 = face_id[3];
            v3 = part->vertices[vid3];
            if (v0.z > 0 || v1.z > 0 || v2.z > 0 || v3.z > 0) zpos++;
            normal = crossProduct((v0 - v1), (v2 - v3));
        } else {
            cout << "face id length error." << endl;
        }

        normal.normalize();
        if(zpos>0)
            normal.z=-normal.z;
        part->facenormals[i]=normal;
    }

    for(unsigned int j=0;j<part->child.size();j++){
        computeFaceNormal(part->child[j]);
    }

}

void Bvh::computeFaceNormal()
{
    computeFaceNormal(bodyRoot);
//  computeFaceNormal(clubRoot);
    computeFaceNormal(ballRoot);
}

void Bvh::computeVexNormal(BvhPart* part)
{
    vector<Vector3> v(part->vertices.size(),Vector3(0,0,0));
    part->vexnormals=v;
    for(int i=0;i<part->faces.size();i++){
        int vid0=part->faces[i][0],vid1=part->faces[i][1],vid2=part->faces[i][2];
        Vector3 v0=part->vertices[vid0];
        Vector3 v1=part->vertices[vid1];
        Vector3 v2=part->vertices[vid2];
        Vector3 normal=crossProduct((v0-v1),(v0-v2));
        normal.normalize();
        part->vexnormals[vid0]+=normal;
        part->vexnormals[vid1]+=normal;
        part->vexnormals[vid2]+=normal;
    }
    for(auto it:part->vexnormals){
        it.normalize();
    }

    for(unsigned int j=0;j<part->child.size();j++){
        computeVexNormal(part->child[j]);
    }
}

void Bvh::computeVexNormal()
{
    computeVexNormal(bodyRoot);
//  computeVexNormal(clubRoot);
    computeVexNormal(ballRoot);
}


void Bvh::computeSlope()
{
    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    float temp;
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();

        for(int i=0;i<framesNum;i++){
            if(current->name=="h_head"){
                ty[i]=current->gmotion[i].ty;
                //std::cout<<ty[i]<<std::endl;
            }
            if(current->name=="h_torso_7"){
                //std::cout<<current->child[0]->name<<std::endl;
            }
            /*if(i==0){
              if(current->name=="h_right_up_arm"||current->name=="h_right_low_arm"||current->name=="h_right_wrist"||current->name=="h_right_hand"){
                current->gmotion[i]=current->gmotion[50];
              }
              if(current->name=="h_left_up_arm"||current->name=="h_left_low_arm"||current->name=="h_left_wrist"||current->name=="h_left_hand"){
                current->gmotion[i]=current->gmotion[130];
              }
            }*/

            for(unsigned int j=0;j<current->child.size();j++){
                float xx= current->child[j]->gmotion[i].tx - current->gmotion[i].tx;
                float yy= current->child[j]->gmotion[i].ty - current->gmotion[i].ty;
                float zz= current->child[j]->gmotion[i].tz - current->gmotion[i].tz;
                temp=sqrt(xx*xx+yy*yy+zz*zz);
                current->length[j]=temp;
                current->slope[j][i].x=xx/temp;
                current->slope[j][i].y=yy/temp;
                current->slope[j][i].z=zz/temp;
                /*if(current->name=="h_right_up_arm"||current->name=="h_right_low_arm"||current->name=="h_right_wrist"){
                  current->slope[j][i].x=-1;
                  current->slope[j][i].y=0;
                  current->slope[j][i].z=0;
                }*/
                /*if(current->name=="h_left_up_arm"||current->name=="h_left_low_arm"||current->name=="h_left_wrist"){
                  current->slope[j][i].x=1;
                  current->slope[j][i].y=0;
                  current->slope[j][i].z=0;
                }*/
                //std::cout<<current->name<<" "<<current->child[j]->name<<std::endl;
            }
        }
        for(unsigned int j=0;j<current->child.size();j++)
            BvhStack.push(current->child[j]);
    }
}


void Bvh::printSlope()
{
    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    std::ofstream out("slope.txt");
    unsigned int max=0;
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();
        out<<current->name<<" "<<current->child.size()<<" "<<framesNum<<std::endl;
        for(unsigned int j=0;j<current->child.size();j++){
            for(int i=0;i<framesNum;i++){
                out<<current->name<<" "<<current->child[j]->name<<" "<<i<<" "
                   <<current->slope[j][i].x<<' '<<current->slope[j][i].y<<' '<<current->slope[j][i].z<<std::endl;
            }
            BvhStack.push(current->child[j]);

        }
    }
    std::cout<<max<<std::endl;
}

void Bvh::computeTranslation(float height,float weight,float waistgirth,int bmi)
{

    std::stack <BvhPart*> BvhStack;
    BvhStack.push(bodyRoot);
    //std::cout<<bodyRoot->name<<std::endl;
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();
        paramBodySize(height,weight,0,bmi);
        for(int i=0;i<framesNum;i++){
            //std::cout<<(height/178.0-1.0)<<std::endl;

            if(current->name=="h_left_toes"){
                ty[i]=current->gmotion[i].ty;
                /*if(tx[i]==0){
                  tx[i]=current->gmotion[i].tx;
                }
                else{
                  tx[i]=(tx[i]+current->gmotion[i].tx)/2;
                }*/
                //std::cout<<"h_left_toes"<<std::endl;
                //std::cout<<i<<" "<<current->gmotion[i].ty<<std::endl;
            }
            if(current->name=="h_waist"){
                tx[i]=current->gmotion[i].tx;
                tz[i]=current->gmotion[i].tz;
                //std::cout<<"h_left_toes"<<std::endl;
                //std::cout<<i<<" "<<current->gmotion[i].ty<<std::endl;
            }
            /*if(current->name=="h_right_toes"){
              if(tx[i]==0){
                tx[i]=current->gmotion[i].tx;
              }
              //std::cout<<"h_right_toes"<<std::endl;
            }*/
            for(unsigned int j=0;j<current->child.size();j++){
                current->child[j]->gmotion[i].tx=current->gmotion[i].tx+(current->slope[j][i].x)*(current->length[j]);
                current->child[j]->gmotion[i].ty=current->gmotion[i].ty+(current->slope[j][i].y)*(current->length[j]);
                current->child[j]->gmotion[i].tz=current->gmotion[i].tz+(current->slope[j][i].z)*(current->length[j]);
            }
            //current->gmotion[i].ty=current->gmotion[i].ty;
            //current->gmotion[i].ty=current->gmotion[i].ty+(height/178)*ty[i];
        }
        for(unsigned int j=0;j<current->child.size();j++)
            BvhStack.push(current->child[j]);
    }
    BvhStack.push(bodyRoot);
    while(BvhStack.empty()==false){
        current=BvhStack.top();
        BvhStack.pop();
        for(int i=0;i<framesNum;i++){
            current->gmotion[i].ty=current->gmotion[i].ty-ty[0];
            current->gmotion[i].tx=current->gmotion[i].tx-tx[0];
            current->gmotion[i].tz=current->gmotion[i].tz-tz[0];
            //current->gmotion[i].tx=current->gmotion[i].tx-tx[i];
            if(current->name=="h_left_toes"){
                //std::cout<<i<<" "<<current->gmotion[i].ty<<std::endl;
            }
        }

        for(unsigned int j=0;j<current->child.size();j++)
            BvhStack.push(current->child[j]);
    }

}

void Bvh::setCommonBodySize(float height,float weight,float waistgirth)
{
    float tp=1;
    float v;
    float tplen=height;
    float h2=weight*4.564+661.2;
    float girth;
    float headgirth=(420.67+0.378*height*10+1.092*weight)/10;
    float chestgirth=(629.364-0.121*height*10+7.388*weight)/10;
    waistgirth=(1115.950-0.700*height*10+13.439*weight)/10;
    float hipgirth=(510.464+0.006*height*10+5.951*weight)/10;
    float len,width,depth;
    //std::cout<<headgirth<<" ";
    //std::cout<<chestgirth<<" ";
    //std::cout<<waistgirth<<" ";
    //std::cout<<hipgirth<<" ";
    len=cmtoinch((-166.796+0.367*height*10+0.278*weight)/10);
    tplen-=len;
    setPartLen("h_right_up_leg",len);
    setPartLen("h_left_up_leg",len);
    girth=cmtoinch((0.581*hipgirth*10-31.2)/10);
    setPartSize("h_right_up_leg",girth/PI,girth/PI);
    setPartSize("h_left_up_leg",girth/PI,girth/PI);


    len=cmtoinch((-153.322+0.299*height*10+0.354*weight)/10);
    tplen-=len;
    setPartLen("h_right_low_leg",len);
    setPartLen("h_left_low_leg",len);
    //girth=cmtoinch((0.347*hipgirth*10+21.6)/10);
    girth=cmtoinch((0.36*hipgirth*10+21.6)/10);
    setPartSize("h_right_low_leg",girth/PI,girth/PI);
    setPartSize("h_left_low_leg",girth/PI,girth/PI);

    len=cmtoinch((-39.312+0.193*height*10+0.479*weight)/10);
    setPartLen("h_right_up_arm",len);
    setPartLen("h_left_up_arm",len);
    width=depth=cmtoinch(4.65-0.005*height+weight*0.1);
    setPartSize("h_right_up_arm",width,depth);
    setPartSize("h_left_up_arm",width,depth);

    len=cmtoinch((-81.495+0.177*height*10+0.353*weight)/10);
    setPartLen("h_right_low_arm",len);
    setPartLen("h_left_low_arm",len);
    width=depth=cmtoinch(3.95-0.005*height+weight*0.1);
    setPartSize("h_right_low_arm",width,depth);
    setPartSize("h_left_low_arm",width,depth);

    len=cmtoinch((6.155+0.093*height*10+0.326*weight)/10);
    //setPartLen("h_right_wrist",len);
    //setPartLen("h_left_wrist",len);

    len=cmtoinch((-16.916+0.190*height*10-0.842*weight)/10);
    tplen-=len;
    depth=width=cmtoinch(headgirth/(2*PI));
    setPartLen("h_head",len);
    setPartSize("h_head",width,depth);

    tplen-=len;
    float prop=weight/75*(180/height);
    setPartSize("h_waist",prop);
    setPartSize("h_torso_2",prop);
    setPartSize("h_torso_3",prop);
    setPartSize("h_torso_4",prop);
    setPartSize("h_torso_5",prop);
    setPartSize("h_torso_6",prop);
    setPartSize("h_torso_7",prop);


    std::stack <BvhPart*> BvhStack;
    //BvhStack.push("h_torso_2");
    while(!BvhStack.empty()){
        current=BvhStack.top();
        BvhStack.pop();


        //for(unsigned int j=0;j<current->child.size();j++)
        if(current->child.size()==1)
            BvhStack.push(current->child[0]);
    }

}



void Bvh::setDetailBodySize(float height,float weight,float waistgirth,std::map<std::string,float> lengthmap,std::map<std::string,float> girthmap)
{
    float leg_len=bodyName["h_right_up_leg"]->skinlen+bodyName["h_right_low_leg"]->skinlen; //大腿+小腿计算整个腿长度
    float new_leg_len=lengthmap["h_right_up_leg"]+lengthmap["h_right_low_leg"];
    float head_neck_foot_len=bodyName["h_head"]->skinlen+bodyName["h_neck_1"]->skinlen+bodyName["h_neck_2"]->skinlen+bodyName["h_right_foot"]->skinlen;
    float waist_torso_len=bodyName["h_waist"]->skinlen+bodyName["h_torso_7"]->skinlen;
    waist_torso_len=0; //突然置零?
    float torso_len=this->height-leg_len-head_neck_foot_len-waist_torso_len;
    float new_torso_len=this->height-new_leg_len-head_neck_foot_len-waist_torso_len;
    cout<<" height:"<<this->height<<endl;
    cout<<"torso_len:"<<torso_len<<endl;
    cout<<"new_torso_len:"<<new_torso_len<<endl;
    float prop=new_torso_len/torso_len;
    cout<<"prop:"<<prop<<endl;
    //float len=0,new_len=0;
    for(auto si:lengthmap){
        setPartLen(si.first,si.second);
        cout<<"input:"<<si.first<<" "<<si.second<<endl;
        //len+=bodyName[si->first]->skinlen;
        //new_len+=si->second;
    }
    //prop=(height-new_len)/(height-len);

    float tp=1;
    float v;
    float tplen=height;
    float h2=weight*4.564+661.2;
    float girth;
    float headgirth=(420.67+0.378*height*10+1.092*weight)/10;
    float chestgirth=(629.364-0.121*height*10+7.388*weight)/10;
    waistgirth=(1115.950-0.700*height*10+13.439*weight)/10;
    float hipgirth=(510.464+0.006*height*10+5.951*weight)/10;
    float len,width,depth;
    //std::cout<<headgirth<<" ";
    //std::cout<<chestgirth<<" ";
    //std::cout<<waistgirth<<" ";
    //std::cout<<hipgirth<<" ";
    len=cmtoinch((-166.796+0.367*height*10+0.278*weight)/10);
    cout<<"compute:h_right_up_leg "<<len<<endl;
    tplen-=len;
    girth=cmtoinch((0.581*hipgirth*10-31.2)/10);
    setPartSize("h_right_up_leg",girth/PI,girth/PI);
    setPartSize("h_left_up_leg",girth/PI,girth/PI);


    len=cmtoinch((-153.322+0.299*height*10+0.354*weight)/10);
    cout<<"compute:h_right_low_leg "<<len<<endl;
    tplen-=len;
    girth=cmtoinch((0.347*hipgirth*10+21.6)/10);
    setPartSize("h_right_low_leg",girth/PI,girth/PI);
    setPartSize("h_left_low_leg",girth/PI,girth/PI);

    len=cmtoinch((-39.312+0.193*height*10+0.479*weight)/10);
    width=depth=cmtoinch(4.65-0.005*height+weight*0.1);
    setPartSize("h_right_up_arm",width,depth);
    setPartSize("h_left_up_arm",width,depth);

    len=cmtoinch((-81.495+0.177*height*10+0.353*weight)/10);
    width=depth=cmtoinch(3.95-0.005*height+weight*0.1);
    setPartSize("h_right_low_arm",width,depth);
    setPartSize("h_left_low_arm",width,depth);

    len=cmtoinch((6.155+0.093*height*10+0.326*weight)/10);
    //setPartLen("h_right_wrist",len);
    //setPartLen("h_left_wrist",len);

    len=cmtoinch((-16.916+0.190*height*10-0.842*weight)/10);
    tplen-=len;
    depth=width=cmtoinch(headgirth/(2*PI));
    setPartLen("h_head",len);
    setPartSize("h_head",width,depth);

    tplen-=len;
    //setPartLen("h_waist",prop);
    setPartLen("h_torso_2",0,prop);
    setPartLen("h_torso_3",0,prop);
    setPartLen("h_torso_4",0,prop);
    setPartLen("h_torso_5",0,prop);
    setPartLen("h_torso_6",0,prop);
    //setPartLen("h_torso_7",prop);


    std::stack <BvhPart*> BvhStack;
    //BvhStack.push("h_torso_2");
    while(!BvhStack.empty()){
        current=BvhStack.top();
        BvhStack.pop();


        //for(unsigned int j=0;j<current->child.size();j++)
        if(current->child.size()==1)
            BvhStack.push(current->child[0]);
    }

}




void Bvh::paramBodySize(float height,float weight,float waistgirth,std::map<std::string,float> length,std::map<std::string,float> girth)
{
    if(waistgirth==0&&length.empty()&&girth.empty()){ //根据参数是否为空设置bodysize，一般都是去else分支
        setCommonBodySize(height,weight,waistgirth);
    }
    else{
        setDetailBodySize(height,weight,waistgirth,length,girth);
    }
}



void Bvh::paramBodySize(float height,float weight,float waistgirth,int bmi)
//bmi 0:偏瘦,<18.5  1:正常,18.5～23.9  2:超重,≥24
{
    float tp=1;
    float v;
    float tplen;
    float h2=weight*4.564+661.2;
    float girth;
    float headgirth=(210.335+0.189*height*10+0.546*weight)/10;
    float chestgirth=(629.364-0.121*height*10+7.388*weight)/10;
    waistgirth=(1115.950-0.700*height*10+13.439*weight)/10;
    float hipgirth=(510.464+0.006*height*10+5.951*weight)/10;

    //std::cout<<headgirth<<" ";
    //std::cout<<chestgirth<<" ";
    //std::cout<<waistgirth<<" ";
    //std::cout<<hipgirth<<" ";

    switch(bmi){
        case 0:
            tp=0.83;break;
        case 1:
            tp=1;break;
        case 2:
            tp=1.4;
    }
    tp=tp*height/178;
    if(current->name=="h_right_up_leg"||current->name=="h_left_up_leg"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        //current->length[0]=-0.166796+0.00367*height+0.000278*weight;
        current->length[0]=(-166.796+0.367*height*10+0.278*weight)/10;
        //current->length[0]=0.433;

        tplen=current->length[0];
        //std::cout<<current->length[0]<<" ";
        current->length[0]*=0.04;
        current->height=current->length[0];//0.859671 0.857993
        //std::cout<<current->height<<" ";
        v=(4.969+0.446*height*10+113.992*weight);
        //std::cout<<v<<" ";
        girth=(0.581*hipgirth*10-31.2)/10;
        //std::cout<<girth<<" ";
        current->width=0.158*4;
        current->width=2*sqrt(v/(4/3*3.1415926*tplen/2));
        current->width=girth/PI;
        //std::cout<<current->width<<" ";
        current->width*=0.04;
        current->depth=0.158*4;
        current->depth=current->width;
        //std::cout<<current->height<<" ";
        //std::cout<<current->width<<" ";
        //std::cout<<current->depth<<" ";
    }
    else if(current->name=="h_right_low_leg"||current->name=="h_left_low_leg"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->length[0]=(-153.322+0.299*height*10+0.354*weight)/10;
        current->length[0]*=0.04;
        current->height=current->length[0];

        girth=(0.347*hipgirth*10+21.6)/10;
        //std::cout<<girth<<" ";

        current->width=0.106*2*tp;
        current->width=girth/PI;
        current->width*=0.04;
        current->depth=0.106*2*tp;
        current->depth=current->width;
    }
    else if(current->name=="h_right_foot"||current->name=="h_left_foot"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->height=0.10*2*tp;

        current->depth=current->length[0]/2;//0.278385 0.278387
        current->depth=(0.777+0.136*height*10+0.306*weight)/10;
        current->depth*=0.04/2;
        //std::cout<<current->height<<" ";
        current->width=0.074*2*tp;//0.206 0.076 0.105

    }
    else if(current->name=="h_right_shoulder"||current->name=="h_left_shoulder"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        current->width=0.111*2*tp;
        current->depth=0.109*2*tp;
    }
    else if(current->name=="h_right_up_arm"||current->name=="h_left_up_arm"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->length[0]=(-39.312+0.193*height*10+0.479*weight)/10;
        current->length[0]*=0.04;
        current->height=current->length[0];

        current->height=current->length[0]/2;
        current->width=0.093-0.0001*height+weight*0.002;
        current->depth=0.093-0.0001*height+weight*0.002;

    }
    else if(current->name=="h_right_low_arm"||current->name=="h_left_low_arm"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->length[0]=(-81.495+0.177*height*10+0.353*weight)/10;
        current->length[0]*=0.04;

        current->height=current->length[0]/2;
        current->width=0.079-0.0001*height+weight*0.002;
        current->depth=0.079-0.0001*height+weight*0.002;
    }
    else if(current->name=="h_right_wrist"||current->name=="h_left_wrist"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->length[0]=(6.155+0.093*height*10+0.326*weight)/10;
        current->length[0]*=0.015;
        //std::cout<<current->length[0]<<" ";
        current->height=current->length[0];
        current->width=0.048*2*tp+weight*0.001;
        current->depth=0.048*2*tp+weight*0.001;
    }
    else if(current->name=="h_waist"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->length[1]=current->length[1]*height/178;
        current->length[2]=current->length[2]*height/178;
        current->height=current->length[0]/2;

        current->width=0.319*2*tp;
        current->width=(0.263*hipgirth*10+95.5)/10;
        current->width*=0.02;
        current->depth=0.22*2*tp;
        current->depth=hipgirth/PI - current->width;
        current->depth*=0.02;
        tp=current->width/current->depth;
        //std::cout<<tp<<" ";
        /*tp=(629.364-0.121*height*10+7.388*weight)/(2*3.14*250);
        current->width=tp;
        current->depth=tp;*/
    }
    else if(current->name=="h_torso_2"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        girth=waistgirth-(waistgirth - hipgirth)*2/3;
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        //std::cout<<current->height<<" ";
        current->width=0.306*2*tp;
        current->depth=0.196*2*tp;
        //current->width=;
        //current->depth=;
    }
    else if(current->name=="h_torso_3"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        girth=waistgirth-(waistgirth - hipgirth)*1/3;
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        current->width=0.267*2*tp;
        current->depth=0.171*2*tp;
        /*tp=(1115.950+0.700*height*10+13.439*weight)/(2*3.14*500*2);
        current->width=tp;
        current->depth=tp;*/
    }
    else if(current->name=="h_torso_4"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        current->width=0.227*2*tp;
        current->depth=0.145*2*tp;
        current->depth=waistgirth/(2*PI);
        //std::cout<<current->depth<<" ";
        current->depth*=0.02;
    }
    else if(current->name=="h_torso_5"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        girth=waistgirth+(chestgirth - waistgirth)*1/2;
        current->width=0.271*2*tp;
        current->depth=0.173*2*tp;
        /*tp=(629.364-0.121*height*10+7.388*weight)/(2*3.14*250);
        current->width=tp;
        current->depth=tp;*/
    }
    else if(current->name=="h_torso_6"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        current->width=0.313*2*tp;
        current->depth=0.2*2*tp;
        current->depth=(0.154*chestgirth*10+2.9)/10;
        current->width=chestgirth/PI - current->depth;
        //std::cout<<chestgirth<<" ";
        //std::cout<<current->depth<<" ";
        current->depth*=0.02;
        current->width*=0.02;
        tp=current->width/current->depth;
        //std::cout<<tp<<" ";
    }
    else if(current->name=="h_torso_7"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;

        current->length[1]=current->length[1]*height/178+weight*0.0015;
        current->length[2]=current->length[2]*height/178+weight*0.0015;
        //current->length[1]=(weight*0.263*chestgirth/(2*PI)*10+95.5)/5;
        //current->length[2]=(weight*0.263*chestgirth/(2*PI)*10+95.5)/5;
        //current->length[1]*=0.02;
        //current->length[2]*=0.02;

        current->height=current->length[0]/2;
        current->width=0.315*2*tp;
        current->depth=0.175*2*tp;

    }
    else if(current->name=="h_neck_1"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        current->width=0.104*2*tp;
        current->depth=0.104*2*tp;
    }
    else if(current->name=="h_neck_2"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->height=current->length[0]/2;
        current->width=0.104*2*tp;
        current->depth=0.104*2*tp;

    }
    else if(current->name=="h_head"){
        //std::cout<<current->length[0]<<" ";
        //std::cout<<current->child.size()<<" ";
        current->length[0]=current->length[0]*height/178;
        current->length[0]=(-16.916+0.190*height*10-0.842*weight)/10;
        current->length[0]*=0.02;
        //std::cout<<current->length[0]<<" ";
        current->height=0.230*2*height/178;
        current->height=current->length[0];
        //current->width=headgirth
        current->width=0.157*2*tp;
        current->width=headgirth/(2*PI);
        current->width*=0.04;
        current->depth=0.184*2*tp;
        current->depth=current->width;
        /*tp=(210.355+0.189*height*10+0.546*weight)/(2*3.14*250);
        //std::cout<<tp<<" ";
        current->width=tp;
        current->depth=tp;*/

    }

}

//qxshen
void adjustTrans(BvhPart * part, float_t proportion){
    cout<<"adjust model:"<<part->name<<endl;
    cout << "调整前：" << part->m.tx << " " << part->m.ty << " " << part->m.tz << endl;
    part->tpose_trans[0] *= proportion;
    part->tpose_trans[1] *= proportion;
    part->tpose_trans[2] *= proportion;
    part->m.ty *= proportion;
    cout << "调整后：" << part->m.tx << " " << part->m.ty << " " << part->m.tz << endl;
    part->lenscale *= proportion;
    if(!part->child.empty()) {
        adjustTrans(part->child[0],proportion);
    }
}
