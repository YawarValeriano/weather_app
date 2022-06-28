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
        let fetchContext = NSFetchRequest<Search>(entityName: "Search")
        CoreDataManager.shared.fetchSearchHistory(Search.self, request: fetchContext, completion: { result in
            switch result {
            case .success(let data):
                self.historyList = data
                self.searchHistoryTable.reloadData()
                break
            case .failure(let error):
                self.showError(error: error.localizedDescription)
                break
            }
        })
        
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
    
    private func showDeleteAlert(searchItem: Search, index: Int) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete the item from history?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:  { action in
            
            CoreDataManager.shared.deleteItem(item: searchItem) { result in
                switch result {
                case .failure(let error):
                    self.showError(error: error.localizedDescription)
                    break
                case .success(()):
                    self.historyList.remove(at: index)
                    self.searchHistoryTable.reloadData()
                    break
                }
            }
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.historyList[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove", handler: {_,_,_ in
            self.showDeleteAlert(searchItem: item, index: indexPath.row)
        })
        deleteAction.image = UIImage(systemName: "trash")
        let actions = [
            deleteAction
        ]
        return UISwipeActionsConfiguration(actions: actions)
    }
    
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
