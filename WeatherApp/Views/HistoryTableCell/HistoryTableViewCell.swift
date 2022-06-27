//
//  HistoryTableViewCell.swift
//  WeatherApp
//
//  Created by admin on 6/23/22.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    static let identifier = "HistoryTableViewCell"
    static let uiNibName = "HistoryTableViewCell"

    @IBOutlet weak var searchedCityLabel: UILabel!
    @IBOutlet weak var searchDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
