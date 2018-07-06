//
//  SelectYearTableViewCell.swift
//  Classmate
//
//  Created by Administrator on 7/4/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

protocol SelectYearTableViewCellDelegate: NSObjectProtocol {
    func selectYearTableViewCell(_ cell: UITableViewCell, selectClicked: Bool )
}

class SelectYearTableViewCell: UITableViewCell {

    var delegate: SelectYearTableViewCellDelegate?
    @IBOutlet weak var selectYearButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectButtonClicked(_ sender: Any) {
        delegate?.selectYearTableViewCell(self, selectClicked: true)
    }

}
