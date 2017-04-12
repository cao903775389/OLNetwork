//
//  OLHttpConfiguration.swift
//  BeautyHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/19.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import UIKit

//请求服务器地址
enum OLHttpRequestMode {
    case Release//正式环境
    case Debug//测试环境
}

//请求的基础配置类
class OLHttpConfiguration: NSObject {

    /**
     * !@brief 单例方法
     *  @note HttpRequest基础配置类
     */
    internal static let sharedOLHttpConfiguration: OLHttpConfiguration = OLHttpConfiguration()
    
    //是否url开启打印开关
    var debugLogEnabled: Bool!
    
    //是否是DEBUG模式
    var requestMode: enumOnlineMode!
    
    //MARK: Private
    private override init() {
        super.init()
        self.debugLogEnabled = true
        self.requestMode = enumOnlineMode.DevMode
    }
}
