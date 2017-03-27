//
//  CreatAccountViewController.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/27/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import UIKit

class CreatAccountViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func creatAccountButton(_ sender: UIButton) {
        if let username = usernameTextField.text {
            if let password = passwordTextField.text {
                if password == passwordTextField2.text {
                    NSLog("userName: \(username)  password: \(password)")
                }
                
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
