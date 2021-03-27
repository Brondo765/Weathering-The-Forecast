//
//  MyCell.swift
//  Weathering the Forecast
//
//  Created by Brandon Wegner on 3/12/21.
//

import UIKit

class MyCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherSprite: UIImageView!
    @IBOutlet weak var averageTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBAction func didTapButton(sender: UIButton) {
        actionBlock?()
    }
    
    var actionBlock: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
