//
//  CoreDataManager.swift
//  Duriso
//
//  Created by 김동현 on 9/27/24.
//

import CoreData

import RxSwift

class CoreDataManager {
  static let shared = CoreDataManager()
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Duriso")
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  func fetchAEDs() -> Observable<[AEDs]> {
    return Observable.create { observer in
      let fetchRequest: NSFetchRequest<AEDs> = AEDs.fetchRequest()
      
      do {
        let results = try self.context.fetch(fetchRequest)
        observer.onNext(results)
        observer.onCompleted()
      } catch {
        observer.onError(error)
      }
      
      return Disposables.create()
    }
  }
  
  func fetchCivilDefenseShelters() -> Observable<[CivilDefenseShelters]> {
    return Observable.create { observer in
      let fetchRequest: NSFetchRequest<CivilDefenseShelters> = CivilDefenseShelters.fetchRequest()
      
      do {
        let results = try self.context.fetch(fetchRequest)
        observer.onNext(results)
        observer.onCompleted()
      } catch {
        observer.onError(error)
      }
      
      return Disposables.create()
    }
  }
  
  func fetchDisasterShelters() -> Observable<[DisasterShelters]> {
    return Observable.create { observer in
      let fetchRequest: NSFetchRequest<DisasterShelters> = DisasterShelters.fetchRequest()
      
      do {
        let results = try self.context.fetch(fetchRequest)
        observer.onNext(results)
        observer.onCompleted()
      } catch {
        observer.onError(error)
      }
      
      return Disposables.create()
    }
  }
  
  // latitude와 longitude로 AED 검색
  func searchAED(lat latitude: Double, lon longitude: Double) -> AEDs? {
    let fetchRequest: NSFetchRequest<AEDs> = AEDs.fetchRequest()
    
    let latitudeDelta = 0.0001
    let longitudeDelta = 0.0001
    
    fetchRequest.predicate = NSPredicate(
      format: "wgs84Lat BETWEEN {%f, %f} AND wgs84Lon BETWEEN {%f, %f}",
      latitude - latitudeDelta, latitude + latitudeDelta,
      longitude - longitudeDelta, longitude + longitudeDelta
    )
    
    do {
      let results = try context.fetch(fetchRequest)
      return results.first
    } catch {
      print("Error fetching AEDs: \(error)")
      return nil
    }
  }
  
  // latitude와 longitude로 CivilDefenseShelter 검색
  func searchCivilDefenseShelter(lat latitude: Double, lon longitude: Double) -> CivilDefenseShelters? {
    let fetchRequest: NSFetchRequest<CivilDefenseShelters> = CivilDefenseShelters.fetchRequest()
    
    let latitudeDelta = 0.0001
    let longitudeDelta = 0.0001
    
    fetchRequest.predicate = NSPredicate(
      format: "latitude BETWEEN {%f, %f} AND longitude BETWEEN {%f, %f}",
      latitude - latitudeDelta, latitude + latitudeDelta,
      longitude - longitudeDelta, longitude + longitudeDelta
    )
    
    do {
      let results = try context.fetch(fetchRequest)
      return results.first
    } catch {
      print("Error fetching Civil Defense Shelters: \(error)")
      return nil
    }
  }
  
  // latitude와 longitude로 DisasterShelter 검색
  func searchDisasterShelter(lat latitude: Double, lon longitude: Double) -> DisasterShelters? {
    let fetchRequest: NSFetchRequest<DisasterShelters> = DisasterShelters.fetchRequest()
    
    let latitudeDelta = 0.0001
    let longitudeDelta = 0.0001
    
    fetchRequest.predicate = NSPredicate(
      format: "lat BETWEEN {%f, %f} AND lot BETWEEN {%f, %f}",
      latitude - latitudeDelta, latitude + latitudeDelta,
      longitude - longitudeDelta, longitude + longitudeDelta
    )
    
    do {
      let results = try context.fetch(fetchRequest)
      return results.first
    } catch {
      print("Error fetching Disaster Shelters: \(error)")
      return nil
    }
  }
}
