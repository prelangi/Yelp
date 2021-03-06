//
//  BusinessCell.swift
//  Yelp
//
//  Created by Prasanthi Relangi on 2/12/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    
    
    
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    
    @IBOutlet weak var reviewsLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBOutlet weak var thumbImageView: UIImageView!

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
   
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            if let imageURL = business.imageURL {
               thumbImageView.setImageWithURL(imageURL)
            }
            else {
                thumbImageView.image = nil
            }
            
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            ratingsImageView.setImageWithURL(business.ratingImageURL!)
            distanceLabel.text = business.distance
            reviewsLabel.text = "\(business.reviewCount!)"
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
