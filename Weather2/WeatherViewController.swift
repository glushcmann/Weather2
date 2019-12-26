//
//  ViewController.swift
//  Weather2
//
//  Created by Никита on 26.12.2019.
//  Copyright © 2019 Nikita Glushchenko. All rights reserved.
//

import UIKit
import RxSwift

class WeatherViewController: UIViewController {

    @IBOutlet private weak var cityNameTextField: UITextField!
    @IBOutlet private weak var cityNameLabel: UILabel!
    @IBOutlet private weak var tempLabel: UILabel!
    
    private let viewModel = WeatherViewModel()
    private let disposeBag = DisposeBag()

    private var alertController: UIAlertController? {
        didSet {
            if let alertController = alertController {
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        doBinding()
    }

    private func doBinding() {
        // Binding the UI
        cityNameTextField.rx.text
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .distinctUntilChanged { $0 == $1 }
            .subscribe(onNext: { self.viewModel.searchText = $0 })
            .disposed(by: disposeBag)

        viewModel.cityName
            .bind(to: cityNameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.temp
            .bind(to: tempLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.errorAlertController
            .subscribe(onNext: { self.alertController = $0 })
            .disposed(by: disposeBag)
    }

}


