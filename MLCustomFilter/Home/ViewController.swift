//
//  ViewController.swift
//  MLCustomFilter
//
//  Created by Srikanth SP on 05/09/22.
//

import UIKit

protocol HomeViewProtocol{
    func showTrainScreen()
    func showTestScreen()
}

class ViewController: UIViewController, Storyboarded {
    let cellReuseIdentifier = "cell"
    var tableSource =  ["Train", "Test"]
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    lazy var mainStack: UIStackView = {
    let stack  = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(mainStack)
        setupMainStack()
        setupTableView()
    }
    
    func setupMainStack() {
        NSLayoutConstraint.activate([
            mainStack.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        mainStack.addArrangedSubview(tableView)
    }
    
    func setupTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: mainStack.leftAnchor),
            tableView.topAnchor.constraint(equalTo: mainStack.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: mainStack.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.textLabel?.text = self.tableSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showTrainScreen()
        } else {
            showTestScreen()
        }
    }
}

extension ViewController: HomeViewProtocol {
    func showTrainScreen() {
        let trainVC = TrainViewController.instantiate()
        navigationController!.pushViewController(trainVC, animated: true)
    }
    
    func showTestScreen() {
        let testVC = TestViewController.instantiate()
        navigationController!.pushViewController(testVC, animated: true)
    }
}
