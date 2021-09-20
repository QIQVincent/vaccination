//
//  SignUpViewController.swift
//  vaccination
//
//  Created by User on 12/9/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    func isValidPassword() -> Bool {
        let passwordreg =  ("(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[@#$%^&*;'.,<>]).{8,}")
        let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
        return passwordtesting.evaluate(with: self)
    }
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        messageLabel.alpha = 0

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func cancelButton(_ sender: Any) {
        self.loadLogin()
    }
    @IBAction func registerButton(_ sender: Any) {
        let fullName = fullNameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        if fullName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || email?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showMessage("Please re-enter registration")
        } else if email!.isValidEmail() == false {
            showMessage("Please use valid email")
        } else if password!.isValidPassword() == false {
            showMessage("Please use strong password with more than 8 characters, including at least one uppercase, lowercase, symbol and digit")
        } else {
            Auth.auth().createUser(withEmail: email!.trimmingCharacters(in: .whitespacesAndNewlines), password: password!.trimmingCharacters(in: .whitespacesAndNewlines)) { (result, autherr) in
                if autherr != nil {
                    self.showMessage("Error with registration")
                } else {
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data:[
                        "fullName": fullName!,
                        "uid": result!.user.uid
                    ]) { (dberr) in
                        if dberr != nil {
                            self.showMessage("Error with database")
                        }
                    }
                    self.loadLogin()
                }
            }
        }
    }
    func showMessage(_ message:String) {
        messageLabel.text = message
        messageLabel.alpha = 1
    }
    
    func loadLogin() {
        navigationController?.popViewController(animated: true)
    }
}
