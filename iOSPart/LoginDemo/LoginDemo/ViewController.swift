//
//  ViewController.swift
//  LoginDemo
//
//  Created by Mon on 31/08/2017.
//  Copyright © 2017 monwingyeung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let session = URLSession.shared
    var dataTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Login"
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.isHidden = true
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        
        sender.isEnabled = false
        loadingIndicator.isHidden = false
        
        let userName = tfUserName.text
        let password = tfPassword.text
        let url = URL(string: "\(RequestAddress)/api/user/accesstoken")
        let params = ["name": userName ?? "", "password": password ?? ""]
        
        NetworkUtil.postEncodedData(to: url!, params: params) { (data: Data?, response: URLResponse?, error: Error?) in
            
            defer {
                DispatchQueue.main.async {
                    self.btnLogin.isEnabled = true
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
                let jsonObject = try! JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any>
                guard let token = jsonObject!["token"] else { return }
                
                UserDefaults.standard.setValue(token as! String, forKey: TokenKey)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "detail", sender: nil)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



