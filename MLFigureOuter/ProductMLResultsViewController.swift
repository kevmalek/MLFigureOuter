//
//  ProductMLResultsViewController.swift
//  MLFigureOuter
//
//  Created by Kevin Malek on 6/26/18.
//  Copyright © 2018 The RealReal. All rights reserved.
//

import UIKit

class ProductMLResultsViewController: UIViewController {
    var predictionOutput: ShoesAndHandbagsPhase2Output!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(predictionOutput.classLabel)

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let resultsTVC = segue.destination as? ProductMLResultsTableViewController {
            resultsTVC.predictionOutput = predictionOutput
        }
        
    }

}
