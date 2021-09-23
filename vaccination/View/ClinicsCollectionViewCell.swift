//
//  ClinicsCollectionViewCell.swift
//  vaccination
//
//  Created by User on 19/9/21.
//

import UIKit

class ClinicsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var clinicLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(clinic: Clinic) {
        clinicLabel.text = clinic.name
        //print(clinic)
    }
}
