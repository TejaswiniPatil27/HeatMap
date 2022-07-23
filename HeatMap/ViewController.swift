//
//  ViewController.swift
//  HeatMap
//
//  Created by Tejaswini Kotagi on 18/07/22.
//

import UIKit

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
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var symbolDict: Symbol?
    var shortSymbol: String = ""
    var longSymbol: String = ""
    var shortCoveringSymbol: String = ""
    var longUnwindingSymbol: String = ""
    var shortSymbolArray: [String] = [];
    var longSymbolArray: [String] = [];
    var shortCoveringSymbolArray: [String] = [];
    var longUnwindingSymbolArray: [String] = [];
    var allSymbolArray = [SymbolDetails]()
    var totalColors: Int = 0
    
//    func colorForIndexPath(indexPath: IndexPath) -> UIColor {
//        totalColors = shortSymbolArray.count
//        if indexPath.row >= totalColors {
//            return UIColor.black    // return black if we get an unexpected row index
//        }
//
//        let hueValue: CGFloat = CGFloat(indexPath.row) / CGFloat(totalColors)
//        return UIColor(red: 0, green: hueValue, blue: 0, alpha: 1.0)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        collectionView.delegate = self
        collectionView.dataSource = self
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        fetchData()

    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
                    print("SymbolDict----\(String(describing: self.symbolDict))")
                    self.shortSymbol = self.symbolDict?.s ?? ""
                    print("Short symbol ----\(self.shortSymbol )")
                    self.longSymbol = self.symbolDict?.l ?? ""
                    print("long symbol ----\(self.longSymbol )")
                    self.shortCoveringSymbol = self.symbolDict?.sc ?? ""
                    print("shortCoveringSymbol  ----\(self.shortCoveringSymbol )")
                    self.longUnwindingSymbol = self.symbolDict?.lu ?? ""
                    print("longUnwindingSymbol  ----\(self.longUnwindingSymbol )")
//                    self.collectionView.reloadData()
                    self.splitString()
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
    func splitString(){
        shortSymbolArray = shortSymbol.split{$0 == ";"}.map(String.init)
        longSymbolArray = longSymbol.split{$0 == ";"}.map(String.init)
        shortCoveringSymbolArray = shortCoveringSymbol.split{$0 == ";"}.map(String.init)
        longUnwindingSymbolArray = longUnwindingSymbol.split{$0 == ";"}.map(String.init)
        
        for i in 0..<shortSymbolArray.count {
            allSymbolArray.append(SymbolDetails(name: shortSymbolArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: shortSymbolArray[i].split{$0 == ","}.map(String.init)[3], category: "s", index: i))
        }
    
        for i in 0..<longSymbolArray.count {
            allSymbolArray.append(SymbolDetails(name: longSymbolArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: longSymbolArray[i].split{$0 == ","}.map(String.init)[3], category: "l", index: i))
        }
        for i in 0..<shortCoveringSymbolArray.count {
            allSymbolArray.append(SymbolDetails(name: shortCoveringSymbolArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: shortCoveringSymbolArray[i].split{$0 == ","}.map(String.init)[3], category: "sc", index: i))
        }
        for i in 0..<longUnwindingSymbolArray.count {
            allSymbolArray.append(SymbolDetails(name: longUnwindingSymbolArray[i].split{$0 == ","}.map(String.init)[0], pricePercentage: longUnwindingSymbolArray[i].split{$0 == ","}.map(String.init)[3], category: "lw", index: i))
        }
        print("allsymbolarray---\(allSymbolArray)")
        allSymbolArray.sort{($0.pricePercentage ?? "" < $1.pricePercentage ?? "")}
    }

    
}
extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("symbolarray---\(shortSymbolArray.count)")
        return allSymbolArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.lbl_symbol.text = allSymbolArray[indexPath.row].name
        cell.lbl_priceChange.text = allSymbolArray[indexPath.row].pricePercentage
        if allSymbolArray[indexPath.row].category == "s"{
            cell.view_background.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1.0)
            
        }else if allSymbolArray[indexPath.row].category == "l"{
            cell.view_background.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1.0)
        }else if allSymbolArray[indexPath.row].category == "sc"{
            cell.view_background.backgroundColor = UIColor(red: 0, green: 208, blue: 249, alpha: 1.0)
        }else if allSymbolArray[indexPath.row].category == "lw"{
            cell.view_background.backgroundColor = UIColor(red: 255, green: 255, blue: 0, alpha: 1.0)
        }
        cell.view_black.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat((CGFloat(allSymbolArray[indexPath.row].index)*0.75)/CGFloat(allSymbolArray.count)) )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }  
}
