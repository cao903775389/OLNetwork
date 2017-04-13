//
//  OLHttpChainRequestManager.swift
//  Beauty
//  操作管理有依赖关系的请求
//  Created by 逢阳曹 on 2016/12/9.
//  Copyright © 2016年 CBSi. All rights reserved.
//

import UIKit

/**
 * !@brief 依赖请求发送操作类
 *  @note 请求之间有依赖关系 在任何一个请求失败时都会中断请求的继续 通过回调告诉业务类操作失败的请求
 *  @note 在上一个请求完成后执行下一个 依添加顺序执行
 */

public class OLHttpChainRequestManager: NSObject {

    public static let sharedOLHttpChainRequestManager: OLHttpChainRequestManager = OLHttpChainRequestManager()

    //请求数组
    private var requestArray: [OLHttpChainRequest]!
    
    //MARK: - Private
    private override init() {
        super.init()
        self.requestArray = []
    }
    
    //MARK: - Public
    public func addChainRequest(request: OLHttpChainRequest) {
        requestArray.append(request)
    }
    
    internal func removeChainRequest(request: OLHttpChainRequest) {
        let index = requestArray.index(of: request)
        if index != nil && index! < requestArray.count {
            requestArray.remove(at: index!)
        }
    }
}
