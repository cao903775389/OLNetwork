//
//  BeautyHttpUtils.swift
//  OLHttpNetwork
//  工具类
//  Created by 逢阳曹 on 2016/10/24.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import Foundation
import AdSupport
extension OLHttpUtils {
    
    //MARK: - 请求信息生成
    //请求参数签名加密 olsign
    class func ol_buildSign(params: [AnyObject]) -> String {
        var newParams = [String]()
        for v in params{
            if let v = v as? NSNumber{
                newParams.append(v.stringValue)
            }else if let v = v as? String{
                newParams.append(v)
            }else{
                newParams.append("\(v)")
            }
        }
        let sortedKeys = NSArray(array: newParams)
        //var newKeys = sorted(dictionary) { $0.1 > $1.1 }
        //var sortedKeys = NSArray(array:params)
        
        let newKeys = sortedKeys.sortedArrayUsingSelector(#selector(NSNumber.compare(_:)))
        var tmpStr = ""
        for k in newKeys{
            tmpStr += "\(k)"
        }
        tmpStr += SignKey
        return tmpStr.md5
    }
    
    //请求信息 OLENV
    class func ol_buildOLEnv() -> String {
        //本地化信息
        let locale : NSLocale! = NSLocale.currentLocale()
        
        let cal = locale.objectForKey(NSLocaleCalendar) as! NSCalendar
        
        let timeZone = cal.timeZone.description
        
        //定义字典对象
        var parameters: [String: AnyObject] = ["tzone":timeZone as AnyObject]
        
        let resolution:String = "\(Int(UIScreen.mainScreen().currentMode!.size.width))*\(Int(UIScreen.mainScreen().currentMode!.size.height))"
        parameters["res"] = resolution as AnyObject//分辨率 格式：宽*高
        parameters["pkg"] = OLHttpUtils.ol_mainBundleInfoWithKey("CFBundleIdentifier") as AnyObject//bundle identifier
        parameters["chan"] = "app store" as AnyObject//渠道来源(无法判断)
        parameters["os"] = "1" as AnyObject
        parameters["osvs"] = UIDevice.currentDevice().systemVersion as AnyObject//操作系统版本
        parameters["model"] = UIDevice.currentDevice().modelName as AnyObject//设备型号
        parameters["avs"] = OLHttpUtils.ol_mainBundleInfoWithKey("CFBundleShortVersionString") as AnyObject//app版本号(外部版本号)
        parameters["aname"] = "优美妆" as AnyObject
        
        parameters["idfa"] = OLHttpUtils.ol_deviceIDFA() as AnyObject//设备唯一标识 idfa
        if let uid = AccountManager.currentUser?.id{
            parameters["uid"] = "\(uid)"
        }else{
            parameters["uid"] = "0" as AnyObject//用户id
        }
        parameters["oid"] = "" as AnyObject
        do {
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.init(rawValue: 0))
            let dataStr = String.init(data: data, encoding: NSUTF8StringEncoding)
            
            let credentialData = dataStr?.dataUsingEncoding(NSUTF8StringEncoding)
            
            if credentialData == nil {
                return ""
            }
            
            let base64Credentials = credentialData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
            return base64Credentials
        } catch {
            return ""
        }
    }
    
    //请求用户信息 USERENV
    class func ol_buildUserEnv() -> String {
        //定义字典对象
        var parameters = [String:AnyObject]()
        
        if let uid = AccountManager.currentUser?.id{
            parameters["uid"] = "\(uid)"
        } else {
            parameters["uid"] = "0" as AnyObject
        }
        
        do {
            // base64加密
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.init(rawValue: 0))
            let dataStr = String.init(data: data, encoding: NSUTF8StringEncoding)
            
            let credentialData = dataStr?.dataUsingEncoding(NSUTF8StringEncoding)
            if credentialData == nil {
                return ""
            }
            let base64Credentials = credentialData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
            return base64Credentials
        } catch {
            return ""
        }
    }
    
    //请求用户 IDFA信息
    class func ol_deviceIDFA() -> String {
        if ASIdentifierManager.sharedManager().advertisingTrackingEnabled {
            let IDFA = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
            return IDFA
        } else {
            return ""
        }
    }
    
    ///获取用户MainBundle信息
    class func ol_mainBundleInfoWithKey(key:String)-> String {
        if let infoDictionary = NSBundle.mainBundle().infoDictionary {
            if let CFBundleShortVersionString = infoDictionary[key] as? String {
                return CFBundleShortVersionString
            }
        }
        return ""
    }
    
    //生成第三方帐号认证信息Authorization
    class func buildAuthorization(uid:String,name:String="")->String{
        let newStr = "\(uid):\(name)"
        let credentialData = newStr.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        return "Basic \(base64Credentials)"
    }
}
