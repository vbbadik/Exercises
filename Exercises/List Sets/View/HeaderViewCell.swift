//
//  SectionHeader.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/24/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import UIKit

protocol HeaderViewCellDelegate: class {
    func toggleSection(_ header: HeaderViewCell, section: Int)
}

// MARK: - Implementation using IB

final class HeaderViewCell: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: HeaderViewCell.self) // "HeaderCell"
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var section: Int = 0
    
    weak var delegate: HeaderViewCellDelegate?
    
    @IBOutlet weak var title: UILabel? {
        get {
            return _title!
        }
        set {
            _title = newValue
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var _title: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader)))
    }
    
    func configure(title: String, isVisible: Bool) {
        self.title?.text = title
        
        if isVisible {
            self.imageView.image = UIImage(named: "arrow-up")
        } else {
            self.imageView.image = UIImage(named: "arrow-down")
        }
        
    }
    
    @objc private func tapHeader() {
        delegate?.toggleSection(self, section: section)
        print("Tapped")
    }
    
}
