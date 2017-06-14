//
//  BeautyHttpConstant.swift
//  OLHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/25.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import Foundation
//签名key
internal let SignKey = "4eA59fEF705f449e-"

//加密key
internal let Md5Key  = "j6mR(b+IF)#6z-La"

//M_API地址
public enum MAPIURL: String {
    case V100 = "https://app.onlylady.com/mapi/beauty/v100/"
    case V110 = "https://app.onlylady.com/mapi/beauty/v110/"
    case V130 = "https://app.onlylady.com/mapi/beauty/v130/"
    case V150 = "https://app.onlylady.com/mapi/beauty/v150/"
}

//M_Server
public let MServerURL: String = "https://app.onlylady.com/mserver/index.php"

//请求号
public enum OLCode: Int {
    
    /**
     * !@brief App 启动相关
     */
    case OL_AppRegisterDeviceInfo = 1011//APP上传用户设备信息
    case OL_AppRegisterDeviceToken = 1015//APP上传用户token
    case OL_AppPushStatics = 1207//APP推送打开数统计
    
    /**
     * !@brief App 广告相关
     */
    case OL_ADAppStart = 1106//APP开屏、发现页首页广告
    case OL_ADHomeBanner = 2009//APP首页顶部通栏广告
    
    /**
     * !@brief 首页
     */
    case OL_HomePageFocusList = 1001//首页焦点图数据
    case OL_HomePageLatestList = 2001//首页最新栏目列表数据
    case OL_HomePageAppVersionCheck = 1310//首页App版本更新检测
    case OL_HomeChannelArticleList = 1005//首页频道分类文章列表
    
    /**
     * !@brief 栏目频道页
     */
    case OL_ColumnArticleList = 2008//手工块栏目(文章或直播列表)
    
    /**
     * !@brief 发现页
     */
    case OL_DiscoverHomePage = 2006//获取发现页数据
    
    /**
     * !@brief 广场帖子页
     */
    case OL_TopicPublish = 2101//帖子发布
    case OL_TopicHotList = 2102//广场首页热门帖子列表
    case OL_TopicLatestList = 2103//广场首页最新帖子列表
    case OL_TopicPraiseOrCancle = 2104//帖子点赞、取消点赞
    case OL_TopicPostComment = 2107//发表帖子评论
    case OL_TopicDetail = 2114//帖子详情
    case OL_TopicCommentPraiseOrCancle = 2109//帖子评论点赞、取消点赞
    case OL_TopicNoticeInfomation = 2116//帖子公告信息
    case OL_TopicHotTagList = 2201//帖子热门标签
    case OL_TopicTagCategoryList = 2202//标签对应的帖子列表
    
    /**
     * !@brief 直播
     */
    case OL_LiveDetail = 1019//获取直播详情
    case OL_LiveReplyChatMessage = 1401//获取直播回放聊天数据
    case OL_LiveAppointment = 1016//直播预约
    case OL_LiveCancleAppointment = 1026//取消直播预约
    case OL_LiveStart = 1103//开始直播
    case OL_LiveStop = 1104//停止直播
    case OL_LiveFollow = 2002//追直播直播列表数据
    case OL_LiveWatchVideo = 2003//看视频直播回放列表数据
    case OL_LiveFollowColumns = 2004//追直播栏目对应的直播列表数据
    case OL_LiveWatchVideoColumns = 2005//看视频栏目对应的直播回放列表数据
    case OL_LiveColumnListInfo = 2007//追直播或看视频直播栏目分类信息
    case OL_LiveSuspend = 2210 // 暂停直播
    
    /**
     * !@brief 文章
     */
    case OL_ArticleDetail = 1017//获取文章详情
    case OL_ArticleLike = 1205//文章点赞或取消点赞
    case OL_ArticleUploadComment = 1020//发表对文章的评论
    case OL_ArticleMoreRelevantList = 1907//产品相关文章列表
    
    /**
     * !@brief 搜索页
     */
    case OL_SearchHotList = 1705//热门搜索列表
    case OL_SearchProductList = 1706//产品 关键字搜索
    case OL_SearchArticleList = 1707//文章 关键字搜索
    case OL_SearchLiveList = 2117//直播 关键字搜索
    
    
    /**
     * !@brief 活动页
     */
    case OL_ActivityList = 1802//活动列表
    case OL_ActivityUploadComment = 1803//活动评论内容上传提交
    
    /**
     * !@breif 图片上传(试用报告图片 活动图片)
     */
    case OL_ImageUpload = 1804//图片上传(试用报告 活动评论)
    
    /**
     * !@brief 试用
     */
    case OL_TrialList = 1301//试用列表
    case OL_TrialUserAppliedList = 1302//用户申请过的试用列表
    case OL_TrialSubmitApplication = 1305//提交试用申请
    case OL_TrialSubmitReport = 1801//提交试用报告
    case OL_TrialDetail = 1303//试用详情
    case OL_TrialReportList = 1309//试用报告列表
    case OL_TrialUserAllTrialList = 2221//用户申请过的试用列表
    case OL_TrialUserSucceedTrialList = 2222//用户申请成功试用列表
    
    /**
     * !@brief 专家达人
     */
    case OL_ExpertDetail = 1904//获取专家达人详情信息
    case OL_ExpertUserList = 1501//获取专家达人用户列表
    case OL_ExpertArticleList = 1503//获取专家达人文章列表
    case OL_ExpertLiveList = 1504//获取专家达人直播列表
    
    /**
     * !@brief 产品库
     */
    case OL_ProductCommentList = 1307//产品点评列表
    case OL_ProductCommentDetail = 1308//产品点评详情
    case OL_ProductDetailInfo = 1601//产品详情
    case OL_ProductCategoryList = 1701//产品库二级三级分类列表
    case OL_ProductList = 1702//品牌分类下对应的产品列表
    case OL_ProductRankList = 1708//产品库榜单列表
    case OL_ProductRankMoreProductList = 1709//产品库榜单产品列表更多分页数据(榜单H5加载更多使用)
    case OL_ProductHomeFocus = 1710//产品库首页焦点图数据
    case OL_ProductMoreRelevantList = 1908//文章相关的产品列表
    
    /**
     * !@brief 用户收藏中心
     */
    case OL_UserCollection = 1201//用户收藏文章
    case OL_UserDeleteCollection = 1202//用户删除收藏内容
    case OL_UserCollectionList = 1203//用户收藏列表
    
    /**
     * !@brief 用户个人资料
     */
    case OL_UserUploadAvatar = 1204//修改用户头像
    case OL_UserInfo = 1806//获取用户信息
    case OL_UserModifyInfomation = 1905//用户修改个人信息(昵称, 性别)
    case OL_UserModifyAddress = 1906//用户修改收货地址
    case OL_UserAddress = 1304//获取用户收货地址
    case OL_UserGetShareInfo = 2220 // 获取分享信息 邀请好友
    
    /**
     * !@brief 用户消息中心
     */
    case OL_MessageCenterList = 1821//消息中心列表
    case OL_MessageCenterReadStatus = 1823//消息中心列表读取状态
    
    /**
     * !@brief 用户关注中心
     */
    case OL_FollowCenterUserMessageList = 1901//关注中心 关注用户发布的动态列表
    case OL_FollowCenterUserAttentionOrCancle = 1902//关注中心 关注或取消关注某个用户
    case OL_FollowCenterUserList = 1903//关注中心 关注用户列表
    case OL_FansCenterUserList = 2113//关注中心 粉丝列表
    
    /**
     * !@brief 用户通知中心
     */
    case OL_NotificationCenterList = 1909//通知中心消息列表
    
    /**
     * !@brief 用户直播中心
     */
    case OL_UserCreateLive = 1101//用户创建直播
    case OL_UserChangeLive = 1102//用户修改直播
    case OL_UserLiveList = 1105//用户直播列表
    case OL_UserDeleteLive = 1107//用户删除创建的直播或回放
    
    /**
     * !@brief 用户帖子中心
     */
    case OL_UserTopicPublishedList = 2105//用户发布的帖子列表
    case OL_UserTopicDelete = 2106//用户删除发布的帖子
    case OL_UserTopicReport = 2112//用户举报他人发布的帖子
    
    /**
     * !@breif 用户反馈
     */
    case OL_FeekBack = 2223//提交反馈
    case OL_FeekBackList = 2224 //反馈列表
    
    /**
     * !@brief 用户登录
     */
    case OL_LoginSendAuthCode = 1012//手机登录获取验证码
    case OL_LoginMobile = 1013//手机号登录
    case OL_LoginBindStatus = 1007//第三方帐号绑定状态
    case OL_LoginBindQQ = 1008//第三方帐号绑定QQ
    case OL_LoginBindSina = 1009//第三方帐号绑定新浪
    case OL_LoginBindWX = 1010//第三方帐号绑定微信
    
    /**
     * !@brief 分享
     */
    case OL_ShareInfo = 1704//获取分享信息
}
