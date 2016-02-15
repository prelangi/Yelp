//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FiltersViewControllerDelegate,UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    var filtered: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120 //used only for scroll height
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        
        
        // the UIViewController comes with a navigationItem property
        // this will automatically be initialized for you if when the
        // view controller is added to a navigation controller's stack
        // you just need to set the titleView to be the search bar
        navigationItem.titleView = searchBar
        
        fetchBusinesses("Restaurants")


    }
    
    func fetchBusinesses(searchTerm: String) {
        Business.searchWithTerm(searchTerm, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            self.tableView.reloadData()
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if businesses != nil {
            return businesses!.count
        }
        else {
            return 0
        }
        
    }
    

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
        
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destinationViewController as! UINavigationController
        let filters = navigationController.topViewController as! FiltersViewController
        
            filters.delegate = self
        
    }
    
    func filtersViewController(filterViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject]) {
        
        let categories = filters["categories"] as? [String]
        let deals = filters["deals"] as? Bool
        let radius = filters["radius"] as? Int
        let sortType = filters["sortType"] as? Int
        let yelpSortType = (sortType==0) ? YelpSortMode.BestMatched : ((sortType==1) ? YelpSortMode.Distance : YelpSortMode.HighestRated)
        
        
        print("In delegate method: sortType = \(sortType)")

        Business.searchWithTerm("Restaurants", sort: yelpSortType, categories: categories, deals: deals,radius: radius) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
        }
    }
    
    ///// Search Bar functionality
    func searchBar(searchBar: UISearchBar,  textDidChange searchText: String) {
        var searchTerm: String = ""
        if(searchText=="") {
            searchTerm = "Restaurants"
        }
        else {
            searchTerm = searchText
        }
        
        fetchBusinesses(searchTerm)
        

    }
    
    //******  Search Bar functions
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    

}
