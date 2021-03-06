//
//  FirebaseManager.swift
//  project_2
//
//  Created by 李思瑩 on 2018/5/14.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FirebaseManager {

    static let shared = FirebaseManager()
    lazy var ref = Database.database().reference()
    lazy var storageRef = Storage.storage().reference()

    // MARK: - ADD NEW ITEM -
    func addNewData(
        photo: UIImage,
        value: [String: Any],
        completion: @escaping (ItemList) -> Void) {

        guard let userId = Auth.auth().currentUser?.uid else { return }

        let filename = String(Int(Date().timeIntervalSince1970))

        let storageRef = Storage.storage().reference().child("\(IKConstants.FirebaseRef.itemsChild)/\(filename).png")

        let metadata = StorageMetadata()

        metadata.contentType = IKConstants.FirebaseRef.metadataContentType

        if let uploadData = UIImageJPEGRepresentation(photo, 0.1) {

            storageRef.putData(uploadData, metadata: metadata, completion: { (_, error) in

                if error != nil {

                    print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")

                } else {

                    storageRef.downloadURL(completion: { (url, error) in

                        if error == nil {

                            if let downloadUrl = url {

                                var tempData = value

                                tempData[IKConstants.FirebaseRef.imageUrl] = downloadUrl.absoluteString

                                guard let info = ItemList.createItemList(data: tempData) else { return }

                                self.ref.child("\(IKConstants.FirebaseRef.itemsChild)/\(userId)").childByAutoId().setValue(tempData)

                                let notificationName = Notification.Name(IKConstants.FirebaseRef.addItem)

                                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: [IKConstants.FirebaseRef.pass: info])

                                DispatchQueue.main.async {

                                    AppDelegate.shared.switchToMainStoryBoard()
                                }

                                completion(info)
                            }

                        } else {

                            print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")
                        }
                    })
                }
            })
        }
    }

    // MARK: - GET FIREBASE ORIGIN DATA -
    func dictGetCategoryData(
        by categoryType: StringGettable,
        completion: @escaping ([String: Any]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        self.ref
            .child("\(IKConstants.FirebaseRef.itemsChild)/\(userId)")
            .queryOrdered(byChild: IKConstants.FirebaseRef.category)
            .queryEqual(toValue: categoryType.getString())
            .observeSingleEvent(of: .value) { (snapshot) in

                if let value = snapshot.value as? [String: Any] {

                    completion(value)

                } else {

                    completion([:])
                }
            }
    }

    // MARK: - UPDATE PROFILE IMAGE -
    func updateProfileImage(uploadimage: UIImage?) {

        if let image = uploadimage, let imageData = UIImageJPEGRepresentation(image, 0.1), let userId = Auth.auth().currentUser?.uid {

            let task = storageRef.child(IKConstants.FirebaseRef.profile).child("\(userId).png")

            task.putData(imageData, metadata: nil, completion: { (_, error) in

                if error != nil {

                    print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")

                    return

                } else {

                    task.downloadURL(completion: { (url, error) in

                        if error == nil {

                            if let downloadUrl = url {

                                let value = downloadUrl.absoluteString

                                self.ref.child("\(IKConstants.FirebaseRef.users)/\(userId)").updateChildValues([IKConstants.FirebaseRef.profileImageUrl: value])
                            }

                        } else {

                            print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")
                        }
                    })
                }
            })
        }
    }

    // MARK: - GET EDIT IMAGE'S URL -
    func updateEditImage(uploadimage: UIImage, createTime: String, completion: @escaping (String) -> Void) {

        let storageRef = Storage.storage().reference().child("\(IKConstants.FirebaseRef.itemsChild)/\(createTime).png")

        let metadata = StorageMetadata()

        metadata.contentType = IKConstants.FirebaseRef.metadataContentType

        if let uploadData = UIImageJPEGRepresentation(uploadimage, 0.1) {

            storageRef.putData(uploadData, metadata: metadata, completion: { (_, error) in

                if error != nil {

                    print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")

                } else {

                    storageRef.downloadURL(completion: { (url, error) in

                        if error == nil {

                            if let downloadUrl = url {

                                completion(downloadUrl.absoluteString)
                            }

                        } else {

                            print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")
                        }
                    })
                }
            })
        }
    }

    // DOTO
    // MARK: - UPLOAD NEW ITEM IMAGE - ???
    func addItemImage(uploadimage: UIImage?, itemdata: [String: Any]) {
        let filename = String(Int(Date().timeIntervalSince1970))
        if let image = uploadimage, let imageData = UIImageJPEGRepresentation(image, 0.1), let userId = Auth.auth().currentUser?.uid {
            let task = storageRef.child(IKConstants.FirebaseRef.itemsChild).child("\(filename).png")
            task.putData(imageData, metadata: nil, completion: { (_, error) in
                if error != nil {
                    print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")
                    return
                } else {
                    task.downloadURL(completion: { (url, error) in
                        if error == nil {
                            if let downloadUrl = url {
                                var tempData = itemdata
                                tempData[IKConstants.FirebaseRef.imageUrl] = downloadUrl.absoluteString
                                self.ref.child("\(IKConstants.FirebaseRef.itemsChild)/\(userId)").childByAutoId().setValue(tempData)
                            }
                        } else {
                            print("\(IKConstants.FirebaseRef.error): \(String(describing: error?.localizedDescription))")
                        }
                    })
                }
            })
        }
    }

    // MARK: - DELETE DATABASE AND STORAGE DATA -
    func deleteData(index: Int, itemList: ItemList, updateDeleteInfo: @escaping () -> Void, popView: @escaping () -> Void ) {

        if let userId = Auth.auth().currentUser?.uid {

            self.ref = Database.database().reference()

            let delStorageRef = Storage.storage().reference().child("\(IKConstants.FirebaseRef.itemsChild)/\(itemList.createDate).png")

            delStorageRef.delete { (error) in

                if let error = error {

                    print(error.localizedDescription)

                } else {

                    print("file deleted successfully")
                }
            }

            // delDatabaseRef
            _ = self.ref.child("\(IKConstants.FirebaseRef.itemsChild)/\(userId)").queryOrdered(byChild: IKConstants.FirebaseRef.createdate).queryEqual(toValue: itemList.createDate).observeSingleEvent(of: .value, with: { (snapshot) in

                let value = snapshot.value as? NSDictionary

                for info in (value?.allKeys)! {

                    print(info)

                    self.ref.child("\(IKConstants.FirebaseRef.itemsChild)/\(userId)/\(info)").setValue(nil)

                    updateDeleteInfo()
                }
            })

            popView()
        }
    }
}
