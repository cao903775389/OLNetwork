//
//  OLHttpBatchRequest.swift
//  Beauty
//
//  Created by 逢阳曹 on 2016/12/9.
//  Copyright © 2016年 CBSi. All rights reserved.
//

import UIKit

@objc protocol OLHttpBatchRequestDelegate {
    
    //请求发送成功
    optional
    func ol_batchRequestFinished(request: OLHttpBatchRequest)
    
    //请求发送失败
    optional
    func ol_batchRequestFailed(request: OLHttpBatchRequest)
}

/**
 * !@brief 批量并发请求类
 *  @note 请求之间没有依赖关系 在任何一个请求失败时都会中断请求的继续 通过回调告诉业务类操作失败的请求
 */

class OLHttpBatchRequest: NSObject, OLHttpRequestDelegate {
    
    //所有请求
    var requestArray: [OLHttpRequest]!
    
    //delegate
    weak var delegate: OLHttpBatchRequestDelegate?
    
    //请求标识tag
    var tag: Int?
    
    //失败的请求
    var failedRequest: OLHttpRequest?
    
    //完成数
    private var finishedCount: Int!
    
    deinit {
        self.stop()
    }
    
    //MARK: - init
    required convenience init(requestArray: [OLHttpRequest]) {
        self.init()
        self.requestArray = requestArray
        self.finishedCount = 0
    }
    
    //MARK: - Public
    func start() {
        if finishedCount > 0 {
            log.info("Error: 请求已经开始! 无法再次开启")
            return
        }
        failedRequest = nil
        OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.addBatchRequest(self)
        for req in requestArray {
            req.delegate = self
            OLHttpRequestManager.sharedOLHttpRequestManager.sendHttpRequest(req)
        }
    }
    
    func stop() {
        self.delegate = nil
        self.clearRequest()
        OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.removeBatchRequest(self)
    }
    
    //MARK: - Private
    func clearRequest() {
        for req in requestArray {
            req.cancleDelegateAndRequest()
        }
    }
    
    //MARK: - OLHttpRequestDelegate
    func ol_requestFinished(request: OLHttpRequest) {
        finishedCount = finishedCount + 1
        //请求完成
        if finishedCount == requestArray.count {
            self.delegate?.ol_batchRequestFinished?(self)
            OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.removeBatchRequest(self)
            log.info("\(self): 请求完成!")
        }
    }
    
    func ol_requestFailed(request: OLHttpRequest) {
        failedRequest = request
        self.clearRequest()
        self.delegate?.ol_batchRequestFailed?(self)
        OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.removeBatchRequest(self)
    }
}
