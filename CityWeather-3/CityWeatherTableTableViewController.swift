//
//  CityWeatherTableTableViewController.swift
//  CityWeather-3
//
//  Created by Jun Dang on 2019-05-12.
//  Copyright © 2019 Jun Dang. All rights reserved.
//

import UIKit
import CoreData

class CityWeatherTableTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CurrentWeather.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cityName", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableContent()
    }

    func updateTableContent() {
       do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
            let count = self.fetchedhResultController.sections?[0].numberOfObjects
            for i in 0...(count! - 1) {
                let indexPath = IndexPath(row: i, section: 0)
                if let weather = fetchedhResultController.object(at: indexPath) as? CurrentWeather {
                   APIService.sharedInstance.getCurrentWeather(cityName: weather.cityName!) { (forecast, error) in
                       if let forecast = forecast {
                        self.clearData(forecast.cityName)
                        self.createCurrentWeatherEntityFrom(forecast)
                        self.tableView.reloadData()
                    } else {
                        print("display error")
                    }
                }
                }
            }
            self.tableView.reloadData()
        } catch let error  {
            print("ERROR: \(error)")
        }
        
       APIService.sharedInstance.getCurrentWeather(cityName: "Xichang") { (forecast, error) in
            if let forecast = forecast {
               
                self.clearData(forecast.cityName)
                self.createCurrentWeatherEntityFrom(forecast)
                self.tableView.reloadData()
            } else {
                print("display error")
            }
        }
       
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       //return weatherSets.count
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       // cell.textLabel?.text = weatherSets[indexPath.row].cityName
        //cell.detailTextLabel?.text = weatherSets[indexPath.row].weatherDescription
        if let weather = fetchedhResultController.object(at: indexPath) as? CurrentWeather {
            cell.textLabel?.text = weather.cityName
            // Info parts
            var infoParts: [String] = []
            
            // Weather description
            if let weatherDescription = weather.weatherDescription {
                infoParts.append(weatherDescription)
            }
            
            // Temp
             infoParts.append("🌡 \(weather.tempKelvin)°")
             cell.detailTextLabel?.text = infoParts.joined(separator: "    ")
            if let iconString = weather.icon {
                let iconURL = URL(string: "http://openweathermap.org/img/w/\(iconString).png")!
                let imageData = try? Data(contentsOf: iconURL)
                cell.imageView?.image = UIImage(data: imageData as! Data)
            }

        }
         return cell
    }
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
   private func createCurrentWeatherEntityFrom(_ forecast: Forecast) {
         let context = appDelegate.persistentContainer.viewContext
         if let weather = NSEntityDescription.insertNewObject(forEntityName: "CurrentWeather", into: context) as? CurrentWeather {
           weather.cityName = forecast.cityName
           weather.time = Int64(forecast.time)
           weather.weatherDescription = forecast.weatherCondition[0].conditionDescription
           weather.icon = forecast.weatherCondition[0].conditionIconCode
           weather.tempKelvin = forecast.temperatures.temperatureKelvin
           weather.maxTempKelvin = forecast.temperatures.tempMax
           weather.minTempKelvin = forecast.temperatures.tempMin
            
            do{
               
                try context.save()
               
               // weatherSets.append(weather)
               // print(weatherSets.count)
               //  print(weatherSets[0].cityName)
              //  let thisIndexPath = IndexPath(row: weatherSets.count - 1, section: 0)
               // tableView.insertRows(at: [thisIndexPath], with: .fade)
            }
            catch{
                
            }
        }
    
    }
  

    
   /* private func saveInCoreDataWith(forecasts: [Forecast]) {
        _ = forecasts.map{self.createCurrentWeatherEntityFrom($0)}
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }*/
    
    private func clearData(_ cityName: String) {
        do {
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CurrentWeather.self))
            fetchRequest.predicate = NSPredicate(format: "cityName == %@", cityName)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
               appDelegate.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}

extension CityWeatherTableTableViewController {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
