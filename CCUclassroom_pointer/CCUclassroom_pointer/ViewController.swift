//
//  ViewController.swift
//  CCUclassroom_pointer
//
//  Created by Veternal on 2018/11/22.
//  Copyright © 2018 oslab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var IPaddress: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JoystickViewController
        vc?.IP = IPaddress.text
    }

    @IBAction func disconnectClick(for segue:UIStoryboardSegue){
        let vc = segue.source as? JoystickViewController
        vc?.TCPsendMes(mes: "xX")

    }
}

