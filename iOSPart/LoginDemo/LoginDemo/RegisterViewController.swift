//
//  RegisterViewController.swift
//  LoginDemo
//
//  Created by Mon on 01/09/2017.
//  Copyright © 2017 monwingyeung. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lbPrompt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Register"
        loadingIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lbPrompt.text = ""
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionRegister(_ sender: UIButton) {
        let userName = tfUserName.text
        let password = tfPassword.text
        
        let params = [
            "name": userName,
            "password": password,
        ]
        
        NetworkUtil.postEncodedData(to: URL(string: RegisterAddress)!, params: params as! [String : String]) { (data, response, error) in
            
            defer {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    sender.isEnabled = true
                }
            }
            
            if let _ = error {
                print(error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else { return }
            if (response.statusCode == 200) {
                let jsonObject = try? JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
                guard let json = jsonObject else { print("failure"); return }
                if (json["success"] as! Bool) {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.lbPrompt.text = "Failed to register"
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
