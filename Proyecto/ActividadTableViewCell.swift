//
//  ActividadTableViewCell.swift
//  Proyecto
//
//  Created by dam on 31/1/17.
//  Copyright © 2017 dam. All rights reserved.
//

import UIKit

class ActividadTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tituloLabel: UILabel!
    
    @IBOutlet weak var profesorLabel: UILabel!
    
    @IBOutlet weak var grupoLabel: UILabel!
    
    @IBOutlet weak var lugarLabel: UILabel!
    
    @IBOutlet weak var fechaLabel: UILabel!
    
    @IBOutlet weak var horaIniLabel: UILabel!
    
    @IBOutlet weak var horaFinLabel: UILabel!
    
    @IBOutlet weak var imagen: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
