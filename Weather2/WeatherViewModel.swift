//
//  WeatherViewModel.swift
//  Weather2
//
//  Created by Никита on 26.12.2019.
//  Copyright © 2019 Nikita Glushchenko. All rights reserved.
//

import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire
import SwiftyJSON

class WeatherViewModel {
    
    private struct Constants {
        static let URLPrefix = "http://api.openweathermap.org/data/2.5/weather?q="
        static let URLPostfix = "&appid=5dbf6189c7cbcff8401f6e13e73c3aa8"
    }
    
    var cityName = PublishSubject<String>()
    var temp = PublishSubject<String>()
    let errorAlertController = PublishSubject<UIAlertController>()

    private let disposeBag = DisposeBag()

    var searchText:String? {
        didSet {
            if let text = searchText {
                if text.count >= 3 {
                    if let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                        let urlString = Constants.URLPrefix + encodedText + Constants.URLPostfix
                        getWeather(for: urlString)
                    } else {
                        print("Something went wrong with encoding the search text.")
                    }
                }
            }
        }
    }

    private var weather:Weather? {
        didSet {
            updateModel()
        }
    }

    private func updateModel() {
        if let city = weather?.cityName {
            self.cityName.on(.next(city))

            if let temp = weather?.temp {
                self.temp.on(.next("\(temp)°С"))
            }
        }
    }
    
    private func getWeather(for urlString: String) {
        Alamofire.request(urlString).rx.responseJSON()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { dataResponse in
                    if let data = dataResponse.data {
                        let json = JSON(data)
                        if let error = json["message"].string {
                            self.postError(title: "Error", message: error)
                            return
                        }
                        self.weather = Weather(json: json)
                    }
                },
                onError: { error in
                    print("Got error")
                    let gotError = error as NSError
                    print(gotError.domain)
                    self.postError(title: "\(gotError.code)", message: gotError.domain)
                })
            .disposed(by: disposeBag)
    }

    private func postError(title: String, message: String) {
        errorAlertController.on(.next(UIAlertController(title: title, message: message, preferredStyle: .alert)))
    }

}
