//
//  MedicineManager.swift
//  project_2
//
//  Created by 李思瑩 on 2018/6/5.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import Foundation

class MedicineManager {

    let firebase = FirebaseManager.shared

    func getMedicineItems(
        success: @escaping ([ItemList], [ItemList]) -> Void,
        failure: (Error) -> Void ) {
        firebase.dictGetCategoryData(
        by: ListCategory.medicine.rawValue) { data in

            var nonTrashItems = [ItemList]()
            var trashItems = [ItemList]()

            for item in data {

                if let info = ItemList.createItemList(data: item.value) {
                    
                    let remainday = DateHandler.calculateRemainDay(enddate: info.endDate)

                    if remainday < 0 {
                        trashItems.append(info)
                    } else {
                        nonTrashItems.append(info)
                    }

                } else {
                    // TODO: Error handler
                }
            }
            //success
            success(nonTrashItems, trashItems)
        }
    }

}
