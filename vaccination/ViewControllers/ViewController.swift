//
//  ViewController.swift
//  vaccination
//
//  Created by User on 18/9/21.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Vaccination Booking"
        loginButton.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
        messageLabel.alpha = 0
    }
    @IBAction func loginAction(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        Auth.auth().signIn(withEmail: email!.trimmingCharacters(in: .whitespacesAndNewlines), password: password!.trimmingCharacters(in: .whitespacesAndNewlines)) { (result, loginerror) in
            if loginerror != nil {
                self.messageLabel.text = loginerror!.localizedDescription
                self.messageLabel.alpha = 1
            } else {
                self.loadBookingView()
            }
        }
    }
    func loadBookingView() {
        let bookingView = storyboard?.instantiateViewController(identifier: "BookingView") as? BookingViewController
        view.window?.rootViewController = bookingView
        view.window?.makeKeyAndVisible()
    }
}

