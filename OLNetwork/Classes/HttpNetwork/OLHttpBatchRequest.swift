//
//  OLHttpBatchRequest.swift
//  Beauty
//
//  Created by 逢阳曹 on 2016/12/9.
//  Copyright © 2016年 CBSi. All rights reserved.
//

import UIKit
@objc public protocol OLHttpBatchRequestDelegate {
    
    //请求发送成功
    @objc optional
    func ol_batchRequestFinished(request: OLHttpBatchRequest)
    
    //请求发送失败
    @objc optional
    func ol_batchRequestFailed(request: OLHttpBatchRequest)
}

/**
 * !@brief 批量并发请求类
 *  @note 请求之间没有依赖关系 在任何一个请求失败时都会中断请求的继续 通过回调告诉业务类操作失败的请求
 */

public class OLHttpBatchRequest: NSObject, OLHttpRequestDelegate {
    
    //所有请求
    public var requestArray: [OLHttpRequest]!
    
    //delegate
    public weak var delegate: OLHttpBatchRequestDelegate?
    
    //请求标识tag
    private var tag: Int?
    
    //失败的请求
    public var failedRequest: OLHttpRequest?
    
    //完成数
    private var finishedCount: Int!
    
    deinit {
        self.stop()
    }
    
    //MARK: - init
    required convenience public init(requestArray: [OLHttpRequest]) {
        self.init()
        self.requestArray = requestArray
        self.finishedCount = 0
    }
    
    //MARK: - Public
    public func start() {
        if finishedCount > 0 {
            print("Error: 请求已经开始! 无法再次开启")
            return
        }
        failedRequest = nil
        OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.addBatchRequest(request: self)
        for req in requestArray {
            req.delegate = self
            OLHttpRequestManager.sharedOLHttpRequestManager.sendHttpRequest(request: req)
        }
    }
    
    public func stop() {
        self.delegate = nil
        self.clearRequest()
        OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.removeBatchRequest(request: self)
    }
    
    //MARK: - Private
    public func clearRequest() {
        for req in requestArray {
            req.cancleDelegateAndRequest()
        }
    }
    
    //MARK: - OLHttpRequestDelegate
    public func ol_requestFinished(request: OLHttpRequest) {
        finishedCount = finishedCount + 1
        //请求完成
        if finishedCount == requestArray.count {
            self.delegate?.ol_batchRequestFinished?(request: self)
            OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.removeBatchRequest(request: self)
            print("\(self): 请求完成!")
        }
    }
    
    public func ol_requestFailed(request: OLHttpRequest) {
        failedRequest = request
        self.clearRequest()
        self.delegate?.ol_batchRequestFailed?(request: self)
        OLHttpBatchRequestManager.sharedOLHttpBatchRequestManager.removeBatchRequest(request: self)
    }
}
