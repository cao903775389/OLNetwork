//
//  BeautyHttpRequest.swift
//  OLHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/24.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import Foundation

//MAPIURL
class BeautyMAPIHttpRequest: OLHttpRequest {
    
    override func ol_requestCustomArgument(requestArgument: [String : AnyObject]?) -> [String : AnyObject]? {
        
        var newParams = [String: AnyObject]()
        if requestArgument != nil {
            newParams = requestArgument!
        }
        newParams["olts"] = "\(NSDate().timeIntervalSince1970)" as AnyObject
        newParams["olsign"] = OLHttpUtils.ol_buildSign(params: newParams.map({$1})) as AnyObject
        return newParams
    }
    
    override func ol_requestCustomHTTPHeaderfileds(headerfileds: [String : AnyObject]?) -> [String : AnyObject]? {
        
        var header = [String: AnyObject]()
        if headerfileds != nil {
            header = headerfileds!
        }
        header["OLENV"] = OLHttpUtils.ol_buildOLEnv() as AnyObject
        if OLHttpConfiguration.sharedOLHttpConfiguration.requestMode == enumOnlineMode.DevMode {
            header["TESTENV"] = "1" as AnyObject
        }
        return header
    }
    
    override func ol_requestCustomJSONValidator() -> Bool {
        
        //校验JSON 格式信息
        /*
         eg: {
         errcode: NSNumber,
         data: AnyObject,
         rd: NSNumber(请求号),
         errormsg: String(错误信息)
         }
         */
        if let responseJSON = self.responseObject as? NSDictionary{
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
