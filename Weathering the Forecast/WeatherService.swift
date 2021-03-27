//
//  APICalls.swift
//  Weathering the Forecast
//
//  Created by Brandon Wegner on 3/9/21.
//

import Foundation   // Default import
import Alamofire    // Used for making request from API
import SwiftyJSON   // Used for parsing JSON in request
import CoreLocation // Allows use of CLGeocoder lib
import Contacts     // Allows us to use PostalAddress in Geocoder
import UIKit        // Useful to save image icons for weather sprites in this swift class than in VC

class WeatherService {
    // Singleton WeatherService:
    static let shared = WeatherService()
    
    // Private vars:
    private var jsonCurrentLocation: JSON?
    private var jsonOneCall: JSON?
    private var weeklyWeatherArray: Array<JSON>?
    private let geocoder = CLGeocoder()
    private static let API_KEY = APIKEY
    
    // Daily Screen:
    var latitude:  Float?
    var longitude: Float?
    var cityName: String?
    var currentDate: String?
    var stateName: String?
    var combinedCityAndState: String?
    var dailyTemp: Float?
    var dailyTempMin: Float?
    var dailyTempMax: Float?
    var dailyHumidity: String?
    var dailyWindSpeed: Float?
    var dailySunrise: String?
    var dailySunset: String?
    var dailyWeatherArray: Array<JSON>?
    
    // Five/Seven Day:
    var weeklyWeatherDates: Array<String>?
    var weeklyWeatherDescriptions: Array<(Int, JSON)>?
    var weeklyWeatherTemps: Array<JSON>?
    var weeklyWeatherHumidity: Array<String>?
    var weeklyWeatherSunrise: Array<String>?
    var weeklyWeatherSunset: Array<String>?
    var weeklyWeatherWind: Array<Float>?
    
    /*
     Does two requests, one to parse the daily/current weather which will appear on the DailyViewController view
     and the second to parse the OneTimeCall request which gets the 7 day forecast, National weather alerts, and
     Historical weather data for the previous 5 days. This data will be put into global vars so the separate views
     will be able to properly display them on each tabbed screen. Done Synchronously with the main thread due to
     latitude and longitude needed for OneTimeCall.
    */
    func getWeatherInfo(zipCode: String, group: DispatchGroup) {
        let userRequest = "https://api.openweathermap.org/data/2.5/weather?zip=\(zipCode)&units=imperial&appid=\(WeatherService.API_KEY)"
        let currentWeatherParse = DispatchGroup()
        currentWeatherParse.enter()
        AF.request(userRequest).responseJSON { response in
            self.jsonCurrentLocation = JSON(response.value!)
            self.latitude = self.jsonCurrentLocation!["coord"]["lat"].float
            self.longitude = self.jsonCurrentLocation!["coord"]["lon"].float
            self.dailyWeatherArray = self.jsonCurrentLocation!["weather"].array
            self.dailyTemp = self.jsonCurrentLocation!["main"]["temp"].float
            self.dailyTempMin = self.jsonCurrentLocation!["main"]["temp_min"].float
            self.dailyTempMax = self.jsonCurrentLocation!["main"]["temp_max"].float
            self.dailyHumidity = self.jsonCurrentLocation!["main"]["humidity"].rawString()
            self.dailyWindSpeed = self.jsonCurrentLocation!["wind"]["speed"].float
            self.dailySunrise = self.jsonCurrentLocation!["sys"]["sunrise"].rawString()
            self.dailySunset = self.jsonCurrentLocation!["sys"]["sunset"].rawString()
            self.currentDate = self.jsonCurrentLocation!["dt"].rawString()
            self.cityName = self.jsonCurrentLocation!["name"].string
            
            let address = CNMutablePostalAddress()
            address.postalCode = zipCode
            self.geocoder.geocodePostalAddress(address) {
                (placemarks, error) -> Void in
                if (error != nil) {
                    currentWeatherParse.leave()
                }
                if let placemark = placemarks?.first {
                    self.stateName = placemark.postalAddress?.state
                    currentWeatherParse.leave()
                }
            }
        }
        currentWeatherParse.notify(queue: DispatchQueue.main) {
            let oneCallParse = DispatchGroup()
            if (self.latitude == nil && self.longitude == nil) {
                group.leave()
                return
            }
            else if (self.latitude != nil && self.longitude != nil) {
                self.callOneTime(lat: self.latitude!, lon: self.longitude!, group: oneCallParse)
                oneCallParse.notify(queue: DispatchQueue.main) {
                    self.combinedCityAndState = self.cityName! + ", " + self.stateName!
                    group.leave()
                }
            }
        }
    }
    
    /*
     The only non-closure type function in the getWeatherInfo func. This does the second request which is the
     OneTimeCall request.
    */
    func callOneTime(lat: Float, lon: Float, group: DispatchGroup) {
        group.enter()
        let request = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,alerts&units=imperial&appid=\(WeatherService.API_KEY)"
        AF.request(request).responseJSON { response in
            self.jsonOneCall = JSON(response.value!)
            let groupWeekly = DispatchGroup()
            groupWeekly.enter()
            self.getWeeklyWeather(jsonArray: self.jsonOneCall!["daily"].array, group: groupWeekly)
            groupWeekly.notify(queue: DispatchQueue.main) {
                let getWeeklyInfo = DispatchGroup()
                getWeeklyInfo.enter()
                self.parseWeeklyWeatherInfo(jsonArray: self.weeklyWeatherArray, group: getWeeklyInfo)
                getWeeklyInfo.notify(queue: DispatchQueue.main) {
                    group.leave()
                }
            }
        }
    }
    
    /*
     Used to get the average temp for the day in the 5-day and 7-day controllers.
     */
    func getAverageTemp(morn: Float, day: Float, eve: Float, night: Float) -> Float {
        return (morn + day + eve + night) / 4
    }
    
    /*
     Searches the OneCall response and parses the JSON for the five/seven day into an array for access
     to in further dervived functions.
     */
    func getWeeklyWeather(jsonArray: [JSON]?, group: DispatchGroup) {
        self.weeklyWeatherArray = [JSON]()
        if (jsonArray == nil) {
            return
        }
        for i in jsonArray! {
            self.weeklyWeatherArray?.append(i)
        }
        group.leave()
    }
    
    /*
     parses the weeklyWeatherArray into separate arrays of themselves. Used for easy access to when displaying data
     in a TableViewCell.
     */
    func parseWeeklyWeatherInfo(jsonArray: [JSON]?, group: DispatchGroup) {
        self.weeklyWeatherDescriptions = [(Int, JSON)]()
        self.weeklyWeatherTemps = [JSON]()
        self.weeklyWeatherHumidity = [String]()
        self.weeklyWeatherDates = [String]()
        self.weeklyWeatherSunrise = [String]()
        self.weeklyWeatherSunset = [String]()
        self.weeklyWeatherWind = [Float]()
        var counter = 0
        
        if (jsonArray == nil) {
            return
        }
        
        for i in jsonArray! {
            self.weeklyWeatherTemps?.append(i["temp"])
            self.weeklyWeatherHumidity?.append(i["humidity"].rawString()!)
            self.weeklyWeatherDates?.append(i["dt"].rawString()!)
            self.weeklyWeatherSunrise?.append(i["sunrise"].rawString()!)
            self.weeklyWeatherSunset?.append(i["sunset"].rawString()!)
            self.weeklyWeatherWind?.append(i["wind_speed"].float!)
            for element in i {
                if (element.0.elementsEqual("weather")) {
                    for (_, values) in element.1 {
                        _ = values.allSatisfy {
                            key, value in
                            if (key.elementsEqual("description")) {
                                self.weeklyWeatherDescriptions?.append((counter, value))
                                counter = counter + 1
                            }
                            return true
                        }
                    }
                }
            }
        }
        group.leave()
    }
    
    /*
     Used to convert the float value temps in the JSON response into Ints then finally, into String to return
     to the user in the UI.
     */
    func tempConvert(temp: Float) -> String {
        let toInt = Int(temp)
        let converted = String(toInt)
        return converted + "°F"
    }
    
    /*
     Used to convert UNIX epoch timstamp to a Date object, then month, day, and year are pull from the object
     and returned to the user in the UI.
     */
    func convertUnixEpochDate(timeStamp: String) ->  String {
        let time = Int(timeStamp)!
        let epochTime = TimeInterval(time)
        let date = Date(timeIntervalSince1970: epochTime)
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        let stringMonth = String(month)
        let stringDay = String(day)
        let stringYear = String(year)
        return stringMonth + "/" + stringDay + "/" + stringYear
    }
    
    /*
     Used to convert UNIX epoch timestamp to a Date object, then hours and minutes are pulled from the
     object and returned to the user in the UI.
     */
    func convertUnixEpochTime(timeStamp: String) ->  String {
        let time = Int(timeStamp)!
        let epochTime = TimeInterval(time)
        let date = Date(timeIntervalSince1970: epochTime)
        
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        let stringMin: String?
        let stringHour: String?
        
        if (minutes < 10) {
            stringMin = "0" + String(minutes)
        } else {
            stringMin = String(minutes)
        }
        
        if (hour > 12) {
            hour = hour - 12
            stringHour = String(hour)
            return "\(stringHour! + ":" + stringMin! + " PM")"
        } else {
            stringHour = String(hour)
            return "\(stringHour! + ":" + stringMin! + " AM")"
        }
    }
    
    /*
     Used to search a JSON array for a specific key, value pair. The function is passed the key and
     returns said value back to the user in the UI.
     */
    func searchJSONArray(jsonArray: Array<JSON>?, passedItem: String) -> String {
        if (jsonArray == nil) {
            return ""
        }
        for item in jsonArray! {
            for (key, value) in item {
                if (key.elementsEqual(passedItem)) {
                    return value.string!.capitalized
                }
            }
        }
        return ""
    }
    
    /*
     Used to obtain the image to display to the user for the Weather associated with that current day/day of
     the week.
    */
    func getWeatherSprite(weatherDescription: String) -> UIImage {
        if (weatherDescription.elementsEqual("Clear Sky")) {
            return UIImage(named: "clear")!
        }
        else if (weatherDescription.elementsEqual("Few Clouds")) {
            return UIImage(named: "few-clouds")!
        }
        else if (weatherDescription.elementsEqual("Scattered Clouds")) {
            return UIImage(named: "scattered-clouds")!
        }
        else if (weatherDescription.elementsEqual("Broken Clouds") || weatherDescription.contains("Clouds")) {
            return UIImage(named: "broken-clouds")!
        }
        else if (weatherDescription.elementsEqual("Shower Rain") || weatherDescription.contains("Drizzle")) {
            return UIImage(named: "shower-rain")!
        }
        else if (weatherDescription.elementsEqual("Rain") || weatherDescription.contains("Shower") || weatherDescription.contains("Rain")) {
            return UIImage(named: "rain")!
        }
        else if (weatherDescription.elementsEqual("Thunderstorm") || weatherDescription.contains("Thunderstorm")) {
            return UIImage(named: "thunderstorm")!
        }
        else if (weatherDescription.elementsEqual("Snow") || weatherDescription.contains("Snow")) {
            return UIImage(named: "snow")!
        }
        else if (weatherDescription.elementsEqual("Mist")) {
            return UIImage(named: "mist")!
        }
        else {
            return UIImage(named: "question-mark")!
        }
    }
}
