//
//  ViewController.swift
//  GitHub Viewer
//
//  Created by Marek Bartak on 12.10.2021.
//

import UIKit

class RepositoryViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var networkingManager = NetworkingManager()
    
    var repository: [RepositoryModel]? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 104/255.0, green: 120/255.0, blue: 217/255.0, alpha: 1.0) // same color as icon
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        tableView.rowHeight = 60
        
        networkingManager.delegate = self
        networkingManager.fetchData()
        
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if repository == nil {
            return 0
        } else {
            let numberOfRowsInSection = repository?.count == 0 ? 1 : repository!.count
            return numberOfRowsInSection
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GitHubCell") as! RepositoryTableViewCell
        
        if let safeRepository = repository {
            if safeRepository.count != 0 {
                cell.repositoryTitle?.text = safeRepository[indexPath.row].name
                cell.repositorySubtitle?.text = safeRepository[indexPath.row].description
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
                
            } else {
                cell.selectionStyle = .none
                cell.accessoryType = .none
                cell.repositoryTitle?.text = "No repository found"
                cell.repositorySubtitle?.text = ""
            }
        }
        return cell
    }
    
    // MARK: - Seque methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if repository?.count != 0 {
        performSegue(withIdentifier: "ShowDetailWebView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailWebViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.repository = repository?[indexPath.row]
        }
    }
}

// MARK: - NetworkingManagerDelegate

extension RepositoryViewController: NetworkingManagerDelegate {
    
    func didFailWithError(_ errorSpot: String, _ error: Error) {
        
        DispatchQueue.main.async {
            let errorMessage = String(error.localizedDescription)
            let alert = UIAlertController(title: "Error: \(errorSpot)", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didUpdateRepositoryView(_ networkingManager: NetworkingManager, _ allRepository: [RepositoryModel]) {
        DispatchQueue.main.async {
            self.repository = allRepository
        }
    }
}

// MARK: - Search bar methods

extension RepositoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let safeSearchText = searchBar.text {
            networkingManager.fetchData(searchText: safeSearchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            repository = nil
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - RepositoryTableViewCell

class RepositoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var repositoryTitle: UILabel!
    @IBOutlet weak var repositorySubtitle: UILabel!
    
}
