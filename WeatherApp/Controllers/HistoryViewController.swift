//
//  HistoryViewController.swift
//  WeatherApp
//
//  Created by admin on 6/23/22.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    
    var historyList: [Search] = []

    @IBOutlet weak var searchHistoryTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDataFromCoreData()
    }
    
    private func setup() {
        searchHistoryTable.delegate = self
        searchHistoryTable.dataSource = self
        searchHistoryTable.register(UINib(nibName: HistoryTableViewCell.uiNibName, bundle: nil), forCellReuseIdentifier: HistoryTableViewCell.identifier)
    }
    
    private func loadDataFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchContext = NSFetchRequest<Search>(entityName: "Search")
        do {
            let dbSearch = try context.fetch(fetchContext)
            self.historyList = dbSearch
            self.searchHistoryTable.reloadData()
        } catch (let error) {
            self.showError(error: error.localizedDescription)
        }
    }
    
    private func showError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            print("OK")
        }))
        self.present(alert, animated: true, completion: nil)
    }

}


//MARK: Table extension
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchHistoryTable.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as? HistoryTableViewCell ?? HistoryTableViewCell()
        let search = historyList[indexPath.row]
        cell.searchedCityLabel.text = search.searchString
        
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        cell.searchDateLabel.text = dateFormatterPrint.string(from: search.createdAt)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityData = historyList[indexPath.row]
        guard let vc = UIStoryboard(name: WeatherDetailViewController.storyboardName, bundle: nil).instantiateViewController(withIdentifier: WeatherDetailViewController.identifier) as? WeatherDetailViewController else { return }
        vc.cityIdString = cityData.cityId
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
