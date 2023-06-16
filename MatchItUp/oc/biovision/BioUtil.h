/**
 * @file BioUtil.h
 * @brief 常用工具
 */

#ifndef __BIOUTIL_H_INCLUDED__
#define __BIOUTIL_H_INCLUDED__

#include <string>
#include <algorithm>
#include <functional>
#include <cctype>
#include <locale>
#include <vector>

/** @brief 将给定字符串去掉左边（前面）的空格 */
static inline std::string &ltrim(std::string &s) {
    int i = 0, j = 0;
    while(' ' == s[i] || '\t' == s[i]){
        if(' ' == s[i]) i++;
        else i+=4;
    }
        

    if(0 == i)
        return s;
    while('\0' != s[j + i])
        {
        s[j] = s[j + i];
        j++;
        }
    
    while(s[j+1]!='\0'){
          s[j] = '\0';
          j++;
    }
    s[j] = '\0';
    s = s.substr(0,s.length()-i);
  return s;
}

/** @brief 将给定字符串去掉右边（后面）的空格 */
static inline std::string &rtrim(std::string &s) {
    int i;


    for(i = s.length(); i > 0; i--)
        {
        if(s[i - 1] == ' ' || s[i - 1] == '\t')
            s[i - 1] = '\0';
        else
            break;
        }

    return s;
}

/** @brief 将给定字符串去掉前后的空格 */
static inline std::string &trim(std::string &s) {
  return ltrim(rtrim(s));
}

/** @brief 判断当前字符串是否一给定字符串开头 */
static inline bool isStartWith(std::string &str, std::string &start) {
  unsigned found = str.find(start);
  return ((signed int)found == 0);
}

/** @brief 按空格 split 当前字符串 */
static inline std::vector<std::string> splitString(std::string &str) {
  std::istringstream iss(str);
  std::vector<std::string> vec =
      std::vector<std::string>(std::istream_iterator<std::string>(iss),
                               std::istream_iterator<std::string>());
  return vec;
}
static inline int splitWithMultiDelimiters(const std::string &str, const std::string &delimiters, std::vector<std::string> &vec_str) {

    if (str.empty())
        return -1;

    std::string::size_type pre = 0, cur = 0;
    std::string::size_type sz = str.size();
    while (pre < sz) {
        if ((cur = str.find_first_of(delimiters, pre)) != std::string::npos) {
            vec_str.push_back(str.substr(pre, cur - pre));
            pre = ++cur;
        }
        else {
            break;
        }
    }
    vec_str.push_back(str.substr(pre, sz - pre));
    return 0;
}

static inline float inchtocm(float f) {
  return f*2.54;
}
static inline float cmtoinch(float f) {
  return f*0.3937008;
}

/////////////////////////////////////////////////////////////
#endif // #ifndef __BIOUTIL_H_INCLUDED__
