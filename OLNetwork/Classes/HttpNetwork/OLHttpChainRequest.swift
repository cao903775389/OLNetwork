//
//  OLHttpChainRequest.swift
//  Beauty
//  带有依赖的请求
//  Created by 逢阳曹 on 2016/12/9.
//  Copyright © 2016年 CBSi. All rights reserved.
//

import UIKit

@objc protocol OLHttpChainRequestDelegate {
    
    //请求发送成功
    optional
    func ol_chainRequestFinished(request: OLHttpChainRequest)
    
    //请求发送失败
    optional
    func ol_chainRequestFailed(request: OLHttpChainRequest, failedRequest: OLHttpRequest)
}

//请求回调
typealias OLHttpChainCallBack = @convention(block) (OLHttpChainRequest, OLHttpRequest) -> Void

class OLHttpChainRequest: NSObject, OLHttpRequestDelegate {

    //delegate
    weak var delegate: OLHttpChainRequestDelegate?
    
    //所有请求数组
    var requestArray: [OLHttpRequest]!
    
    //所有请求回调
    var requestCallBackArray: [OLHttpChainCallBack]!
    
    //下一个请求的索引
    private var nextRequestIndex: Int!

    //emptyCallBack
    private var emptyCallBack: OLHttpChainCallBack!
    
    //MARK: - init
    deinit {
        //取消所有请求
        self.delegate = nil
        self.stop()
    }
    
    convenience init(requestArray: [OLHttpRequest]) {
        self.init()
        self.requestArray = requestArray
    }
    
    override init() {
        super.init()
        self.requestArray = []
        self.requestCallBackArray = []
        self.nextRequestIndex = 0
        //当没有回调时使用
        self.emptyCallBack = {chainRequest, request in
            
        }
    }
    
    //MARK: - Public
    func start() {
        if nextRequestIndex > 0 {
            log.info("Error: 依赖请求已经开启! 无法再次开启!!")
            return
        }
        if requestArray.count > 0 {
            self.startNextRequest()
            OLHttpChainRequestManager.sharedOLHttpChainRequestManager.addChainRequest(self)
        }else {
            log.info("Error: 请求数组为空!!")
        }
    }
    
    func stop() {
        self.clearRequest()
        OLHttpChainRequestManager.sharedOLHttpChainRequestManager.removeChainRequest(self)
    }
    
    //需要依赖传值时调用此方法发送请求
    func addRequest(request: OLHttpRequest, callback: OLHttpChainCallBack?) {
        requestArray.append(request)
        if callback != nil {
            requestCallBackArray.append(callback!)
        }else {
            requestCallBackArray.append(self.emptyCallBack)
        }
    }
    
    //MARK: - Private
    private func startNextRequest() -> Bool {
        if nextRequestIndex < requestArray.count {
            let request = requestArray[nextRequestIndex]
            nextRequestIndex = nextRequestIndex + 1
            request.delegate = self
            OLHttpRequestManager.sharedOLHttpRequestManager.sendHttpRequest(request)
            return true
        }else {
            return false
        }
    }
    
    private func clearRequest() {
        let currentRequestIndex = nextRequestIndex - 1
        if currentRequestIndex < requestArray.count {
            let request = requestArray[currentRequestIndex]
            request.cancleDelegateAndRequest()
        }
        requestArray.removeAll()
        requestCallBackArray.removeAll()
    }
    
    //MARK: - OLHttpRequestDelegate
    func ol_requestFinished(request: OLHttpRequest) {
        let currentRequestIndex = nextRequestIndex - 1
        let callBack = requestCallBackArray[currentRequestIndex]
        callBack(self, request)
        //请求已完成
        if !self.startNextRequest() {
            self.delegate?.ol_chainRequestFinished?(self)
            OLHttpChainRequestManager.sharedOLHttpChainRequestManager.removeChainRequest(self)
        }
    }
    
    func ol_requestFailed(request: OLHttpRequest) {
        self.delegate?.ol_chainRequestFailed?(self, failedRequest: request)
        OLHttpChainRequestManager.sharedOLHttpChainRequestManager.removeChainRequest(self)
    }
}
