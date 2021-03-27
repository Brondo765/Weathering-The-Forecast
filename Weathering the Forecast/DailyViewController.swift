//
//  DailyViewController.swift
//  Weathering the Forecast
//
//  Created by Brandon Wegner on 2/24/21.
//

import UIKit
import SwiftyJSON

class DailyViewController: UIViewController {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var currTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    /*
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+300)
    }
     */
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+300)

    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        cityLabel.text = WeatherService.shared.combinedCityAndState! + "\n" + WeatherService.shared.convertUnixEpochDate(timeStamp: WeatherService.shared.currentDate!)
        
        weatherDescriptionLabel.text = WeatherService.shared.searchJSONArray(jsonArray: WeatherService.shared.dailyWeatherArray, passedItem: "description")
        
        imageView.image = WeatherService.shared.getWeatherSprite(weatherDescription: weatherDescriptionLabel.text!)
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.black.cgColor
    
        currTempLabel.text = WeatherService.shared.tempConvert(temp: WeatherService.shared.dailyTemp!)
        minTempLabel.text = WeatherService.shared.tempConvert(temp: WeatherService.shared.dailyTempMin!)
        maxTempLabel.text = WeatherService.shared.tempConvert(temp: WeatherService.shared.dailyTempMax!)
        
        sunriseLabel.text = WeatherService.shared.convertUnixEpochTime(timeStamp: WeatherService.shared.dailySunrise!)
        sunsetLabel.text = WeatherService.shared.convertUnixEpochTime(timeStamp: WeatherService.shared.dailySunset!)
        
        windSpeedLabel.text = "\(WeatherService.shared.dailyWindSpeed!)" + " MPH"
        
        humidityLabel.text = WeatherService.shared.dailyHumidity! + "%"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
