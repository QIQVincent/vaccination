//
//  AppointmentViewController.swift
//  vaccination
//
//  Created by User on 20/9/21.
//

import UIKit
import Firebase
import MessageUI

class AppointmentViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var selectedClinicDetails: Clinic?
    var userEmail: String?
    
    @IBOutlet weak var clinicDetailsLabel: UILabel!
    @IBOutlet weak var clinicAddressLabel: UILabel!
    @IBOutlet weak var appointmentTableView: UITableView!
    @IBOutlet weak var appointmentDateTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!

    var hoursDict = [String:Hours]()
    var timePeriodArray = [Int]()
    var bookingNumber: Int?
    var bookingDate: String?

    let datePicker = UIDatePicker()
    let db = Firestore.firestore()
    var hoursCollectionRef: CollectionReference!
    var bookingCollectionRef: CollectionReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let floatNum = selectedClinicDetails!.distance
        let distanceStr = NSString(format: "%.2f", floatNum)
        clinicDetailsLabel.text = "Vaccine: \(selectedClinicDetails!.vaccineType)\nDistance: \(distanceStr) km\nHours:\(selectedClinicDetails!.hours)\n\(selectedClinicDetails!.name)"
        clinicAddressLabel.text = "Address\n\(selectedClinicDetails!.address)"
        //print(clinicDetailsLabel.text)

        hoursCollectionRef = db.collection("hours")
        bookingCollectionRef = db.collection("booking")
        
        appointmentTableView.delegate = self
        appointmentTableView.dataSource = self

        createDatePicker()
        
        messageLabel.alpha = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        hoursCollectionRef.getDocuments { (querySnapshot, error) in
            if let err = error {
                debugPrint("Error getting docs: \(err)")
            } else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let data = document.data()
                    let id = data["id"] as? Int ?? 0
                    let name = data["name"] as? String ?? ""
                    let weekdayStart = data["weekdayStart"] as? Int ?? 0
                    let weekdayEnd = data["weekdayEnd"] as? Int ?? 0
                    let SaturdayStart = data["saturdayStart"] as? Int ?? 0
                    let SaturdayEnd = data["saturdayEnd"] as? Int ?? 0
                    let SundayStart = data["sundayStart"] as? Int ?? 0
                    let SundayEnd = data["sundayEnd"] as? Int ?? 0
                    //let docId = document.documentID
                    //print(data,name,id)
                    let test = Hours(id: id, name: name, weekdayStart: weekdayStart, weekdayEnd: weekdayEnd, SaturdayStart: SaturdayStart, SaturdayEnd: SaturdayEnd, SundayStart: SundayStart, SundayEnd: SundayEnd)
                    self.hoursDict[name] = test
                    //self.clinicsList.append(newClinic)
                }
            }
        }
    }
    func createDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let dateButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateEntry))
        toolbar.setItems([dateButton], animated: true)
        
        appointmentDateTextField.textAlignment = .center
        appointmentDateTextField.inputAccessoryView = toolbar
        appointmentDateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
    }
    @objc func dateEntry() {
        let format = DateFormatter()
        format.dateStyle = .full
        format.timeStyle = .none

        let format2 = DateFormatter()
        format2.dateStyle = .medium
        format2.timeStyle = .none

        self.bookingDate = format2.string(from: datePicker.date)
        appointmentDateTextField.text = format.string(from: datePicker.date)
        self.view.endEditing(true)
        let timePeriod = self.startEndTime(dayOfWeek: datePicker.date.dayOfWeek(), clinicHours: selectedClinicDetails!.hours)
        if (timePeriod.start == timePeriod.end) {
            timePeriodArray.removeAll()
        } else {
            timePeriodArray = Array(timePeriod.start...timePeriod.end)
        }
        //print(timePeriodArray)
        //print("Time for Day: ", timePeriod.start, timePeriod.end, timePeriodArray.count)
        self.appointmentTableView.reloadData()
    }
    
    func startEndTime(dayOfWeek: String?, clinicHours: String) -> (start: Int, end: Int) {
        //let hours = self.hoursDict[clinicHours]
        //print("called runs \(self.hoursDict)")
        //print("called unit \(self.hoursDict[clinicHours]?.SaturdayStart)")
        //print("1", dayOfWeek!)
        switch dayOfWeek! {
            case "Saturday":
//                print("Sat", dayOfWeek!)
//                print(self.hoursDict[clinicHours])
//                print(self.hoursDict[clinicHours]?.SaturdayStart as! Int, self.hoursDict[clinicHours]?.SaturdayEnd as! Int)
                return(self.hoursDict[clinicHours]?.SaturdayStart as! Int, self.hoursDict[clinicHours]?.SaturdayEnd as! Int)
            case "Sunday":
//                print("Sun", dayOfWeek!)
//                print(self.hoursDict[clinicHours]?.SundayStart as! Int, self.hoursDict[clinicHours]?.SundayEnd as! Int)
                return(self.hoursDict[clinicHours]?.SundayStart as! Int, self.hoursDict[clinicHours]?.SundayEnd as! Int)
            default:
                return(self.hoursDict[clinicHours]?.weekdayStart as! Int, self.hoursDict[clinicHours]?.weekdayEnd as! Int)
        }
    }
    
    func showMessage(_ message:String) {
        messageLabel.text = message
        messageLabel.alpha = 1
    }
    
}

extension AppointmentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = appointmentTableView.dequeueReusableCell(withIdentifier: "booking", for: indexPath)
        let clinicId = selectedClinicDetails!.id
        // let bookingTime = String(timePeriodArray[indexPath.row])
        // print("bookings/\(clinicId)/\(self.bookingDate!)")
        bookingCollectionRef.document(clinicId).collection(self.bookingDate!).document(String(timePeriodArray[indexPath.row])).getDocument() { (querySnapshot, err) in
        if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let snap = querySnapshot else {return}
                let bookingCount = snap["count"] as? Int ?? 0
                if bookingCount ==  1 {
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.isEnabled = false
                } else {
                    cell.isUserInteractionEnabled = true
                    cell.textLabel?.isEnabled = true
                }
                // print("Already booked: Cell: \(indexPath.row) Timeslot: \(self.timePeriodArray[indexPath.row]) Count: \(bookingCount)")
            }
        }
        cell.textLabel?.text = "\(timePeriodArray[indexPath.row]):00 Hours"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clinicId = selectedClinicDetails!.id
        let bookingTime = String(timePeriodArray[indexPath.row])
        bookingCollectionRef.document(clinicId).collection(self.bookingDate!).document(String(timePeriodArray[indexPath.row])).setData(["count" : 1], merge: true)
        sendEmail(message: "Your vaccination booking has been made at \(selectedClinicDetails!.name) for \(selectedClinicDetails!.vaccineType) on \(self.bookingDate!) at \(bookingTime):00 Hours")
        showMessage("Your vaccination booking has been made at \(selectedClinicDetails!.name) for \(selectedClinicDetails!.vaccineType) on \(self.bookingDate!) at \(bookingTime):00 Hours, and email has been sent to your registered email")
        self.appointmentTableView.reloadData()
    }
    func sendEmail(message: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([self.userEmail!])
            mail.setMessageBody(message, isHTML: true)
            present(mail, animated: true)
        } else {
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timePeriodArray.count
    }
}
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
}
