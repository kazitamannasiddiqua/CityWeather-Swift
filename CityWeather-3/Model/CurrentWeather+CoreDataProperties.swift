//
//  CurrentWeather+CoreDataProperties.swift
//  CityWeather-3
//
//  Created by Jun Dang on 2019-05-12.
//  Copyright © 2019 Jun Dang. All rights reserved.
//
//

import Foundation
import CoreData


extension CurrentWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentWeather> {
        return NSFetchRequest<CurrentWeather>(entityName: "CurrentWeather")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var weatherDescription: String?
    @NSManaged public var icon: String?
    @NSManaged public var time: Int64
    @NSManaged public var tempKelvin: Double
    @NSManaged public var maxTempKelvin: Double
    @NSManaged public var minTempKelvin: Double

}
