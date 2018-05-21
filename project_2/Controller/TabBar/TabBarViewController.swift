//
//  TabBarViewController.swift
//  project_2
//
//  Created by 李思瑩 on 2018/4/30.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import UIKit

enum TabBar {
    case itemList
//    case instock
//    case alertList
    case addItem
    case profile

    func controller() -> UIViewController {
        switch self {
        case .itemList: return UIStoryboard.itemListStoryboard().instantiateInitialViewController()!
//        case .instock: return  UIStoryboard.instockStoryboard().instantiateInitialViewController()!
//        case .alertList: return UIStoryboard.alerListStoryboard().instantiateInitialViewController()!
        case .addItem: return UIStoryboard.addItemStoryboard().instantiateInitialViewController()!
        case .profile: return UIStoryboard.profileStoryboard().instantiateInitialViewController()!
        }
    }

    func image() -> UIImage {
        switch self {
        case .itemList: return #imageLiteral(resourceName: "025-package-cube-box-for-delivery")
//        case .instock: return #imageLiteral(resourceName: "031-archive-black-box")
//        case .alertList: return #imageLiteral(resourceName: "023-music-1")
        case .addItem: return #imageLiteral(resourceName: "003-plus")
        case .profile: return #imageLiteral(resourceName: "017-social")
        }
    }

    func selectedImage() -> UIImage {
        switch self {
        case .itemList: return #imageLiteral(resourceName: "025-package-cube-box-for-delivery").withRenderingMode(.alwaysTemplate)
//        case .instock: return #imageLiteral(resourceName: "031-archive-black-box").withRenderingMode(.alwaysTemplate)
//        case .alertList: return #imageLiteral(resourceName: "023-music-1").withRenderingMode(.alwaysTemplate)
        case .addItem: return #imageLiteral(resourceName: "003-plus").withRenderingMode(.alwaysTemplate)
        case .profile: return #imageLiteral(resourceName: "017-social").withRenderingMode(.alwaysTemplate)
        }
    }
}

class TabBarViewController: UITabBarController {

    let tabs: [TabBar] = [.itemList, .addItem, .profile]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupTab() {
//        tabBar.tintColor = UIColor(named: "47B9AD")
        tabBar.tintColor = UIColor(displayP3Red: 235/255.0, green: 158/255.0, blue: 87/255.0, alpha: 1.0)
        tabBar.barTintColor = UIColor(red: 9/255.0, green: 23/255.0, blue: 39/255.0, alpha: 1.0)
        var controllers: [UIViewController] = []
        for tab in tabs {
            let controller = tab.controller()
            let item = UITabBarItem(title: nil, image: tab.image(), selectedImage: tab.selectedImage())
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            controller.tabBarItem = item
            controllers.append(controller)
        }
        setViewControllers(controllers, animated: false)
    }

}
