//
//  OLHttpRequestDelegate.swift
//  BeautyHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/19.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import Foundation

//请求回调代理
@objc public protocol OLHttpRequestDelegate {
    
    //请求完成
    @objc optional
    func ol_requestFinished(request: OLHttpRequest) -> Void
    
    //请求失败
    @objc optional
    func ol_requestFailed(request: OLHttpRequest) -> Void
}

//请求附件配置
@objc protocol OLHttpRequestAccessory {
    
    //自定义参数
    @objc optional
    func ol_requestCustomArgument(requestArgument: [String: AnyObject]?) -> [String: AnyObject]?
    
    //自定义header参数
    @objc optional
    func ol_requestCustomHTTPHeaderfileds(headerfileds: [String: AnyObject]?) -> [String: AnyObject]?
    
    //自定义Response数据校验
    @objc optional
    func ol_requestCustomJSONValidator() -> Bool
}
