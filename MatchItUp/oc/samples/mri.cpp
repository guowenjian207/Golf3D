/*----------------------------------------
 *
 * pred3d Project by WangYang -add by wl
 *
 *
 ---------------------------------------*/


#include <string>
#include <iomanip>
#include <iostream>
#include <fstream>
#include <json/json.h>
#include "../biovision/Bvh.h"

using namespace std;

const int PI = 3.1415926;

void printMatrix(Matrix4x3 m) {
  printf("  %f, %f, %f\n",m.m11, m.m12, m.m13);
  printf("  %f, %f, %f\n",m.m21, m.m22, m.m23);
  printf("  %f, %f, %f\n",m.m31, m.m32, m.m33);
  printf("  %f, %f, %f\n",m.tx, m.ty, m.tz);
  printf("\n");
}

void printPre3d(Matrix4x3 m) {
  printf("[%f,%f,%f,%f" ,m.m11, m.m21, m.m31, m.tx);
  printf(",%f,%f,%f,%f" ,m.m12, m.m22, m.m32, m.ty);
  printf(",%f,%f,%f,%f]" ,m.m13, m.m23, m.m33, m.tz);
}

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
  visionOrder.push_back("h_right_shoulder");
  visionOrder.push_back("h_right_up_arm");
  visionOrder.push_back("h_right_low_arm");
  visionOrder.push_back("h_right_wrist");
  visionOrder.push_back("h_right_hand");
  visionOrder.push_back("h_left_up_leg");
  visionOrder.push_back("h_left_low_leg");
  visionOrder.push_back("h_left_foot");
  visionOrder.push_back("h_left_toes");
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
  visionOrder.push_back("hosel");
  visionOrder.push_back("lie");
  visionOrder.push_back("loft");
  visionOrder.push_back("clubface");
  visionOrder.push_back("ball");
  return visionOrder;
}

void writePre3d(Bvh bvhs, std::string pre3dFile) {
  std::ofstream pFile (pre3dFile.c_str());
  if (pFile.is_open()){
    std::vector<std::string> visionOrder = getPre3dOrder();
    //pFile << "var rotations = new Array(\n";

    // pFile << "[";
  for (int f=0; f< bvhs.framesNum; f++) {
    for (unsigned int i=0 ; i< visionOrder.size();i++) {
        BvhPart *part = bvhs.getBvhPart(visionOrder[i]);

        Matrix4x3 m = part->gmotion[f];
        pFile<< part->name <<" | frame= "<<f<<endl;
        pFile <<m.m11<<" "<<m.m12<<" "<<m.m13<<"\n";
        pFile <<m.m21<<" "<<m.m22<<" "<<m.m23<<"\n";
        pFile <<m.m31<<" "<<m.m32<<" "<<m.m33<<"\n";
        pFile <<m.tx<<" "<<m.ty<<" "<<m.tz<<"\n";
        pFile<<endl;
//        pFile <<m.m11<<" "<<m.m21<<" "<<m.m31<<" "<<m.tx<<"\n";
//        pFile <<m.m12<<" "<<m.m22<<" "<<m.m32<<" "<<m.ty<<"\n";
//        pFile <<m.m13<<" "<<m.m23<<" "<<m.m33<<" "<<m.tz<<"\n";

        //pFile <<m.tx<<"\n";
       // pFile <<m.ty<<"\n";
        //pFile <<m.tz<<"\n";
       // if (i < visionOrder.size()-1)
         // pFile << ",";
      }

     // if (f < bvhs.framesNum -1)
     //   pFile << "],\n";
     // else
       // pFile << "]);\n";
    }
  } else
    std::cout << "Unable to open file " << std::endl;
}

//create by wanglong
void writeGmotion(Bvh bvhs, std::string pre3dFile) {
    std::ofstream pFile (pre3dFile.c_str());
    if (pFile.is_open()){
        std::vector<std::string> visionOrder = getPre3dOrder();
        //pFile << "var rotations = new Array(\n";

        // pFile << "[";
        for (int f=0; f< bvhs.framesNum; f++) {
            for (unsigned int i=0 ; i< visionOrder.size();i++) {
                BvhPart *part = bvhs.getBvhPart(visionOrder[i]);

                Matrix4x3 m = part->gmotion[f];
                pFile<< part->name <<" | frame= "<<f<<endl;
                pFile <<m.m11<<" "<<m.m12<<" "<<m.m13<<"\n";
                pFile <<m.m21<<" "<<m.m22<<" "<<m.m23<<"\n";
                pFile <<m.m31<<" "<<m.m32<<" "<<m.m33<<"\n";
                pFile <<m.tx<<" "<<m.ty<<" "<<m.tz<<"\n";
                pFile<<endl;
            }
        }
    } else
        std::cout << "Unable to open file " << std::endl;
}




// create by wanglong
void writeGm(Bvh bvhs, std::string pre3dFile) {
    std::ofstream pFile (pre3dFile.c_str());
    if (pFile.is_open()){
        std::vector<std::string> visionOrder = getPre3dOrder();
        for (unsigned int i=0 ; i< visionOrder.size();i++) {
            BvhPart *part = bvhs.getBvhPart(visionOrder[i]);
            Matrix4x3 m = part->gm;
            pFile<< part->name<<endl;
            pFile <<m.m11<<" "<<m.m12<<" "<<m.m13<<"\n";
            pFile <<m.m21<<" "<<m.m22<<" "<<m.m23<<"\n";
            pFile <<m.m31<<" "<<m.m32<<" "<<m.m33<<"\n";
            pFile <<m.tx<<" "<<m.ty<<" "<<m.tz<<"\n";
            pFile<<endl;
        }

    } else
        std::cout << "Unable to open file " << std::endl;
}

void writeAnalysisReport(Bvh bvhs, std::string reportFile) {
  std::ofstream pFile (reportFile.c_str());
  if (pFile.is_open()){
    pFile << "Frame Num = " << bvhs.framesNum << "\n";
    float startx = 0.0f, distx = 0.0f;
    float starty = 0.0f, disty = 0.0f;
    float startz = 0.0f, distz = 0.0f;

    for (int f=0; f< bvhs.framesNum; f++) {
        BvhPart *part = bvhs.getBvhPart("clubface");
        Matrix4x3 m = part->gmotion[f];
        if (f>0) {
          distx = m.tx - startx;
          disty = m.ty - starty;
          distz = m.tz - startz;
        }
        startx = m.tx;
        starty = m.ty;
        startz = m.tz;

        pFile << std::left << std::setw(14) << f+1
              << std::setw(14) << m.tx * 10
              << std::setw(14) << m.ty * 10
              << std::setw(14) << m.tz * 10
              << std::setw(14) << distx * 10 * 110 * 3600 / 63360
              << std::setw(14) << disty * 10 * 110 * 3600 / 63360
              << std::setw(14) << distz * 10 * 110 * 3600 / 63360
              << "\n";
    }
  } else
    std::cout << "Unable to open file " << std::endl;
}

/*--------------------
 *
 * create by fjh 2020.6
 * use new initial pose (put hand down) to fix the corrddinate system oriention bug.
 *
 -----------------------*/

// create by fjh 2020.6
void writeNewInitialPose(Bvh bvhs, std::string newInitialPoseFile) {
    std::ofstream pFile (newInitialPoseFile.c_str());
    if (pFile.is_open()){
        std::vector<std::string> visionOrder = getPre3dOrder();
        pFile << 1 << "\n";
        for (unsigned int i=0 ; i< visionOrder.size();i++) {
            BvhPart *part = bvhs.getBvhPart(visionOrder[i]);
            Matrix4x3 m = part->m;
//            Matrix4x3 mInverse = inverse(m);
            pFile<< part->name <<" | frame= 0" << "\n";
//            pFile <<m.m11<<" "<<m.m12<<" "<<m.m13<<"\n";
//            pFile <<m.m21<<" "<<m.m22<<" "<<m.m23<<"\n";
//            pFile <<m.m31<<" "<<m.m32<<" "<<m.m33<<"\n";
            pFile <<m.m11<<" "<<m.m21<<" "<<m.m31<<"\n";
            pFile <<m.m12<<" "<<m.m22<<" "<<m.m32<<"\n";
            pFile <<m.m13<<" "<<m.m23<<" "<<m.m33<<"\n";
            pFile <<m.tx<<" "<<m.ty<<" "<<m.tz<<"\n";
            pFile<<endl;
        }

    } else
        std::cout << "Unable to open file " << std::endl;
}


void writeMotion(Bvh bvhs, std::string pre3dFile) {
    std::ofstream pFile (pre3dFile.c_str());
    if (pFile.is_open()){
        std::vector<std::string> visionOrder = getPre3dOrder();
        //pFile << "var rotations = new Array(\n";

        pFile << bvhs.framesNum << endl;
        // pFile << "[";
        for (int f=0; f< bvhs.framesNum; f++) {
            for (unsigned int i=0 ; i< visionOrder.size();i++) {
                BvhPart *part = bvhs.getBvhPart(visionOrder[i]);

                Matrix4x3 m = part->motion[f];
                Matrix4x3 mInverse = inverse(m);
                pFile<< part->name <<" | frame= "<<f<<endl;
                pFile <<m.m11<<" "<<m.m21<<" "<<m.m31<<"\n";
                pFile <<m.m12<<" "<<m.m22<<" "<<m.m32<<"\n";
                pFile <<m.m13<<" "<<m.m23<<" "<<m.m33<<"\n";

//                pFile <<mInverse.m11<<" "<<mInverse.m12<<" "<<mInverse.m13<<"\n";
//                pFile <<mInverse.m21<<" "<<mInverse.m22<<" "<<mInverse.m23<<"\n";
//                pFile <<mInverse.m31<<" "<<mInverse.m32<<" "<<mInverse.m33<<"\n";
//                pFile <<mInverse.tx<<" "<<mInverse.ty<<" "<<mInverse.tz<<"\n";

                pFile <<m.tx<<" "<<m.ty<<" "<<m.tz<<"\n";
                pFile<<endl;
            }
        }
    } else
        std::cout << "Unable to open file " << std::endl;
}

// write euler angle from var, t-pose initial pose, order: xzy
void writeEulerAngle(Bvh bvhs, std::string EulerAngleFile) {
    std::ofstream pFile (EulerAngleFile.c_str());
    if (pFile.is_open()){
        std::vector<std::string> visionOrder = getPre3dOrder();
        //pFile << "var rotations = new Array(\n";

        pFile << bvhs.framesNum << endl;
        // pFile << "[";
        for (int f=0; f< bvhs.framesNum; f++) {
            for (unsigned int i=0 ; i< visionOrder.size();i++) {
                BvhPart *part = bvhs.getBvhPart(visionOrder[i]);

                pFile << part->name << " | frame= " << f << ":";

                float tmp_angle[3];
                for(int i = 0; i < 3; i++) {
                    tmp_angle[i] = part->euler_angle[f * 3 + i] * 180 / PI;
                }
                pFile << tmp_angle[0] << "," << tmp_angle[1] << ","
                     << tmp_angle[2] << std::endl;
            }
        }
    } else
        std::cout << "Unable to open file " << std::endl;
}

// write motion_rot, which is the rotate motion matrix from t-pose
void writeMotionRot(Bvh bvhs, std::string motionRotFile) {
    std::ofstream pFile (motionRotFile.c_str());
    if (pFile.is_open()){
        std::vector<std::string> visionOrder = getPre3dOrder();
        //pFile << "var rotations = new Array(\n";

        pFile << bvhs.framesNum << endl;
        // pFile << "[";
        for (int f=0; f< bvhs.framesNum; f++) {
            for (unsigned int i=0 ; i< visionOrder.size();i++) {
                BvhPart *part = bvhs.getBvhPart(visionOrder[i]);

                Matrix4x3 m = part->motion_rot[f];
                Matrix4x3 mInverse = inverse(m);
                Vector3 v = part->motion_tran[f];
                pFile << part->name <<" | frame= " << f << endl;
//                pFile << mInverse.m11 << " " << mInverse.m12 << " " << mInverse.m13 << "\n";
//                pFile << mInverse.m21 << " " << mInverse.m22 << " " << mInverse.m23 << "\n";
//                pFile << mInverse.m31 << " " << mInverse.m32 << " " << mInverse.m33 << "\n";
                pFile << m.m11 << " " << m.m12 << " " << m.m13 << "\n";
                pFile << m.m21 << " " << m.m22 << " " << m.m23 << "\n";
                pFile << m.m31 << " " << m.m32 << " " << m.m33 << "\n";
                pFile << v.x << " " << v.y << " " << v.z << "\n";
                pFile << endl;
            }
        }
    } else
        std::cout << "Unable to open file " << std::endl;
}

// create by fjh 2020.9
void writePosition3d(Bvh bvhs, std::string pre3dFile) {
    std::ofstream pFile (pre3dFile.c_str());
    if (pFile.is_open()){
        std::vector<std::string> visionOrder = getPre3dOrder();

        pFile << bvhs.framesNum << endl;
        for (int f=0; f< bvhs.framesNum; f++) {
            for (unsigned int i=0 ; i< visionOrder.size();i++) {
                BvhPart *part = bvhs.getBvhPart(visionOrder[i]);

                Matrix4x3 m = part->gmotion[f];
                pFile<< part->name <<" | frame= "<< f << ":";
                pFile <<m.tx<<","<<m.ty<<","<<m.tz<<"\n";
            }
        }
    } else
        std::cout << "Unable to open file " << std::endl;
}


/*-----------------------
 *
 * origin version
 *
 --------------------- */
//int main(int argc, char** argv) {
//  Bvh bvhs;
//  if(argc < 7) {
//    std::cout << "At least need 6 parameters " << std::endl;
//    return 1;
//  }
//
//  bvhs.mdlParse(argv[1]);
//  bvhs.dofParse(argv[2]);
//  bvhs.bdfParse(argv[3]);
//  bvhs.varParse(argv[4]);
//
//  writePre3d(bvhs, argv[5]);
//  writeAnalysisReport(bvhs, argv[6]);
//
//  return 0;
//}


/*-----------------------
 *
 * in dragon's Ubuntu
 *
 --------------------- */
int main(int argc, char** argv) {
    Json::Reader reader;
    Json::Value root;

    //从文件中读取，保证当前文件有demo.json文件
    ifstream in("./samples/input.json", ios::binary);

    if (!in.is_open()) {
        cout << "Error opening file\n";
        return -1;
    }

    if(reader.parse(in, root)) {
        cout << "Parse json success." << endl;
        const Json::Value input_file_arr = root["input"];
        for(int i = 0; i < input_file_arr.size(); i++) {
            string mdl_file = input_file_arr[i]["mdl"].asString();
            string dof_file = input_file_arr[i]["dof"].asString();
            string bdf_file = input_file_arr[i]["bdf"].asString();
            string var_file = input_file_arr[i]["var"].asString();
            string output_file = input_file_arr[i]["output"].asString();

            Bvh bvhs;
            bvhs.mdlParse(mdl_file);
            cout << "mdlParse finish" << endl;
            bvhs.dofParse(dof_file);
            cout << "dofParse finish" << endl;
            bvhs.bdfParse(bdf_file);
            cout << "bdfParse finish" << endl;
            bvhs.varParse(var_file);
            cout << "varParse finish" << endl;
//            writeGmotion(bvhs, "./samples/result/gmotion-withClub.txt");
            //writeGm(bvhs, "./samples/result/gm-withClub.txt");
            //writeMotion(bvhs, "/home/dragon/MRIProj/3dModel-gcy/3dModel/samples/mri_sg/motion_withClub_transpose.txt");
            //writeNewInitialPose(bvhs, "./samples/mri_sg/List_m_tpose.txt");
            //writeEulerAngle(bvhs, "./samples/mri_sg/List_euler_angle.txt");
            //writeMotionRot(bvhs, "./samples/mri_sg/List_motion_rot.txt");
            writePosition3d(bvhs, output_file);
            //writeAnalysisReport(bvhs, "/home/dragon/MRIProj/3dModel-gcy/3dModel/samples/mri_sg/AnaRes.txt");

            cout << "write finish " << i << endl;
        }
    }
    return 0;
}