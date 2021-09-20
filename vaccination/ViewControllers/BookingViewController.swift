//
//  HomeViewController.swift
//  vaccination
//
//  Created by User on 12/9/21.
//

import UIKit
import MapKit
import Firebase

class DropDownClass: UITableViewCell {
    
}
class BookingViewController: UIViewController, CLLocationManagerDelegate {

    // Variables for dealing with user location
    var locationManager = CLLocationManager()
    var center = CLLocationCoordinate2D()
    
    // variables related to Database
    var clinicsList = [Clinic]()
    var clinicsCollectionRef: CollectionReference!
    
    let selectorView = UIView()
    let selectorTableView = UITableView()
    let db = Firestore.firestore()
    
    var dataSource = [String]()

    var buttonSelected = UIButton()

    @IBOutlet weak var clinicsCollectionView: UICollectionView!
    @IBOutlet weak var selectVaccineTypeButton: UIButton!
    @IBOutlet weak var selectOperatingHoursButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Select Vaccine Selector setup
        selectorTableView.delegate = self
        selectorTableView.dataSource = self
        selectorTableView.register(DropDownClass.self, forCellReuseIdentifier: "Cell")
        
        // Select Clinic Table setup
        clinicsCollectionView.dataSource = self
        clinicsCollectionView.delegate = self
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        clinicsCollectionRef = db.collection("clinics")
    }
    override func viewWillAppear(_ animated: Bool) {
        clinicsCollectionRef.getDocuments { (querySnapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            } else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let data = document.data()
                    let vaccineType = data["vaccineType"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let address = data["address"] as? String ?? ""
                    let latitude = data["latitude"] as? CLLocationDegrees ?? 0
                    let longitude = data["longitude"] as? CLLocationDegrees ?? 0
                    let docId = document.documentID
                    let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    //print(data,name,docId)
                    let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance)
                    self.clinicsList.append(newClinic)
                }
                self.clinicsCollectionView.reloadData()
            }
        }
        //print(clinicsList.count)
    }
    func fetchData() {
        db.collection("clinics").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            documents.map { (queryDocumentSnapshot) -> Clinic in
                let data = queryDocumentSnapshot.data()
                let vaccineType = data["Vaccine Type"] as? String ?? ""
                let name = data["Name"] as? String ?? ""
                let address = data["Address"] as? String ?? ""
                let latitude = data["Latitude"] as? CLLocationDegrees ?? 0
                let longitude = data["Longitude"] as? CLLocationDegrees ?? 0
                let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                let docId = queryDocumentSnapshot.documentID
                return Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance)
            }
        }
    }
    
    func addFilterSelector(CGRectframe: CGRect) {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        selectorView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(selectorView)
        selectorTableView.frame = CGRect(x: CGRectframe.origin.x, y: CGRectframe.origin.y + CGRectframe.height, width: CGRectframe.width, height: 0)
        self.view.addSubview(selectorTableView)
        selectorTableView.layer.cornerRadius = 5
        selectorView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        selectorView.alpha = 0
        
        selectorTableView.reloadData()
        let selectVaccineGesture = UITapGestureRecognizer(target: self, action: #selector(removeFilterSelector))
        selectorView.addGestureRecognizer(selectVaccineGesture)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveLinear, animations: { self.selectorView.alpha = 0.8
            self.selectorTableView.frame = CGRect(x: CGRectframe.origin.x, y: CGRectframe.origin.y + CGRectframe.height, width: CGRectframe.width + 10, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil )
    }
    @objc func removeFilterSelector() {
        let CGRectframe = buttonSelected.frame
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveLinear, animations: { self.selectorView.alpha = 0
            self.selectorTableView.frame = CGRect(x: CGRectframe.origin.x, y: CGRectframe.origin.y + CGRectframe.height, width: CGRectframe.width, height: 0)
        }, completion: nil )
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])  {
   
        // get the latest location as an array
        let location = locations.last! as CLLocation
        
        // get center of current location
        self.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func calculateDistance (_ clinicLocation: CLLocationCoordinate2D) -> Double {
        let point1 = MKMapPoint(self.center)
        let point2 = MKMapPoint(clinicLocation)
        let distance = point1.distance(to: point2)/1000
        return distance
    }
// ["string":data, "string":"string"]
    @IBAction func selectVaccineTypeAction(_ sender: Any) {
        dataSource = ["Pfizer-BioNTech", "Moderna", "Sinovac"]
        buttonSelected = selectVaccineTypeButton
        addFilterSelector(CGRectframe: selectVaccineTypeButton.frame)
    }
    @IBAction func selectOperatingHoursAction(_ sender: Any) {
        dataSource = ["All", "24hours", "ExtendedHours", "WeekdaysOnly"]
        buttonSelected = selectOperatingHoursButton
        addFilterSelector(CGRectframe: selectOperatingHoursButton.frame)
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

extension BookingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        buttonSelected.setTitle(dataSource[indexPath.row], for: .normal)
        removeFilterSelector()
    }
}

extension BookingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clinicsList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let clinicCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ClinicsCollectionViewCell {
            clinicCell.configure(clinic: clinicsList[indexPath.row])
            return clinicCell
        } else {
            return UICollectionViewCell()
        }
    }
}

