//
//  OLHttpRequestManager.swift
//  BeautyHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/18.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import UIKit

//网络连接池
class OLHttpRequestManager: NSObject {

    /**
     * !@brief 单例方法
     *  @note 网络连接池
     */
    static let sharedOLHttpRequestManager: OLHttpRequestManager = OLHttpRequestManager()
    
    //AFHTTPSessionManager
    private var manager: AFHTTPSessionManager!
    
    //请求配置信息
    private var requestConfig: OLHttpConfiguration!
    
    //请求缓存池
    private var requestRecord: [NSNumber: OLHttpRequest]!
    
    //AFJSONResponseSerializer
    private lazy var jsonResponseSerializer: AFJSONResponseSerializer = {
        let json = AFJSONResponseSerializer()
        json.acceptableContentTypes = Set(["application/json", "text/json", "text/javascript","text/html", "application/x-javascript"])
        return json
    }()
    
    //AFXMLResponseSerializer
    private lazy var xmlResponseSerializer: AFXMLParserResponseSerializer = {
        let xml = AFXMLParserResponseSerializer()
        xml.acceptableContentTypes = Set(["application/json", "text/json", "text/javascript","text/html", "application/x-javascript"])
        return xml
    }()
    
    //MARK: - 发送请求
    //发起普通请求
    func sendHttpRequest(request: OLHttpRequest) {
        self.sendHttpRequest(request, uploadProgressBlock: nil, downloadProgressBlock: nil)
    }
    
    //发起带有上传进度回调的请求
    func sendHttpRequest(request: OLHttpRequest, uploadProgressBlock: ((NSProgress) -> Void)) {
        self.sendHttpRequest(request, uploadProgressBlock: uploadProgressBlock, downloadProgressBlock: nil)
    }
    
    //发起带有下载进度回调的请求
    func sendHttpRequest(request: OLHttpRequest, downloadProgressBlock: ((NSProgress) -> Void)?) {
        self.sendHttpRequest(request, uploadProgressBlock: nil, downloadProgressBlock: downloadProgressBlock)
    }
    
    //取消某个请求
    func cancleHttpRequest(request: OLHttpRequest?) {
        
        guard request?.requestTask != nil else { return }
        if self.requestRecord[NSNumber(integerLiteral: request!.requestTask!.taskIdentifier)] != nil {
            if request!.requestTask?.state == NSURLSessionTaskState.Running {
                log.info("========请求已取消: \(request!.requestCode)========")
                request!.requestTask?.cancel()
                self.removeRequestFromPool(request!)
            }
        }
    }
    
    //取消所有请求
    func cancleAllHttpRequests() {
        let allKeys = self.requestRecord.keys
        if allKeys.count > 0 {
            let copiedKeys = allKeys
            for key in copiedKeys {
                let request = self.requestRecord[key]
                request?.cancleDelegateAndRequest()
            }
        }
    }
    
    //MARK: Private
    private override init() {
        super.init()
        self.requestConfig = OLHttpConfiguration.sharedOLHttpConfiguration
        self.manager = AFHTTPSessionManager(baseURL: nil)
        //给定一个默认的解析方式
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        self.manager.responseSerializer.acceptableContentTypes = Set( ["application/json", "text/json", "text/javascript","text/html", "application/x-javascript"])
        self.requestRecord = [:]
    }
    
    //添加请求到缓存池
    private func addRequestToPool(request: OLHttpRequest) {
        if request.requestTask != nil {
            self.requestRecord[NSNumber(integerLiteral: request.requestTask!.taskIdentifier)] = request
        }
    }
    
    //移除请求出缓存池
    private func removeRequestFromPool(request: OLHttpRequest) {
        self.requestRecord.removeValueForKey(NSNumber(integerLiteral: request.requestTask!.taskIdentifier))
    }
    
    //请求状态码校验
    private func ol_validateResult(request: OLHttpRequest) -> (Bool, NSError?) {
        
        var result = OLHttpUtils.ol_statusCodeValidator(request.statusCode!)
        if !result {
            return (result, NSError(domain: OLHttpRequestValidationErrorDomain, code: OLHttpRequestValidationError.InvalidStatusCode.rawValue, userInfo: [NSLocalizedDescriptionKey: OL_NetworkError]))
        }
        result = request.ol_requestCustomJSONValidator()
        if !result {
            return (result, NSError(domain: OLHttpRequestValidationErrorDomain, code: request.errorCode!, userInfo: [NSLocalizedDescriptionKey: request.errorMsg == nil ? OL_ServerError : request.errorMsg!]))
        }
        return (true, nil)
    }
    
    //HTTPStatusCode异常处理
    private func handleResponseErrorCode(errorCode: Int) -> NSError {
        
        var responseError: NSError?
        if errorCode == NSURLErrorNotConnectedToInternet {
            //网络不可用
            responseError = NSError(domain: OLHttpRequestValidationErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: OL_NetworkErrorNotConnectedToInternet])
        }else if errorCode == NSURLErrorTimedOut {
            //网络请求超时
            responseError = NSError(domain: OLHttpRequestValidationErrorDomain, code: NSURLErrorTimedOut, userInfo: [NSLocalizedDescriptionKey: OL_NetworkErrorTimedOut])
        }else {
            //其他错误
            responseError = NSError(domain: OLHttpRequestValidationErrorDomain, code: OLHttpRequestValidationError.InvalidStatusCode.rawValue, userInfo: [NSLocalizedDescriptionKey: OL_NetworkError])
        }
        return responseError!
    }
    
    //MARK: 请求发起相关
    private func sendHttpRequest(request: OLHttpRequest, uploadProgressBlock: ((NSProgress) -> Void)?, downloadProgressBlock: ((NSProgress) -> Void)?) {
        
        var requestSerializationError: NSError?
        request.requestTask = self.sessionTaskForRequest(request, uploadProgressBlock: uploadProgressBlock, downloadProgressBlock: downloadProgressBlock ,error: &requestSerializationError)
        if requestSerializationError != nil {
            //请求失败
            return
        }
        
        log.info("\n========\n========开始请求: url = \(request.requestUrl!)\n========请求模式: \(OLHttpConfiguration.sharedOLHttpConfiguration.requestMode!)\n========接口号: \(request.requestCode!.rawValue)\n========请求参数: \(request.requestArgument)\n========")
        //添加请求到缓存池
        self.addRequestToPool(request)
        request.requestTask?.resume()
    }
    
    //创建URLSessionTask会话
    private func sessionTaskForRequest(request: OLHttpRequest, uploadProgressBlock: ((NSProgress) -> Void)?, downloadProgressBlock: ((NSProgress) -> Void)?, error: NSErrorPointer) -> NSURLSessionTask {
        
        let url = request.requestUrl!
        let method = request.requestMethod!
        let requestSerializer = self.requestSerializerForRequest(request)
        let param = request.requestArgument
        
        switch method {
            case .GET:
                return self.dataTaskWithHTTPMethod("GET", requestSerializer: requestSerializer, URLString: url, parameters: param, error: error)
            case .POST:
                return self.dataTaskWithHTTPMethod("POST", requestSerializer: requestSerializer, URLString: url, parameters: param, error: error)
            case .UPLOAD:
                return self.dataTaskWithHTTPMethod("POST", requestSerializer: requestSerializer, URLString: url, parameters: param, constructingBodyBlock: request.constructingBlock, uploadProgress: uploadProgressBlock, error: error)
            case .DOWNLOAD:
                return self.downloadTaskWithDownloadPath(request.resumableDownloadPath!, requestSerializer: requestSerializer, URLString: url, parameters: param, downloadProgressBlock: downloadProgressBlock, error: error)
        }
    }
    
    //MARK: -
    //NSURLSessionDataTask 普通请求
    private func dataTaskWithHTTPMethod(method: String,
                                        requestSerializer: AFHTTPRequestSerializer,
                                        URLString: String,
                                        parameters: [String: AnyObject]?,
                                        error: NSErrorPointer) -> NSURLSessionDataTask {
        
        return self.dataTaskWithHTTPMethod(method, requestSerializer: requestSerializer, URLString: URLString, parameters: parameters, constructingBodyBlock: nil, uploadProgress: nil, error: error)
    }
    
    //NSURLSessionUploadTask 上传请求
    private func dataTaskWithHTTPMethod(method: String,
                                        requestSerializer: AFHTTPRequestSerializer,
                                        URLString: String,
                                        parameters: [String: AnyObject]?,
                                        constructingBodyBlock: ((AFMultipartFormData) -> Void)?,
                                        uploadProgress: ((NSProgress) -> Void)?,
                                        error: NSErrorPointer) -> NSURLSessionDataTask {
        var request: NSURLRequest?
        if constructingBodyBlock != nil {
            request = requestSerializer.multipartFormRequestWithMethod(method, URLString: URLString, parameters: parameters, constructingBodyWithBlock: constructingBodyBlock, error: error)
        }else {
            request = requestSerializer.requestWithMethod(method, URLString: URLString, parameters: parameters, error: error)
        }
        var dataTask: NSURLSessionDataTask?
        dataTask = manager.dataTaskWithRequest(request!, uploadProgress: uploadProgress, downloadProgress: nil) { (_, responseObject, error) in
            self.handleRequestResult(dataTask!, responseObject: responseObject, error: error)
        }
        return dataTask!
    }
    
    //NSURLSessionDownloadTask  下载请求
    private func downloadTaskWithDownloadPath(downloadPath: String,
                                              requestSerializer: AFHTTPRequestSerializer,
                                              URLString: String,
                                              parameters: [String: AnyObject]?,
                                              downloadProgressBlock: ((NSProgress) -> Void)?,
                                              error: NSErrorPointer) -> NSURLSessionDownloadTask {
        
        var downloadTargetPath: String?
        let request = requestSerializer.requestWithMethod("GET", URLString: URLString, parameters: parameters, error: error)
        var isDirectory: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(downloadPath, isDirectory: &isDirectory) == false {
            isDirectory = false
        }
        
        //如果目标下载路径是一个文件夹 使用从url中获取到的最后路径名
        //确保下载的目标路径是一个文件 而不是一个文件夹
        if isDirectory.boolValue == true {
            
            let fileName = request.URL!.lastPathComponent! as String
            downloadTargetPath = NSString.pathWithComponents([downloadPath, fileName]) as String
        }else {
            downloadTargetPath = downloadPath
        }
        //判断本地是否有已下载的原始数据
        var resumeDataFileExists: Bool = false
        var data: NSData?
        let filePath = OLHttpUtils.incompletedDownloadTempPathForDownloadPath(downloadPath)
        if filePath != nil {
            resumeDataFileExists = NSFileManager.defaultManager().fileExistsAtPath(filePath!.path!)
            data = NSData(contentsOfURL: filePath!)
        }

        //判断已下载原始数据是否失效
        let resumeDataIsValid = OLHttpUtils.validateResumeData(data)
        
        //判断此下载任务是否可以被重新唤起
        let canBeResumed: Bool = resumeDataFileExists && resumeDataIsValid
        
        var downloadTask: NSURLSessionDownloadTask?
        if canBeResumed {
            
            downloadTask = manager.downloadTaskWithResumeData(data!, progress: downloadProgressBlock, destination: { (targetPathURL, response) -> NSURL in
                  return NSURL(fileURLWithPath: downloadTargetPath!, isDirectory: false)
                
                }, completionHandler: { (response, filePathURL, error) in
                  self.handleRequestResult(downloadTask!, responseObject: filePathURL as AnyObject?, error: error)
            })
        }else {
            downloadTask = manager.downloadTaskWithRequest(request, progress: downloadProgressBlock, destination: { (targetPathURL, response) -> NSURL in
                return NSURL(fileURLWithPath: downloadTargetPath!, isDirectory: false)
                
                }, completionHandler: { (response, filePathURL, error) in
                    self.handleRequestResult(downloadTask!, responseObject: filePathURL as AnyObject?, error: error)
            })
        }
        return downloadTask!
    }
    
    //获取请求的序列化方式
    private func requestSerializerForRequest(request: OLHttpRequest) -> AFHTTPRequestSerializer {
        var requestSerializer: AFHTTPRequestSerializer?
        switch request.requestSerializerType! {
            case .HTTP:
                requestSerializer = AFHTTPRequestSerializer()
            case .JSON:
                requestSerializer = AFJSONRequestSerializer()
        }
        requestSerializer!.timeoutInterval = request.requestTimeoutInterval
        
        //如果服务器请求需要用户名和密码进行认证操作
        let authorizationHeaderFieldArray = request.requestAuthorizationHeaderFieldArray
        if authorizationHeaderFieldArray != nil && authorizationHeaderFieldArray!.count > 2 {
            requestSerializer?.setAuthorizationHeaderFieldWithUsername(authorizationHeaderFieldArray!.first!, password: authorizationHeaderFieldArray!.last!)
        }
        
        //如果服务器请求需要自定义HTTPHeaderField
        let headerFieldValueDictionary = request.requestHeaders
        if headerFieldValueDictionary != nil {
            for httpHeaderFieldKey in headerFieldValueDictionary!.keys {
                let httpHeaderFieldValue = headerFieldValueDictionary![httpHeaderFieldKey] as? String
                requestSerializer?.setValue(httpHeaderFieldValue, forHTTPHeaderField: httpHeaderFieldKey)
            }
        }
        return requestSerializer!
    }
    
    //处理请求回调
    private func handleRequestResult(task: NSURLSessionTask, responseObject: AnyObject?, error: NSError?) {
        
        let request = requestRecord[NSNumber(integerLiteral: task.taskIdentifier)]
        if request == nil {
            return
        }

        request!.responseObject = responseObject
        if error != nil {
            let responseError = self.handleResponseErrorCode(error!.code)
            self.requestDidFailWithRequest(request!, error: responseError)
            self.removeRequestFromPool(request!)
            return
        }
        
        if request?.responseObject == nil {
            self.requestDidFailWithRequest(request!, error: NSError(domain: OLHttpRequestValidationErrorDomain, code: OLHttpRequestValidationError.InvalidJSONFormat.rawValue, userInfo: [NSLocalizedDescriptionKey: OL_ServerError]))
            self.removeRequestFromPool(request!)
            return
        }
        //请求错误信息
        var requestError: NSError?
        //JSON序列化错误信息
        var serializationError: NSError?
        
        //请求成功还是失败
        var succees: Bool = false
        
        switch request!.responseSerializerType! {
        case .HTTP:
            //默认方式
            break
        case .JSON:
            
            request?.responseObject = self.jsonResponseSerializer.responseObjectForResponse(task.response, data: request!.responseObject as? NSData, error: &serializationError) as AnyObject?
            break
        case .XML:
            request?.responseObject = self.xmlResponseSerializer.responseObjectForResponse(task.response, data: request!.responseObject as? NSData, error: &serializationError) as AnyObject?
            break
        }
        
        if serializationError != nil {
            succees = false
            requestError = NSError(domain: OLHttpRequestValidationErrorDomain, code: OLHttpRequestValidationError.InvalidJSONFormat.rawValue, userInfo: [NSLocalizedDescriptionKey: OL_ServerError])
        }else {
            let validateResult = self.ol_validateResult(request!)
            succees = validateResult.0
            requestError = validateResult.1
        }
        
        if succees {
            self.requestDidSucceedWithRequest(request!)
        } else {
            self.requestDidFailWithRequest(request!, error: requestError!)
        }
        self.removeRequestFromPool(request!)
    }
    
    //MARK: - 请求回调
    private func requestDidFailWithRequest(request: OLHttpRequest, error: NSError) {
        
        request.errorCode = error.code
        request.errorMsg = error.userInfo[NSLocalizedDescriptionKey] as? String
        log.info("\n========\n========请求失败: url = \(request.requestUrl!)\n========请求模式: \(OLHttpConfiguration.sharedOLHttpConfiguration.requestMode!)\n========接口号: \(request.requestCode!.rawValue)\n========请求参数: \(request.requestArgument)\n========错误信息: \(request.errorMsg)\n========错误码: \(request.errorCode)\n========URLResponseStatusCode状态码: \(request.statusCode)\n========")
        
        let incompleteDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? NSData
        if incompleteDownloadData != nil && request.resumableDownloadPath != nil {
            let path = OLHttpUtils.incompletedDownloadTempPathForDownloadPath(request.resumableDownloadPath!)
            if path != nil {
                incompleteDownloadData?.writeToURL(path!, atomically: true)
            }
        }
        request.delegate?.ol_requestFailed?(request)
    }
    
    private func requestDidSucceedWithRequest(request: OLHttpRequest) {
        
        log.info("\n========\n========请求成功: url = \(request.requestUrl!)\n========请求模式: \(OLHttpConfiguration.sharedOLHttpConfiguration.requestMode!)\n========接口号: \(request.requestCode!.rawValue)\n========请求参数: \(request.requestArgument)\n========返回JSON: \n\(request.responseObject!.yy_modelToJSONString())\n========错误码: \(request.errorCode)\n========URLResponseStatusCode状态码: \(request.statusCode)\n========")
        request.delegate?.ol_requestFinished?(request)
    }
}
