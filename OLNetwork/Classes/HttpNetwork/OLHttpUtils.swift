//
//  OLHttpUtils.swift
//  BeautyHttpNetwork
//
//  Created by 逢阳曹 on 2016/10/19.
//  Copyright © 2016年 逢阳曹. All rights reserved.
//

import Foundation
//网络请求工具类
class OLHttpUtils: NSObject {
    
    //MARK: - 状态码验证
    class func ol_statusCodeValidator(statusCode: Int) -> Bool {
        if statusCode >= 200 && statusCode <= 299 {
            return true
        }else {
            return false
        }
    }
    
    //MARK: Download
    //获取沙盒Temp目录下未完成的下载任务的文件夹路径
    class func incompleteDownloadTemCacheFolder() -> String? {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        var cacheFolder: String?
        if cacheFolder == nil {
            let cacheDir = NSTemporaryDirectory() as NSString
            cacheFolder = cacheDir.stringByAppendingPathComponent(OLHttpNetworkIncompleteDownloadFolderName)
        }
        do {
           try fileManager.createDirectoryAtPath(cacheFolder!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("创建文件目录:\(cacheFolder!)失败！")
            cacheFolder = nil
        }
        return cacheFolder
    }
    
    //获取沙盒Temp目录下未完成的下载任务的URL
    class func incompletedDownloadTempPathForDownloadPath(downloadPath: String) -> NSURL? {
    
        var tempPath: String?
        let incompleteCacheFolder = OLHttpUtils.incompleteDownloadTemCacheFolder()
        tempPath = (incompleteCacheFolder as NSString?)?.stringByAppendingPathComponent(downloadPath)
        guard tempPath != nil else {
            return nil
        }
        return NSURL(fileURLWithPath: tempPath!)
    }
    
    //判断NSData数据是否失效
    class func validateResumeData(data: NSData?) -> Bool {
        //From YTKNetwork
        if data == nil || data!.length < 1 {
            return false
        }
        //解析本地缓存数据
        var resumeDictionary: NSDictionary?
        do {
           resumeDictionary = try NSPropertyListSerialization.propertyListWithData(data!, options: NSPropertyListReadOptions.init(rawValue: 0), format: nil) as? NSDictionary
        } catch {
            print("缓存数据已失效")
            return false
        }
        
        //解析失败
        if resumeDictionary == nil {
            return false
        }
        
        // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
        // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
        // We can only assume that the plist being successfully parsed means the resume data is valid.
        if #available(iOS 9.0, *) {
            return true
        }else {
            
            let localFilePath = resumeDictionary?.objectForKey("NSURLSessionResumeInfoLocalPath") as? String
            if localFilePath == nil || localFilePath!.characters.count < 1  {
                return false
            }
            return NSFileManager.defaultManager().fileExistsAtPath(localFilePath!)
        }
    }
}
