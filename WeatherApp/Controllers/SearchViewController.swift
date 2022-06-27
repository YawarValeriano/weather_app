//
//  ViewController.swift
//  WeatherApp
//
//  Created by admin on 6/23/22.
//

import UIKit
import SVProgressHUD
import CoreData

class SearchViewController: UIViewController {

    @IBOutlet weak var cityDataTableView: UITableView!
    @IBOutlet weak var citySearchBar: UISearchBar!
    
    @IBOutlet weak var bottomTableConstraint: NSLayoutConstraint!
    var searchResults: [CityWeather] = []
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        cityDataTableView.dataSource = self
        cityDataTableView.delegate = self
        citySearchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        cityDataTableView.register(UINib(nibName: SearchTableViewCell.uiNibName, bundle: nil), forCellReuseIdentifier: SearchTableViewCell.identifier)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        bottomTableConstraint.constant = keyboardFrame.size.height
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        bottomTableConstraint.constant = 5
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func showError(withDescription error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            print("OK")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func convertFahrenheitToCelcius(_ temperature: Double) -> String {
        let rounded = round((temperature - 273.15) * 10) / 10
        return "\(rounded) Cº"
    }
}

// MARK: Table View Extension
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell ?? SearchTableViewCell()
        let cityData = searchResults[indexPath.row]
        let weatherDetail = cityData.weather[0]
        cell.cityNameLabel.text = "\(cityData.name), \(cityData.sys.country)"
        cell.temperatureLabel.text = self.convertFahrenheitToCelcius(cityData.main.temp)
        cell.weatherStatusLabel.text = weatherDetail.weatherDescription.capitalized
        if let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(weatherDetail.icon)@2x.png") {
            cell.weatherImage.image = ImageManager.shared.getUIImage(formURL: iconUrl)
        }
        
        return cell
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityData = searchResults[indexPath.row]
        let fetchRequest = NSFetchRequest<Search>(entityName: "Search")
        fetchRequest.predicate = NSPredicate(format: "cityId == %@", String(cityData.id))
        CoreDataManager.shared.fetchSearchHistory(Search.self, request: fetchRequest, completion: { result in
            switch result {
            case .success(let data):
                if data.isEmpty {
                    self.saveInCoreDataAfterTap(cityId: String(cityData.id), searchString: "\(cityData.name), \(cityData.sys.country)")
                }
                self.showWeatherDetailViewController(String(cityData.id))
                break
            case .failure(let error):
                self.showError(withDescription: error.localizedDescription)
                break
            }
            
        })
        
    }
    
    func showWeatherDetailViewController(_ cityId: String) {
        guard let vc = UIStoryboard(name: WeatherDetailViewController.storyboardName, bundle: nil).instantiateViewController(withIdentifier: WeatherDetailViewController.identifier) as? WeatherDetailViewController else { return }
        vc.cityIdString = String(cityId)
        show(vc, sender: nil)
    }
    
    func saveInCoreDataAfterTap(cityId: String, searchString: String) {
        let context = CoreDataManager.shared.getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Search", in: context) else { return }
        guard let city = NSManagedObject(entity: entity, insertInto: context) as? Search else { return }


        city.cityId = cityId
        city.searchString = searchString
        city.createdAt = Date()

        CoreDataManager.shared.saveContext()
    }

}

//MARK: SearchBar extension
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        guard let cityText = searchBar.text else { return }
        let formatedCity = cityText.replacingOccurrences(of: " ", with: "+")
        let urlStr = "https://openweathermap.org/data/2.5/find?q=\(formatedCity)&appid=439d4b804bc8187953eb36d2a8c26a02"
        guard let url = URL(string: urlStr) else { return }
        SVProgressHUD.show()
        NetworkManager.shared.get(WeatherResult.self, from: url) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let data):
                self.searchResults = data.list
                self.cityDataTableView.reloadData()
            case .failure(let error):
                self.showError(withDescription: error.localizedDescription)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
