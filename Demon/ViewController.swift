//
//  ViewController.swift
//  Demon
//
//  Created by immortal on 2021/3/22.
//

import UIKit
import IMProgressHUD

struct SectionModel {
    var name: String
    var models: [CellModel]
}

struct CellModel {
    
    var name: String
    
    var selectHandler: (() -> Void)
}

class ViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return tableView
    }()
    
    private let models: [SectionModel] = [
        SectionModel(name: "Toast", models: [
            CellModel(name: "Toast", selectHandler: {
                IMProgressHUD.showToast("IMProgressHUD Toast.")
            }),
            CellModel(name: "Short Toast - Custom style", selectHandler: {
                let hud = IMProgressHUD()
                hud.location = .top(offset: 12.0)
                hud.configuration.contentInsets = .init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
                hud.configuration.cornerRadius = 8.0
                hud.configuration.numberOfMessageLines = 1
                hud.message = "IMProgressHUD Toast."
                hud.show(in: UIApplication.shared.keyWindow!)
            }),
            CellModel(name: "Long Toast - Custom style", selectHandler: {
                let hud = IMProgressHUD()
                hud.location = .bottom(offset: 12.0)
                hud.configuration.contentInsets = .init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
                hud.configuration.cornerRadius = 8.0
                hud.message = "IMProgressHUD Toast. long long long long long long long long long long long long long long long long long long."
                hud.show(in: UIApplication.shared.keyWindow!)
            })
        ]),
        SectionModel(name: "Success", models: [
            CellModel(name: "Success - No message", selectHandler: {
                IMProgressHUD.showSuccess()
            }),
            CellModel(name: "Success - Short message", selectHandler: {
                IMProgressHUD.showSuccess("Success")
            }),
            CellModel(name: "Fail - No message", selectHandler: {
                IMProgressHUD.showFail()
            }),
            CellModel(name: "Fail - Short message", selectHandler: {
                IMProgressHUD.showFail("Fail")
            })
        ]),
        SectionModel(name: "Indicator", models: [
            CellModel(name: "Default", selectHandler: {
                IMProgressHUD.showIndicator(.default, message: "Loading")
            }),
            CellModel(name: "System", selectHandler: {
                IMProgressHUD.showIndicator(.system, message: "Loading")
            }),
            CellModel(name: "Circle", selectHandler: {
                IMProgressHUD.showIndicator(.circle, message: "Loading")
            }),
            CellModel(name: "Half Circle", selectHandler: {
                IMProgressHUD.showIndicator(.halfCircle, message: "Loading")
            }),
            CellModel(name: "Asymmetric Fade Circle", selectHandler: {
                IMProgressHUD.showIndicator(.asymmetricFadeCircle, message: "Loading")
            })
        ]), SectionModel(name: "Progress", models: [
            CellModel(name: "Default", selectHandler: {
                showProgress(0.0, indicatorType: .default)
            }),
            CellModel(name: "Half Circle", selectHandler: {
                showProgress(0.0, indicatorType: .halfCircle)
            }),
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(didDismissHUD))
        title = "IMProgressHUD"
    }
    
    static var timer: Timer?

    static func invalidateProgressHUD() {
        if let timer = timer {
            timer.invalidate()
            Self.timer = nil
        }
    }
    
    static func showProgress(_ progress: CGFloat, indicatorType: IMProgressHUD.ProgressIndicatorType) {
        invalidateProgressHUD()
        IMProgressHUD.showProgress(progress, indicatorType: indicatorType, message: "Loading")
        guard let keyWindow = UIApplication.shared.keyWindow,
              let hud = IMProgressHUD.hud(from: keyWindow) else { return }
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {
            let value = hud.progress + 0.002
            IMProgressHUD.showProgress(value, indicatorType: indicatorType, message: "Loading")
            if value >= 1.0 {
                IMProgressHUD.showSuccess("Success")
                $0.invalidate()
            }
        }
        timer.fire()
        Self.timer = timer
    }
    
    @objc func didDismissHUD() {
        Self.invalidateProgressHUD()
        IMProgressHUD.dismiss()
    }
}


extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models[section].models.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        models[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = models[indexPath.section].models[indexPath.row].name
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Self.invalidateProgressHUD()
        models[indexPath.section].models[indexPath.row].selectHandler()
    }
}
