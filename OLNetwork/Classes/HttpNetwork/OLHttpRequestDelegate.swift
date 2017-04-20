//
//  OLHttpRequestDelegate.swift
//  BeautyHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/19.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import Foundation

//请求回调代理
public protocol OLHttpRequestDelegate: class {
    
    //请求完成
    func ol_requestFinished(request: OLHttpRequest)
    
    //请求失败
    func ol_requestFailed(request: OLHttpRequest)
}
extension OLHttpRequestDelegate {
    func ol_requestFinished(request: OLHttpRequest) {}
    
    //请求失败
    func ol_requestFailed(request: OLHttpRequest) {}
}

//请求附件配置
protocol OLHttpRequestAccessory: class {
    
    //自定义参数
    func ol_requestCustomArgument(requestArgument: [String: Any]?) -> [String: Any]?
    
    //自定义header参数
    func ol_requestCustomHTTPHeaderfileds(headerfileds: [String: Any]?) -> [String: Any]?
    
    //自定义Response数据校验
    func ol_requestCustomJSONValidator() -> Bool
}
extension OLHttpRequestAccessory {
    
    func ol_requestCustomArgument(requestArgument: [String: Any]?) -> [String: Any]? {
        return nil
    }
    func ol_requestCustomHTTPHeaderfileds(headerfileds: [String: Any]?) -> [String: Any]? {
        return nil
    }
    func ol_requestCustomJSONValidator() -> Bool {
        return false
    }
}
