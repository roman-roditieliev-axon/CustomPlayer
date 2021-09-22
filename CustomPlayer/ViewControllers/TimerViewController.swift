//
//  TimerViewController.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 21.07.2021.
//

//import FittedSheets
import UIKit

final class TimerViewController: UIViewController {
    var timeRemaining: String = "--:--"
    private var selectedIndex: Int = 0
    private let scheduler = Scheduler.shared
    
    private let tableviewCellHeight: CGFloat = 45
    private let labelHeight: CGFloat = 22
    private let buttonHeight: CGFloat = 50
    private let buttonPadding: CGFloat = 16
    private var buttonHeightAndPadding: CGFloat { buttonHeight + buttonPadding }
    private let bottomSpace: CGFloat = 70
    private var tableViewHeight: CGFloat { tableviewCellHeight * CGFloat(slideUpViewDataSource.count) }
    private let cellIdentifier = "SlideUpTimerMenuCell"
    
    lazy var headerLabel: UILabel = {
        let view =  UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: 197, height: 22)
        view.font = UIFont(name: "SFProDisplay-Semibold", size: 17)
        view.frame.size.height = labelHeight
        view.textAlignment = .center
        view.text = "Set timer to stop podcast"
        return view
    }()
    
    lazy var timerInfoLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: 153, height: 22)
        view.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        view.frame.size.height = labelHeight
        view.textAlignment = .center
        view.text = "Stop playing in \(timeRemaining)"
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        view.isScrollEnabled = false
        view.delegate = self
        view.dataSource = self
        view.register(SlideUpTimerMenuCell.self, forCellReuseIdentifier: cellIdentifier)
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.backgroundColor = UIColor(red: 0, green: 0.569, blue: 1, alpha: 1).cgColor
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.backgroundColor = .systemBlue
        view.setTitle("Start", for: .normal)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.isEnabled = false
        view.backgroundColor = .systemGray
        view.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        return view
    }()
    
    private var slideUpViewDataSource: [SlideUpTimerOptions] = [
        SlideUpTimerOptions(title: "5 min", time: 5 * 60),
        SlideUpTimerOptions(title: "10 min", time: 10 * 60),
        SlideUpTimerOptions(title: "15 min", time: 15 * 60),
        SlideUpTimerOptions(title: "20 min", time: 20 * 60),
        SlideUpTimerOptions(title: "30 min", time: 30 * 60),
        SlideUpTimerOptions(title: "45 min", time: 45 * 60),
        SlideUpTimerOptions(title: "60 min", time: 60 * 60),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        scheduler.schedulerMulticast.addDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard tableView.delegate == nil else { return }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupView() {
        view.addSubview(headerLabel)
        view.addSubview(timerInfoLabel)
        view.addSubview(tableView)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerInfoLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 35),
            timerInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: timerInfoLabel.bottomAnchor, constant: 13),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor),
            
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            confirmButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: view.layoutMargins.top + view.layoutMargins.bottom + labelHeight * 2 + tableViewHeight + buttonHeightAndPadding + bottomSpace + 60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extension for Timer ViewController
extension TimerViewController {
    @objc private func didTapConfirmButton() {
        scheduler.setTimer(endTime: slideUpViewDataSource[selectedIndex].time)
        self.dismiss(animated: true, completion: nil)
    }
}
// MARK: - TableView Delegate
extension TimerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { tableviewCellHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        confirmButton.isEnabled = true
        confirmButton.backgroundColor = .systemBlue
    }
}

// MARK: - TableView DataSource
extension TimerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard slideUpViewDataSource.count != 0 else { return 4 }
        let count = slideUpViewDataSource.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SlideUpTimerMenuCell else {
            fatalError("No cell's registered")
        }
        
        cell.labelView.text = slideUpViewDataSource[indexPath.row].title
        
        return cell
    }
}

// MARK: - Multicast Delegates
extension TimerViewController: SchedulerTimerViewControllerDelegate {
    func updateTimerInfo(endTime: Float, currentTime: Float) {
        let time = TimeFormatter.format(duration: TimeInterval(endTime), currentTime: TimeInterval(currentTime))
        
        timerInfoLabel.text = "Stop playing in \(time.timePlayed)"
    }
}
