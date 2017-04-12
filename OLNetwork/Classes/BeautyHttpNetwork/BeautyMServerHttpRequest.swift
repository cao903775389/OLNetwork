//
//  BeautyMServerHttpRequest.swift
//  OLHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/24.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import UIKit

//MServerURL
class BeautyMServerHttpRequest: OLHttpRequest {

    override func ol_requestCustomArgument(requestArgument: [String : AnyObject]?) -> [String : AnyObject]? {
        
        var newParams = [String: AnyObject]()
        if requestArgument != nil {
            newParams["_Request"] = requestArgument! as AnyObject
        }
        
        var header = ["_Sign": OLHttpUtils.ol_deviceIDFA(), "_ExtMsg": ""]
        
        header["olts"] = "\(NSDate().timeIntervalSince1970)"
        header["olsign"] = OLHttpUtils.ol_buildSign(newParams.map({$1}))
        
        header["OLENV"] = OLHttpUtils.ol_buildOLEnv()
        header["USERENV"] = OLHttpUtils.ol_buildUserEnv()
        
        newParams["_Header"] = header as AnyObject
        
        //加密参数
        let data = try? NSJSONSerialization.dataWithJSONObject(newParams, options: NSJSONWritingOptions.init(rawValue: 0))
        if data != nil {
            
            let result = String(data: data!, encoding: NSUTF8StringEncoding)
            //先MD5加密
            let md5Str = (result! + Md5Key).md5
            //然后sha1加密
            return ["r": result!.base64 as AnyObject, "s": md5Str!.sha1 as AnyObject]
        }else {
            return nil
        }
    }
    
    override func ol_requestCustomHTTPHeaderfileds(headerfileds: [String : AnyObject]?) -> [String : AnyObject]? {
        
        var header = [String: AnyObject]()
        if headerfileds != nil {
            header = headerfileds!
        }
        header["OLENV"] = OLHttpUtils.ol_buildOLEnv() as AnyObject
        if OLHttpConfiguration.sharedOLHttpConfiguration.requestMode == enumOnlineMode.DevMode {
            header["TESTENV"] = "2" as AnyObject
        }
        return header
    }
    
    override func ol_requestCustomJSONValidator() -> Bool {
        
        //校验JSON 格式信息
        /*
         eg: {
            "_Header": {
                "OLENV": String
                "_Sign": String
                "_ExtMsg": String
                "_USERENV": String
                "olts": String
                "olsign": String
            },
            "_Request": {
                "_Func": NSNumber(请求号)
            },
            "_Status": {
                "_Code": String(错误码)
                "_Msg": String(错误信息)
            },
            "_Response": {
                JSON数据
            }
         }
         */
        if let responseJSON = self.responseObject as? NSDictionary{
            if let status = responseJSON["_Status"] as? NSDictionary {
                let errorCode = status["_Code"]
                if let error = errorCode as? NSNumber {
                    self.errorCode = error.integerValue
                    
                }else if let error = errorCode as? String {
                    self.errorCode = Int(error)
                }
                
                if self.errorCode != nil && self.errorCode == 2000 {
                    return true
                }else if self.errorCode == nil {
                    self.errorCode = OLHttpRequestValidationError.InvalidErrorCode.rawValue
                }
                self.errorMsg = status["_Msg"] as? String
                return false
            }
        }
        
        self.errorCode = OLHttpRequestValidationError.InvalidJSONFormat.rawValue
        self.errorMsg = OL_ServerError
        return false
    }
    
}
