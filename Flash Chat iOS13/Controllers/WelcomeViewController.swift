//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.isNavigationBarHidden = false
    }

    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = Constants.appName
        
/*      Manual way of making the text animation
        let text = "⚡️FlashChat"
        var title: String = ""
        var charIndex = 0
        
        //We use the charIndex to stagger the timers
        //Without this, all the timers start at the same time so we don't see the delayed affect
        for char in text {
            Timer.scheduledTimer(withTimeInterval: 0.2 * Double(charIndex), repeats: false) { (timer) in
                title.append(char)
                self.titleLabel.text = title
                //print(title)
            }
            
            charIndex += 1
        }
*/

    }

}
