//
//  OLHttpBatchRequestManager.swift
//  Beauty
//  批量发送请求操作类
//  Created by 逢阳曹 on 2016/12/9.
//  Copyright © 2016年 CBSi. All rights reserved.
//

import UIKit

/**
 * !@brief 批量并发请求操作类
 *  @note 请求之间没有依赖关系 在任何一个请求失败时都会中断请求的继续 通过回调告诉业务类操作失败的请求
 */

class OLHttpBatchRequestManager: NSObject {
    
    static let sharedOLHttpBatchRequestManager: OLHttpBatchRequestManager = OLHttpBatchRequestManager()
    
    //请求数组
    private var requestArray: [OLHttpBatchRequest]!
    
    //MARK: - Private
    private override init() {
        super.init()
        self.requestArray = []
    }
    
    //MARK: - Public
    //添加请求
    func addBatchRequest(request: OLHttpBatchRequest) {
        requestArray.append(request)
    }
    
    //移除请求
    func removeBatchRequest(request: OLHttpBatchRequest) {
        let index = requestArray.index(of: request)
        if index != nil && index! < requestArray.count {
            requestArray.remove(at: index!)
        }
    }
}
