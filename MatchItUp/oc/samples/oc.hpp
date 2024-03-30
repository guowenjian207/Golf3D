
//
//  Test.hpp
//  TestOcUseCpp
//
//  Created by andrew on 2021/7/8.
//
 
#ifndef oc_hpp
#define oc_hpp
#include <iostream>
#include <stdio.h>
#include <vector>

using namespace std;

#endif /* Test_hpp */
vector<vector<double>> Display(int frame);
vector<vector<vector<double>>> Display2(int frame);
vector<vector<vector<double>>> front_lines();
vector<vector<vector<double>>> beside_lines();
vector<vector<vector<double>>> new_lines();
int getFrameCount( string path, string file_name);
vector<int> getBodyCount();
vector<int> getHeadCount();
vector<int> test_key_frames(string player_name);
void timeFunc();
