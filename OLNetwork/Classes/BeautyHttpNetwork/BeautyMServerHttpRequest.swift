//
//  BeautyMServerHttpRequest.swift
//  OLHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/24.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import UIKit

//MServerURL
public class BeautyMServerHttpRequest: OLHttpRequest {

    override public func ol_requestCustomArgument(requestArgument: [String : Any]?) -> [String : Any]? {
        
        var newParams = [String: Any]()
        if requestArgument != nil {
            newParams["_Request"] = requestArgument!
        }
        
        var header = ["_Sign": OLHttpUtils.ol_deviceIDFA(), "_ExtMsg": ""]
        
        header["olts"] = "\(NSDate().timeIntervalSince1970)"
        header["olsign"] = OLHttpUtils.ol_buildSign(params: newParams.map({$1 as AnyObject}))
        
        header["OLENV"] = OLHttpUtils.ol_buildOLEnv()
        header["USERENV"] = OLHttpUtils.ol_buildUserEnv()
        
        newParams["_Header"] = header
        
        //加密参数
        let data = try? JSONSerialization.data(withJSONObject: newParams, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        if data != nil {
            
            let result = String(data: data!, encoding: String.Encoding.utf8)
            //先MD5加密
            let md5Str = ((result! + Md5Key) as NSString).tb_MD5()
            let sha1Str = (md5Str! as NSString).tb_SHA1()
            //然后sha1加密
            return ["r": (result! as NSString).tb_base64() as AnyObject, "s": sha1Str as AnyObject]
        }else {
            return nil
        }
    }
    
    override public func ol_requestCustomHTTPHeaderfileds(headerfileds: [String : Any]?) -> [String : Any]? {
        
        var header = [String: Any]()
        if headerfileds != nil {
            header = headerfileds!
        }
        header["OLENV"] = OLHttpUtils.ol_buildOLEnv()
        if OLHttpConfiguration.sharedOLHttpConfiguration.requestMode == OLHttpRequestMode.Debug {
            header["TESTENV"] = "2"
        }
        return header
    }
    
    override public func ol_requestCustomJSONValidator() -> Bool {
        
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
        if let responseJSON = self.responseObject {
            if let status = responseJSON["_Status"] as? [String: AnyObject] {
                let errorCode = status["_Code"]
                if let error = errorCode as? NSNumber {
                    self.errorCode = error.intValue
                    
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
