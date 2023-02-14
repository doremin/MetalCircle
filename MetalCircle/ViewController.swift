//
//  ViewController.swift
//  MetalCircle
//
//  Created by doremin on 2023/02/14.
//

import UIKit
import PinLayout

class ViewController: UIViewController {

  let circleView = CircleView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    self.view.addSubview(circleView)
    self.circleView.pin.center().size(CGSize(width: 300, height: 300))
  }

}

