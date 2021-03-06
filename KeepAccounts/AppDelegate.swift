//
//  AppDelegate.swift
//  KeepAccounts
//
//  Created by admin on 16/2/16.
//  Copyright © 2016年 jerry. All rights reserved.
//

import UIKit

private var ScreenWithRatio = UIScreen.mainScreen().bounds.width / 375
let firmAccountPath = "AccountBooks/firmAccount.archiver"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var booksArray:[AccountBookBtn] = []
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //在沙盒中创建目录
        initWithCreateDirectory()
        initWithCreateAccountBooks()

        //找到正在被使用的账本
        var item:AccountBookBtn!
        let path = String.createFilePathInDocumentWith(firmAccountPath) ?? ""
        if let accountsBtns = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [AccountBookBtn]{
            for i in 0...accountsBtns.count - 1{
                if accountsBtns[i].selectedFlag{
                    item = accountsBtns[i]
                }
            }
        }
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainVCModel = MainVCModel()
        let leftMenuVC = MainViewController(model: mainVCModel)
        let singleAccountModel = SingleAccountModel(initDBName: item.dataBaseName, accountTitle: item.btnTitle)
        let homeVC = SingleAccountVC(model: singleAccountModel)
        let sideMenu = RESideMenu.init(contentViewController: homeVC, leftMenuViewController: leftMenuVC, rightMenuViewController: nil)
        sideMenu.delegate = self
        sideMenu.contentViewInPortraitOffsetCenterX = 150 * ScreenWithRatio
        sideMenu.contentViewShadowEnabled = true
        sideMenu.contentViewShadowOffset = CGSize(width: -2, height: -2)
        sideMenu.contentViewShadowColor = UIColor.blackColor()
        sideMenu.scaleContentView = false
        sideMenu.scaleMenuView = false
        sideMenu.fadeMenuView = false
        window?.rootViewController = sideMenu
        window?.makeKeyAndVisible()
        return true
    }
    private func initWithCreateDirectory(){
        String.createDirectoryInDocumentWith("DatabaseDoc")
        String.createDirectoryInDocumentWith("AccountPhoto")
        String.createDirectoryInDocumentWith("AccountBooks")
    }
    private func initWithCreateAccountBooks(){
        let path = String.createFilePathInDocumentWith(firmAccountPath) ?? ""
        var booksArray:[AccountBookBtn] = []
        if NSFileManager.defaultManager().fileExistsAtPath(path) == false {
            //初始化账本页
            let booksitem = AccountBookBtn(title: "日常账本", count: "0笔", image: "book_cover_0", flag: true, dbName: "DatabaseDoc/AccountModel.db")
            booksArray.append(booksitem)
            booksArray.append(AccountBookBtn(title: "", count: "", image: "menu_cell_add", flag: false, dbName: ""))
            NSKeyedArchiver.archiveRootObject(booksArray, toFile: path)
        }
        self.booksArray = booksArray
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate:RESideMenuDelegate{
}

