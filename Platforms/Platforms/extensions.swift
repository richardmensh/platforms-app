//
//  extensions.swift
//  Platforms
//
//  Created by Richard Essemiah on 01/05/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func downloadImg(from url: String) {
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.sync {
                    self.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
}
