//
//  AboutViewController.swift
//  DeliveryFeePinas
//
//  Created by user on 29/8/20.
//  Copyright © 2020 Ernest Martin Gayyed. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var flatIconLabel: UILabel!
    @IBOutlet weak var attributeTextView: UITextView!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let attributedString = NSMutableAttributedString(string: "Icons made by Freepik from Flaticon")
        let url1 = URL(string: "https://www.flaticon.com/authors/freepik")!
        let url2 = URL(string: "https://www.flaticon.com")!

        // Set the 'click here' substring to be the link
        attributedString.setAttributes([.link: url1], range: NSMakeRange(14, 7))
        attributedString.setAttributes([.link: url2], range: NSMakeRange(27, 8))

        self.attributeTextView.attributedText = attributedString
        self.attributeTextView.isUserInteractionEnabled = true
        self.attributeTextView.isEditable = false
        
        self.versionLabel.text = getAppCurrentVersionNumber()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    func getAppCurrentVersionNumber() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        return nsObject as! String
    }
}
