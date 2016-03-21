//
//  SingleAccountVC.swift
//  KeepAccounts
//
//  Created by admin on 16/2/25.
//  Copyright © 2016年 jerry. All rights reserved.
//

import UIKit


protocol SubViewProtocol{
    func clickManageBtn(sender:AnyObject!)
    func clickMidAddBtn(sender:AnyObject!)
}

class SingleAccountVC: UIViewController{
    
    //上一次cell的值，用于和当前值做比较
    let lastDay = NSDate().timeIntervalSince1970 - 86400
    var lastCellInterval:NSTimeInterval = NSDate().timeIntervalSince1970 - 86400
    //每日的消费金额
    var dayCost:String = ""
    var dayCostCell:AccountCell?
    //改时间
    var mainView:SingleAccountView?
    var itemAccounts:[AccountItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadDataSource", name: "ChangeDataSource", object: nil)
        self.view.backgroundColor = UIColor.whiteColor()
        setupMainView()
        initDataSource()
    }
    func reloadDataSource(){
        initDataSource()
        mainView?.tableView?.reloadData()
    }
    
    //MARK: - datasource
    private func initDataSource(){
        var dayCostItem:AccountItem = AccountItem()
        //从数据库中取出所有数据
        itemAccounts = AccoutDB.selectDataOrderByDate()
        //处理符合显示要求的数据
        //1、分开日期； 2、计算日金额
        var tmpItemAccounts:[AccountItem] = []
        for sourceItem in itemAccounts {
            //1、比较大小
            let showDate = compareDate(NSTimeInterval(sourceItem.date), lastInterval: lastCellInterval)
            //2、保存当前的日期值到lastCellInterval
            lastCellInterval = NSTimeInterval(sourceItem.date)
            //3、修改原数据
            sourceItem.dateString = showDate
            sourceItem.dayCost = sourceItem.money
            //4、判断showDate是否为空字符串，为空则加上本次的金额，不为空则替换cell
            if showDate == "" {
                let curMoney = Float(dayCostItem.dayCost)! + Float(sourceItem.money)!
                dayCostItem.dayCost = NSString(format: "%.2f", curMoney) as String
                sourceItem.dayCost = ""
            }
            else{
                dayCostItem = sourceItem
            }
            tmpItemAccounts.append(sourceItem)
        }
        lastCellInterval = lastDay
        itemAccounts = tmpItemAccounts
    }
    private func setupMainView(){
        let singleAccountView = SingleAccountView(frame: self.view.frame, delegate:self)
        mainView = singleAccountView
        self.view.addSubview(singleAccountView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    private func compareDate(currentInterval:NSTimeInterval, lastInterval:NSTimeInterval) -> String{
        let currentCom = NSDate.intervalToDateComponent(currentInterval)
        let lastCom = NSDate.intervalToDateComponent(lastInterval)
        let yearEqual = currentCom.year == lastCom.year
        let monthEqual = currentCom.month == lastCom.month
        let dayEqual = currentCom.day == lastCom.day
        if yearEqual == true{
            if monthEqual == true{
                if dayEqual == true{
                    return ""
                }
                else{
                    return "\(currentCom.day)日"
                }
            }
            else{
                return "\(currentCom.month)月\(currentCom.day)日"
            }
        }
        else{
            return "\(currentCom.year)年\(currentCom.month)月\(currentCom.day)日"
        }
    }

}

extension SingleAccountVC: SubViewProtocol{
    func clickManageBtn(sender:AnyObject!){
        self.presentLeftMenuViewController(sender)
    }
    func clickMidAddBtn(sender:AnyObject!){
        self.presentViewController(ChooseItemVC(), animated: true, completion: nil)
    }
}
//MARK: - tableview delegate
extension SingleAccountVC:UITableViewDelegate{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(100)
    }
}

//MARK: - tableview datasource
extension SingleAccountVC:UITableViewDataSource{
    
    func itemFromDataSourceWith(indexPath:NSIndexPath) -> AccountItem{
        if indexPath.row < itemAccounts.count{
           return itemAccounts[indexPath.row]
        }
        return AccountItem()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let rowAmount = tableView.numberOfRowsInSection(indexPath.section)
        let identify = "AccountCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identify, forIndexPath: indexPath) as! AccountCell
        cell.selectionStyle = .None
        //tableview的蛋疼之处，从cell池中拿出来的cell可能属性已经改变了，所以得有初始化这一步
        //所以tableview只能用于内容高度一致
        cell.botmLine.hidden = false
        cell.dayIndicator.hidden = true
        
        let item = itemFromDataSourceWith(indexPath)
        let imagePath = String.createFilePathInDocumentWith(item.photo) ?? ""
        cell.iconTitle.text = item.iconTitle
        cell.icon.image = UIImage(named: item.iconName)
        cell.itemCost.text = item.money
        cell.remark.text = item.remark
        cell.dayCost.text = item.dayCost
        cell.date.text = item.dateString
        
        //图片
        if let data = NSData(contentsOfFile: imagePath){
            cell.photoView.image = UIImage(data: data)
        }
        //日期指示器
        if item.dayCost != "" && item.dateString != ""{
            cell.dayIndicator.hidden = false
        }
        
        //最后一个去掉尾巴
        if indexPath.row == rowAmount - 1{
            cell.botmLine.hidden = true
            lastCellInterval = lastDay
        }
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemAccounts.count
    }
    
}