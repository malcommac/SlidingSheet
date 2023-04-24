//
//  ListController.swift
//  Example
//
//  Created by daniele on 13/03/23.
//

import UIKit
import SlidingSheet

public class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource, SlideSheetPresented {
   
    public static let identifier = "ListController"
   
    public var presentedView: UIView {
        view
    }
    
    public var scrollView: UIScrollView? {
        tableView
    }
    
    public lazy var headerView: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = .yellow
        label.isOpaque = true
        label.text = "12 Results"
        return label
    }()
    
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "DetailCell", bundle: .main), forCellReuseIdentifier: "DetailCell")
        return tableView
    }()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.backgroundColor = .white
        self.presentedView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: presentedView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: presentedView.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: presentedView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.presentedView.addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: presentedView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: presentedView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: presentedView.bottomAnchor)
        ])
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
