//
//  ViewController.swift
//  OLNetwork
//
//  Created by cao903775389 on 04/12/2017.
//  Copyright (c) 2017 cao903775389. All rights reserved.
//

import UIKit

import OLNetwork
import YYModel
private let identifier = "identifier"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, OLHttpRequestDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var request: BeautyMAPIHttpRequest!
    
    var data: [TrialListItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "TestTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        
        // Do any additional setup after loading the view, typically from a nib.
        let param: [String: Any] = ["rd": OLCode.OL_TrialList.rawValue, "ie": 1]
        
        self.request = BeautyMAPIHttpRequest(delegate: self, requestMethod: OLHttpMethod.GET, requestUrl: MAPIURL.V130.rawValue, requestArgument: param, OL_CODE: OLCode.OL_TrialList)
        
        OLHttpRequestManager.sharedOLHttpRequestManager.sendHttpRequest(request: self.request)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = TestTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        let model = self.data[indexPath.row]
//        (cell as! TestTableViewCell).imageView?.sd_setImage(with: URL(string: model.iu!)!, placeholderImage: UIImage(named: "demo3.png"))
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    //HttpRequestDelegate
    func ol_requestFinished(request: OLHttpRequest) {
        
        if let json = request.responseObject {
            let response = json["data"] as? [String: AnyObject]
            let trialData = response?["trylist"] as? [[NSObject: AnyObject]]
            
            if let trialJSON = trialData {
                for trial in trialJSON {
                    let trialModel = TrialListItemModel.yy_model(with: trial)
                    self.data.append(trialModel!)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func ol_requestFailed(request: OLHttpRequest) {
        
    }
}


class TrialListItemModel: NSObject {
    /// 试用ID
    var tryid:String?
    /// 试用标题
    var tt:String?
    /// 试用数量
    var tnum:String?
    /// 试用人气
    var wnum:String?
    /// 开始时间
    var stat:String?
    /// 结束时间
    var end:String?
    /// 图片地址
    var iu:String?
    /// 使用介绍
    var des:String?
    /// 申请状态
    var stu:String?
    /// 试用规格 0正装 1小样 2中样
    var type: String?
    /// 试用状态
    var tstu:String?
}
