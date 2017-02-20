//
//  DetailViewController.swift
//  iBooFlickr
//
//  Created by Miquel Viladomat on 13/2/17.
//  Copyright © 2017 Miquel Viladomat. All rights reserved.
//

import UIKit
protocol DetailViewControllerDelegate: class {
    func changeSwift(photo: Photo, position: Int)
}
class DetailViewController: UIViewController {
    weak var delegate:ViewController!
    let defaultSeason = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    var dataTask: NSURLSessionDataTask?
    var photo: Photo = Photo()
    var position:Int = 0

    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPhoto.image=UIImage(data: NSData(contentsOfURL: NSURL(string: "\("https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.ide)_\(photo.secret).jpg")")!)!)
        statusSwitch.on = photo.state

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func change(sender: AnyObject) {
        photo.state = sender.on
        print(sender.on)
        delegate?.changeSwift(photo,position: position)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
