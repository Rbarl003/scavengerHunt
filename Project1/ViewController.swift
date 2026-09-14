//
//  ViewController.swift
//  Project1
//
//  Created by Ritch Barlatier on 9/12/26.
//


import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"
        view.backgroundColor = .systemBackground

        // Load persisted tasks or create defaults
        let loaded = TaskStore.shared.load()
        if loaded.isEmpty {
            tasks = [
                Task(title: "Buy groceries", details: "Milk, eggs, bread."),
                Task(title: "Take park photo", details: "Capture a photo of the big oak tree."),
                Task(title: "Inspect mailbox", details: "Check for packages.")
            ]
            TaskStore.shared.save(tasks)
        } else {
            tasks = loaded
        }

        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = tasks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        content.secondaryText = task.details
        cell.contentConfiguration = content
        cell.accessoryType = task.completed ? .checkmark : .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var task = tasks[indexPath.row]
        let detail = TaskDetailViewController(task: task)
        detail.onSave = { [weak self] updated in
            guard let self = self else { return }
            // Update the task
            self.tasks[indexPath.row] = updated
            // Save to disk (this will write images and clear imageData)
            TaskStore.shared.save(self.tasks)
            // Reload the saved tasks to ensure imageData is nil
            self.tasks = TaskStore.shared.load()
            // Refresh UI
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        navigationController?.pushViewController(detail, animated: true)
    }
}
