//
//  MainViewController.swift
//  MyPlaces
//
//  Created by mac on 07.07.2023.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {

    // MARK: - Variables

    private var places: Results<Place>! // Returns "Place" objects from the database
    private var filtredPlaces: Results<Place>!

    private let searchController = UISearchController(searchResultsController: nil)
    private let searchBar = UISearchBar()

    private var sortedSegmentedControll = 0 // Helper variable for sorting
    private var myAscending = true

    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)

        setupSearchController()

        NotificationCenter.default.addObserver(self, selector: #selector(sortingSelection(_ :)), name: Notification.Name("SortSelectionDidChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reversedSorting(_ :)), name: Notification.Name("ReversedSortingDidChanged"), object: nil)
    }

    //MARK: - Setup searchController

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.isActive = false
        navigationItem.searchController = searchController
        searchController.definesPresentationContext = true

        navigationItem.hidesSearchBarWhenScrolling = true
    }

    //MARK: - Notification observers

    @objc func sortingSelection(_ notification: Notification) {
        if let selectedOption = notification.object as? Int {

            if selectedOption == 0 {
                places = places.sorted(byKeyPath: "date", ascending: myAscending)
                sortedSegmentedControll = 0
            } else {
                places = places.sorted(byKeyPath: "name", ascending: myAscending)
                sortedSegmentedControll = 1
            }
            tableView.reloadData()
        }
    }

    @objc func reversedSorting(_ notification: Notification) {
        if let selectedOption = notification.object as? Bool {

            if sortedSegmentedControll == 0 {
                places = places.sorted(byKeyPath: "date", ascending: selectedOption)
                myAscending = selectedOption
            } else {
                places = places.sorted(byKeyPath: "name", ascending: selectedOption)
                myAscending = selectedOption
            }
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            // Cells that match the user's search
            return filtredPlaces.count
        }

        // Checking if we have at least one "Place" value in the database
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableViewCell else { fatalError() }

        // Array definitions to create a cell
        let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating

        return cell
    }

    //MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Hides the searchController
        if searchController.isActive {
            searchController.isActive = false
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // Delete cells from tableView and database by swipe

        let place = places[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { _,_,_ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }

    //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]

            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }

    //MARK: - @IBAction

    @IBAction func unwindNewPlaceSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }

        newPlaceVC.savePlace()
        tableView.reloadData()
    }

    @IBAction func unwindSortedSegue(_ segue: UIStoryboardSegue) {
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit", MainViewController.self)
    }
}

//MARK: - UISearchResultsUpdating

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    private func filterContentForSearchText(_ searchText: String) { // Search for a place on request
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@",
                                      searchText.lowercased(), searchText.lowercased())
        tableView.reloadData()
    }
}
