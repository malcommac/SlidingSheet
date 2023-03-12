//
//  ViewController.swift
//  Example
//
//  Created by daniele on 12/03/23.
//

import UIKit
import SlidingSheet

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let CellIdentifier = "DemoAppCell"
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.CellIdentifier)
        
        return tableView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sliding Sheet Demo"
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.CellIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "Test"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let configuration = SlidingSheetView.Config(
            contentView: data.tableView,
            parentViewController: self,
            initialPosition: .middle(),
            allowedPositions: [.middle(), .top(), .bottom()],
            showPullIndicator: true,
            isDismissable: true
        )
        let bottomSheetView = SlidingSheetView(config: configuration)
        let bottomSheetViewController = SlidingSheetController(sheetView: bottomSheetView)
        
       // bottomSheetViewController.delegate = self
        bottomSheetViewController.present(from: self)
        if #available(iOS 13.0, *) {
            bottomSheetView.backgroundColor = .systemBackground
        }
        
        data.tableView.reloadData()
    }
 
    let data = ExampleTableViewDataSource()

}

class ExampleTableViewDataSource: NSObject {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        
        return tableView
    }()
}

extension ExampleTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        cell.textLabel?.text = "Index is \(indexPath.row)"
        return cell
    }
}
