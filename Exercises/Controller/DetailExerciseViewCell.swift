//
//  DetailExerciseViewCell.swift
//  Exercises
//
//  Created by Vitaly Badion on 20.09.2018.
//  Copyright © 2018 Vitaly Badion. All rights reserved.
//

import UIKit

class DetailExerciseViewCell: UITableViewCell {
    
    weak var dateLabel: UILabel?
    weak var timeLabel: UILabel?
    weak var repeatLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
