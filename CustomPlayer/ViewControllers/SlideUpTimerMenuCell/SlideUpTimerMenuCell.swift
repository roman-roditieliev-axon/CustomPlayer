//
//  SlideUpTimerMenuCell.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 16.07.2021.
//

import UIKit

class SlideUpTimerMenuCell: UITableViewCell {

    // Updated: Remove static

    lazy var labelView: UILabel = {
        let view = UILabel(frame: CGRect(x: 0,
                                         y: 0,
                                         width: self.frame.width,
                                         height: 40))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(labelView)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
