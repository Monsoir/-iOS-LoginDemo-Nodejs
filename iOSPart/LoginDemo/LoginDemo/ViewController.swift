//
//  ViewController.swift
//  LoginDemo
//
//  Created by Mon on 31/08/2017.
//  Copyright © 2017 monwingyeung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var lbPrompt: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Login"
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lbPrompt.text = ""
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        
        sender.isEnabled = false
        btnRegister.isEnabled = false
        loadingIndicator.isHidden = false
        
        let userName = tfUserName.text
        let password = tfPassword.text
        let url = URL(string: AccessTokenAddress)
        let params = ["name": userName ?? "", "password": password ?? ""]
        
        NetworkUtil.postEncodedData(to: url!, params: params) { (data: Data?, response: URLResponse?, error: Error?) in
            
            defer {
                DispatchQueue.main.async {
                    self.btnLogin.isEnabled = true
                    self.btnRegister.isEnabled = true
                    self.loadingIndicator.isHidden = true
                }
            }
            
            if let _ = error {
                print(error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else { print("No data"); return }
            
            if (response.statusCode == 200) {
                
                var jsonObject: Dictionary<String, Any>!
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    guard let innerJsonObject = json as? Dictionary<String, Any> else {
                        DispatchQueue.main.async {
                            self.lbPrompt.text = "Something wrong when convert json"
                        }
                        return
                    }
                    jsonObject = innerJsonObject
                } catch {
                    DispatchQueue.main.async {
                        self.lbPrompt.text = "Something wrong when convert json"
                    }
                    return
                }
                
                let success = jsonObject["success"] as! Bool
                if (success) {
                    guard let token = jsonObject["token"] else { return }
                    UserDefaults.standard.setValue(token as! String, forKey: TokenKey)
                    DispatchQueue.main.async {
                        self.lbPrompt.text = (jsonObject["msg"] as! String)
                        self.performSegue(withIdentifier: "detail", sender: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.lbPrompt.text = (jsonObject["msg"] as! String)
                    }
                }
            }
        }
    }
    
    @IBAction func actionRegister(_ sender: Any) {
        self.performSegue(withIdentifier: "register", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



