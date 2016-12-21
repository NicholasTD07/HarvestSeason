//
//  LoginViewController.swift
//  HarvestSeason
//
//  Created by Nicholas Tian on 20/12/2016.
//  Copyright © 2016 nicktd. All rights reserved.
//

import UIKit

import HarvestAPI

struct ErrorLogging {
    enum Error {
        case ui(UI)
        case api(API)

        enum UI {
            case warning(message: String)
        }
        enum API {
            case error(message: String)
        }
    }

    static func log(_ error: Error) {
        debugPrint("\(error)")
    }

    static func log(_ error: HarvestAPI.API.Error) -> Void {
        ErrorLogging.log(.api(.error(message: "Failed because of \n\(error)")))

    }

}

class LoginViewController: UIViewController {

    @IBOutlet weak var company: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.password.keyboardType = .asciiCapable
        self.password.isSecureTextEntry = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.company.becomeFirstResponder()
    }

    @IBAction func logIn(_ sender: UIButton) {
        guard
            let company = company.text, !company.isEmpty,
            let username = username.text, !username.isEmpty,
            let password = password.text, !password.isEmpty
        else {
            ErrorLogging.log(.ui(.warning(message: "Check your input for company, username, and password")))
            return
        }

        action.login(company: company, username: username, password: password)
    }
}
