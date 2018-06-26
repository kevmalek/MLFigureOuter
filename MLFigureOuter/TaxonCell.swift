//
//  TaxonCell.swift
//  MLFigureOuter
//
//  Created by Kevin Malek on 6/26/18.
//  Copyright © 2018 The RealReal. All rights reserved.
//

import UIKit

class TaxonCell: UITableViewCell {

    @IBOutlet weak var taxonLabel: UILabel!
    @IBOutlet weak var confidenceInterval: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
