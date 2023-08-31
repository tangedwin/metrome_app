//
//  UserMacro.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#ifndef UserMacro_h
#define UserMacro_h


//#define SELECTED_CITY @"SELECTED_CITY"
#define SELECTED_CITY_ID_KEY @"SELECTED_CITY_ID"
#define SELECTED_CITY_NAME_KEY @"SELECTED_CITY_NAME"
//定位
#define CURRENT_CITY_ID_KEY @"CURRENT_CITY_ID"
#define CURRENT_CITY_NAME_KEY @"CURRENT_CITY_NAME"
//定位经纬度
#define LOCATION_LOC_KEY @"LOCATION_LOC"

#define main_color_white [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
#define main_color_blue [UIColor colorWithRed:17/255.0 green:148/255.0 blue:246/255.0 alpha:1.0]
#define main_color_pink [UIColor colorWithRed:255/255.0 green:126/255.0 blue:171/255.0 alpha:1.0]
#define main_color_black [UIColor colorWithRed:0/255.0 green:22/255.0 blue:39/255.0 alpha:1.0]
#define main_color_gray [UIColor colorWithRed:127/255.0 green:138/255.0 blue:147/255.0 alpha:1.0]
#define main_color_lightgray [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]
#define main_color_middlegray [UIColor colorWithRed:191/255.0 green:197/255.0 blue:201/255.0 alpha:1.0]


#define dynamic_color(lightColor, darkColor)\
^(){\
  if (@available(iOS 13.0, *)) {\
      return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {\
          if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {\
                return (darkColor);\
          } else {\
              return (lightColor);\
          }\
      }];\
  } else {\
      return (lightColor);\
  }\
}()\

#define dynamic_cgcolor(lightColor, darkColor)\
^(){\
  if (@available(iOS 13.0, *)) {\
      UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {\
          if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {\
                return (darkColor);\
          } else {\
              return (lightColor);\
          }\
      }];\
      return ((dyColor).CGColor);\
  } else {\
      return ((lightColor).CGColor);\
  }\
}()\


#define main_color_dark_black [UIColor colorWithRed:19/255.0 green:20/255.0 blue:21/255.0 alpha:1]
#define main_color_dark_gray [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]
#define main_color_dark_lightgray [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5]
#define main_color_dark_darkgray [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1.0]

#define main_color_dark_middlegray [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1.0]
#define main_color_dark_dark [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:1.0]

//背景色
#define dynamic_color_white dynamic_color(main_color_white, main_color_dark_black)
//标题颜色
#define dynamic_color_black dynamic_color(main_color_black, main_color_dark_gray)
//文字颜色
#define dynamic_color_gray dynamic_color(main_color_gray, main_color_dark_lightgray)
//顶层view背景色
#define dynamic_color_lightwhite dynamic_color(main_color_white, main_color_dark_darkgray)
//顶层view背景色
#define dynamic_color_lightGrayWhite dynamic_color(main_color_lightgray, main_color_dark_darkgray)
//浅色背景
#define dynamic_color_lightgray dynamic_color(main_color_lightgray, main_color_dark_middlegray)
#define dynamic_color_lightgray2 dynamic_color(main_color_lightgray, main_color_dark_dark)
//深色背景
#define dynamic_color_middlegray dynamic_color(main_color_middlegray, main_color_dark_middlegray)

//背景色
//#define dynamic_color_white main_color_white
////标题颜色
//#define dynamic_color_black main_color_black
////文字颜色
//#define dynamic_color_gray main_color_gray
////顶层view背景色
//#define dynamic_color_lightwhite main_color_white
////浅色背景
//#define dynamic_color_lightgray main_color_lightgray
////深色背景
//#define dynamic_color_middlegray main_color_middlegray

////浅色分割线
//#define dynamic_color_lightgray dynamic_cgcolor(main_color_lightgray, main_color_dark_middlegray)
////深色分割线
//#define dynamic_color_middlegray dynamic_cgcolor(main_color_middlegray, main_color_dark_middlegray)



#define gradual_color_blue @[(__bridge id)[UIColor colorWithRed:39/255.0 green:198/255.0 blue:251/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:17/255.0 green:148/255.0 blue:246/255.0 alpha:1.0].CGColor]
#define gradual_color_pink @[(__bridge id)[UIColor colorWithRed:255/255.0 green:181/255.0 blue:213/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:126/255.0 blue:171/255.0 alpha:1.0].CGColor]
#define gradual_color_black @[(__bridge id)[UIColor colorWithRed:0/255.0 green:49/255.0 blue:79/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:22/255.0 blue:39/255.0 alpha:1.0].CGColor]

//#define dynamic_gradual_color_dark_settingbg @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor]
#define dynamic_gradual_color_dark_settingbg @[(__bridge id)dynamic_color([UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0],[UIColor colorWithRed:19/255.0 green:20/255.0 blue:21/255.0 alpha:0.0]).CGColor, (__bridge id)dynamic_color([UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:19/255.0 green:20/255.0 blue:21/255.0 alpha:1.0]).CGColor]


#define main_font_big [UIFont fontWithName:@"PingFangSC-Semibold" size: 18]
#define main_font_middle [UIFont fontWithName:@"PingFangSC-Semibold" size: 16]
#define main_font_small [UIFont fontWithName:@"PingFangSC-Regular" size: 14]
#define main_font_middle_small [UIFont fontWithName:@"PingFangSC-Semibold" size: 14]

#define sub_font_big [UIFont fontWithName:@"PingFangSC-Regular" size: 14]
#define sub_font_middle [UIFont fontWithName:@"PingFangSC-Regular" size: 12]
#define sub_font_small [UIFont fontWithName:@"PingFangSC-Regular" size: 10]

#define fitFloat(a) ceil((a)*[UIScreen mainScreen].bounds.size.width/375)
#define fitIconFloat(a) ceil([UIScreen mainScreen].bounds.size.width>375?((a)*1.5):(a))

#define view_margin fitFloat(12.0)


#define LOGIN_USER_TYPE_KEY @"USER_TYPE"
#define LOGIN_USER_TYPE_TOURIST @"tourist"
#define LOGIN_USER_TYPE_NORMAL @"normal"

#define LOGIN_USER_KEY @"CURRENT_USER"
#define LOGIN_USER_ID_KEY @"CURRENT_USER_ID"
#define LOGIN_USER_TOKEN_KEY @"CURRENT_USER_TOKEN"
#define USER_MESSAGE_REGISTER_ID_KEY @"USER_MESSAGE_REGISTER_ID"

#define THLOGIN_WEIBO_CREDENTIAL_KEY @"THLOGIN_WEIBO_CREDENTIAL"
#define THLOGIN_WEIBO_USER_KEY @"THLOGIN_WEIBO_USER_CREDENTIAL"

#define THLOGIN_QQ_CREDENTIAL_KEY @"THLOGIN_QQ_CREDENTIAL"
#define THLOGIN_QQ_USER_KEY @"THLOGIN_QQ_USER_CREDENTIAL"

#define THLOGIN_WEIXIN_CREDENTIAL_KEY @"THLOGIN_WEIXIN_CREDENTIAL"
#define THLOGIN_WEIXIN_USER_KEY @"THLOGIN_WEIXIN_USER_CREDENTIAL"


#define AMAP_API_KEY @"aaa"
#define GDT_APP_ID @"aaa"
#define GDT_SLASH_AD_ID @"aaa"
#define GDT_NATIVE_AD_ID @"aaa"
#define GDT_BANNER_AD_ID @"aaa"
#define GDT_NATIVE_ARTICLE_AD_ID @"aaa"

#define QQ_APP_ID @"aaa"
#define QQ_APP_KEY @"aaa"
#define WEICHAT_APP_ID @"aaa"
#define WEICHAT_APP_SECRET @"aaa"
#define UNIVERSAL_LINK @"aaa"
#define WEIBO_APP_KEY @"aaa"
#define WEIBO_APP_SECRET @"aaa"
#define WEIBO_REDIRECT_URL @"aaa"


#define APP_ID @"1477038745"
// iOS 11 以下的评价跳转
#define APP_OPEN_EVALUATE [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", APP_ID]
// iOS 11 的评价跳转
#define APP_OPEN_EVALUATE_AFTER_IOS11 [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8&action=write-review", APP_ID]
// iOS 11 的评价跳转
#define APP_STORE_OPEN_IOS11 [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8", APP_ID]

#define qqNumber @"aaa"
#define qqKey @"aaa"
#define email @"aaa"
#endif /* UserMacro_h */
