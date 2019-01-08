//
//  MovieTableViewCell.swift
//  TMDBApp
//
//  Created by Damian Modernell on 09/11/2018.
//  Copyright © 2018 Damian Modernell. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    func setMovie(movie:Movie, mewIndexPath:IndexPath, imageCompletion:@escaping (UIImage, IndexPath) -> ()) {
        self.movieTitleLabel.text = movie.title
        self.movieImageView.image = nil
        self.movieImageView.alpha = 0
        movie.getImage(completion: {[weak self] (image:UIImage?) ->() in
            let cellImage = image != nil ? image : UIImage(named: "default")
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self?.movieImageView.alpha = 1
            },
                           completion:nil
            )
            imageCompletion(cellImage!, mewIndexPath)
        })
    }
    
}
