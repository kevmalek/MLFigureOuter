//
//  ProductMLResultsTableViewController.swift
//  MLFigureOuter
//
//  Created by Kevin Malek on 6/26/18.
//  Copyright © 2018 The RealReal. All rights reserved.
//

import UIKit

class ProductMLResultsTableViewController: UITableViewController {
    var predictionOutput: ShoesAndHandbagsPhase2Output!
    var dataSource: [(category: String, confidence: Double)]?
    enum Sections: Int {
        case taxons
        case colors
        
        case count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = predictionOutput.classLabelProbs.compactMap { return ($0.key, $0.value) }
        dataSource?.sort(by: { $0.confidence > $1.confidence })
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.taxons.rawValue:
            return dataSource?.count ?? 0
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Sections.taxons.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taxonCell", for: indexPath) as! TaxonCell
            cell.taxonLabel.text = dataSource?[indexPath.row].category
            let ci = dataSource?[indexPath.row].confidence ?? 0.0
            
            cell.confidenceInterval.text = String(ci * 100)
            return cell
        default: return UITableViewCell()
        }
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
