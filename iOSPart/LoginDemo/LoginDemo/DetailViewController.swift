//
//  DetailViewController.swift
//  LoginDemo
//
//  Created by Mon on 31/08/2017.
//  Copyright © 2017 monwingyeung. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var lbDetail: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var prompt: String = "" {
        didSet {
            lbDetail.text = prompt
        }
    }
    
    let token = UserDefaults.standard.value(forKey: TokenKey) as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.isHidden = true
        
        prompt = token
    }
    
    @IBAction func actionGetUserInfo(_ sender: UIButton) {
        sender.isEnabled = false
        loadingIndicator.isHidden = false
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": token,
        ]
        
        NetworkUtil.getData(from: URL(string: "\(RequestAddress)/api/user/info")!, headers: headers, params: nil) { (data, response, error) in
            defer {
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    self.loadingIndicator.isHidden = true
                }
            }
            
            if let _ = error {
                print(error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else { print("No Data"); return }
            
            if (response.statusCode == 200) {
                let jsonObject = try? JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
                guard let json = jsonObject else { print("failure"); return }
                
                DispatchQueue.main.async {
                    if let text = json["username"] as? String {
                        self.lbDetail.text = text
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
