//
//  NecessaryManager.swift
//  project_2
//
//  Created by 李思瑩 on 2018/6/5.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import Foundation

class NecessaryManager {

    let firebase = FirebaseManager.shared

    func getNecessaryItems(
        success: @escaping ([ItemList], [ItemList]) -> Void,
        failure: (Error) -> Void ) {
        firebase.dictGetCategoryData(
        by: ListCategory.necessary) { data in

            var nonTrashItems = [ItemList]()

            var trashItems = [ItemList]()

            for item in data {

                if let info = ItemList.createItemList(data: item.value) {

                    let remainday = DateHandler.calculateRemainDay(enddate: info.endDate)

                    if remainday < IKConstants.DateRef.remaindayPoint {

                        trashItems.append(info)

                    } else {

                        nonTrashItems.append(info)
                    }

                } else {

                    // DOTO: Error handler
                    print("====== error ======")
                }
            }

            //success
            success(nonTrashItems, trashItems)
        }
    }
}
