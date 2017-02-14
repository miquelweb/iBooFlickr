//
//  ViewController.swift
//  iBooFlickr
//
//  Created by Miquel Viladomat on 13/2/17.
//  Copyright © 2017 Miquel Viladomat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var table: UITableView!
    
    let defaultSeason = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    var dataTask: NSURLSessionDataTask?
    
    
    var photosArray = [Photo]()
    
    
    var totalItems:Int = 0;
    var currentPage:Int = 1;
    var loadingMore:Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchFlickr(currentPage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchFlickr(page:Int){
        
        let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=939af47c832dd92c423d68dd2c23e54b&text=Barcelona&format=json&nojsoncallback=1&per_page=20&page="+String(page))
        
        if dataTask != nil{
            dataTask?.cancel()
        }
        dataTask = defaultSeason.dataTaskWithURL(url!){
            data, response, error in
            if let error = error{print("\(error)")}
            else if let httpResponse = response as? NSHTTPURLResponse{
                if  httpResponse.statusCode == 200{
                    do{
                        if let data = data, let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]{
                            let photos = response["photos"] as? [String: AnyObject]
                            let photosData = photos!["photo"] as! NSArray
                            //print ("photoData:"+photoData)
                            NSOperationQueue.mainQueue().addOperationWithBlock{
                                var n:Int = 0
                                while(n<photosData.count){
                                    let photoData = photosData[n]
                                    let photo:Photo =  Photo()
                                    photo.farm = photoData["farm"] as! Int
                                    photo.server = photoData["server"] as! String
                                    photo.ide = photoData ["id"] as!String
                                    photo.secret = photoData["secret"] as! String
                                    self.photosArray.append(photo)
                                    n += 1
                                }
                                self.loadingMore=false
                                self.table.reloadData();
                            }
                            
                        }
                        
                        
                    }
                    catch let error as NSError{print("\(error)")}
                }
                else {print("\(httpResponse.statusCode)")}
            }
            
        }
        dataTask?.resume()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "detailSegue"){
            let indexPath:NSIndexPath = sender as! NSIndexPath
            let destination:DetailViewController = segue.destinationViewController as! DetailViewController
            let photo = photosArray[indexPath.row]
            destination.photo=photo
        }
    }

}
extension ViewController:UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosArray.count+1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row==photosArray.count){
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath)
            let label = cell.viewWithTag(1) as! UILabel
            label.text = NSLocalizedString("loading_more", comment: "")
            loadingMore=true
            currentPage += 1
            searchFlickr(currentPage)
            return cell
        }
        else{
            
        
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath)
            let photo = photosArray[indexPath.row]
            let photoImageView = cell.viewWithTag(1) as! UIImageView
            
            
            let switchElement = cell.viewWithTag(2) as! UISwitch
            switchElement.addTarget(self, action: #selector(ViewController.switchPress(_:)), forControlEvents: UIControlEvents.ValueChanged)


            photoImageView.image=UIImage(data: NSData(contentsOfURL: NSURL(string: "\("https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.ide)_\(photo.secret).jpg")")!)!)
            
            return cell
        }
    }
    func switchPress(sender:UISwitch){
        let cell = sender.superview?.superview as! UITableViewCell
        let row = table.indexPathForCell(cell)?.row
        
        let photo = photosArray[row!] 
        photo.state = sender.on
    }
}
extension ViewController:UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("detailSegue", sender: indexPath)
    }
}

