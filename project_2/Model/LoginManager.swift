//
//  LoginManager.swift
//  project_2
//
//  Created by 李思瑩 on 2018/5/17.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class LoginManager {

    // MARK: - SIGNIN WITH EMAIL -
    func signInFirebaseWithEmail(email: String, password: String, failure: @escaping () -> Void, animation: @escaping () -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if error == nil {

                print("success login")

                if let userId = Auth.auth().currentUser?.uid {

                    let userDefault = UserDefaults.standard
                    userDefault.set(userId, forKey: "User_ID")

                    animation()

                    DispatchQueue.main.async {
                        AppDelegate.shared.switchToMainStoryBoard()
                    }
                }

            } else {

                print(error?.localizedDescription as Any)

                //TODO: LUKE
                failure()
            }
        }
    }

    // MARK: - FORGET PASSWORD -
    func forgetPasswordWithEmail(email: String) {

        Auth.auth().sendPasswordReset(withEmail: email) { error in

            if let error = error {

                print(error.localizedDescription)

            } else {
                // send new password
            }
        }

    }

    // MARK: - REGISTER BY EMAIL -
    func registerFirebaseByEmail(name: String, email: String, password: String, presentAlert: @escaping (UIAlertController) -> Void) {

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in

            if error != nil {

                print(error?.localizedDescription as Any)

                DispatchQueue.main.async {
                    AppDelegate.shared.switchToLoginStoryBoard()
                }

            } else {

                print("success register")

                if let uid = user?.uid {

                    let values = ["name": name as AnyObject, "email": email as AnyObject, "profileImageUrl": "" as AnyObject] as [String: AnyObject]
                    let ref = Database.database().reference()
                    let usersReference = ref.child("users").child(uid)
                    usersReference.updateChildValues(values, withCompletionBlock: { (err, _) in

                        if err != nil {
                            print(String(describing: err?.localizedDescription))
                            return
                        }
                        // send verify mail
                        user?.sendEmailVerification(completion: { (error) in

                            if let error = error {
                                print(error)
                            }
                        })
                    })
                }

                let alertController = UIAlertController(title: "", message: "請到註冊信箱進行驗證，再行登入", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "了解", style: .default) { (_) in
                    DispatchQueue.main.async {
                        AppDelegate.shared.switchToLoginStoryBoard()
                    }
                }
                alertController.addAction(okAction)
                presentAlert(alertController)
            }
        }
    }

}
