// #include <GL/glut.h>
// #include <GL/glu.h>
// #include <GL/gl.h>
// #include <string>
// #include <iomanip>
// #include <iostream>
// #include <fstream>
// #include "../biovision/Bvh.h"
// #include <vector>
// #include <stdlib.h>
// #include <cfloat>
// #include <iterator>
// #include <sstream>
// #include <unordered_set>
// #include <map>
// #include "../biovision/BioUtil.h"
// #include "../3dmath/Vector3.h"
// #include "../3dmath/math3d.h"
//
// #define PI 3.1415926535857
//
// //#include <pcl/point_types.h>
//
// using namespace std;
//
// unordered_set<float> weight_set;
//
// /*
// MATERIAL {
//   NAME: skin
//   EMISSION: 0 0 0
//   AMBIENT: 0.647059 0.584314 0.227451
//   DIFFUSE: 0.647059 0.584314 0.227451
//   SPECULAR: 1 1 1
//   SHININESS: 128
//   ALPHA: 1
//   TEXTURE {
//     NAME: /home/golf/data/model/interior_reflect.rgb
//     S_ATTRIBUTES: 3168 9218
//     T_ATTRIBUTES: 3169 9218
//   }
// }
// */
// GLfloat EMISSION []={ 0 ,0, 0,1.0};
// GLfloat AMBIENT []={0.647059, 0.584314, 0.227451,1.0};
// GLfloat DIFFUSE []={0.647059, 0.584314, 0.227451,1.0};
// GLfloat SPECULAR []={ 1 ,1, 1,1.0};
// GLfloat SHININESS []={128};
//
//
// const GLfloat lightPosition[] = {0,3,-3,1.0};
// const GLfloat whiteLight[] = {0.8,0.8,0.8,1.0};
// GLfloat matSpecular [] = {0.3,0.3,0.3,1.0};
// GLfloat matShininess [] = {20.0};
// GLfloat matEmission [] = {0.3,0.3,0.3,1.0};
// GLfloat spin = 0;
// M3DMatrix44f shadowMat;
// float angle=0;
// void initOpenGLOption()
// {
//     glClearColor(0.3,0.3,0.3,1.0);
//     glClearColor(0.0,0.0,0.0,1.0);
//
//     glEnable(GL_DEPTH_TEST);    // Hidden surface removal
//     glFrontFace(GL_CCW);        // Counter clock-wise polygons face out
//     glEnable(GL_CULL_FACE);        // Do not calculate inside of jet
//
//     glClearDepth(2.0);
//     glShadeModel(GL_SMOOTH);
//     glEnable(GL_LIGHTING);
//     glEnable(GL_LIGHT0);
//     glMatrixMode(GL_MODELVIEW);
//     glLoadIdentity();
//     glLightfv(GL_LIGHT0,GL_POSITION,lightPosition);
//     glLightfv(GL_LIGHT0,GL_DIFFUSE,DIFFUSE);
//     glLightfv(GL_LIGHT0,GL_AMBIENT,AMBIENT);
//     glLightfv(GL_LIGHT0,GL_SPECULAR,SPECULAR);
//     glLightfv(GL_LIGHT0,GL_EMISSION,EMISSION);
//     gluLookAt(0,0,-1,0,0,0,0,1.0,0);
// }
//
// void initOpenGLProjOption()
// {
//     glClearColor(0.3,0.3,0.3,1.0);
//     glClearColor(0.0,0.0,0.0,1.0);
//
//     //glEnable(GL_DEPTH_TEST);    // Hidden surface removal
//     glFrontFace(GL_CCW);        // Counter clock-wise polygons face out
//     glDisable(GL_CULL_FACE);        // Do not calculate inside of jet
//
//     //glClearDepth(2.0);
//     glShadeModel(GL_SMOOTH);
//     glEnable(GL_LIGHTING);
//     glEnable(GL_LIGHT0);
//     glMatrixMode(GL_MODELVIEW);
//     glLoadIdentity();
//     glLightfv(GL_LIGHT0,GL_POSITION,lightPosition);
//     glLightfv(GL_LIGHT0,GL_DIFFUSE,DIFFUSE);
//     glLightfv(GL_LIGHT0,GL_AMBIENT,AMBIENT);
//     glLightfv(GL_LIGHT0,GL_SPECULAR,SPECULAR);
//     glLightfv(GL_LIGHT0,GL_EMISSION,EMISSION);
//     gluLookAt(0,0,-1,0,0,0,0,1.0,0);
// }
//
// void SetupRC()
// {
//   // Light values and coordinates
//   GLfloat  ambientLight[] = { 0.3f, 0.3f, 0.3f, 1.0f };
//   GLfloat  diffuseLight[] = { 0.7f, 0.7f, 0.7f, 1.0f };
//
//   glEnable(GL_DEPTH_TEST);    // Hidden surface removal
//   glFrontFace(GL_CW);        // Counter clock-wise polygons face out
//   glEnable(GL_CULL_FACE);        // Do not calculate inside of jet
//
//   // Enable lighting
//   glEnable(GL_LIGHTING);
//
//   // Setup and enable light 0
//   glLightfv(GL_LIGHT0,GL_AMBIENT,ambientLight);
//   glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
//   glEnable(GL_LIGHT0);
//
//   // Enable color tracking
//   glEnable(GL_COLOR_MATERIAL);
//
//   // Set Material properties to follow glColor values
//   glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
//
//   // Light blue background
//   glClearColor(0.0f, 0.0f, 1.0f, 1.0f );
//
//   glEnable(GL_NORMALIZE);
// }
//
// /*
// glColor3f(0.0, 0.0, 0.0);  --> 黑色
// glColor3f(1.0, 0.0, 0.0);  --> 红色
// glColor3f(0.0, 1.0, 0.0);  --> 绿色
// glColor3f(0.0, 0.0, 1.0);  --> 蓝色
// glColor3f(1.0, 1.0, 0.0);  --> 黄色
// glColor3f(1.0, 0.0, 1.0);  --> 品红色
// glColor3f(0.0, 1.0, 1.0);  --> 青色
// glColor3f(1.0, 1.0, 1.0);  --> 白色
// */
// Bvh bvhs;
//
// void inputParam(float &h,float &w, float &wg,map<string,float> &length,map<string,float> &girth)
// {
//   h=180;
//   w=70;
//   wg=1;
//   if(wg){
//     float l60=cmtoinch(60);
//     float l50=cmtoinch(50);
//     float l40=cmtoinch(40);
//     float l35=cmtoinch(35);
//     float l30=cmtoinch(30);
//     length["h_left_up_leg"]=length["h_right_up_leg"]=l40;
//     length["h_left_low_leg"]=length["h_right_low_leg"]=l40;
//     length["h_left_up_arm"]=length["h_right_up_arm"]=l30;
//     length["h_left_low_arm"]=length["h_right_low_arm"]=l30;
//   }
// }
//
//
// int cnt=0;
// void InitModel()
// {
//   /*bvhs.setPartLen("h_left_low_leg",50);
//   bvhs.setPartLen("h_right_low_leg",50);
//   bvhs.recurSetFamilyGlobalMatrix();*/
//
//   float t=cmtoinch(30);
//   float h,w,wg;
//   map<string,float> length,girth;
//   bvhs.computeHeight();
//   //bvhs.setPartLen("h_left_up_leg",t,1);
//   //bvhs.setPartSize("h_left_up_leg",t/9,t/);
//
//   bvhs.computeHeight();
//
//   //bvhs.resetOriginPoint();
//   if(cnt==0&0){
//     bvhs.normalization(178);
//     bvhs.recurSetFamilyGlobalMatrix();
//     //cnt++;
//   }
//   //bvhs.resetOriginPoint();
//   //bvhs.recurSetFamilyGlobalMatrix();
//   bvhs.computeHeight();
//   if(cnt==0){
//     inputParam(h,w,wg,length,girth);
//     cout<<bvhs.bodyName["h_right_up_leg"]->height<<endl;
//     t=cmtoinch(60);
//     cout<<"30/60cm:"<<t<<endl;
//     //bvhs.setPartLen("h_right_up_leg",t,1);
//     //bvhs.setPartLen("h_left_up_leg",t,1);
//     bvhs.computePartSize();
//     bvhs.paramBodySize(h,w,wg,length,girth);
//     bvhs.recurSetFamilyGlobalMatrix();
//     bvhs.resetOriginPoint();
//     /*t=cmtoinch(60);
//     bvhs.setPartLen("h_right_low_leg",t,1);
//     bvhs.setPartLen("h_left_low_leg",t,1);*/
//     //bvhs.recurSetFamilyGlobalMatrix();
//     //bvhs.normalization(180);
//     //bvhs.recurGetMotionMatrix(bvhs.bodyName["h_right_up_leg"]);
//     //bvhs.recurSetFamilyGlobalMatrix();
//     //bvhs.resetOriginPoint();
//     bvhs.recurSetFamilyGlobalMatrix();
//     cnt++;
//   }
//   bvhs.computeHeight();
//   bvhs.computeFaceNormal();
//   bvhs.computeVexNormal();
// }
//
//
//
// /*void printMatrix(Matrix4x3 m) {
//   printf("  %f, %f, %f\n",m.m11, m.m12, m.m13);
//   printf("  %f, %f, %f\n",m.m21, m.m22, m.m23);
//   printf("  %f, %f, %f\n",m.m31, m.m32, m.m33);
//   printf("  %f, %f, %f\n",m.tx, m.ty, m.tz);
//   printf("\n");
// }*/
//
// void printPre3d(Matrix4x3 m) {
//   printf("[%f,%f,%f,%f" ,m.m11, m.m21, m.m31, m.tx);
//   printf(",%f,%f,%f,%f" ,m.m12, m.m22, m.m32, m.ty);
//   printf(",%f,%f,%f,%f]" ,m.m13, m.m23, m.m33, m.tz);
// }
//
// std::vector<std::string> getPre3dOrder() {
//   std::vector<std::string> visionOrder;
//   visionOrder.push_back("h_waist");
//   visionOrder.push_back("h_torso_2");
//   visionOrder.push_back("h_torso_3");
//   visionOrder.push_back("h_torso_4");
//   visionOrder.push_back("h_torso_5");
//   visionOrder.push_back("h_torso_6");
//   visionOrder.push_back("h_torso_7");
//   visionOrder.push_back("h_neck_1");
//   visionOrder.push_back("h_neck_2");
//   visionOrder.push_back("h_head");
//   visionOrder.push_back("h_left_shoulder");
//   visionOrder.push_back("h_left_up_arm");
//   visionOrder.push_back("h_left_low_arm");
//   visionOrder.push_back("h_left_wrist");
//   visionOrder.push_back("h_left_hand");
//   visionOrder.push_back("h_right_shoulder");
//   visionOrder.push_back("h_right_up_arm");
//   visionOrder.push_back("h_right_low_arm");
//   visionOrder.push_back("h_right_wrist");
//   visionOrder.push_back("h_right_hand");
//   visionOrder.push_back("h_left_up_leg");
//   visionOrder.push_back("h_left_low_leg");
//   visionOrder.push_back("h_left_foot");
//   visionOrder.push_back("h_left_toes");
//   visionOrder.push_back("h_right_up_leg");
//   visionOrder.push_back("h_right_low_leg");
//   visionOrder.push_back("h_right_foot");
//   visionOrder.push_back("h_right_toes");
//   /*visionOrder.push_back("club");
//   visionOrder.push_back("shaft_1");
//   visionOrder.push_back("shaft_2");
//   visionOrder.push_back("shaft_3");
//   visionOrder.push_back("shaft_4");
//   visionOrder.push_back("shaft_5");
//   visionOrder.push_back("shaft_6");
//   visionOrder.push_back("shaft_7");
//   visionOrder.push_back("shaft_8");
//   visionOrder.push_back("hosel");
//   visionOrder.push_back("lie");
//   visionOrder.push_back("loft");
//   visionOrder.push_back("clubface");
//   visionOrder.push_back("ball");*/
//   return visionOrder;
// }
//
// void writePre3d(Bvh bvhs, std::string pre3dFile) {
//   std::ofstream pFile (pre3dFile.c_str());
//   if (pFile.is_open()){
//     std::vector<std::string> visionOrder = getPre3dOrder();
//     pFile << "var rotations = new Array(\n";
//     for (int f=0; f< bvhs.framesNum; f++) {
//       pFile << "[";
//
//       for (unsigned int i=0 ; i< visionOrder.size();i++) {
//         BvhPart *part = bvhs.getBvhPart(visionOrder[i]);
//         Matrix4x3 m = part->gmotion[f];
//         pFile <<"["<<m.m11<<","<<m.m21<<","<<m.m31<<","<<m.tx;
//         pFile <<","<<m.m12<<","<<m.m22<<","<<m.m32<<","<<m.ty;
//         pFile <<","<<m.m13<<","<<m.m23<<","<<m.m33<<","<<m.tz<<"]";
//
//         if (i < visionOrder.size()-1)
//           pFile << ",";
//       }
//
//       if (f < bvhs.framesNum -1)
//         pFile << "],\n";
//       else
//         pFile << "]);\n";
//     }
//   } else
//     std::cout << "Unable to open file " << std::endl;
// }
//
//
//
// void drawsphere(float (&gtranslation)[16],std::string name,int mode,float x=0.2,float y=0.2,float z=0.2)
// {//0表示轴点，1表示肢体部件
//   glPushMatrix();
//   glMaterialfv(GL_FRONT,GL_SPECULAR,matSpecular);
//   glMaterialfv(GL_FRONT,GL_SHININESS,matShininess);
//   glMaterialfv(GL_FRONT,GL_EMISSION,matEmission);
//
//
//   glTranslatef(gtranslation[12],gtranslation[13],gtranslation[14]);
//   gtranslation[12]=0;gtranslation[13]=0;gtranslation[14]=0;
//   glMultMatrixf(gtranslation);
//   //glMultMatrixf(translation);
//   //if(name=="h_head") glScalef(1.5,2,1.5);
//
//   /*if(name=="h_neck_2"){
//     glTranslatef(gtranslation[12],gtranslation[13]+0.5,gtranslation[14]);
//   }*/
//
//   if(mode==0){
//     glutSolidSphere(0.1,40,40);
//   }
//   else if(mode==1){
//     if(name=="h_head"){
//       glTranslatef(0,gtranslation[13]+y,0);
//     }
//     else if(name.find("wrist")!=std::string::npos){
//       glTranslatef(0,gtranslation[13]-y,0);
//     }
//
//     /*if(name=="h_head") glScalef(1.6,2.3,1.84);
//     else if (name=="h_neck_1")glScalef(1,0.6,1);
//     else if (name=="h_neck_2")glScalef(1,0.6,1);
//     else if(name=="h_waist")glScalef(2,0.8,1);
//     //else if(name=="h_waist")glScalef(0,0,0);
//     else if (name=="h_torso_2")glScalef(3.4,0.8,2.2);
//     else if(name=="h_torso_3")glScalef(2.9,0.7,1.9);
//     else if(name=="h_torso_4")glScalef(2.5,0.96,1.6);
//     else if(name=="h_torso_5")glScalef(2.64,0.96,1.9);
//     else if(name=="h_torso_6")glScalef(3.39,1.08,2.2);
//     else if(name=="h_torso_7")glScalef(3.4,1,1.84);
//     //else if(name=="h_torso_7")glScalef(0,0,0);
//     else if(name=="h_left_shoulder"||name=="h_right_shoulder")glScalef(1.2,0.6,1.2);
//     else if(name=="h_left_up_arm"||name=="h_right_up_arm")glScalef(1.1,3,1.1);
//     else if(name=="h_left_low_arm"||name=="h_right_low_arm")glScalef(1,2.5,1);
//     else if(name=="h_left_up_hand"||name=="h_right_up_hand")glScalef(0.7,1.35,0.7);
//     else if(name=="h_left_up_leg"||name=="h_right_up_leg")glScalef(1.6,4.6,1.6);
//     else if(name=="h_left_low_leg"||name=="h_right_low_leg")glScalef(1.1,4,1.1);
//     else if(name=="h_left_foot"||name=="h_right_foot")glScalef(0.8,1,2);
//     else if(name=="h_left_toes"||name=="h_right_toes")glScalef(0.0001,0.0001,0.0001);*/
//     if(name.find("up_leg")!=std::string::npos||name.find("low_leg")!=std::string::npos){
//       glScalef(x/0.2,y/0.2,z/0.2);
//       glutSolidSphere(0.1,40,40);
//     }
//     else{
//       glScalef(x/0.2,y/0.2,z/0.2);
//       glutSolidSphere(0.2,40,40);
//     }
//
//   }
//   /*if(name=="h_left_up_leg"){
//     for(int i=0;i<11;i++){
//     glPushMatrix();
//     glMaterialfv(GL_FRONT,GL_SPECULAR,matSpecular);
//     glMaterialfv(GL_FRONT,GL_SHININESS,matShininess);
//     glMaterialfv(GL_FRONT,GL_EMISSION,matEmission);
//     glTranslatef(0,-0.3*i,0);
//     glutSolidSphere(0.2,40,40);
//     glPopMatrix();
//     }
//   }*/
//
//
//   glPopMatrix();
// }
// /*x轴表示宽度，y轴表示高度，z轴表示深度*/
//
// void MultiMatrix(float (&M1)[4],float (&M2)[16],float (&M3)[4]){
//   M3[0]=M1[0]*M2[0]+M1[1]*M2[4]+M1[2]*M2[8]+M1[3]*M2[12];
//   M3[1]=M1[0]*M2[1]+M1[1]*M2[5]+M1[2]*M2[9]+M1[3]*M2[13];
//   M3[2]=M1[0]*M2[2]+M1[1]*M2[6]+M1[2]*M2[10]+M1[3]*M2[14];
//   M3[3]=M1[0]*M2[3]+M1[1]*M2[7]+M1[2]*M2[11]+M1[3]*M2[15];
// }
//
//
//
// int fr=0;
// int mode=1;//0表示绘制骨架，1表示绘制肢体
//
// void recursivedraw(Bvh bvhs){
//
//   std::vector<std::string> visionOrder = getPre3dOrder();
//   for (unsigned int i=0 ; i< visionOrder.size();i++) {
//     BvhPart *part = bvhs.getBvhPart(visionOrder[i]);
//     Matrix4x3 gm = part->gmotion[fr];
//     Matrix4x3 cgm;
//     cgm.identity();
//
//
//
//     float gtranslation[16]={0};
//     float matrix[4]={0,0,0,1};
//
//     /*绘制坐标原点*/
//     glutSolidSphere(0.2,40,40);
//
//     if(part->name=="h_left_up_leg"){
//       for(int i=0;i<part->vertices.size();i++){
//
//         //std::cout<<std::endl;
//       }
//
//     }
//
//     if(part->name=="h_left_up_arm"){
//       gtranslation[12]=gm.tx;gtranslation[13]=gm.ty;gtranslation[14]=gm.tz;gtranslation[15]=1;
//       float trans[4]={0,0,0,0};
//       MultiMatrix(matrix,gtranslation,trans);
//       glPushMatrix();
//       glTranslatef(trans[0],trans[1],trans[2]);
//       //glutSolidSphere(0.2,40,40);
//       glPopMatrix();
//     }
//
//
//     gtranslation[0]=gm.m11;gtranslation[1]=gm.m12;gtranslation[2]=gm.m13;gtranslation[3]=0;
//     gtranslation[4]=gm.m21;gtranslation[5]=gm.m22;gtranslation[6]=gm.m23;gtranslation[7]=0;
//     gtranslation[8]=gm.m31;gtranslation[9]=gm.m32;gtranslation[10]=gm.m33;gtranslation[11]=0;
//     gtranslation[12]=gm.tx;gtranslation[13]=gm.ty;gtranslation[14]=gm.tz;
//     gtranslation[15]=1;
//
//     //gtranslation[15]=1;
//     if(mode==1){
//       //drawsphere(gtranslation,part->name,0);
//       if((part->name.find("h_left")!=std::string::npos||part->name.find("h_right")!=std::string::npos)&&part->child.size()==1&&part->child[0]->name.find("h_")!=std::string::npos){
//         //std::cout<<part->name<<std::endl;
//         cgm=part->child[0]->gmotion[fr];
//         /*gtranslation[0]=(gm.m11+cgm.m11)/2;gtranslation[1]=(gm.m12+cgm.m12)/2;gtranslation[2]=(gm.m13+cgm.m13)/2;gtranslation[3]=0;
//         gtranslation[4]=(gm.m21+cgm.m21)/2;gtranslation[5]=(gm.m22+cgm.m22)/2;gtranslation[6]=(gm.m23+cgm.m23)/2;gtranslation[7]=0;
//         gtranslation[8]=(gm.m31+cgm.m31)/2;gtranslation[9]=(gm.m32+cgm.m32)/2;gtranslation[10]=(gm.m33+cgm.m33)/2;gtranslation[11]=0;*/
//         //gtranslation[12]=(gm.tx+cgm.tx)/2;gtranslation[13]=(gm.ty+cgm.ty)/2;gtranslation[14]=(gm.tz+cgm.tz)/2;
//
//
//       }
//
//       /*if(part->name=="h_left_up_leg"){
//         float x=gm.tx;
//         float y=gm.ty;
//         float z=gm.tz;
//         Vector3 gmtrans(x,y,z);
//         Vector3 cgmtrans(cgm.tx,cgm.ty,cgm.tz);
//         glPushMatrix();
//         glMaterialfv(GL_FRONT,GL_SPECULAR,matSpecular);
//         glMaterialfv(GL_FRONT,GL_SHININESS,matShininess);
//         glMaterialfv(GL_FRONT,GL_EMISSION,matEmission);
//         glTranslatef(cgm.tx,cgm.ty,cgm.tz);
//         //glutSolidSphere(0.2,40,40);
//         glPopMatrix();
//
//         glPushMatrix();
//         glMultMatrixf(gtranslation);
//         glBegin(GL_LINES);
//         glVertex3f(0.0f, 0.0f, 0.0f);
//         float d=distance(gmtrans,cgmtrans);
//         glVertex3f(0.0f,d,0.0f);
//         glEnd();
//         glPopMatrix();
//         for(int i=0;i<11;i++){
//
//           x=x+(cgm.tx-gm.tx)*i/10;
//           y=y+(cgm.ty-gm.ty)*i/10;
//           z=z+(cgm.tz-gm.tz)*i/10;
//           glPushMatrix();
//           glMaterialfv(GL_FRONT,GL_SPECULAR,matSpecular);
//           glMaterialfv(GL_FRONT,GL_SHININESS,matShininess);
//           glMaterialfv(GL_FRONT,GL_EMISSION,matEmission);
//           glTranslatef(x,y,z);
//           //glutSolidSphere(0.2,40,40);
//           glPopMatrix();
//       }*/
//
//
//
//       //(part->name.find("h_torso")!=std::string::npos||
//       if((part->name.find("h_neck")!=std::string::npos)&&part->child.size()==1&&part->child[0]->name.find("h_")!=std::string::npos){
//         //std::cout<<part->name<<std::endl;
//
//         cgm=part->child[0]->gmotion[fr];
//         /*gtranslation[0]=(gm.m11+cgm.m11)/2;gtranslation[1]=(gm.m12+cgm.m12)/2;gtranslation[2]=(gm.m13+cgm.m13)/2;gtranslation[3]=0;
//         gtranslation[4]=(gm.m21+cgm.m21)/2;gtranslation[5]=(gm.m22+cgm.m22)/2;gtranslation[6]=(gm.m23+cgm.m23)/2;gtranslation[7]=0;
//         gtranslation[8]=(gm.m31+cgm.m31)/2;gtranslation[9]=(gm.m32+cgm.m32)/2;gtranslation[10]=(gm.m33+cgm.m33)/2;gtranslation[11]=0;*/
//         //gtranslation[12]=(gm.tx+cgm.tx)/2;gtranslation[13]=(gm.ty+cgm.ty)/2;gtranslation[14]=(gm.tz+cgm.tz)/2;
//
//       }
//
//       // if(part->name.find("h_")!=std::string::npos){
//       //   float trans[4]={0,0,0,0};
//       //   //gtranslation[12]=0;gtranslation[13]=0;gtranslation[14]=0;
//       //   MultiMatrix(matrix,gtranslation,trans);
//       //   glPushMatrix();
//       //   glMaterialfv(GL_FRONT,GL_SPECULAR,matSpecular);
//       //   glMaterialfv(GL_FRONT,GL_SHININESS,matShininess);
//       //   glMaterialfv(GL_FRONT,GL_EMISSION,matEmission);
//       //   glTranslatef(trans[0],trans[1],trans[2]);
//       //   //glMultMatrixf(trans);
//       //   //glutSolidSphere(0.1,40,40);
//       //   glPopMatrix();
//       // }
//
//       if(part->child.size()==1&&part->name.find("h_")!=std::string::npos
//         &&part->name.find("wrist")==std::string::npos
//         &&part->name.find("hand")==std::string::npos&&part->name.find("toes")==std::string::npos
//         &&part->name.find("mcarpal")==std::string::npos&&part->name.find("fing")==std::string::npos&&part->name.find("club")==std::string::npos
//         &&part->name.find("h_torso_7")==std::string::npos){//&&part->name.find("h_waist")==std::string::npos
//       //if((part->name.find("h_left")!=std::string::npos||part->name.find("h_right")!=std::string::npos)&&part->child.size()==1&&part->child[0]->name.find("h_")!=std::string::npos){
//       //std::cout<<part->name<<std::endl;
//       cgm=part->child[0]->gmotion[fr];
//       gtranslation[12]=(gm.tx+cgm.tx)/2;gtranslation[13]=(gm.ty+cgm.ty)/2;gtranslation[14]=(gm.tz+cgm.tz)/2;
//       }
//       /*if(part->name=="h_torso_7")
//         std::cout<<part->child[0]->name<<" "<<part->child[1]->name<<" "<<part->child[2]->name<<std::endl;*/
//       //gtranslation[15]=1;
//     }
//     //
//     if(part->name.find("h_")!=std::string::npos&&part->name.find("hand")==std::string::npos&&part->name.find("mcarpal")==std::string::npos&&part->name.find("fing")==std::string::npos&&part->name.find("club")==std::string::npos){
//       glPushMatrix();
//       //std::cout<<170.0/178.0-1.0<<std::endl;
//       //glTranslatef(0,(170.0/178.0-1.0)*bvhs.ty[180],0);
//
//       drawsphere(gtranslation,part->name,mode,part->width,part->height,part->depth);
//       glPopMatrix();
//     }
//       //if(part->name.find("hand")!=std::string::npos||part->name.find("wrist")!=std::string::npos)
//
//   }
// }
//
//
// void writeAnalysisReport(Bvh bvhs, std::string reportFile) {
//   std::ofstream pFile (reportFile.c_str());
//   if (pFile.is_open()){
//     pFile << "Frame Num = " << bvhs.framesNum << "\n";
//     float startx = 0.0f, distx = 0.0f;
//     float starty = 0.0f, disty = 0.0f;
//     float startz = 0.0f, distz = 0.0f;
//
//     for (int f=0; f< bvhs.framesNum; f++) {
//         BvhPart *part = bvhs.getBvhPart("clubface");
//         Matrix4x3 m = part->gmotion[f];
//         if (f>0) {
//           distx = m.tx - startx;
//           disty = m.ty - starty;
//           distz = m.tz - startz;
//         }
//         startx = m.tx;
//         starty = m.ty;
//         startz = m.tz;
//
//         pFile << std::left << std::setw(14) << f+1
//               << std::setw(14) << m.tx * 10
//               << std::setw(14) << m.ty * 10
//               << std::setw(14) << m.tz * 10
//               << std::setw(14) << distx * 10 * 110 * 3600 / 63360
//               << std::setw(14) << disty * 10 * 110 * 3600 / 63360
//               << std::setw(14) << distz * 10 * 110 * 3600 / 63360
//               << "\n";
//     }
//   }
//   else
//     std::cout << "Unable to open file " << std::endl;
// }
//
//
// //float height=180;
// //float weight=70;
// //float waistgirth;
// //float bmi;
// int times=0;
//
// /*void display()
// {
//   //glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
//   glMatrixMode(GL_PROJECTION);
//   //glLoadIdentity();
//   glOrtho(-10.0,10.0,-10.0,10.0,-10.0,20.0);
//   //glFrustum(-10.0,10.0,-10.0,10.0,1,10.0);
//
//   //Bvh bvhs;
//
//   bvhs.mdlParse("/home/spider/3dModel/deformer/samples/mri_sg/swing_001.mdl");
//   bvhs.dofParse("/home/spider/3dModel/deformer/samples/mri_sg/swing_001.dof");
//   bvhs.bdfParse("/home/spider/3dModel/deformer/samples/mri_sg/swing_001.bdf");
//   bvhs.varParse("/home/spider/3dModel/deformer/samples/mri_sg/swing_003.var");
//   //bvhs.printGlobalMatrix();
//   bvhs.computeSlope();
//   //bvhs.printSlope();
//   bvhs.computeTranslation(height,weight);
//   glMatrixMode(GL_MODELVIEW);
//   recursivedraw(bvhs);
//   glutSwapBuffers();
//   glFlush();
// }
// void reshape(int w,int h)
// {
//     glViewport(0.0,0.0,(GLsizei) w,(GLsizei) h);
// }
// */
// int k=0;
// void timerProc(int id)
// {
//     if(fr<bvhs.framesNum-1&&k==0){
//       fr++;
//     glutPostRedisplay();
//     glutTimerFunc(50,timerProc,1);//需要在函数中再调用一次，才能保证循环
//     }
//     if(fr==bvhs.framesNum-1){
//       fr=0;
//       k++;
//       glutPostRedisplay();
//       glutTimerFunc(5,timerProc,1);//需要在函数中再调用一次，才能保证循环
//     }
// }
//
// /*
// typedef struct BITMAPFILEHEADER
// {
//     u_int16_t bfType;
//     u_int32_t bfSize;
//     u_int16_t bfReserved1;
//     u_int16_t bfReserved2;
//     u_int32_t bfOffBits;
// }BITMAPFILEHEADER;
//
// typedef struct BITMAPINFOHEADER
// {
//     u_int32_t biSize;
//     u_int32_t biWidth;
//     u_int32_t biHeight;
//     u_int16_t biPlanes;
//     u_int16_t biBitCount;
//     u_int32_t biCompression;
//     u_int32_t biSizeImage;
//     u_int32_t biXPelsPerMeter;
//     u_int32_t biYPelsPerMeter;
//     u_int32_t biClrUsed;
//     u_int32_t biClrImportant;
// }BITMAPINFODEADER;
//
// void showBmpHead(BITMAPFILEHEADER &pBmpHead);
// void showBmpInforHead(BITMAPINFODEADER &pBmpInforHead);
// void outputImg(const char * fileName,float ang=angle);
//
// */
// Matrix4x3 rotmat;
//
// void keyboard( unsigned char key, int x, int y )
// {
//   Matrix4x3 RI;
//
//     switch( key  )
//     {
//         case 'w':
//         case 'W':
//             if(fr<bvhs.framesNum)fr++;
//             else fr=0;
//             std::cout<<fr<<" ";
//             break;
//         case 's':
//         case 'S':
//             if(fr>0)fr--;
//             break;
//         case 'u':
//           glMatrixMode(GL_MODELVIEW);
//           glRotatef(45,0.0f,1.0f,0.0f);
//           angle-=45;
//           if(angle==-360)angle=0;
//           std::cout<<angle<<std::endl;
//           break;
//         case 'j':
//           glMatrixMode(GL_MODELVIEW);
//           glRotatef(45,0,-1,0);
//           angle+=45;
//           if(angle==360)angle=0;
//           std::cout<<angle<<std::endl;
// //
// //            glColor3f(1.0,1.0,0);
// //            glutWireTeapot(30);
//
// //            glTranslated(50,0,0);
//           break;
//         case 'h':
//           glMatrixMode(GL_MODELVIEW);
//           glRotatef(angle,0,1,0);
//           angle=0;
//           break;
//
//         case 'i':
//           glMatrixMode(GL_MODELVIEW);
//           //glRotatef(1,1,0,0);
//           RI.setupRotate(1,PI/36);
//           rotmat=RI*rotmat;
//           //rotmat=rotmat*RI;
//           break;
//         case 'k':
//           glMatrixMode(GL_MODELVIEW);
//           //glRotatef(-1,1,0,0);
//           RI.setupRotate(1,-PI/36);
//           rotmat=RI*rotmat;
//           break;
//         case 'o':
//           glMatrixMode(GL_MODELVIEW);
//           //glRotatef(1,0,0,1);
//           RI.setupRotate(2,PI/12);
//           rotmat=RI*rotmat;
//           break;
//         case 'l':
//           glMatrixMode(GL_MODELVIEW);
//           //glRotatef(-1,0,0,1);
//           RI.setupRotate(2,-PI/12);
//           rotmat=RI*rotmat;
//           break;
//         case 'p':
//           glMatrixMode(GL_MODELVIEW);
//           //glScalef(1.1,1.1,1.1);
//           RI.setupRotate(3,PI/36);
//           rotmat=RI*rotmat;
//           break;
//         case ';':
//           glMatrixMode(GL_MODELVIEW);
//           //glScalef(0.9,0.9,0.9);
//           RI.setupRotate(3,-PI/36);
//           rotmat=RI*rotmat;
//           break;
//         case 'm':
//           //k=0;
//           fr++;
//           glutTimerFunc(5,timerProc,1);
//           break;
//         case 'b':
//           mode=1-mode;
//           break;
// /*        case 'z':
//           std::cin>>height;
//           break;
//         case 'x':
//           std::cin>>weight;
//           break;
//         case 'q':
//           glDisable(GL_LIGHTING);
//           glDisable(GL_LIGHT0);
//           break;
//         case 'a':
//           glEnable(GL_LIGHTING);
//           glEnable(GL_LIGHT0);
//           break;
//         case '/':
//           std::string imgName="/home/spider/projection/";
//           imgName.append(std::to_string((int)angle));
//           imgName.append(".bmp");
//           outputImg(imgName.c_str(),angle);
//           break;
// */
//     }
//     glutPostRedisplay();
// }
//
// void inputParam()
// {
//   float height,weight;
//   std::cout<<"height(cm):"<<std::endl;
//   std::cin>>height;
//   std::cout<<"weight(kg):"<<std::endl;
//   std::cin>>weight;
//
// }
//
// void loadobj(std::string filename,vector<vector<float> >& v)
// {
//     FILE *fp;
//     char line[1000]="";
//     int vnum=0;
//     if ((fp = fopen(filename.c_str(), "r")) == NULL)
//         return;
//     glBegin(GL_POINTS);
//     while(!feof(fp))
//     {
//         vector<float> xyz;
//         float x=0;
//         vnum++;
//         for(int i=0;i<3;i++){
//             //cout<<1;
//             fscanf(fp, "%f", &x);
//             //cout<<x<<"\n";
//             xyz.push_back(x);
//         }
//         //cout<<2<<endl;
//         cout<<xyz[0]<<" "<<xyz[1]<<" "<<xyz[2]<<endl;
//         v.push_back(xyz);
//         glVertex3f(xyz[0],xyz[1],xyz[2]);
//
//     }
//     cout<<endl<<endl;
//     glEnd();
//     fclose(fp);
// }
//
// float height=0;
// float highest=FLT_MIN;
// float lowest=FLT_MAX;
// int highestId=0,lowestId=0;
// string highestName,lowestName;
// float higher=FLT_MIN;
// float lower=FLT_MAX;
// int higherId=0,lowerId=0;
// string higherName,lowerName;
// float lowest_left=FLT_MAX;
// int lowest_left_Id=0;
// string lowest_left_Name;
//
// void recursivedrawVexTest(Bvh &bvhs){
//     vector<string> visionOrder = getPre3dOrder();
//     int vexNum = 0;
//     for(string &visionOrderItem:visionOrder){
//         // || visionOrderItem == "h_left_up_leg"
//         BvhPart *part;
//         part = bvhs.getBvhPart(visionOrderItem);
//         vector<Vector3> v = part->vertices;
//         Matrix4x3 gm = part->gmotion[fr];
//         Matrix4x3 m = part->motion[fr];
//         Matrix4x3 m0 = part->matrix;
//
//         //绘制坐标原点
//         glBegin(GL_POINTS);
//         glVertex3f(0.0f,0.0f,0.0f);
//         glEnd();
//
//         glPushMatrix();
//         glBegin(GL_POINTS);
//         for (int vi = 0;vi < visionOrder.size();vi++){
//             Vector3 v0(v[vi].x,v[vi].y,v[vi].z);
//             //cout<<"前"<<v0.x<<v0.y<<v0.z<<endl;
//             //part->gmatrix.tx += 2;
//             v0 *= part->gmatrix;
//             //cout<<"后"<<v0.x<<v0.y<<v0.z<<endl;
//             glVertex3f(v0.x,v0.y,v0.z);
// //            cout<<"旋转矩阵："<<endl;
// //            printMatrix(part->matrix);
// //            cout<<"全局旋转矩阵"<<endl;
// //            printMatrix(part->gmatrix);
//             glEnd();
//             glPopMatrix();
//         }
//     }
// }
//
// void recursivedrawVex(Bvh &bvhs){
// //  int n=30;
// //  float maxy=0;
//   vector<vector<float>> vwaist;
// //  Matrix4x3 gmlupleg = bvhs.bodyName["h_left_up_leg"]->gmotion[fr];
// //  gmlupleg.tx=gmlupleg.ty=gmlupleg.tz=0;
// //  Matrix4x3 gmllowleg = bvhs.bodyName["h_left_low_leg"]->gmotion[fr];
// //  gmllowleg.tx=gmllowleg.ty=gmllowleg.tz=0;
//   //cout <<"aaaa"<<endl;
//   std::vector<std::string> visionOrder = getPre3dOrder();
//   std::ofstream outfile("tposevex.txt",std::ofstream::out);
//
//   int vexnum=0;
//   for (unsigned int i=0 ; i< visionOrder.size();i++) {
//
//       BvhPart *part;
//       //if(bvhs.bodyName.count(visionOrder[i])==0)
//       part = bvhs.getBvhPart(visionOrder[i]);
//       //else
//       //part = bvhs.bodyName[visionOrder[i]];
//       Matrix4x3 gm = part->gmotion[fr];
//       Matrix4x3 m = part->motion[fr];
// //    Matrix4x3 m0=part->matrix;
// //    Vector3 mtrans(m.tx,m.ty,m.tz);
// //    Vector3 m0trans(m0.tx,m0.ty,m0.tz);
//       //cout<<part->name<<" "<<vectorMag(m0trans)<<" "<<vectorMag(mtrans)/vectorMag(m0trans)<<endl;
//       //if(part->name=="h_left_low_leg"||1){
//       //cout<<part->name<<endl;
//       //printMatrix(part->m);
//       //printMatrix(part->motion[0]);
//       //printMatrix(part->matrix);
//       //}
//       Matrix4x3 cgm;
//       Matrix4x3 tpgm=gm;
//       tpgm.tx=tpgm.ty=tpgm.tz=0;
//       cgm.identity();
//       std::vector<Vector3> v=part->vertices;
//       float gtranslation[16]={0};
//       float matrix[4]={0,0,0,1};
//
//       //绘制坐标原点
//
//       glBegin(GL_POINTS);
//       glVertex3f(0.0f,0.0f,0.0f);
//       glEnd();
//
// //    glPushMatrix();
// //    glBegin(GL_POINTS);
//       /*glTranslatef(part->tpose_gtrans[0],part->tpose_gtrans[1],part->tpose_gtrans[2]);
//       glRotatef(part->tpose_grotAngle
//
//
//        [2],0,0,1);
//       glRotatef(part->tpose_grotAngle[1],0,1,0);
//       glRotatef(part->tpose_grotAngle[0],1,0,0);*/
//       //glVertex3f(part->tpose_gtrans[0],part->tpose_gtrans[1],part->tpose_gtrans[2]);
// //    Vector3 J(0,0,0);
//       /*if(part->name=="h_right_low_leg"){
//         Vector3 K(1,1,1);
//         K*=part->gm;
//         glVertex3f(K.x,K.y,K.z);
//         Vector3 X(1,1,1);
//         Matrix4x3 ttt=part->gm;
//         ttt.m21*=2;
//         X*=ttt;
//         glVertex3f(X.x,X.y,X.z);
//       }*/
//
//       //J*=part->gm;
// //    J*=part->gmatrix;
//       //glColor3f(1.0f, 0.0f, 0.0f);
//       //glVertex3f(J.x,J.y,J.z);
//       //cout<<part->name<<" ";
//       //cout<<part->name<<" "<<part->tpose_gtrans[0]<<" "<<part->tpose_gtrans[1]<<" "<<part->tpose_gtrans[2]
//       //  <<" "<<part->tpose_grotAngle[0]<<" "<<part->tpose_grotAngle[1]<<" "<<part->tpose_grotAngle[2]<<endl;
//       //cout<<part->name<<" "<<v.size()<<endl;
// //    glEnd();
// //    glPopMatrix();
//
//       gtranslation[0]=gm.m11;gtranslation[1]=gm.m12;gtranslation[2]=gm.m13;gtranslation[3]=0;
//       gtranslation[4]=gm.m21;gtranslation[5]=gm.m22;gtranslation[6]=gm.m23;gtranslation[7]=0;
//       gtranslation[8]=gm.m31;gtranslation[9]=gm.m32;gtranslation[10]=gm.m33;gtranslation[11]=0;
//       //gtranslation[12]=gm.tx/n;gtranslation[13]=gm.ty/n;gtranslation[14]=gm.tz/n;
//       gtranslation[12]=gm.tx;gtranslation[13]=gm.ty;gtranslation[14]=gm.tz;gtranslation[15]=1;
// //    glPushMatrix();
// //    //glMultMatrixf(gtranslation);
// //    //glTranslatef(gm.tx,gm.ty,gm.tz);
// //    //glTranslatef(m.tx/n,m.ty/n,m.tz/n);
// //    glBegin(GL_POINTS);
// //    //glBegin(GL_LINES);
// //    glColor3f(1.0f, 0.0f, 0.0f);
// //    //if(part->name.find("h_")!=std::string::npos&&part->name.find("hand")==std::string::npos&&part->name.find("mcarpal")==std::string::npos&&part->name.find("fing")==std::string::npos&&part->name.find("club")==std::string::npos){
// //    if(1){
// //    //glVertex3f(gm.tx,gm.ty,gm.tz);
// //    }
// //    glVertex3f(0,0,0);
// //    //glutSolidSphere(0.05,40,40);
// //    glColor3f(1.0f, 1.0f, 1.0f);
// //    glEnd();
// //    glPopMatrix();
//       //cout<<part->name<<endl;
//       /* gtranslation[0]=m.m11;gtranslation[1]=m.m12;gtranslation[2]=m.m13;gtranslation[3]=0;
//        gtranslation[4]=m.m21;gtranslation[5]=m.m22;gtranslation[6]=m.m23;gtranslation[7]=0;
//        gtranslation[8]=m.m31;gtranslation[9]=m.m32;gtranslation[10]=m.m33;gtranslation[11]=0;
//        gtranslation[12]=m.tx;gtranslation[13]=m.ty;gtranslation[14]=m.tz;
//        gtranslation[15]=1;
//    */
//
//       /*cout<<part->name<<endl;
//       for(int i=0;i<part->vexweight.size();i++){
//         cout<<part->vexweight[i].first<<" "<<i<<" "<<part->vexweight[i].second<<endl;
//       }*/
//
//       //if(part->name=="h_waist"||part->name=="h_left_up_leg"||part->name=="h_right_up_leg"){
//       if(1){
//           //std::cout<<part->name<<" "<<gm.tx-part->gmatrix.tx<<" "<<gm.ty-part->gmatrix.ty<<" "<<gm.tz-part->gmatrix.tz<<std::endl;
//           //std::cout<<std::endl;
//       }
//
//       //if(part->name=="h_waist"||part->name=="h_left_up_leg"){
//       //if(part->name.find("h_")!=std::string::npos&&part->name.find("mcarpal")==std::string::npos&&part->name.find("club")==std::string::npos){
//       //if(part->name.find("h_")!=std::string::npos){
//       //if(part->name.find("h_")!=std::string::npos&&part->name!="h_waist"){
//       //if(part->name=="h_waist"){
//       //if(part->name=="h_right_foot"||part->name=="h_right_low_leg"){
//       //if(part->name=="h_right_up_leg"||part->name=="h_right_low_leg"){
//       //if(part->name=="h_left_low_leg"){
//       //if(part->name=="h_right_shoulder"||part->name=="h_left_shoulder"){
//       //if(part->name=="h_torso_7"||part->name=="h_neck_1"||part->name=="h_left_shoulder"){
//       if(1){
//           //cout<<part<<endl;
//           //glPushMatrix();
//           //glMultMatrixf(gtranslation);
//           //glTranslatef(m.tx/n,m.ty/n,m.tz/n);
//
//
//           /*glBegin(GL_POINTS);//必须是加上s，要不然显示不了
//           //glBegin(GL_LINE_STRIP);
//           std::ifstream waist;
//           float vec[3];
//           std::string s;
//           int n=40;
//           waist.open("/home/spider/CLionProjects/loadwaist/waistdata.txt",std::fstream::in);
//
//           if(!waist){
//               std::cout<<"fail to open"<<std::endl;
//           }
//           while (!waist.eof())
//           {
//               waist>>vec[0]>>vec[1]>>vec[2];
//               std::cout<<vec[0]<<" "<<vec[1]<<" "<<vec[2]<<std::endl;
//               //glVertex3f(vec[0]/n,vec[1]/n,vec[2]/n);
//               glVertex3f(vec[0],vec[1],vec[2]);
//           }
//           waist.close();
//           glEnd();*/
//           //cout<<gm.tx<<" "<<gm.ty<<" "<<gm.tz<<endl;
//           //cout<<part->name<<" "<<part->vertices.size()<<endl;
//           //glPushMatrix();
// //        bvhs.recurGetGlobalMatrixAfterAdjustTrans(part,2);
//           float uplegmin=200;
//           float uplegmax=-200;
//           glBegin(GL_POINTS);
//           for(int vi=0;vi < v.size();vi++){
//               vexnum++;
//               float  xx=v[vi].x,yy=v[vi].y,zz=v[vi].z;
//               float wk=1;
//               Vector3 v0(xx,yy,zz);
//               v0.x*=part->widthscale;
//               v0.y*=part->lenscale;
//               v0.z*=part->depthscale;
//               //if(part->name.find("arm")!=string::npos||part->name.find("hand")!=string::npos||part->name.find("wrist")!=string::npos)
//               /*v0.x=xx*part->width;
//               v0.y=yy*part->height;
//               v0.z=zz*part->depth;*/
//               //Matrix4x3 offset;
//               //offset.setupTranslation(Vector3(part->gmatrix.tx,part->gmatrix.ty,part->gmatrix.tz));
//               //v0*=part->gmatrix;
//               //part->gm.ty = part->gm.ty + 1;
//               v0*=part->gm;
//
//               //v0*=offset;
//               Vector3 tpose=v0;
// //        if(part->name=="h_left_up_leg"){
// //          if(v0.y>uplegmax)
// //            uplegmax=v0.y;
// //          if(v0.y<uplegmin)
// //            uplegmin=v0.y;
// //        }
//               //glVertex3f(v0.x,v0.y,v0.z);
//               Matrix4x3 Rk=gm;
//               Matrix4x3 R0=part->gm;
// //        Matrix4x3 R0i=inverse(R0);
//               Matrix4x3 I;
//               I.identity();
//               /*if(part->name=="h_right_low_leg"&&0)
//               {
//                 R0.identity();
//                 Vector3 m0(m.tx,m.ty,m.tz);
//                 //R0.m11=m.m11;R0.m22=m.m22;R0.m33=m.m33;
//                 //R0.m11=abs(m.m11);R0.m22=abs(m.m22);R0.m33=abs(m.m33);
//                 //R0.tx=m.tx;R0.ty=m.ty;R0.tz=m.tz;
//                 //R0.ty=m.ty;
//                 float sign=m.ty/abs(m.ty);
//                 //R0.tx=0;R0.ty=vectorMag(m0)*sign;R0.tz=0;
//                 //cout<<R0.ty<<endl;
//                 //R0=m;
//                 Rk=part->parent->gmotion[fr]*R0*I;
//                 //cout<<part->name<<" "<<Rk.tx<<" "<<Rk.ty<<" "<<Rk.tz<<endl;
//               }*/
//               //Rk=gm*(inverse(m))*R0*I;
// //        Rk=gm;
//               //cout<<part->name<<" "<<Rk.tx<<" "<<Rk.ty<<" "<<Rk.tz<<endl;
//               //if(part->name=="h_right_low_leg")
//
//
//               //cout<<Rk.tx<<" "<<Rk.ty<<" "<<Rk.tz<<endl;
//               //Matrix4x3 Rtk=Rk*
// //        Vector3 Vk(Rk.tx,Rk.ty,Rk.tz);
//               //Rk.tx=Rk.ty=Rk.tz=0;
//               //Vector3 vw(xx,yy,zz);
//               Vector3 vw(0,0,0);
//               //Rk=Rk*inverse(bvhs.bodyName["h_waist"]->gmotion[fr]);
//               //v0.y*=0.82;
//               R0=part->gmatrix;
//               //!!!!glVertex3f((v0*R0).x,(v0*R0).y,(v0*R0).z);
//               //glVertex3f((v0*part->gm).x,(v0*part->gm).y,(v0*part->gm).z);
//               //glVertex3f((v0*part->gm).z,(v0*part->gm).y,(v0*part->gm).x);
//
//
//               if((v0*R0).y>highest){
//                   higher=highest;
//                   higherId=highestId;
//                   higherName=higherName;
//                   highest=(v0*R0).y;
//                   highestName=part->name;
//                   highestId=vi;
//               }
//               else if((v0*R0).y>higher){
//                   higher=(v0*R0).y;
//                   higherName=part->name;
//                   higherId=vi;
//               }
//               if((v0*R0).y<lowest){
//                   lower=lowest;
//                   lowerName=lowestName;
//                   lowerId=lowestId;
//                   lowest=(v0*R0).y;
//                   lowestName=part->name;
//                   lowestId=vi;
//               }
//               else if((v0*R0).y<lower)
//               {
//                   lower=(v0*R0).y;
//                   lowerName=part->name;
//                   lowerId=vi;
//               }
//               if(part->name=="h_left_foot"){
//                   if((v0*R0).y<lowest_left){
//                       lowest_left=(v0*R0).y;
//                       lowest_left_Name=part->name;
//                       lowest_left_Id=vi;
//                   }
//               }
//               /*if((v0*part->gm).y>highest){
//                 highest=(v0*part->gm).y;
//                 highestName=part->name;
//                 highestId=vi;
//               }
//               if((v0*part->gm).y<lowest){
//                 lowest=(v0*part->gm).y;
//                 lowestName=part->name;
//                 lowestId=vi;
//               }*/
//               //vw*=tpgm*w0;
//               /*xx=vw.x;
//               yy=vw.y;
//               zz=vw.z;*/
//               //cout<<v0.x<<" "<<v0.y<<" "<<v0.z<<endl;
//               //v0=v0*R0*inverse(R0);
//               //cout<<v0.x<<" "<<v0.y<<" "<<v0.z<<endl;
//               //cout<<xx<<" "<<yy<<" "<<zz<<endl;
//               //outfile<<xx<<" "<<yy<<" "<<zz<<endl;
//
//               //cout<<part->vexweight[i].first<<" "<<i<<" "<<part->vexweight[i].second<<endl;
//               Matrix4x3 Rwaist=bvhs.bodyName["h_waist"]->gmotion[fr];
//               for(auto it=part->Jweight[vi].begin();it!=part->Jweight[vi].end();it++){
//
//                   float wij=it->second;
//                   Matrix4x3 Rj=bvhs.bodyName[it->first]->gmotion[fr];
//                   Matrix4x3 R0j=(bvhs.bodyName[it->first]->gm);
//                   Matrix4x3 R0ji=inverse(R0j);
//                   //cout<<Rj<<endl;
//                   Vector3 Tj(Rj.tx,Rj.ty,Rj.tz);
//                   vw+=wij*(v0*R0*R0ji*Rj);
//                   //vw+=wij*(v0*(part->gm)*R0ji*Rj);
//                   //Rj.tx=Rj.ty=Rj.tz=0;
//                   //vw+=wij*(v0*R0*inverse(Rwaist));
//                   //vw+=wij*v0*Rj+wij*Tj;
//                   //vw+=wij*(v0*Rj);
//                   wk-=wij;
//                   if(part->name=="h_left_low_leg"){
//                       //cout<<vi<<" "<<it->first<<" "<<wij<<endl;
//                   }
//               }
//               /*if(part->name=="h_left_low_leg"){
//                 cout<<vi<<":"<<wk<<endl;
//               }*/
//               //Matrix4x3 R0;
//               vw+=wk*(v0*Rk);
//               weight_set.insert(wk);
//               //glColor3f(wk,wk,wk);
//               if(wk==0){
//                   glColor3f(0.5,0.5,0.5);
//               }
//                   /*else if(wk==0.2)
//                     glColor3f(0,1,0);
//                   else if(wk==0.25)
//                     glColor3f(1,1,0);*/
//               else if(wk>0.33&&wk<0.34)
//                   glColor3f(1,0,0);
//
//                   /*else if(wk==0.5)
//                     glColor3f(1,0,0);
//                   else if(wk==0.75)
//                     glColor3f(0,1,1);
//                   else if(wk==0.8)
//                     glColor3f(0,1,1);*/
//                   //if(wk==0.75)
//                   /*if(wk!=0.5&&wk!=1)
//                     glColor3f(1,0,0);*/
//               else
//                   glColor3f(1,1,1);
//               //Matrix4x3 rx;rx.identity();
//               //rx.setupRotate(1,3.1415/12);
//               //tpose*=rx;
//               //if(part->name!="h_left_foot")
//               //tpose*=rotmat;
//               //2.蒙皮权重分析
//               //if(part->name=="h_neck_1")
//               //if(part->name=="h_torso_2")
//               //if(part->name=="h_left_shoulder")
//               //if(part->name=="h_left_up_arm")
//               //if(part->name=="h_right_low_arm")
//               //if(part->name=="h_waist")
//               glVertex3f(tpose.x,tpose.y,tpose.z);
//               /*glVertex3f(vw.x,vw.y,vw.z);
//               //outfile<<tpose.x<<" "<<tpose.y<<" "<<tpose.z<<endl;
//               /*if(part->name=="h_left_low_leg"){
//                 //cout<<part->name<<" "<<part->vertices.size()<<endl;
//                 //glVertex3f(vw.x,vw.y,vw.z);
//                 //Matrix4x3 Rj=bvhs.bodyName["h_left_up_leg"]->gmotion[fr];
//                 //Matrix4x3 R0j=
//               }
//               //glVertex3f(vw.x,vw.y,vw.z);
//               //cout<<vw.x<<" "<<vw.y<<" "<<vw.z<<endl;
//               //vw=wk*v0*Rk;
//               //vw=v0+Vk;
//               /*if(part->vexweight.find(vi+1)!=part->vexweight.end()||part->vexweight[vi+1].first!=""){
//
//                 float wij=part->vexweight[vi+1].second;
//                 string jiname=part->vexweight[vi+1].first;
//                 Matrix4x3 Rj=bvhs.bodyName[jiname]->gmotion[fr];
//                 Vector3 Vj(Rj.tx,Rj.ty,Rj.tz);
//                 Rj.tx=Rj.ty=Rj.tz=0;
//                 //vw=wk*v0*Rj;//+wij*Vj;
//                 //wk-=wij;
//
//                 /*xx+=w*fx;
//                 yy+=w*fy;
//                 zz+=w*fz;
//
//               }
//               //cout<<xx<<" "<<yy<<" "<<zz<<endl;
//               /*xx=xx+w0*gm.tx;
//               yy=yy+w0*gm.ty;
//               zz=zz+w0*gm.tz;
//               /*vw=wk*v0*Rk;
//               vw.x+=gm.tx;
//               vw.y+=gm.ty;
//               vw.z+=gm.tz;
//
//               //vw=vw+wk*v0*Rk+wk*Vk;
//               //vw=vw*Rk;
//               //cout<<xx<<" "<<yy<<" "<<zz<<endl;
//               //glBegin(GL_POINTS);
//               //glVertex3f(0,0,0);
//               //glVertex3f(xx,yy,zz);
//               //glVertex3f(vw.x,vw.y,vw.z);
//               /*if(part->name=="h_left_up_leg")
//               glVertex3f((v0*gmlupleg).x+gm.tx,(v0*gmlupleg).y+gm.ty,(v0*gmlupleg).z+gm.tz);
//               if(part->name=="h_left_low_leg")
//               glVertex3f((v0*gmllowleg).x+gm.tx,(v0*gmllowleg).y+gm.ty,(v0*gmllowleg).z+gm.tz);
//               //glVertex3f((0.5*(v0*gmllowleg+v0*gmlupleg)).x+gm.tx,0.5*(v0*gmllowleg+v0*gmlupleg).y+gm.ty,0.5*(v0*gmllowleg+v0*gmlupleg).z+gm.tz);
//               //glEnd();
//
//
//               //glVertex3f(part->vertices[i][0],part->vertices[i][1],part->vertices[i][2]);
//               //glVertex3f(part->vertices[i][0]/n,part->vertices[i][1]/n,part->vertices[i][2]/n);
//               //std::cout<<part->vertices[i][0]<<" "<<part->vertices[i][1]<<" "<<part->vertices[i][2]<<std::endl;*/
//
//           }
//           glEnd();
//           /*if(part->name=="h_left_up_leg")
//             cout<<"upleg:"<<uplegmax-uplegmin<<endl;
//           cout<<gx<<" "<<gy<<" "<<gz<<endl;
//           glVertex3f(0.0f,0.0f,0.0f);
//           glVertex3f(part->vertices[0][0],part->vertices[0][1],part->vertices[0][2]);
//
//           glPopMatrix();*/
//       }
//
//   }
//   //cout<<maxy<<endl;
//   cout<<"vexnum:"<<vexnum<<endl;
//   outfile.close();/*if(part->vexweight.find(vi+1)!=part->vexweight.end()||part->vexweight[vi+1].first!=""){
//
//           float wij=part->vexweight[vi+1].second;
//           string jiname=part->vexweight[vi+1].first;
//           Matrix4x3 Rj=bvhs.bodyName[jiname]->gmotion[fr];
//           Vector3 Vj(Rj.tx,Rj.ty,Rj.tz);
//           Rj.tx=Rj.ty=Rj.tz=0;
//           //vw=wk*v0*Rj;//+wij*Vj;
//           //wk-=wij;
//
//           /*xx+=w*fx;
//           yy+=w*fy;
//           zz+=w*fz;
//
//         }*/
//   cout<<endl<<endl;
// }
//
// void recursivedrawFace(Bvh &bvhs){
//   int n=30;
//   float maxy=0;
//   vector<vector<float>> vwaist;
//   Matrix4x3 gmlupleg = bvhs.bodyName["h_left_up_leg"]->gmotion[fr];
//   gmlupleg.tx=gmlupleg.ty=gmlupleg.tz=0;
//   Matrix4x3 gmllowleg = bvhs.bodyName["h_left_low_leg"]->gmotion[fr];
//   gmllowleg.tx=gmllowleg.ty=gmllowleg.tz=0;
//   //cout <<"aaaa"<<endl;
//   std::vector<std::string> visionOrder = getPre3dOrder();
//   std::ofstream outfile("tposevex.txt",std::ofstream::out);
//   int vexnum=0;
//     cout<<"begin draw face"<<endl;
//   for (unsigned int i=0 ; i< visionOrder.size();i++) {
//     BvhPart *part;
//     //if(bvhs.bodyName.count(visionOrder[i])==0)
//     part = bvhs.getBvhPart(visionOrder[i]);
//     if(part->child.size()>1)
//     {
//       cout<<part->name<<" "<<part->child.size()<<endl;
//     }
//     //else
//       //part = bvhs.bodyName[visionOrder[i]];
//     Matrix4x3 gm = part->gmotion[fr];
//     Matrix4x3 m = part->motion[fr];
//
//     /*if(part->name=="h_left_up_leg"){
//       cout<<"h_left_up_leg:"<<endl;
//       for(auto i=0;i<part->motion.size();i++){
//         Matrix4x3 m = part->motion[fr];
//         Vector3 t(m.tx,m.ty,m.tz);
//         float tmag=vectorMag(t);
//         cout<<i<<" "<<tmag<<endl;
//       }
//     }*/
//
//     Matrix4x3 m0=part->matrix;
//
//     Vector3 mtrans(m.tx,m.ty,m.tz);
//     Vector3 m0trans(m0.tx,m0.ty,m0.tz);
//     //cout<<part->name<<" "<<vectorMag(m0trans)<<" "<<vectorMag(mtrans)/vectorMag(m0trans)<<endl;
//
//     Matrix4x3 cgm;
//     Matrix4x3 tpgm=gm;
//     tpgm.tx=tpgm.ty=tpgm.tz=0;
//     cgm.identity();
//     std::vector<Vector3> v=part->vertices;
//     float gtranslation[16]={0};
//     float matrix[4]={0,0,0,1};
//
//     //绘制坐标原点
//
//     glBegin(GL_POINTS);
//     glVertex3f(0.0f,0.0f,0.0f);
//     glEnd();
//
//     glPushMatrix();
//     //glColor3f(1.0f, 0.0f, 0.0f);
//     glBegin(GL_POINTS);
//     /*glTranslatef(part->tpose_gtrans[0],part->tpose_gtrans[1],part->tpose_gtrans[2]);
//     glRotatef(part->tpose_grotAngle[2],0,0,1);
//     glRotatef(part->tpose_grotAngle[1],0,1,0);
//     glRotatef(part->tpose_grotAngle[0],1,0,0);*/
//     //glVertex3f(part->tpose_gtrans[0],part->tpose_gtrans[1],part->tpose_gtrans[2]);
//     Vector3 J(0,0,0);
//     /*if(part->name=="h_right_low_leg"){
//       Vector3 K(1,1,1);
//       K*=part->gm;
//       glVertex3f(K.x,K.y,K.z);
//       Vector3 X(1,1,1);
//       Matrix4x3 ttt=part->gm;
//       ttt.m21*=2;
//       X*=ttt;
//       glVertex3f(X.x,X.y,X.z);
//     }*/
//
//     //J*=part->gm;
//     J*=part->gmatrix;
//     //glColor3f(1.0f, 0.0f, 0.0f);
//     //glVertex3f(J.x,J.y,J.z);
//
//     //glColor3f(1.0f, 0.0f, 0.0f);
//     //glVertex3f(gm.tx,gm.ty,gm.tz);
//     //cout<<part->name<<" ";
//     //cout<<part->name<<" "<<part->tpose_gtrans[0]<<" "<<part->tpose_gtrans[1]<<" "<<part->tpose_gtrans[2]
//     //  <<" "<<part->tpose_grotAngle[0]<<" "<<part->tpose_grotAngle[1]<<" "<<part->tpose_grotAngle[2]<<endl;
//     //cout<<part->name<<" "<<v.size()<<endl;
//     glEnd();
//     glPopMatrix();
//
//     gtranslation[0]=gm.m11;gtranslation[1]=gm.m12;gtranslation[2]=gm.m13;gtranslation[3]=0;
//     gtranslation[4]=gm.m21;gtranslation[5]=gm.m22;gtranslation[6]=gm.m23;gtranslation[7]=0;
//     gtranslation[8]=gm.m31;gtranslation[9]=gm.m32;gtranslation[10]=gm.m33;gtranslation[11]=0;
//     //gtranslation[12]=gm.tx/n;gtranslation[13]=gm.ty/n;gtranslation[14]=gm.tz/n;
//     gtranslation[12]=gm.tx;gtranslation[13]=gm.ty;gtranslation[14]=gm.tz;
//
//     gtranslation[15]=1;
//     glPushMatrix();
//     //glMultMatrixf(gtranslation);
//     //glTranslatef(gm.tx,gm.ty,gm.tz);
//     //glTranslatef(m.tx/n,m.ty/n,m.tz/n);
//     glBegin(GL_POINTS);
//     //glBegin(GL_LINES);
//     glColor3f(1.0f, 0.0f, 0.0f);
//     //if(part->name.find("h_")!=std::string::npos&&part->name.find("hand")==std::string::npos&&part->name.find("mcarpal")==std::string::npos&&part->name.find("fing")==std::string::npos&&part->name.find("club")==std::string::npos){
//     if(1){
//     //glVertex3f(gm.tx,gm.ty,gm.tz);
//     }
//     glVertex3f(0,0,0);
//     //glutSolidSphere(0.05,40,40);
//     glColor3f(1.0f, 1.0f, 1.0f);
//     glEnd();
//     glPopMatrix();
//     //cout<<part->name<<endl;
//    /* gtranslation[0]=m.m11;gtranslation[1]=m.m12;gtranslation[2]=m.m13;gtranslation[3]=0;
//     gtranslation[4]=m.m21;gtranslation[5]=m.m22;gtranslation[6]=m.m23;gtranslation[7]=0;
//     gtranslation[8]=m.m31;gtranslation[9]=m.m32;gtranslation[10]=m.m33;gtranslation[11]=0;
//     gtranslation[12]=m.tx;gtranslation[13]=m.ty;gtranslation[14]=m.tz;
//     gtranslation[15]=1;
// */
//
//     /*cout<<part->name<<endl;
//     for(int i=0;i<part->vexweight.size();i++){
//       cout<<part->vexweight[i].first<<" "<<i<<" "<<part->vexweight[i].second<<endl;
//     }*/
//
//     //if(part->name=="h_waist"||part->name=="h_left_up_leg"||part->name=="h_right_up_leg"){
//     if(1){
//       //std::cout<<part->name<<" "<<gm.tx-part->gmatrix.tx<<" "<<gm.ty-part->gmatrix.ty<<" "<<gm.tz-part->gmatrix.tz<<std::endl;
//       //std::cout<<std::endl;
//     }
//
//     //if(part->name=="h_waist"||part->name=="h_left_up_leg"){
//     //if(part->name.find("h_")!=std::string::npos&&part->name.find("mcarpal")==std::string::npos&&part->name.find("club")==std::string::npos){
//     //if(part->name.find("h_")!=std::string::npos){
//     //if(part->name.find("h_")!=std::string::npos&&part->name!="h_waist"){
//     //if(part->name=="h_waist"){
//     //if(part->name=="h_right_foot"||part->name=="h_right_low_leg"){
//     //if(part->name=="h_right_up_leg"||part->name=="h_right_low_leg"){
//     //if(part->name=="h_left_low_leg"){
//     //if(part->name=="h_right_shoulder"||part->name=="h_left_shoulder"){
//     //if(part->name=="h_torso_7"||part->name=="h_neck_1"||part->name=="h_left_shoulder"){
//     if(1){
//       //cout<<part<<endl;
//       //glPushMatrix();
//       //glMultMatrixf(gtranslation);
//       //glTranslatef(m.tx/n,m.ty/n,m.tz/n);
//
//
//       /*glBegin(GL_POINTS);//必须是加上s，要不然显示不了
//       //glBegin(GL_LINE_STRIP);
//       std::ifstream waist;
//       float vec[3];
//       std::string s;
//       int n=40;
//       waist.open("/home/spider/CLionProjects/loadwaist/waistdata.txt",std::fstream::in);
//
//       if(!waist){
//           std::cout<<"fail to open"<<std::endl;
//       }
//       while (!waist.eof())
//       {
//           waist>>vec[0]>>vec[1]>>vec[2];
//           std::cout<<vec[0]<<" "<<vec[1]<<" "<<vec[2]<<std::endl;
//           //glVertex3f(vec[0]/n,vec[1]/n,vec[2]/n);
//           glVertex3f(vec[0],vec[1],vec[2]);
//       }
//       waist.close();
//       glEnd();*/
//
//
//
//
//       //cout<<gm.tx<<" "<<gm.ty<<" "<<gm.tz<<endl;
//       //cout<<part->name<<" "<<part->vertices.size()<<endl;
//       //glPushMatrix();
//
//       if(part->name=="h_head"){
//         //printMatrix(part->gmatrix);
//       }
//
//       float uplegmin=200;
//       float uplegmax=-200;
//       if(part->name=="h_left_up_leg"){
//         //cout<<"h_vertices:"<<v.size()<<endl;
//       }
//
//       int faceid=0;
//       //cout<<part->name<<endl;
//       for(auto faceit:part->faces){
//         //glBegin(GL_POINTS);
//         glBegin(GL_POLYGON);
//         //glBegin(GL_TRIANGLE_FAN);
//         //glBegin(GL_LINE_LOOP);
//         Vector3 normal;
//         int zpos=0;
//         //glNormal3f(part->facenormals[faceid].x,part->facenormals[faceid].y,part->facenormals[faceid].z);
//         for(auto vexid:faceit){
//           vexnum++;
//           int vi=vexid;
//           float  xx=v[vi].x,yy=v[vi].y,zz=v[vi].z;
//           float wk=1;
//           Vector3 v0(xx,yy,zz);
//           /*if(zz>0)zpos--;
//           else if(zz<0) zpos++;*/
//           v0.x*=part->widthscale;
//           v0.y*=part->lenscale;
//           v0.z*=part->depthscale;
//           Matrix4x3 offset;
//           //offset.setupTranslation(Vector3(2*(part->gmatrix.tx),part->gmatrix.ty,part->gmatrix.tz));
//           //v0*=part->gmatrix;
//           //v0*=part->gm;
//
//           //v0*=offset;
//           Vector3 tpose=v0*part->gmatrix;;
//           if(part->name=="h_left_up_leg"){
//             if(v0.y>uplegmax)
//               uplegmax=v0.y;
//             if(v0.y<uplegmin)
//               uplegmin=v0.y;
//           }
//           //glVertex3f(v0.x,v0.y,v0.z);
//           Matrix4x3 Rk=gm;
//           Matrix4x3 R0=part->gm;
//           //Matrix4x3 R0i=inverse(R0);
//           Matrix4x3 I;
//           I.identity();
//           if(part->name=="h_right_low_leg"&&0)
//           {
//             R0.identity();
//             Vector3 m0(m.tx,m.ty,m.tz);
//
//             float sign=m.ty/abs(m.ty);
//
//             Rk=part->parent->gmotion[fr]*R0*I;
//             //cout<<part->name<<" "<<Rk.tx<<" "<<Rk.ty<<" "<<Rk.tz<<endl;
//           }
//           //Rk=gm*(inverse(m))*R0*I;
//           Rk=gm;
//           //cout<<part->name<<" "<<Rk.tx<<" "<<Rk.ty<<" "<<Rk.tz<<endl;
//           //if(part->name=="h_right_low_leg")
//
//
//           //cout<<Rk.tx<<" "<<Rk.ty<<" "<<Rk.tz<<endl;
//           //Matrix4x3 Rtk=Rk*
//           Vector3 Vk(Rk.tx,Rk.ty,Rk.tz);
//           //Rk.tx=Rk.ty=Rk.tz=0;
//           //Vector3 vw(xx,yy,zz);
//           Vector3 vw(0,0,0);
//           //Rk=Rk*inverse(bvhs.bodyName["h_waist"]->gmotion[fr]);
//           //v0.y*=0.82;
//           //R0=part->gmatrix;
//           R0=part->gm;
//           //!!!!glVertex3f((v0*R0).x,(v0*R0).y,(v0*R0).z);
//           Matrix4x3 Rwaist=bvhs.bodyName["h_waist"]->gmotion[fr];
//           Vector3 normal(0,0,0);//compute vexnormal each frame
//           for(auto it=part->Jweight[vi].begin();it!=part->Jweight[vi].end()&&part->name.find("toes")==string::npos;it++){
//             float wij=it->second;
//             Matrix4x3 Rj=bvhs.bodyName[it->first]->gmotion[fr];
//             Matrix4x3 R0j=(bvhs.bodyName[it->first]->gm);
//             Matrix4x3 R0ji=inverse(R0j);
//             //cout<<Rj<<endl;
//             Vector3 Tj(Rj.tx,Rj.ty,Rj.tz);
//             vw+=wij*(v0*R0*R0ji*Rj);
//             //normal+=wij*((part->vexnormals[vi])*R0*R0ji*Rj);
//             //vw+=wij*(v0*(part->gm)*R0ji*Rj);
//             //Rj.tx=Rj.ty=Rj.tz=0;
//             //vw+=wij*(v0*R0*inverse(Rwaist));
//             //vw+=wij*v0*Rj+wij*Tj;
//             //vw+=wij*(v0*Rj);
//             wk -= wij;
//             if(part->name=="h_left_low_leg"){
//               //cout<<vi<<" "<<it->first<<" "<<wij<<endl;
//             }
//           }
//           /*if(part->name=="h_left_low_leg"){
//             cout<<vi<<":"<<wk<<endl;
//           }*/
//           //Matrix4x3 R0;
//           vw+=wk*(v0*Rk);
//           //vw=wk*(v0*Rk);
//           //normal+=wk*((part->vexnormals[vi])*Rk);
//           //vw=(v0*Rk);
//           weight_set.insert(wk);
//           glColor3f(1,1,1);
//           tpose*=rotmat;
//           vw*=rotmat;
//           /*if(zpos<0)
//             glNormal3f(part->vexnormals[vi].x,part->vexnormals[vi].y,part->vexnormals[vi].z);
//           else*/
//           normal=part->vexnormals[vi];
//           normal*=rotmat;
//           normal.normalize();
//           //draw model;if draw proj commment out
//           glNormal3f(normal.x,normal.y,normal.z);
//           //glNormal3f(normal.x,normal.y,normal.z);
//           //if(part->name=="h_left_up_arm"||part->name=="h_left_shoulder")
//           //glVertex3f(tpose.x,tpose.y,tpose.z);
//           glVertex3f(vw.x,vw.y,vw.z);
//         }
//         glEnd();
//         zpos=0;
//       }
//       faceid++;
//
//
//       if(part->name=="h_left_up_leg")
//         cout<<"upleg:"<<uplegmax-uplegmin<<endl;
//       //cout<<gx<<" "<<gy<<" "<<gz<<endl;
//       //glVertex3f(0.0f,0.0f,0.0f);
//       //glVertex3f(part->vertices[0][0],part->vertices[0][1],part->vertices[0][2]);
//
//       //glPopMatrix();
//     }
//   }
//   //cout<<maxy<<endl;
//   cout<<"vexnum:"<<vexnum<<endl;
//   outfile.close();
//   cout<<endl<<endl;
// }
//
// void testLBS()
// {
//   std::vector<std::vector<float>> v1;
//   std::vector<std::vector<float>> v2;
//   for(float x=-1;x<=1;x+=2){
//     for(float y=0;y<=10;y++){
//       vector<float> vex;
//       vex.push_back(x);
//       vex.push_back(y);
//       vex.push_back(0);
//       vector<float> vex2=vex;
//       if(y>5){
//         vex.push_back(0.5);
//         vex2.push_back(0);
//       }
//       else{
//         vex.push_back(0);
//         vex2.push_back(0.5);
//       }
//       v1.push_back(vex);
//       v2.push_back(vex2);
//     }
//   }
//   Matrix4x3 m1;
//   m1.identity();
//   Matrix4x3 m2;
//   m2.setupTranslation(Vector3(0,10,0));
//   Matrix4x3 gm2=m2*m1;
//   Matrix4x3 m22;
//   Matrix4x3 m20;
//   m20.identity();
//   m22.identity();
//   m22.m11=1;m22.m12=2;m22.m21=1.3;m22.m22=1.5;
//   m22.setupRotate(3,3.14159/4);
//   glBegin(GL_POINTS);
//   for(int i=0;i<v1.size();i++){
//     float xx=v1[i][0];
//     float yy=v1[i][1];
//     Vector3 vv1(xx,yy,0);
//     vv1*=m1;
//     glVertex2f(vv1.x,vv1.y);
//   }
//   for(int i=0;i<v2.size();i++){
//     float xx=v1[i][0];
//     float yy=v1[i][1];
//     float ww=v1[i][3];
//     float w=1;
//     Vector3 vv2(xx,yy,0);
//     Vector3 vv21=0.5*(vv2*m20*gm2);
//     Vector3 vv22=0.5*(vv2*m22*gm2);
//     vv2=vv21+vv22;
//     //vv2=(1-ww)*vv2*m20*gm2+ww*vv2*m22*gm2;
//     glVertex2f(vv2.x,vv2.y);
//   }
//   glEnd();
//
//
// }
//
// bool sortVector3(const Vector3 &v1,const Vector3 &v2){
//     if(v1.y == v2.y){
//         return v1.x < v2.x;
//     }
//     return v1.y < v2.y;
// }
//
// void drawTest(Bvh &bvhs){
// //  int n=30;
// //  float maxy=0;
//     vector<vector<float>> vwaist;
// //  Matrix4x3 gmlupleg = bvhs.bodyName["h_left_up_leg"]->gmotion[fr];
// //  gmlupleg.tx=gmlupleg.ty=gmlupleg.tz=0;
// //  Matrix4x3 gmllowleg = bvhs.bodyName["h_left_low_leg"]->gmotion[fr];
// //  gmllowleg.tx=gmllowleg.ty=gmllowleg.tz=0;
//     //cout <<"aaaa"<<endl;
//     std::vector<std::string> visionOrder = getPre3dOrder();
//     std::ofstream outfile("tposevex.txt",std::ofstream::out);
//
//     int vexnum=0;
//     for (unsigned int i=0 ; i< visionOrder.size();i++) {
//         if(visionOrder[i] == "h_right_up_leg"){}
//
//
//         BvhPart *part;
//         part = bvhs.getBvhPart(visionOrder[i]);
//         Matrix4x3 gm = part->gmotion[fr];
//         Matrix4x3 m = part->motion[fr];
//         Matrix4x3 cgm;
//         Matrix4x3 tpgm=gm;
//         tpgm.tx=tpgm.ty=tpgm.tz=0;
//         cgm.identity();
//         std::vector<Vector3> v=part->vertices;
//         float gtranslation[16]={0};
//         float matrix[4]={0,0,0,1};
//
//         //绘制坐标原点
//
//         glBegin(GL_POINTS);
//         glVertex3f(0.0f,0.0f,0.0f);
//         glEnd();
//
//         gtranslation[0]=gm.m11;gtranslation[1]=gm.m12;gtranslation[2]=gm.m13;gtranslation[3]=0;
//         gtranslation[4]=gm.m21;gtranslation[5]=gm.m22;gtranslation[6]=gm.m23;gtranslation[7]=0;
//         gtranslation[8]=gm.m31;gtranslation[9]=gm.m32;gtranslation[10]=gm.m33;gtranslation[11]=0;
//         //gtranslation[12]=gm.tx/n;gtranslation[13]=gm.ty/n;gtranslation[14]=gm.tz/n;
//         gtranslation[12]=gm.tx;gtranslation[13]=gm.ty;gtranslation[14]=gm.tz;gtranslation[15]=1;
//
//         if(1){
//             float uplegmin=200;
//             float uplegmax=-200;
//
//                 for(auto vectorsInEachFace : part->faces){
//                     //sort(v.begin(),v.end(),sortVector3);
//                     glBegin(GL_POLYGON);
//                     for(int vexId : vectorsInEachFace){
//                         float xx = v[vexId].x,yy = v[vexId].y,zz = v[vexId].z;
//                         Vector3 v0(xx,yy,zz);
//                         v0.x *= part->widthscale;
//                         v0.y *= part->lenscale;
//                         v0.z *= part->depthscale;
//                         Vector3 tPose = v0 * part->gm;
//                         Vector3 normal(0,0,0);
//                         normal = part->vexnormals[vexId];
//                         normal.normalize();
//                         glNormal3f(normal.x,normal.y,normal.z);
//                         glVertex3f(tPose.x,tPose.y,tPose.z);
//                     }
//                     glEnd();
//                 }
//
//             //sort(v.begin(),v.end(),sortVector3);
// //            glBegin(GL_POLYGON);
// //            for(int vi=0;vi < v.size();vi++){
// //                vexnum++;
// //                float  xx=v[vi].x,yy=v[vi].y,zz=v[vi].z;
// //                float wk=1;
// //                Vector3 v0(xx,yy,zz);
// //                v0.x*=part->widthscale;
// //                v0.y*=part->lenscale;
// //                v0.z*=part->depthscale;
// //
// //                v0*=part->gm;
// //                Vector3 tpose=v0;
// //
// //                Matrix4x3 Rk=gm;
// //                Matrix4x3 R0=part->gm;
// //
// //                Matrix4x3 I;
// //                I.identity();
// //
// //                Vector3 vw(0,0,0);
// //                //Rk=Rk*inverse(bvhs.bodyName["h_waist"]->gmotion[fr]);
// //                //v0.y*=0.82;
// //                R0=part->gmatrix;
// //                //!!!!glVertex3f((v0*R0).x,(v0*R0).y,(v0*R0).z);
// //                //glVertex3f((v0*part->gm).x,(v0*part->gm).y,(v0*part->gm).z);
// //                //glVertex3f((v0*part->gm).z,(v0*part->gm).y,(v0*part->gm).x);
// //
// //
// //                if((v0*R0).y>highest){
// //                    higher=highest;
// //                    higherId=highestId;
// //                    higherName=higherName;
// //                    highest=(v0*R0).y;
// //                    highestName=part->name;
// //                    highestId=vi;
// //                }
// //                else if((v0*R0).y>higher){
// //                    higher=(v0*R0).y;
// //                    higherName=part->name;
// //                    higherId=vi;
// //                }
// //                if((v0*R0).y<lowest){
// //                    lower=lowest;
// //                    lowerName=lowestName;
// //                    lowerId=lowestId;
// //                    lowest=(v0*R0).y;
// //                    lowestName=part->name;
// //                    lowestId=vi;
// //                }
// //                else if((v0*R0).y<lower)
// //                {
// //                    lower=(v0*R0).y;
// //                    lowerName=part->name;
// //                    lowerId=vi;
// //                }
// //                if(part->name=="h_left_foot"){
// //                    if((v0*R0).y<lowest_left){
// //                        lowest_left=(v0*R0).y;
// //                        lowest_left_Name=part->name;
// //                        lowest_left_Id=vi;
// //                    }
// //                }
// //                Matrix4x3 Rwaist=bvhs.bodyName["h_waist"]->gmotion[fr];
// //                for(auto it=part->Jweight[vi].begin();it!=part->Jweight[vi].end();it++){
// //
// //                    float wij=it->second;
// //                    Matrix4x3 Rj=bvhs.bodyName[it->first]->gmotion[fr];
// //                    Matrix4x3 R0j=(bvhs.bodyName[it->first]->gm);
// //                    Matrix4x3 R0ji=inverse(R0j);
// //                    //cout<<Rj<<endl;
// //                    Vector3 Tj(Rj.tx,Rj.ty,Rj.tz);
// //                    vw+=wij*(v0*R0*R0ji*Rj);
// //                    wk-=wij;
// //                    if(part->name=="h_left_low_leg"){
// //                        //cout<<vi<<" "<<it->first<<" "<<wij<<endl;
// //                    }
// //                }
// //                vw+=wk*(v0*Rk);
// //                weight_set.insert(wk);
// //                if(wk==0){
// //                    glColor3f(0.5,0.5,0.5);
// //                }
// //                else if(wk>0.33&&wk<0.34)
// //                    glColor3f(1,0,0);
// //                else
// //                    glColor3f(1,1,1);
// //                glVertex3f(tpose.x,tpose.y,tpose.z);
// //            }
// //            glEnd();
//         }
//
//
//     }
//     cout<<"vexnum:"<<vexnum<<endl;
//     outfile.close();
//     cout<<endl<<endl;
// }
//
// void Display(void) {
//   //draw model
//   glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
//   //draw projection
//   //glClear(GL_COLOR_BUFFER_BIT);
//   glMatrixMode(GL_MODELVIEW);
//   glLoadIdentity();
//   //gluPerspective(90,720/1280,0,10);
//   //glFrustum(-10.0,10.0,-10.0,10.0,-10.0,10.0);
//   //glOrtho(-3,3.0,-5,5.0,-3.0,5.0);
//   //glOrtho(-5.0,5.0,-5.0,5.0,-5.0,5.0);
//   //glOrtho(-7.0,7.0,-7.0,7.0,-7.0,7.0);
//   //glOrtho(-15.0,15.0,-15.0,15.0,-15.0,20.0);
//   //glOrtho(-10.0,10.0,-10.0,10.0,-10.0,10.0);
//   //glOrtho(-40.0,40.0,-40.0,40.0,-40.0,40.0);
//   //glOrtho(-80.0,80.0,-80.0,80.0,-80.0,80.0);
//   //glOrtho(-200.0,200.0,-200.0,200.0,-100.0,100.0);
//   //glOrtho(-100.0,100.0,-100.0,100.0,-100.0,100.0);
//   glOrtho(-100.0,100.0,-50,100.0,-100.0,100.0);
//   //glFrustum(-200.0,200.0,-200.0,200.0,-100.0,100.0);
//   if(times==0){
//     bvhs.mdlParse("/home/gcy/Golf/3dModel/samples/mri_sg/swing_001.mdl");
//     cout<<"mdlParse"<<endl;
//     bvhs.dofParse("/home/gcy/Golf/3dModel/samples/mri_sg/swing_001.dof");
//     cout<<"dofParse"<<endl;
//     bvhs.bdfParse("/home/gcy/Golf/3dModel/samples/mri_sg/swing_001.bdf");
//     cout<<"bdfParse"<<endl;
//     bvhs.varParse("/home/gcy/Golf/3dModel/samples/mri_sg/swing_003.var");
//     cout<<"varParse"<<endl;
//   }
//   cout<<"loadFiles"<<endl;
//   times++;
//   //cout<<bvhs.bodyName["h_head"]->vertices.size()<<endl;
// //  for(auto it:bvhs.bodyName){
// //      cout<<"**********"<<endl;
// //    cout<<it.first<<endl;
// //    cout<<"vertices.size: "<<it.second->vertices.size()<<endl;
// //    cout<<"bones.size "<<it.second->bones.size()<<endl;
// //    cout<<"texture.size"<<it.second->texture.size()<<endl;
// //    cout<<"faces.size"<<it.second->faces.size()<<endl;
// //      cout<<"**********"<<endl;
// //  }
//
//
//   //bvhs.scale();
//   //bvhs.printGlobalMatrix();
//   //bvhs.computeSlope();
//   //bvhs.printSlope();
//   //bvhs.computeTranslation(height,weight);
//   //glScalef(0.1,0.1,0.1);
//   InitModel();
//   cout<<"InitModel"<<endl;
//   //glClear(GL_COLOR_BUFFER_BIT);
//   //glPointSize(2.0f);
//
//
//
//   /*glPushMatrix();
//   //glTranslatef(3.507598/n,-1.465415/n,1.131140/n);
//    GLfloat mlul[16]=  {
//    0.999512   , 0.031234  ,  0.000000,0,
//   -0.031219   , 0.999013   , -0.031589,0,
//   -0.000987  ,  0.031573   , 0.999501,0,
//   3.507598  ,  -1.465415   , 1.131140,1};
//   //glTranslatef(mlul[1],mlul[],mlul[]);
//   mlul[12]/=n;
//   mlul[13]/=n;
//   mlul[14]/=n;
//   glMultMatrixf(mlul);
//    //0.999512    0.031234    0.000000
//   //-0.031219    0.999013    -0.031589
//   //-0.000987    0.031573    0.999501
//   glBegin(GL_POINTS);//必须是加上s，要不然显示不了
// //  glBegin(GL_LINE_STRIP);
//   glVertex3f(0,0,0);
//
//   waist.open("/home/spider/CLionProjects/loadwaist/leftuplegdata.txt",std::fstream::in);
//   if(!waist){
//       std::cout<<"fail to open"<<std::endl;
//   }
//   while (!waist.eof())
//   {
//       waist>>vec[0]>>vec[1]>>vec[2];
//       //std::cout<<vec[0]<<" "<<vec[1]<<" "<<vec[2]<<std::endl;
//       glVertex3f(vec[0]/n,vec[1]/n,vec[2]/n);
//       //glVertex3f(vec[0],vec[1],vec[2]);
//   }
//   waist.close();
//   glEnd();
//   glPopMatrix();
//
//   GLfloat mrul[16]={0.999512   ,-0.031235  ,  -0.000001,0,
//                 0.031220   ,0.999013    ,-0.031589,0,
//                 0.000987   ,0.031573    ,0.999501,0,
//                -3.507598   ,-1.465415    ,1.131140,1};
//   //GLfloat a[16];
//   for(int i=0;i<15;i++){
//     //a[i]=mrul[i]/n;
//   }
//   mrul[12]/=n;
//   mrul[13]/=n;
//   mrul[14]/=n;
//   glPushMatrix();
//   //glTranslatef(-3.507598/n,-1.465415/n,1.131140/n);
//   glMultMatrixf(mrul);
//    //0.999512    0.031234    0.000000
// //-0.031219    0.999013    -0.031589
// //-0.000987    0.031573    0.999501
//   glBegin(GL_POINTS);//必须是加上s，要不然显示不了
// //  glBegin(GL_LINE_STRIP);
//
//   waist.open("/home/spider/CLionProjects/loadwaist/rightuplegdata.txt",std::fstream::in);
//   if(!waist){
//       std::cout<<"fail to open"<<std::endl;
//   }
//   while (!waist.eof())
//   {
//       waist>>vec[0]>>vec[1]>>vec[2];
//       //std::cout<<vec[0]<<" "<<vec[1]<<" "<<vec[2]<<std::endl;
//       glVertex3f(vec[0]/n,vec[1]/n,vec[2]/n);
//       //glVertex3f(vec[0],vec[1],vec[2]);
//   }
//   waist.close();
//   glEnd();
//   glPopMatrix();*/
//
// /*  GLfloat mlll[16]={
//   0.999854,    -0.017068   , -0.000001,0,
//   0.017043 ,   0.998419    ,-0.053556,0,
//   0.000915  ,  0.053549    ,0.998565,0,
//   0.000030   , -17.967381 ,   -0.000003,1};
//   mlll[12]/=n;
//   mlll[13]/=n;
//   mlll[14]/=n;
//   glPushMatrix();
//   //glTranslatef(-3.507598/n,-1.465415/n,1.131140/n);
//   glMultMatrixf(mrul);
//   glMultMatrixf(mlll);
//   glBegin(GL_POINTS);//必须是加上s，要不然显示不了
//   waist.open("/home/spider/CLionProjects/loadwaist/leftlowlegdata.txt",std::fstream::in);
//   if(!waist){
//       std::cout<<"fail to open"<<std::endl;
//   }
//   glVertex3f(0,0,0);
//
//   while (!waist.eof())
//   {
//       waist>>vec[0]>>vec[1]>>vec[2];
//       //std::cout<<vec[0]<<" "<<vec[1]<<" "<<vec[2]<<std::endl;
//       //glVertex3f(vec[0]/n,vec[1]/n,vec[2]/n);
//       glVertex3f(vec[0],vec[1],vec[2]);
//   }
//   waist.close();
//   glEnd();
//   glPopMatrix();
// */
// //    BvhPart* part = bvhs.getBvhPart("h_left_up_leg");
// //    adjustTrans(part,1.5);
// //    bvhs.recurSetFamilyGlobalMatrix();
//     //testLBS();
//
//     glRotatef(angle,0,1,0);
//     //recursivedraw(bvhs);
// //  recursivedrawVex(bvhs);
// //    drawTest(bvhs);
//   recursivedrawFace(bvhs);
//   //height=highest-lowest;
//   /*cout<<highestName<<" "<<highestId<<" "<<highest<<endl;
//   cout<<higherName<<" "<<higherId<<" "<<higher<<endl;
//   cout<<lowestName<<" "<<lowestId<<" "<<lowest<<endl;
//   cout<<lowest_left_Name<<" "<<lowest_left_Id<<" "<<lowest_left<<endl;
//   cout<<lowerName<<" "<<lowerId<<" "<<lower<<endl;
//   cout<<"height:"<<height<<endl;*/
//   //glFinish();
//   glFlush();
//   //glutSwapBuffers();
//   for(auto it:weight_set){
//     //cout<<it<<" ";
//   }
//   cout<<endl;
//
// }
//
//
// int main(int argc, char** argv) {
//
//   /*if(argc==2){
//     std::string h(argv[1]);
//     height=std::stof(&h);
//   }
//   else if(argc==3){
//     std::string h(argv[1]);
//     height=std::stof(&h);
//     std::string w(argv[2]);
//     weight=std::stof(&w);
//   }*/
//   //inputParam();
//   glutInit(&argc, argv);
//   //glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE|GLUT_DEPTH);
//   glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE|GLUT_DEPTH);
//
//
//   glutInitWindowSize(600,800);    //显示框大小
//   //glutInitWindowSize(720,1280);    //显示框大小
//   //glutInitWindowPosition(500,720); //确定显示框左上角的位置
//   //glutInitWindowSize(500,500);    //显示框大小
//   glutInitWindowPosition(2000,50); //确定显示框左上角的位置
//   glutCreateWindow("人体三维模型");//
//   //draw model
//   initOpenGLOption();
//   //draw projeciton
//   //initOpenGLProjOption();
//   //SetupRC();
//     glutKeyboardFunc( keyboard );
//   glutDisplayFunc(Display);
//
//   //glMatrixMode(GL_MODELVIEW);
//   //glutDisplayFunc(display);
//   //glutDisplayFunc(Displaywaist);
//   //glTranslatef(-3.507598,-1.465415,1.131140);
//
//
//
//
//
//
//   //glRotated();
//   //......//你要画的球或者其它的图像；
//   //如:
//   //glBegin();
//   //.......
//   //glutDisplayFunc(myDisplay);
//   //glutReshapeFunc(reshape);
//   //glEnd();
//   //glutDisplayFunc(display2);
//   //glutReshapeFunc(reshape);
//
//   //gluPerspective(90,720/1280,0,100);
//   //glScalef(75,75,75);
//   //glutTimerFunc(5,timerProc,1);
//   glutMainLoop();
//   //cin>>aaa;
//   //writePre3d(bvhs, "Pre3d");
//   //writeAnalysisReport(bvhs, "writeAnalysisReport");
//
//   return 0;
//
//
// }
//
//
//
// /*
// void showBmpHead(BITMAPFILEHEADER &pBmpHead)
// {
//     cout<<"位图文件头:"<<endl;
//     cout<<"文件头类型:"<<pBmpHead.bfType<<" "<<sizeof(pBmpHead.bfType)<<endl;
//     cout<<"文件大小:"<<pBmpHead.bfSize<<" "<<sizeof(pBmpHead.bfSize)<<endl;
//     cout<<"保留字_1:"<<pBmpHead.bfReserved1<<" "<<sizeof(pBmpHead.bfReserved1)<<endl;
//     cout<<"保留字_2:"<<pBmpHead.bfReserved2<<" "<<sizeof(pBmpHead.bfReserved2)<<endl;
//     cout<<"实际位图数据的偏移字节数:"<<pBmpHead.bfOffBits<<" "<<sizeof(pBmpHead.bfOffBits)<<endl<<endl;
// }
//
// void showBmpInforHead(BITMAPINFODEADER &pBmpInforHead)
// {
//     cout<<"位图信息头:"<<endl;
//     cout<<"结构体的长度:"<<pBmpInforHead.biSize<<" "<<sizeof(pBmpInforHead.biSize)<<endl;
//     cout<<"位图宽:"<<pBmpInforHead.biWidth<<" "<<sizeof(pBmpInforHead.biWidth)<<endl;
//     cout<<"位图高:"<<pBmpInforHead.biHeight<<" "<<sizeof(pBmpInforHead.biHeight)<<endl;
//     cout<<"biPlanes平面数:"<<pBmpInforHead.biPlanes<<" "<<sizeof(pBmpInforHead.biPlanes)<<endl;
//     cout<<"biBitCount采用颜色位数:"<<pBmpInforHead.biBitCount<<" "<<sizeof(pBmpInforHead.biBitCount)<<endl;
//     cout<<"压缩方式:"<<pBmpInforHead.biCompression<<" "<<sizeof(pBmpInforHead.biCompression)<<endl;
//     cout<<"biSizeImage实际位图数据占用的字节数:"<<pBmpInforHead.biSizeImage<<" "<<sizeof(pBmpInforHead.biSizeImage)<<endl;
//     cout<<"X方向分辨率:"<<pBmpInforHead.biXPelsPerMeter<<" "<<sizeof(pBmpInforHead.biXPelsPerMeter)<<endl;
//     cout<<"Y方向分辨率:"<<pBmpInforHead.biYPelsPerMeter<<" "<<sizeof(pBmpInforHead.biYPelsPerMeter)<<endl;
//     cout<<"使用的颜色数:"<<pBmpInforHead.biClrUsed<<" "<<sizeof(pBmpInforHead.biClrUsed)<<endl;
//     cout<<"重要颜色数:"<<pBmpInforHead.biClrImportant<<" "<<sizeof(pBmpInforHead.biClrImportant)<<endl;
//     cout<<sizeof(BITMAPFILEHEADER)<<endl<<sizeof(BITMAPINFOHEADER)<<endl;
// }
//
// void outputImg(const char *fileName,float ang)
// {
//   GLint ViewPort[4]={0,0,720,1280};
//
//  //glGetIntegerv(GL_VIEWPORT,ViewPort);
//  //cout<<ViewPort[0]<<ViewPort[1]<<ViewPort[2]<<ViewPort[3];
//
//  GLsizei ColorChannel = 3;
//
//  GLsizei bufferSize = ViewPort[2]*ViewPort[3]*sizeof(GLubyte)*ColorChannel;
//  unsigned char *ImgData = (unsigned char *) malloc (ViewPort[2]*ViewPort[3] * 4);
//  //GLubyte * ImgData = (GLubyte*)malloc(bufferSize);
//  //static void * aImgData;
//  int len = ViewPort[2]*ViewPort[3] * 3;
//   //ImgData = malloc(len);
//   memset(ImgData,0,len);
//
//
//  //glPixelStorei(GL_UNPACK_ALIGNMENT,1);
//   GLint a;
//   glGetIntegerv(GL_UNSIGNED_BYTE,&a);
//   cout<<a<<endl;
//   glGetIntegerv(GL_RGB,&a);
//   cout<<a<<endl;
//  //glReadPixels(ViewPort[0],ViewPort[1],ViewPort[2],ViewPort[3],GL_RGB,GL_UNSIGNED_BYTE,aImgData);
//  //glutSwapBuffers();
//  glReadPixels(ViewPort[0],ViewPort[1],ViewPort[2],ViewPort[3],GL_BGR,GL_UNSIGNED_BYTE,ImgData);
//   glClear(GL_COLOR_BUFFER_BIT);
//   glDrawPixels(ViewPort[2],ViewPort[3],GL_BGR,GL_UNSIGNED_BYTE,ImgData);
//    //glutSwapBuffers();
//    glutPostRedisplay();
//
//  /*
//  glDrawPixels(ViewPort[2],ViewPort[3], GL_BGR_EXT, GL_UNSIGNED_BYTE,aImgData);*/
// /*
//
//  BITMAPFILEHEADER hdr;
//  BITMAPINFOHEADER infoHdr;
//   memset(&hdr,0,14);
//   memset(&infoHdr,0,40);
//  infoHdr.biSize = 40;
//  infoHdr.biWidth = ViewPort[2];
//  infoHdr.biHeight = ViewPort[3];
//  infoHdr.biPlanes = 1;
//  infoHdr.biBitCount = 24;
//  infoHdr.biCompression = 0;
//  infoHdr.biSizeImage =ViewPort[2]*ViewPort[3]*3;
//  infoHdr.biXPelsPerMeter = 0;
//  infoHdr.biYPelsPerMeter = 0;
//  infoHdr.biClrUsed = 0;
//  infoHdr.biClrImportant = 0;
//
//
//
//  hdr.bfType = 0x4D42;
//  hdr.bfReserved1 = 0;
//  hdr.bfReserved2 = 0;
//
//  hdr.bfOffBits = sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER);
//  hdr.bfOffBits = 54;
//  hdr.bfSize =hdr.bfOffBits+ViewPort[2]* ViewPort[3] * 24;
//
// */
// //unsigned char* ImgData=(unsigned char*)aImgData;
// /*unsigned char tempRGB;  //临时色素
//   int imageIdx;
// for (imageIdx = 0;imageIdx < infoHdr.biSizeImage;imageIdx +=3)
//   {
//     tempRGB = ImgData[imageIdx];
//     ImgData[imageIdx] = ImgData[imageIdx + 2];
//     ImgData[imageIdx + 2] = tempRGB;
//   }*/
// /*
//  FILE *fid=NULL;
//
// showBmpHead(hdr);
// showBmpInforHead(infoHdr);
//
//  if( !(fid = fopen(fileName,"wb+")) )
//
//  {
//   std::cout<<fileName<<std::endl;
//   std::cout<<"Cannot load bmp image format!"<<std::endl;
//
//   getchar();
//
//  }
//  fwrite(&hdr,14,1,fid);
//  fwrite(&infoHdr,40,1,fid);
//  fwrite(ImgData,infoHdr.biSizeImage,1,fid);
//
//  fclose(fid);
//
//  free(ImgData);
// }
// */
