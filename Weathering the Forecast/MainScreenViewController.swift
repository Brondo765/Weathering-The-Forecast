//
//  MainScreenViewController.swift
//  Weathering the Forecast
//
//  Created by Brandon Wegner on 2/24/21.
//


// API for weather data
// https://openweathermap.org/
// Library used for JSON parsing
// https://github.com/SwiftyJSON/SwiftyJSON
// Framework used for network requests
// https://github.com/Alamofire/Alamofire


import UIKit

/*
 Extensions created for UIElements and making border drawing easier for labels/buttons
 also to adjust color saturation. 
 */
@IBDesignable extension UILabel {
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else {
                return
            }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else {
                return
            }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
}

extension UIColor {
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
    
class MainScreenViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textFieldLabel: UITextField!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    var zipCode: String?
    
    @IBAction func textField(_ sender: UITextField) {
        sender.resignFirstResponder()
        textFieldLabel.resignFirstResponder()
    }
    
    @IBAction func backgroundTouch(_ sender: UIControl) {
        sender.resignFirstResponder()
        textFieldLabel.resignFirstResponder()
    }
    
    /*
     When the user presses the search button the App queues operations synchronously as to not miss
     information parsed from the weather API. If the user enters in invalid zip code the user is alerted with
     an alert message for them to dismiss.
     */
    @IBAction func searchPress(_ sender: UIButton) {
        let group = DispatchGroup()
        zipCode = textFieldLabel.text!
        group.enter()
        WeatherService.shared.getWeatherInfo(zipCode: zipCode!, group: group)
        group.notify(queue: DispatchQueue.main) {
            if (WeatherService.shared.latitude == nil && WeatherService.shared.longitude == nil) {
                let title = "Error"
                let message = "Invalid Zip Code Provided"
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okay = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                alertController.addAction(okay)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let board = UIStoryboard(name: "Main", bundle: Bundle.main)
                let tabBarController = board.instantiateViewController(identifier: "TabBarController") as! UITabBarController
                self.navigationController?.pushViewController(tabBarController, animated: true)
                self.textFieldLabel.resignFirstResponder()
                self.textFieldLabel.text = ""
            }
        }
    }
    
    /*
     Changes screen background color when between the hours of 07-12
     */
    func morning() {
        backgroundView.backgroundColor = UIColor.systemTeal.adjust(by: 40)
    }
    
    /*
     Changes screen background color when between the hours of 13-17
     */
    func afternoon() {
        backgroundView.backgroundColor = UIColor.orange.adjust(by: 40)
    }
    
    /*
     Changes screen background color when between the hours of 18-23
     */
    func evening() {
        backgroundView.backgroundColor = UIColor.gray
    }
    
    /*
     Changes screen background color when between the hours of 24-06
     */
    func overNight() {
        backgroundView.backgroundColor = UIColor.black
    }
    
    /*
     Checks current time of the day returns a tuple of hour, minutes, and seconds.
     */
    func getTime() -> (hour: Int, minute: Int, second: Int) {
        let currentDate = Date()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: currentDate)
        let minutes = calendar.component(.minute, from: currentDate)
        let seconds = calendar.component(.second, from: currentDate)
        return (hour, minutes, seconds)
    }
    
    /*
     Switch case function which calls the corresponding function that changes the user's app background
     to a specific color depending the time of day in which the app was launched.
     */
    func timeCheck() {
        let time = getTime().hour
        switch time {
            case 07...12:
                morning()
                break
            
            case 13...17:
                afternoon()
                break
                
            case 18...23:
                evening()
                break
        
            default:
                overNight()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeCheck() // Changes background color based on time of the day
        // When overNight function called, the default black colored UI elements swapped to white color
        if (getTime().hour >= 24 || getTime().hour <= 06) {
            imageView1.tintColor = UIColor.white
            imageView2.tintColor = UIColor.white
            imageView3.tintColor = UIColor.white
            imageView4.tintColor = UIColor.white
            searchButton.tintColor = UIColor.white
            searchButton.setTitleColor(UIColor.white, for: .normal)
            searchButton.borderColor = UIColor.white
            titleLabel.textColor = UIColor.white
            titleLabel.borderColor = UIColor.white
        }
        // Sets the nav bar invisible
        self.navigationController?.setNavigationBarHidden(true, animated: true)
            super.viewWillDisappear(true)
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
