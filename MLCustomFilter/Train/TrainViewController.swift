//
//  TrainViewController.swift
//  MLCustomFilter
//
//  Created by Srikanth SP on 05/09/22.
//

import Foundation
import UIKit

protocol TrainViewProtocol {
    func trainModel(_ completion:()->Void)
}

class TrainViewController: UIViewController, Storyboarded {
    // PENDING
}

extension TrainViewController: TrainViewProtocol {
    func trainModel(_ completion: () -> Void) {
    }
    
    func trainModel(){
    }
}

