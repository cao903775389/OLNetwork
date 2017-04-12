//
//  OLHttpRequest.swift
//  BeautyHttpNetwork
//  网络请求信息体封装
//  Created by 逢阳曹 on 2016/10/18.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import UIKit
import Foundation

//网络请求方式
enum OLHttpMethod: UInt {
    case GET = 0
    case POST = 1
    case UPLOAD = 2
    case DOWNLOAD = 3
}

//请求发起序列化方式
enum OLHttpRequestSerializerType: Int {
    case HTTP
    case JSON
}

//请求响应序列化方式
enum OLHttpResponseSerializerType: Int {
    case HTTP
    case JSON
    case XML
}

//请求结果校验
enum OLHttpRequestValidationError: Int {
    case InvalidStatusCode = -10000//URLResponse状态码异常
    case InvalidJSONFormat = -10001//JSON数据验证异常
    case InvalidErrorCode  = -10002//服务器ErrorCode异常
}

//ErrorDimain
let OLHttpRequestValidationErrorDomain = "com.ol.request.validation"

//网络请求信息包装类
class OLHttpRequest: NSObject, OLHttpRequestAccessory {
    
    /**
     * !@brief 请求体相关
     */
    //NSURLSessionTask 实际请求的发起类 (iOS7之后NSURLConnection的替代)
    var requestTask: NSURLSessionTask?
    
    //请求url
    var requestUrl: String!
    
    //请求参数
    var requestArgument: [String: AnyObject]?
    
    //请求头信息
    var requestHeaders: [String: AnyObject]?
    
    //请求附加信息 不传默认为空
    var requestUserInfo: [String: AnyObject]?
    
    //流文件上传请求回调(图片 视频 表单 等流文件上传时使用)
    var constructingBlock: ((AFMultipartFormData) -> Void)?
    
    //流文件下载请求目标路径(仅在使用断点续传下载请求时使用)
    var resumableDownloadPath: String?
    
    //请求的接口号
    var requestCode: OLCode!
    
    //请求超时时间
    var requestTimeoutInterval: NSTimeInterval!
    
    //请求发起序列化方式
    var requestSerializerType: OLHttpRequestSerializerType!
    
    //请求响应序列化方式
    var responseSerializerType: OLHttpResponseSerializerType!
    
    //请求签名认证的用户名和密码(在某些情况下需要 如登录 注册)
    var requestAuthorizationHeaderFieldArray: [String]?
    
    //请求方式
    var requestMethod: OLHttpMethod!
    
    /**
     * !@brief 返回体相关
     */
    //请求返回体
    var response: NSHTTPURLResponse? {
        get {
            return self.requestTask?.response as? NSHTTPURLResponse
        }
    }
    
    //返回体头信息
    var responseHeaders: NSDictionary? {
        get {
            return self.response?.allHeaderFields as NSDictionary?
        }
    }
    
    //返回体状态码
    var statusCode: Int? {
        get {
            return self.response?.statusCode
        }
    }
    
    //服务器错误码
    var errorCode: Int?
    
    //服务器错误信息
    var errorMsg: String?
    
    //返回体JSON对象(JSON数据 如果是下载任务 那么该值返回的是文件下载成功后被保存的URL路径)
    var responseObject: AnyObject?
    
    //请求完成回调
    weak var delegate: OLHttpRequestDelegate?
    
    //MARK: initialize
    //普通请求(POST GET)
    convenience init(delegate: OLHttpRequestDelegate?,
                            requestMethod: OLHttpMethod = OLHttpMethod.POST,
                            requestUrl: String,
                            requestArgument: [String: AnyObject]?,
                            OL_CODE: OLCode) {
        
        self.init(delegate: delegate, requestMethod: requestMethod, requestUrl: requestUrl, requestArgument: requestArgument, requestHeaders: nil, OL_CODE: OL_CODE, requestSerializerType: OLHttpRequestSerializerType.HTTP, responseSerializerType: OLHttpResponseSerializerType.JSON, requestTimeoutInterval: 30, requestAuthorizationHeaderFieldArray: nil, constructingBlock: nil, resumableDownloadPath: nil)
    }
    
    //上传请求(UPLOAD)
    convenience init(delegate: OLHttpRequestDelegate?,
                            requestMethod: OLHttpMethod = OLHttpMethod.UPLOAD,
                            requestUrl: String,
                            requestArgument: [String: AnyObject]?,
                            constructingBlock: (AFMultipartFormData) -> Void,
                            OL_CODE: OLCode) {
        
        self.init(delegate: delegate, requestMethod: requestMethod, requestUrl: requestUrl, requestArgument: requestArgument, requestHeaders: nil, OL_CODE: OL_CODE, requestSerializerType: OLHttpRequestSerializerType.HTTP, responseSerializerType: OLHttpResponseSerializerType.JSON, requestTimeoutInterval: 30, requestAuthorizationHeaderFieldArray: nil, constructingBlock: constructingBlock, resumableDownloadPath: nil)
    }
    
    //下载请求(DOWMLOAD)
    convenience init(delegate: OLHttpRequestDelegate?,
                            requestMethod: OLHttpMethod = OLHttpMethod.DOWNLOAD,
                            requestUrl: String,
                            requestArgument: [String: AnyObject]?,
                            resumableDownloadPath: String,
                            OL_CODE: OLCode) {
        
        self.init(delegate: delegate, requestMethod: requestMethod, requestUrl: requestUrl, requestArgument: requestArgument, requestHeaders: nil, OL_CODE: OL_CODE, requestSerializerType: OLHttpRequestSerializerType.HTTP, responseSerializerType: OLHttpResponseSerializerType.JSON, requestTimeoutInterval: 30, requestAuthorizationHeaderFieldArray: nil, constructingBlock: nil, resumableDownloadPath: resumableDownloadPath)
    }
    
    //MARK: Public
    func start() {
        OLHttpRequestManager.sharedOLHttpRequestManager.sendHttpRequest(self)
    }
    
    func cancleDelegateAndRequest() {
        self.delegate = nil
        OLHttpRequestManager.sharedOLHttpRequestManager.cancleHttpRequest(self)
    }
    
    //MARK: - OLHttpRequestAccessory
    func ol_requestCustomArgument(requestArgument: [String : AnyObject]?) -> [String: AnyObject]? {
        //子类overload此方法实现参数自定义
        return nil
    }
    
    func ol_requestCustomHTTPHeaderfileds(headerfileds: [String : AnyObject]?) -> [String : AnyObject]? {
        //子类overload此方法实现header头信息自定义
        return nil
    }
    
    func ol_requestCustomJSONValidator() -> Bool {
        //子类overload此方法实现ResponseJSON格式校验
        return true
    }
    
    //MARK: Private
    override init() {
        super.init()
        self.setUp()
    }
    
    //如果需要自定义更多内容可以使用该方法
    convenience init(delegate: OLHttpRequestDelegate?,
                             requestMethod: OLHttpMethod = OLHttpMethod.POST,
                             requestUrl: String,
                             requestArgument: [String: AnyObject]?,
                             requestHeaders: [String: AnyObject]?,
                             OL_CODE: OLCode,
                             requestSerializerType: OLHttpRequestSerializerType = OLHttpRequestSerializerType.HTTP,
                             responseSerializerType: OLHttpResponseSerializerType = OLHttpResponseSerializerType.JSON,
                             requestTimeoutInterval: NSTimeInterval = 30,
                             requestAuthorizationHeaderFieldArray: [String]?,
                             constructingBlock: ((AFMultipartFormData) -> Void)?,
                             resumableDownloadPath: String?) {
        
        self.init()
        self.delegate = delegate
        
        self.requestUrl = requestUrl
        self.requestCode = OL_CODE
        self.requestArgument = self.ol_requestCustomArgument(requestArgument)
        self.requestAuthorizationHeaderFieldArray = requestAuthorizationHeaderFieldArray
        self.constructingBlock = constructingBlock
        self.resumableDownloadPath = resumableDownloadPath
        
        self.requestSerializerType = requestSerializerType
        self.responseSerializerType = responseSerializerType
        self.requestTimeoutInterval = requestTimeoutInterval
        self.requestMethod = requestMethod
        self.requestHeaders = self.ol_requestCustomHTTPHeaderfileds(requestHeaders)
    }
    
    private func setUp() {
        self.requestSerializerType = OLHttpRequestSerializerType.HTTP
        self.responseSerializerType = OLHttpResponseSerializerType.JSON
        self.requestTimeoutInterval = 30
        self.requestMethod = OLHttpMethod.POST
    }

}
