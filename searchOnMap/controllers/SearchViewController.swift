//
//  ViewController.swift
//  searchOnMap
//
//  Created by Luciano de Castro Martins on 26/06/2018.
//  Copyright © 2018 luciano. All rights reserved.
//

import UIKit
import GoogleMaps

enum sectionType: String {
    case oneLine
    case multiple
    case zero
}

class SearchViewController: UITableViewController {
    
    // MARK: - properties
    
    var locations = [Location]()
    let kMapViewController = "kMapViewController"
    let kDisplayAllOnMap = "Display All on Map"
    let kScreenAcessibilityIndentifier = "searchView"
    let kNoresults = "No results"
    let cellId = "cellId"
    let locationTableViewCellNib = "LocationTableViewCell"
    let defaultColor = UIColor(red: 237/255, green: 236/255, blue: 242/255, alpha: 1)
    var reloadNoResults = true
    var selectedLocation: Location?
    var numberOfSections = 1
    var showAllonMaps = false
    var sectionType: sectionType = .zero
    lazy var activityIndicator: UIActivityIndicatorView = {
      let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        ai.hidesWhenStopped = true
        ai.center = view.center
        ai.color = .black
        return ai
    }()
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search on Google Maps"
        sb.delegate = self
        return sb
    }()

    
    
    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBar()
        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kMapViewController {
            if let vc = segue.destination as? MapViewController {
                searchBar.isHidden = true
                searchBar.resignFirstResponder()
                if showAllonMaps {
                    vc.locations = locations
                    return
                }
                vc.location = selectedLocation
            }
        }
    }
    
    // MARK: - private methods

    private func setupTableView() {
        registerXibCell()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 23
        tableView.tableFooterView = UIView()
        tableView.accessibilityIdentifier = kScreenAcessibilityIndentifier
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.addSubview(searchBar)
        let navBar = navigationController?.navigationBar
        navBar?.backgroundColor = .gray
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBotton: 0, paddingRight: 8, width: 0, height: 0)
    }

    
    private func findLocation(_ text: String) {
        let provider = mapProvider()
        activityIndicator.startAnimating()
        provider.findLocation(text: text) {locals in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.locations = locals
                if locals.count == 0 {
                    self?.sectionType = .zero
                    self?.reloadNoResults = false
                    self?.tableView.bounces = false
                } else {
                    self?.reloadNoResults = true
                    self?.tableView.bounces = true
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    private func registerXibCell() {
        tableView.register(UINib(nibName: locationTableViewCellNib, bundle: nil), forCellReuseIdentifier: cellId)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 3 {
            findLocation(searchText)
        }
    }
}


// MARK: - UITableViewDelegate and UITableViewDataSource handlers
extension SearchViewController {
    
    override func numberOfSections(in tablevView: UITableView) -> Int {
        if sectionType == .zero && !reloadNoResults {
            return 1
        }
        switch locations.count {
        case 0:
            sectionType = .zero
            return 0
        case 1:
            sectionType = .oneLine
            return 1
        default:
            sectionType = .multiple
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionType == .zero && !reloadNoResults {
            return 1
        }
        if sectionType == .zero && reloadNoResults {
            return 0
        }
        if sectionType == .oneLine {
            return 1
        }
        return section == 0 ? 1 : locations.count
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && (sectionType == .multiple || sectionType == .oneLine)  {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
            header.backgroundColor = defaultColor
            return header
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && (sectionType == .multiple || sectionType == .oneLine)  {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
            footer.backgroundColor = defaultColor
            return footer
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 25.0 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40.0 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sectionType == .zero {
            return buildNoResultsCell(tableView, indexPath: indexPath)
        }
        return buildResultCell(tableView, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if locations.count == 0 {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? LocationTableViewCell, cell.type == .all {
            showAllonMaps = true
        } else {
            showAllonMaps = false
            selectedLocation = locations[indexPath.row]
        }
        performSegue(withIdentifier: kMapViewController, sender: self)
    }
    
    private func buildResultCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? LocationTableViewCell
            else { return UITableViewCell() }
        cell.type = .single
        
        if indexPath.section == 0 && sectionType == .multiple  {
            cell.name.text = kDisplayAllOnMap
            cell.type = .all
            return cell
        }
        
        let row = locations.count > 1 ? indexPath.row : 0
        if indexPath.section == 1 && sectionType == .multiple {
            let simpleAddress = locations[row].formattedAddress
            cell.name.text = simpleAddress == nil ? locations[indexPath.row].formattedAddress : simpleAddress
            return cell
        }
        
        let simpleAddress = sectionType == .multiple ? locations[row].formattedAddress : locations[row].alternativeFormattedAddress
        cell.name.text = simpleAddress == nil ? locations[indexPath.row].formattedAddress : simpleAddress
        return cell
    }
    
    private func buildNoResultsCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let navBarHeigth =  UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0.0)
        let cellFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - navBarHeigth)
        let cell = UITableViewCell(frame: cellFrame)
        cell.backgroundColor = defaultColor
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = kNoresults
        return cell
    }
}
