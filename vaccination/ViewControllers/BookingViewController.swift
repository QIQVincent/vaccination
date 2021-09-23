//
//  BookingViewController.swift
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
    var userEmail: String?
    
    // variables related to Database
    var clinicsList = [Clinic]()
    var clinicsCollectionRef: CollectionReference!
    var clinicDetails: Clinic?
    var hoursSelected: String = "All"
    var searchText: String?
    var distanceMaximum: Double?
    
    let selectorView = UIView()
    let selectorTableView = UITableView()
    let db = Firestore.firestore()
    
    var dataSource = [String]()

    var buttonSelected = UIButton()

    @IBOutlet weak var clinicsCollectionView: UICollectionView!
    @IBOutlet weak var selectVaccineTypeButton: UIButton!
    @IBOutlet weak var selectOperatingHoursButton: UIButton!
    @IBOutlet weak var distanceMaximumTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchButton.layer.cornerRadius = 10
        messageLabel.alpha = 0

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
                debugPrint("Error getting docs: \(err)")
            } else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let data = document.data()
                    let vaccineType = data["vaccineType"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let address = data["address"] as? String ?? ""
                    let latitude = data["latitude"] as? CLLocationDegrees ?? 0
                    let longitude = data["longitude"] as? CLLocationDegrees ?? 0
                    let hours = data["hours"] as? String ?? ""
                    let docId = document.documentID
                    let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    //print(data,name,docId)
                    let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                    self.clinicsList.append(newClinic)
                }
                self.clinicsCollectionView.reloadData()
            }
        }
        //print(clinicsList.count)
    }
    func fetchData(vaccineType: String) {
        clinicsList.removeAll()
        print("Retrieving \(vaccineType)")
        if (searchText == nil || searchText! == "") {
            if self.hoursSelected == "All" || self.hoursSelected == "Filter by Operating Hours" {
                clinicsCollectionRef.whereField("vaccineType", isEqualTo: vaccineType).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        guard let snap = querySnapshot else {return}
                        for document in snap.documents {
                            let data = document.data()
                            let vaccineType = data["vaccineType"] as? String ?? ""
                            let name = data["name"] as? String ?? ""
                            let address = data["address"] as? String ?? ""
                            let latitude = data["latitude"] as? CLLocationDegrees ?? 0
                            let longitude = data["longitude"] as? CLLocationDegrees ?? 0
                            let hours = data["hours"] as? String ?? ""
                            let docId = document.documentID
                            let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            //print(data,name,docId)
                            if self.distanceMaximum != nil {
                                if distance < self.distanceMaximum! {
                                    let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                                    self.clinicsList.append(newClinic)
                                }
                            } else {
                                let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                                self.clinicsList.append(newClinic)
                            }
                         }
                    }
                    debugPrint("search by vaccine type only \(self.searchText) \(self.distanceMaximum)")
                    self.clinicsCollectionView.reloadData()
                }
            } else {
                clinicsCollectionRef.whereField("vaccineType", isEqualTo: vaccineType).whereField("hours", isEqualTo: self.hoursSelected).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        guard let snap = querySnapshot else {return}
                        for document in snap.documents {
                            let data = document.data()
                            let vaccineType = data["vaccineType"] as? String ?? ""
                            let name = data["name"] as? String ?? ""
                            let address = data["address"] as? String ?? ""
                            let latitude = data["latitude"] as? CLLocationDegrees ?? 0
                            let longitude = data["longitude"] as? CLLocationDegrees ?? 0
                            let hours = data["hours"] as? String ?? ""
                            let docId = document.documentID
                            let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            //print(data,name,docId)
                            let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                            self.clinicsList.append(newClinic)
                         }
                    }
                    debugPrint("search by vaccine type and hours")
                    self.clinicsCollectionView.reloadData()
                }
            }
        } else {
            if self.hoursSelected == "All" || self.hoursSelected == "Filter by Operating Hours" {
                clinicsCollectionRef.whereField("vaccineType", isEqualTo: vaccineType).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        guard let snap = querySnapshot else {return}
                        for document in snap.documents {
                            let data = document.data()
                            let vaccineType = data["vaccineType"] as? String ?? ""
                            let name = data["name"] as? String ?? ""
                            let address = data["address"] as? String ?? ""
                            let latitude = data["latitude"] as? CLLocationDegrees ?? 0
                            let longitude = data["longitude"] as? CLLocationDegrees ?? 0
                            let hours = data["hours"] as? String ?? ""
                            let docId = document.documentID
                            let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            //print(data,name,docId)
                            if self.distanceMaximum != nil {
                                if (name.contains(self.searchText!) && distance < self.distanceMaximum! ) {
                                    let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                                    self.clinicsList.append(newClinic)
                                }
                            } else {
                                if name.contains(self.searchText!) {
                                    let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                                    self.clinicsList.append(newClinic)
                                }
                            }
                        }
                    }
                    print("search by vaccine type and search text")
                    self.clinicsCollectionView.reloadData()
                }
            } else {
                clinicsCollectionRef.whereField("vaccineType", isEqualTo: vaccineType).whereField("hours", isEqualTo: self.hoursSelected).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        guard let snap = querySnapshot else {return}
                        for document in snap.documents {
                            let data = document.data()
                            let vaccineType = data["vaccineType"] as? String ?? ""
                            let name = data["name"] as? String ?? ""
                            let address = data["address"] as? String ?? ""
                            let latitude = data["latitude"] as? CLLocationDegrees ?? 0
                            let longitude = data["longitude"] as? CLLocationDegrees ?? 0
                            let hours = data["hours"] as? String ?? ""
                            let docId = document.documentID
                            let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            //print(data,name,docId)
                            if self.distanceMaximum != nil {
                                if (name.contains(self.searchText!) && distance < self.distanceMaximum! ) {
                                    let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                                    self.clinicsList.append(newClinic)
                                }
                            } else {
                                if name.contains(self.searchText!) {
                                    let newClinic = Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
                                    self.clinicsList.append(newClinic)
                                }
                            }
                         }
                    }
                    print("search by vaccine type and hours and search text")
                    self.clinicsCollectionView.reloadData()
                }
            }
        }
        
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
                let hours = data["hours"] as? String ?? ""
                let distance = self.calculateDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                let docId = queryDocumentSnapshot.documentID
                return Clinic(id: docId, vaccineType: vaccineType, name: name, address: address, latitude: latitude, longitude: longitude, distance: distance, hours: hours)
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

    @IBAction func selectVaccineTypeAction(_ sender: Any) {
        dataSource = ["Pfizer-BioNTech", "Moderna", "SinoVac"]
        buttonSelected = selectVaccineTypeButton
        addFilterSelector(CGRectframe: selectVaccineTypeButton.frame)
    }
    @IBAction func selectOperatingHoursAction(_ sender: Any) {
        dataSource = ["All", "24hours", "Normal", "Extended", "Weekday"]
        buttonSelected = selectOperatingHoursButton
        addFilterSelector(CGRectframe: selectOperatingHoursButton.frame)
    }
    @IBAction func searchAction(_ sender: Any) {
        showMessage("")
        let vaccineType = selectVaccineTypeButton.title(for: .normal)! as String
        self.hoursSelected = selectOperatingHoursButton.title(for: .normal)! as String
        if let distance = Double(distanceMaximumTextField.text!) {
            self.distanceMaximum = distance
        } else {
            showMessage("Please enter valid number for distance")
        }
        self.searchText = searchTextField.text
        self.fetchData(vaccineType: vaccineType)
    }

    func showMessage(_ message:String) {
        messageLabel.text = message
        messageLabel.alpha = 1
    }
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
        showMessage("")
        buttonSelected.setTitle(dataSource[indexPath.row], for: .normal)
        removeFilterSelector()
        let vaccineType = selectVaccineTypeButton.title(for: .normal)! as String
        self.hoursSelected = selectOperatingHoursButton.title(for: .normal)! as String
        if let distance = Double(distanceMaximumTextField.text!) {
            self.distanceMaximum = distance
        } else {
            showMessage("Please enter valid number for distance")
        }
        self.searchText = searchTextField.text
        //print(selectVaccineTypeButton.title(for: .normal))
        //print(selectOperatingHoursButton.title(for: .normal))
        self.fetchData(vaccineType: vaccineType)
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.clinicDetails = clinicsList[indexPath.row]
        performSegue(withIdentifier: "appointment", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! AppointmentViewController
        vc.selectedClinicDetails = self.clinicDetails
        vc.userEmail = self.userEmail
    }
}

