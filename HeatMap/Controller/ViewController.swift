//
//  ViewController.swift
//  HeatMap
//
//  Created by Tejaswini Kotagi on 18/07/22.
//

import UIKit

class SearchCollectionReusableView: UICollectionReusableView, UISearchBarDelegate{
    @IBOutlet weak var searchBar: UISearchBar!
}


class CustomCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var view_background: UIView!
    @IBOutlet weak var lbl_symbol: UILabel!
    @IBOutlet weak var lbl_priceChange: UILabel!
    @IBOutlet weak var view_black: UIView!
    override func awakeFromNib() {
        lbl_symbol.font = lbl_symbol.font.withSize(10)
        lbl_priceChange.font = lbl_priceChange.font.withSize(10)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var txt_search: UITextField!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var symbolDict: Symbol?
    var sArray: [String] = [];
    var lArray: [String] = [];
    var scArray: [String] = [];
    var lwArray: [String] = [];
    var shortSymbolArray = [SymbolDetails]()
    var longSymbolArray = [SymbolDetails]()
    var shortCoveringArray = [SymbolDetails]()
    var longUnwindingArray = [SymbolDetails]()
    var allSymbolArray = [SymbolDetails]()
    var filteredArray = [SymbolDetails]()
    var selectedTab = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        collectionView.delegate = self
        collectionView.dataSource = self
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        collectionView.reloadData()
        fetchData()
        uiSetUp()
        
    }
    
    func uiSetUp(){
         
    }
    
    func fetchData(){
        let url = URL(string: "https://qapptemporary.s3.ap-south-1.amazonaws.com/test/synopsis.json" )
        
        let task = URLSession.shared.dataTask(with: url! , completionHandler: { (data, response, error) in
            let responseData = data
            print("responseData ---- \(String(describing: responseData))")
            
            if  let responseDict  = try? JSONSerialization.jsonObject(with: data! , options: .init(rawValue: 0)) as? [String : Any] {
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: responseDict as Any, options: .init(rawValue: 0))
                    self.symbolDict = try Symbol(data:jsonData)
                    self.splitString(s: self.symbolDict?.s ?? "", l: self.symbolDict?.l ?? "", sc: self.symbolDict?.sc ?? "", lw: self.symbolDict?.lu ?? "")
                } catch {
                    print("\(#function) : error : \(String(describing: error.localizedDescription))")
                }
                
            }
            if error != nil {
                print("Error accessing qapptemporary \(String(describing: error))")
                return
            }
        })
        
        task.resume()
    }
    
    func splitString(s: String,l: String,sc: String, lw: String){
        sArray = s.split{$0 == ";"}.map(String.init)
        lArray = l.split{$0 == ";"}.map(String.init)
        scArray = sc.split{$0 == ";"}.map(String.init)
        lwArray = lw.split{$0 == ";"}.map(String.init)
        
        for i in 0..<sArray.count {
            allSymbolArray.append(SymbolDetails(name: sArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(sArray[i].split{$0 == ","}.map(String.init)[3]), category: "s", index: i))
            shortSymbolArray.append(SymbolDetails(name: sArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(sArray[i].split{$0 == ","}.map(String.init)[3]), category: "s", index: i))
            
        }
        
        for i in 0..<lArray.count {
            allSymbolArray.append(SymbolDetails(name: lArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(lArray[i].split{$0 == ","}.map(String.init)[3]), category: "l", index: i))
            longSymbolArray.append(SymbolDetails(name: lArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(lArray[i].split{$0 == ","}.map(String.init)[3]), category: "l", index: i))
        }
        for i in 0..<scArray.count {
            allSymbolArray.append(SymbolDetails(name: scArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(scArray[i].split{$0 == ","}.map(String.init)[3]), category: "sc", index: i))
            shortCoveringArray.append(SymbolDetails(name: scArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(scArray[i].split{$0 == ","}.map(String.init)[3]), category: "sc", index: i))
        }
        for i in 0..<lwArray.count {
            allSymbolArray.append(SymbolDetails(name: lwArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(lwArray[i].split{$0 == ","}.map(String.init)[3]), category: "lw", index: i))
            longUnwindingArray.append(SymbolDetails(name: lwArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: Float(lwArray[i].split{$0 == ","}.map(String.init)[3]), category: "lw", index: i))
        }
        print("allsymbolarray---before\(String(describing: allSymbolArray[0].pricePercentage))")
        allSymbolArray.sort{($0.pricePercentage ?? 0.0 < $1.pricePercentage ?? 0.0)}
        print("allsymbolarray---after\(String(describing: allSymbolArray[0].pricePercentage))")
        filteredArray = allSymbolArray
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            selectedTab = 0
        case 1:
            selectedTab = 1
        case 2:
            selectedTab = 2
        case 3:
            selectedTab = 3
        case 4:
            selectedTab = 4
        default:
            selectedTab = 0
        }
        print("selected Tab -- \(selectedTab)")
        collectionView.reloadData()
    }
    
}
extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedTab{
        case 0:
            return allSymbolArray.count
        case 1:
            return longSymbolArray.count
        case 2:
            return shortCoveringArray.count
        case 3:
            return shortSymbolArray.count
        case 4:
            return longUnwindingArray.count
        default:
            return allSymbolArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        switch selectedTab{
        case 0:
            cell.lbl_symbol.text = allSymbolArray[indexPath.row].name
            cell.lbl_priceChange.text = "\((allSymbolArray[indexPath.row].pricePercentage ?? 0.0) * 100) %"
            print("percentage---\(String(describing: allSymbolArray[indexPath.row].pricePercentage) )---\(indexPath.row)")
            if allSymbolArray[indexPath.row].category == "s"{
                cell.view_background.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1.0)
            }else if allSymbolArray[indexPath.row].category == "l"{
                cell.view_background.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1.0)
            }else if allSymbolArray[indexPath.row].category == "sc"{
                cell.view_background.backgroundColor = UIColor(red: 0, green: 208, blue: 249, alpha: 1.0)
            }else if allSymbolArray[indexPath.row].category == "lw"{
                cell.view_background.backgroundColor = UIColor(red: 255, green: 255, blue: 0, alpha: 1.0)
            }
            cell.view_black.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat((CGFloat(indexPath.row)*0.75)/CGFloat(allSymbolArray.count)))
        case 1:
            cell.lbl_symbol.text = longSymbolArray[indexPath.row].name
            cell.lbl_priceChange.text = "\((longSymbolArray[indexPath.row].pricePercentage ?? 0.0) * 100) %"
            cell.view_background.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1.0)
            cell.view_black.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat((CGFloat(indexPath.row)*0.75)/CGFloat(longSymbolArray.count)))
        case 2:
            cell.lbl_symbol.text = shortCoveringArray[indexPath.row].name
            cell.lbl_priceChange.text = "\((shortCoveringArray[indexPath.row].pricePercentage ?? 0.0) * 100) %"
            cell.view_background.backgroundColor = UIColor(red: 0, green: 208, blue: 249, alpha: 1.0)
            cell.view_black.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat((CGFloat(indexPath.row)*0.75)/CGFloat(shortCoveringArray.count)))
        case 3:
            cell.lbl_symbol.text = shortSymbolArray[indexPath.row].name
            cell.lbl_priceChange.text = "\((shortSymbolArray[indexPath.row].pricePercentage ?? 0.0) * 100) %"
            cell.view_background.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1.0)
            cell.view_black.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat((CGFloat(indexPath.row)*0.75)/CGFloat(shortSymbolArray.count)))
        case 4:
            cell.lbl_symbol.text = longUnwindingArray[indexPath.row].name
            cell.lbl_priceChange.text = "\((longUnwindingArray[indexPath.row].pricePercentage ?? 0.0) * 100) %"
            cell.view_background.backgroundColor = UIColor(red: 255, green: 255, blue: 0, alpha: 1.0)
            cell.view_black.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat((CGFloat(indexPath.row)*0.75)/CGFloat(longUnwindingArray.count)))
        default:
            cell.lbl_symbol.text = allSymbolArray[indexPath.row].name
            cell.lbl_priceChange.text = "\((allSymbolArray[indexPath.row].pricePercentage ?? 0.0) * 100) %"
            print("percentage---\(String(describing: allSymbolArray[indexPath.row].pricePercentage) )---\(indexPath.row)")
            if allSymbolArray[indexPath.row].category == "s"{
                cell.view_background.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1.0)
            }else if allSymbolArray[indexPath.row].category == "l"{
                cell.view_background.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1.0)
            }else if allSymbolArray[indexPath.row].category == "sc"{
                cell.view_background.backgroundColor = UIColor(red: 0, green: 208, blue: 249, alpha: 1.0)
            }else if allSymbolArray[indexPath.row].category == "lw"{
                cell.view_background.backgroundColor = UIColor(red: 255, green: 255, blue: 0, alpha: 1.0)
            }
            cell.view_black.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat((CGFloat(indexPath.row)*0.75)/CGFloat(allSymbolArray.count)))
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth/4 , height: screenWidth/4);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchBar", for: indexPath)as! SearchCollectionReusableView
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
}



extension ViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if(!(searchBar.text?.isEmpty)!){
            self.allSymbolArray.removeAll()
            for item in self.filteredArray {
                if (item.name!.lowercased().contains(searchBar.text!.lowercased())){
                    self.allSymbolArray.append(item)
                }
            }
        }else{
            self.allSymbolArray = self.filteredArray
        }
        collectionView.reloadData()
    }
    
}

