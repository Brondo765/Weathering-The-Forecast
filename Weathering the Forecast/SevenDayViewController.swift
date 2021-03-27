//
//  SevenDayViewController.swift
//  Weathering the Forecast
//
//  Created by Brandon Wegner on 2/24/21.
//

import UIKit

class SevenDayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as! MyCell
        cell.dateLabel.text = WeatherService.shared.convertUnixEpochDate(timeStamp: WeatherService.shared.weeklyWeatherDates![indexPath.row + 1])
        
        cell.weatherSprite.image = WeatherService.shared.getWeatherSprite(weatherDescription: (WeatherService.shared.weeklyWeatherDescriptions![indexPath.row + 1].1.string?.capitalized)!)
        
        let morning = WeatherService.shared.weeklyWeatherTemps![indexPath.row + 1]["morn"].float!
        let day = WeatherService.shared.weeklyWeatherTemps![indexPath.row + 1]["day"].float!
        let evening = WeatherService.shared.weeklyWeatherTemps![indexPath.row + 1]["eve"].float!
        let night = WeatherService.shared.weeklyWeatherTemps![indexPath.row + 1]["night"].float!
        
        let avg = WeatherService.shared.getAverageTemp(morn: morning, day: day, eve: evening, night: night)
        
        cell.averageTempLabel.text = WeatherService.shared.tempConvert(temp: avg)
        
        cell.lowTempLabel.text = WeatherService.shared.tempConvert(temp: WeatherService.shared.weeklyWeatherTemps![indexPath.row + 1]["min"].float!)
        
        cell.highTempLabel.text = WeatherService.shared.tempConvert(temp: WeatherService.shared.weeklyWeatherTemps![indexPath.row + 1]["max"].float!)
        
        cell.sunriseLabel.text = WeatherService.shared.convertUnixEpochTime(timeStamp: WeatherService.shared.weeklyWeatherSunrise![indexPath.row + 1])
        
        cell.sunsetLabel.text = WeatherService.shared.convertUnixEpochTime(timeStamp: WeatherService.shared.weeklyWeatherSunset![indexPath.row + 1])
        
        cell.actionBlock = {
            let title = "Additional Details\n" + cell.dateLabel.text!
            let desc = WeatherService.shared.weeklyWeatherDescriptions![indexPath.row + 1].1.string!.capitalized
            let message = "Description: " + desc + "\nHumidity: " + WeatherService.shared.weeklyWeatherHumidity![indexPath.row + 1] + "%\n" + "Wind: " + "\(WeatherService.shared.weeklyWeatherWind![indexPath.row + 1]) " + "MPH"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
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
