//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Prasanthi Relangi on 2/14/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filterViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
    
}

class FiltersViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SwitchCellDelegate {

    var categories:[[String:String]]!
    //Empty dictionary
    var switchStates = [Int:Bool]()
    var dealState: Bool = false
    var selectedDistance:Int?
    
    var selectedSortType:YelpSortMode?
    var sortTypes: [String] = ["Best Match", "Distance", "Highest Rated"]
    var sortValues: [YelpSortMode] = [YelpSortMode.BestMatched, YelpSortMode.Distance, YelpSortMode.HighestRated]
    
    var sortSelected: [Bool] = [false,false,false]
    
    var distanceLabels: [String] = ["0.3 miles", "1 mile", "3 miles", "5 miles"]
    var distanceValues: [Int] = [482, 1609, 4828, 8046]
    var distanceSelected: [Bool] = [false,false,false,false]
    
    var distanceCollapsedView = false
    //rgb(196,18,0)
    var yelpRedColor = UIColor(red: 196/255.0, green: 18/255.0, blue: 0/255.0, alpha: 1.0)

    
    
    weak var delegate:FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        tableView.dataSource = self
        tableView.delegate = self
        
        
        self.navigationController!.navigationBar.barTintColor = yelpRedColor
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true,completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func onSearchButton(sender: AnyObject) {
        //Dismiss the current view controller
        dismissViewControllerAnimated(true,completion: nil)
        
        var filters = [String: AnyObject]()
        
        var selectedCategories =  [String]()
        for (row,isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        if dealState {
            filters["deals"] = dealState
        }
        
        if (selectedDistance != nil) {
            filters["radius"] = selectedDistance
        }
        
        if (selectedSortType != nil) {
            filters["sortType"] = selectedSortType?.rawValue
        }
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //
        if(section==0) {
            return 1
        }
        
        //Distance
        if(section==1) {
            if(distanceCollapsedView) {
                return 1
            }
            else {
                return 4
            }
        }
        
        //Sort type
        if(section==2) {
            return 3
        }
        if(section==3) {
            return categories.count
        }
        
        return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SwitchCell!
        
        //Deals
        if(indexPath.section==0) {
            cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = "Offering a Deal"
            
            cell.delegate = self
            cell.onSwitch.on = dealState
            
        }
        
        //Distance
        if(indexPath.section==1) {
            cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = distanceLabels[indexPath.row]
            cell.delegate = self
            cell.onSwitch.on = distanceSelected[indexPath.row]
        }
        
        //Sort by
        if(indexPath.section==2) {
            cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = sortTypes[indexPath.row]
            cell.delegate = self
            cell.onSwitch.on = sortSelected[indexPath.row]
            
        }
        
        //Categories
        if(indexPath.section==3) {
            cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = switchStates[indexPath.row] ?? false
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section==1) {
            distanceCollapsedView = false
            self.tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }// Default is 1 if not implemented
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionName:String = ""
        if(section==0) {
            sectionName = "Deal"
        }
        if(section==1) {
            sectionName = "Distance"
        }
        if(section==2) {
            sectionName = "Sort by"
        }
        if(section==3) {
            sectionName = "Categories"
        }
        
        return sectionName
        
    }
    
    
    func switchCell(switchCell:SwitchCell,
        didChangeValue value: Bool) {
            let indexPath = tableView.indexPathForCell(switchCell)!
            
            if(indexPath.section==0) {
                dealState = value
                print("dealState set to \(dealState)")
            }
            if(indexPath.section==1) {
                selectedDistance = distanceValues[indexPath.row]
                distanceSelected[indexPath.row] = value
                print("selectedDistance = \(selectedDistance)m")
            }
            
            if(indexPath.section==2) {
                switch indexPath.row {
                case 0:selectedSortType = YelpSortMode.BestMatched
                case 1: selectedSortType = YelpSortMode.Distance
                case 2: selectedSortType = YelpSortMode.HighestRated
                default: selectedSortType = YelpSortMode.BestMatched
                }
                //selectedSortType = sortValues[indexPath.row]
                sortSelected[indexPath.row] = value
                print("selectedSortType = \(selectedSortType)")
            }
            
            if(indexPath.section==3) {
                switchStates[indexPath.row] = value
            }
            
            
            print("Filter view saw switch cell event for section: \(indexPath.section) row: \(indexPath.row)")
            
    }
    
    
    func yelpCategories()->[[String:String]] {
        return[["name" : "Afghan", "code": "afghani"],
        ["name" : "African", "code": "african"],
        ["name" : "American, New", "code": "newamerican"],
        ["name" : "American, Traditional", "code": "tradamerican"],
        ["name" : "Arabian", "code": "arabian"],
        ["name" : "Argentine", "code": "argentine"],
        ["name" : "Armenian", "code": "armenian"],
        ["name" : "Asian Fusion", "code": "asianfusion"],
        ["name" : "Asturian", "code": "asturian"],
        ["name" : "Australian", "code": "australian"],
        ["name" : "Austrian", "code": "austrian"],
        ["name" : "Baguettes", "code": "baguettes"],
        ["name" : "Bangladeshi", "code": "bangladeshi"],
        ["name" : "Barbeque", "code": "bbq"],
        ["name" : "Basque", "code": "basque"],
        ["name" : "Bavarian", "code": "bavarian"],
        ["name" : "Beer Garden", "code": "beergarden"],
        ["name" : "Beer Hall", "code": "beerhall"],
        ["name" : "Beisl", "code": "beisl"],
        ["name" : "Belgian", "code": "belgian"],
        ["name" : "Bistros", "code": "bistros"],
        ["name" : "Black Sea", "code": "blacksea"],
        ["name" : "Brasseries", "code": "brasseries"],
        ["name" : "Brazilian", "code": "brazilian"],
        ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
        ["name" : "British", "code": "british"],
        ["name" : "Buffets", "code": "buffets"],
        ["name" : "Bulgarian", "code": "bulgarian"],
        ["name" : "Burgers", "code": "burgers"],
        ["name" : "Burmese", "code": "burmese"],
        ["name" : "Cafes", "code": "cafes"],
        ["name" : "Cafeteria", "code": "cafeteria"],
        ["name" : "Cajun/Creole", "code": "cajun"],
        ["name" : "Cambodian", "code": "cambodian"],
        ["name" : "Canadian", "code": "New)"],
        ["name" : "Canteen", "code": "canteen"],
        ["name" : "Caribbean", "code": "caribbean"],
        ["name" : "Catalan", "code": "catalan"],
        ["name" : "Chech", "code": "chech"],
        ["name" : "Cheesesteaks", "code": "cheesesteaks"],
        ["name" : "Chicken Shop", "code": "chickenshop"],
        ["name" : "Chicken Wings", "code": "chicken_wings"],
        ["name" : "Chilean", "code": "chilean"],
        ["name" : "Chinese", "code": "chinese"],
        ["name" : "Comfort Food", "code": "comfortfood"],
        ["name" : "Corsican", "code": "corsican"],
        ["name" : "Creperies", "code": "creperies"],
        ["name" : "Cuban", "code": "cuban"],
        ["name" : "Curry Sausage", "code": "currysausage"],
        ["name" : "Cypriot", "code": "cypriot"],
        ["name" : "Czech", "code": "czech"],
        ["name" : "Czech/Slovakian", "code": "czechslovakian"],
        ["name" : "Danish", "code": "danish"],
        ["name" : "Delis", "code": "delis"],
        ["name" : "Diners", "code": "diners"],
        ["name" : "Dumplings", "code": "dumplings"],
        ["name" : "Eastern European", "code": "eastern_european"],
        ["name" : "Ethiopian", "code": "ethiopian"],
        ["name" : "Fast Food", "code": "hotdogs"],
        ["name" : "Filipino", "code": "filipino"],
        ["name" : "Fish & Chips", "code": "fishnchips"],
        ["name" : "Fondue", "code": "fondue"],
        ["name" : "Food Court", "code": "food_court"],
        ["name" : "Food Stands", "code": "foodstands"],
        ["name" : "French", "code": "french"],
        ["name" : "French Southwest", "code": "sud_ouest"],
        ["name" : "Galician", "code": "galician"],
        ["name" : "Gastropubs", "code": "gastropubs"],
        ["name" : "Georgian", "code": "georgian"],
        ["name" : "German", "code": "german"],
        ["name" : "Giblets", "code": "giblets"],
        ["name" : "Gluten-Free", "code": "gluten_free"],
        ["name" : "Greek", "code": "greek"],
        ["name" : "Halal", "code": "halal"],
        ["name" : "Hawaiian", "code": "hawaiian"],
        ["name" : "Heuriger", "code": "heuriger"],
        ["name" : "Himalayan/Nepalese", "code": "himalayan"],
        ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
        ["name" : "Hot Dogs", "code": "hotdog"],
        ["name" : "Hot Pot", "code": "hotpot"],
        ["name" : "Hungarian", "code": "hungarian"],
        ["name" : "Iberian", "code": "iberian"],
        ["name" : "Indian", "code": "indpak"],
        ["name" : "Indonesian", "code": "indonesian"],
        ["name" : "International", "code": "international"],
        ["name" : "Irish", "code": "irish"],
        ["name" : "Island Pub", "code": "island_pub"],
        ["name" : "Israeli", "code": "israeli"],
        ["name" : "Italian", "code": "italian"],
        ["name" : "Japanese", "code": "japanese"],
        ["name" : "Jewish", "code": "jewish"],
        ["name" : "Kebab", "code": "kebab"],
        ["name" : "Korean", "code": "korean"],
        ["name" : "Kosher", "code": "kosher"],
        ["name" : "Kurdish", "code": "kurdish"],
        ["name" : "Laos", "code": "laos"],
        ["name" : "Laotian", "code": "laotian"],
        ["name" : "Latin American", "code": "latin"],
        ["name" : "Live/Raw Food", "code": "raw_food"],
        ["name" : "Lyonnais", "code": "lyonnais"],
        ["name" : "Malaysian", "code": "malaysian"],
        ["name" : "Meatballs", "code": "meatballs"],
        ["name" : "Mediterranean", "code": "mediterranean"],
        ["name" : "Mexican", "code": "mexican"],
        ["name" : "Middle Eastern", "code": "mideastern"],
        ["name" : "Milk Bars", "code": "milkbars"],
        ["name" : "Modern Australian", "code": "modern_australian"],
        ["name" : "Modern European", "code": "modern_european"],
        ["name" : "Mongolian", "code": "mongolian"],
        ["name" : "Moroccan", "code": "moroccan"],
        ["name" : "New Zealand", "code": "newzealand"],
        ["name" : "Night Food", "code": "nightfood"],
        ["name" : "Norcinerie", "code": "norcinerie"],
        ["name" : "Open Sandwiches", "code": "opensandwiches"],
        ["name" : "Oriental", "code": "oriental"],
        ["name" : "Pakistani", "code": "pakistani"],
        ["name" : "Parent Cafes", "code": "eltern_cafes"],
        ["name" : "Parma", "code": "parma"],
        ["name" : "Persian/Iranian", "code": "persian"],
        ["name" : "Peruvian", "code": "peruvian"],
        ["name" : "Pita", "code": "pita"],
        ["name" : "Pizza", "code": "pizza"],
        ["name" : "Polish", "code": "polish"],
        ["name" : "Portuguese", "code": "portuguese"],
        ["name" : "Potatoes", "code": "potatoes"],
        ["name" : "Poutineries", "code": "poutineries"],
        ["name" : "Pub Food", "code": "pubfood"],
        ["name" : "Rice", "code": "riceshop"],
        ["name" : "Romanian", "code": "romanian"],
        ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
        ["name" : "Rumanian", "code": "rumanian"],
        ["name" : "Russian", "code": "russian"],
        ["name" : "Salad", "code": "salad"],
        ["name" : "Sandwiches", "code": "sandwiches"],
        ["name" : "Scandinavian", "code": "scandinavian"],
        ["name" : "Scottish", "code": "scottish"],
        ["name" : "Seafood", "code": "seafood"],
        ["name" : "Serbo Croatian", "code": "serbocroatian"],
        ["name" : "Signature Cuisine", "code": "signature_cuisine"],
        ["name" : "Singaporean", "code": "singaporean"],
        ["name" : "Slovakian", "code": "slovakian"],
        ["name" : "Soul Food", "code": "soulfood"],
        ["name" : "Soup", "code": "soup"],
        ["name" : "Southern", "code": "southern"],
        ["name" : "Spanish", "code": "spanish"],
        ["name" : "Steakhouses", "code": "steak"],
        ["name" : "Sushi Bars", "code": "sushi"],
        ["name" : "Swabian", "code": "swabian"],
        ["name" : "Swedish", "code": "swedish"],
        ["name" : "Swiss Food", "code": "swissfood"],
        ["name" : "Tabernas", "code": "tabernas"],
        ["name" : "Taiwanese", "code": "taiwanese"],
        ["name" : "Tapas Bars", "code": "tapas"],
        ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
        ["name" : "Tex-Mex", "code": "tex-mex"],
        ["name" : "Thai", "code": "thai"],
        ["name" : "Traditional Norwegian", "code": "norwegian"],
        ["name" : "Traditional Swedish", "code": "traditional_swedish"],
        ["name" : "Trattorie", "code": "trattorie"],
        ["name" : "Turkish", "code": "turkish"],
        ["name" : "Ukrainian", "code": "ukrainian"],
        ["name" : "Uzbek", "code": "uzbek"],
        ["name" : "Vegan", "code": "vegan"],
        ["name" : "Vegetarian", "code": "vegetarian"],
        ["name" : "Venison", "code": "venison"],
        ["name" : "Vietnamese", "code": "vietnamese"],
        ["name" : "Wok", "code": "wok"],
        ["name" : "Wraps", "code": "wraps"],
        ["name" : "Yugoslav", "code": "yugoslav"]]
    }

}
