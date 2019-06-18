//
//  SectionHeader.swift
//  Exercises
//
//  Created by Vitaly Badion on 5/24/19.
//  Copyright © 2019 Vitaly Badion. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
    func toggleSection(_ header: HeaderView, section: Int)
}

// MARK: - Implementation using code

final class HeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: self) // "HeaderCell"
    
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var section: Int = 0
    private var collapsed: Bool?
    
    weak var delegate: HeaderViewDelegate?
    
    private override init(reuseIdentifier: String? = reuseIdentifier) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setTitleLabel()
        setImageView()
        
        // Call tapHeader when tapping on this header
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader)))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(section: Int, title: String, collapsed: Bool) {

    }

    private func setTitleLabel() {
        titleLabel.textColor = #colorLiteral(red: 0.4117058218, green: 0.4116234779, blue: 0.4331404567, alpha: 1)
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Constraint for title
        titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
    }
    
    private func setImageView() {
//        imageView.image = UIImage(named: "arrow")?.imageWithColor(#colorLiteral(red: 0.4117058218, green: 0.4116234779, blue: 0.4331404567, alpha: 1)) // For use one image - ARROW
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // Constraints for imageView
        imageView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    func configure(_ set: Set, by section: Int) {
        self.section = section
        collapsed = set.isVisible
        titleLabel.text = DateFormatter.localizedString(from: set.date, dateStyle: .medium, timeStyle: .none)
        imageView.image = set.isVisible ? UIImage(named: "arrow-up") : UIImage(named: "arrow-down") // For use two images - ARROW-UP, ARROW-DOWN
        imageView.imageColor = #colorLiteral(red: 0.4117058218, green: 0.4116234779, blue: 0.4331404567, alpha: 1)
        
        // For use one image - ARROW
//        if set.isVisible {
//            let arrowUp = imageView.transform.rotated(by: -.pi)
//            imageView.transform = arrowUp
//        }
    }
    
    func collapsed(_ isVisible: Bool) {
        guard let collapsed = collapsed else { return }

//        imageView.rotate(isVisible ? -.pi : 0.0) // For use one image - ARROW
        
        // For use two images - ARROW-UP, ARROW-DOWN
        if collapsed { 
            imageView.rotate(isVisible ? 0.0 : .pi)
        } else {
            imageView.rotate(isVisible ? -.pi : 0.0)
        }
    }

    @objc private func tapHeader() {
        delegate?.toggleSection(self, section: section)
    }

}
