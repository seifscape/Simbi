//
//  SMBCountryPicker.swift
//  Simbi
//
//  Created by flynn on 11/16/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


protocol SMBCountryPickerDelegate {
    func countryPickerDidSelectItem(country: String, codeNum: Int, codeStr: String)
}


class SMBCountryPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let countriesKeys: [String] = kCountriesArray
    
    var currentCountry: String?
    var currentCodeNum: Int?
    var currentCodeStr: String?
    
    var countryPickerDelegate: SMBCountryPickerDelegate?
    
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        currentCountry = countriesKeys[0]
        currentCodeNum = kCountriesDict[currentCountry!]!
        currentCodeStr = formatCountryCode(currentCodeNum!)
        
        self.dataSource = self
        self.delegate = self
    }
    
    
    func formatCountryCode(code: Int) -> String {
        
        var str = String(code)
        
        if str.characters.count > 3 {
            str.insert(" ", atIndex: str.endIndex.advancedBy(-3))
        }
        
        return str
    }

    
    // MARK: - UIPickerDataSource/Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kCountriesDict.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let countryName = countriesKeys[row]
        let countryCode = formatCountryCode(kCountriesDict[countryName]!)
        
        return "\(countryName) (+\(countryCode))"
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        currentCountry = countriesKeys[row]
        currentCodeNum = kCountriesDict[currentCountry!]!
        currentCodeStr = formatCountryCode(currentCodeNum!)
        
        countryPickerDelegate?.countryPickerDidSelectItem(currentCountry!, codeNum: currentCodeNum!, codeStr: currentCodeStr!)
    }
}
