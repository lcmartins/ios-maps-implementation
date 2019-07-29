//
//  LocationTableViewCell.swift
//  searchOnMap
//
//  Created by Luciano de Castro Martins on 27/06/2018.
//  Copyright © 2018 luciano. All rights reserved.
//

import UIKit

enum LocationViewType: String {
    case single
    case all
}

class LocationTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    
    var type: LocationViewType = .single
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = .white
    }
}
