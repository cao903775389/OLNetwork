//
//  BeautyHttpRequest.swift
//  OLHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/24.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import Foundation

//MAPIURL
public class BeautyMAPIHttpRequest: OLHttpRequest {
    
    override public func ol_requestCustomArgument(requestArgument: [String : Any]?) -> [String : Any]? {
        var newParams = [String: Any]()
        if requestArgument != nil {
            newParams = requestArgument!
        }
        newParams["olts"] = "\(NSDate().timeIntervalSince1970)"
        newParams["olsign"] = OLHttpUtils.ol_buildSign(params: newParams.map({$1 as AnyObject}))
        return newParams
    }
    
    override public func ol_requestCustomHTTPHeaderfileds(headerfileds: [String : Any]?) -> [String : Any]? {
        
        var header = [String: Any]()
        if headerfileds != nil {
            header = headerfileds!
        }
        header["OLENV"] = OLHttpUtils.ol_buildOLEnv()
        if OLHttpConfiguration.sharedOLHttpConfiguration.requestMode == OLHttpRequestMode.Debug {
            header["TESTENV"] = "1"
        }
        return header
    }
    
    override public func ol_requestCustomJSONValidator() -> Bool {
        
        //校验JSON 格式信息
        /*
         eg: {
         errcode: NSNumber,
         data: AnyObject,
         rd: NSNumber(请求号),
         errormsg: String(错误信息)
         }
         */
        if let responseJSON = self.responseObject {
            let errorCode = responseJSON["errcode"]
            if let error = errorCode as? NSNumber {
                self.errorCode = error.intValue
                
            }else if let error = errorCode as? String {
                self.errorCode = Int(error)
            }
            
            if self.errorCode != nil && self.errorCode == 0 {
                return true
            }else if self.errorCode == nil {
                self.errorCode = OLHttpRequestValidationError.InvalidErrorCode.rawValue
            }
            self.errorMsg = responseJSON["errmsg"] as? String
            return false
        }
        
        self.errorCode = OLHttpRequestValidationError.InvalidJSONFormat.rawValue
        self.errorMsg = OL_ServerError
        return false
    }
}
