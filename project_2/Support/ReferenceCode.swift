//
//  ReferenceCode.swift
//  project_2
//
//  Created by 李思瑩 on 2018/5/1.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import Foundation
import FirebaseAuth

class Aaa: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.presentLoggedInScreen()
        }
    }

    

    // present logged in screen
    func presentLoggedInScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loggedInVC: LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        self.present(loggedInVC, animated: true, completion: nil)
    }

}
