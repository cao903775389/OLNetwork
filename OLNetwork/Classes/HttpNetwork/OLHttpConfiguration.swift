//
//  OLHttpConfiguration.swift
//  BeautyHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/19.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import UIKit
//请求服务器地址
public enum OLHttpRequestMode {
    case Release//正式环境
    case Debug//测试环境
}

//请求的基础配置类
public class OLHttpConfiguration: NSObject {

    /**
     * !@brief 单例方法
     *  @note HttpRequest基础配置类
     */
    public static let sharedOLHttpConfiguration: OLHttpConfiguration = OLHttpConfiguration()
    
    //用户id
    public var userId: Int?
    
    //是否url开启打印开关
    public var debugLogEnabled: Bool!
    
    //是否是DEBUG模式
    public var requestMode: OLHttpRequestMode!
    
    //MARK: Private
    private override init() {
        super.init()
        self.debugLogEnabled = true
        self.requestMode = OLHttpRequestMode.Debug
        
    }
}
