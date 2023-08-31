//
//  ArticleModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModel


+(ArticleModel*)createFakeModel{
    int i = arc4random() % 5 ;
    ArticleModel *article = [ArticleModel new];
    article.identifyCode = @"aaaa";
    article.title = @"开往未来的地铁 - 地铁6号线去上海自贸区买遍全球所有商品哈哈哈哈哈这是不可能的";
    article.summary = @"为庆祝新中国成立70周年，上海人民广播电台携手上海地铁，从9月2日起6号线将增加班次，沿线的广大乘客将享受利好";
    article.publishTime = @"2018-10-02 12:01:23";
    article.homeImage = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1570440022396&di=ecc51d8b8950d5638885d549551018cb&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170605%2Fced5f249cbd94e119659a1bd8b83fca0_th.jpg";
    article.likedSum = 291;
    article.commentedSum = 28;
    if(i==0){
        article.title = @"揭秘常州地铁1号线运营的“大脑”";
        article.summary = @"地铁列车穿梭在城市地下，往返运行。作为大运量的城市快速交通体系，即将正式开通的地铁1号线将给市民的出···带来便捷。你知道这个庞大、复杂、精密的地铁系统是怎样做到协调运作的吗？是谁在指挥列";
    }else if(i==1){
        article.title = @"厉害了成都,9年内开通6条地铁,连续4年新一线城市排名榜首";
        article.summary = @"作为城市中最为明显而标致的现代交通之一的地铁，不仅是人们出行不可缺少的交通工具之一，也是体现一座城市的发展程度，在1993年开通的上海地铁为中国乃至世界上规模最大、线路最长的地铁系统，到现在我国建有地铁的城市也才有39个，出去北上广深一线城市，这个城市可谓是中国“发展最快”的都市，9年内开通6条地铁，连续4年新一线城市排名榜首！";
    }
    return article;
}
@end
