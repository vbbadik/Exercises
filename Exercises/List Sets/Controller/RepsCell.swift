//
//  RepsCell.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/31/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import UIKit

final class RepsCell: UITableViewCell {
    static let reuseIdentifier = String(describing: self)
    
    var repsLabel: UILabel? {
        get { return textLabel }
    }
    var timeLabel: UILabel? {
        get { return detailTextLabel }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String? = reuseIdentifier) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func infoForCell(reps: Int, time: Date) {
        textLabel?.text = String(reps)
        detailTextLabel?.text = DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .medium)
    }
    
    func configure(from set: Set, by indexPath: IndexPath) {
        let reps = set.reps[indexPath.row].reps
        let time = set.reps[indexPath.row].time
        infoForCell(reps: reps, time: time)
    }
}
