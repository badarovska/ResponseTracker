import Foundation
import UIKit

class ResponseDetailsViewController: UIViewController {

    static let storyboardID = "ResponseDetailsViewController"

    @IBOutlet weak var incidentNumber: UITextField!
    @IBOutlet weak var incidentDetails: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incidentDate: UILabel!
    @IBOutlet weak var emergencyType: UILabel!
    @IBOutlet weak var datePickerHeught: NSLayoutConstraint!
    @IBOutlet weak var changeDate: UIButton!
    @IBOutlet weak var deleteResponse: UIButton!
    
    private var emergency: Emergency?
    private var response: Response?
    private var editResponse: Response?
    private var isEditMode: Bool = false
    private let kDatePickerHeight: CGFloat = 216

    override func viewDidLoad() {
        setupViews()
    }

    func update(withEmergencyType emergencyType: Emergency, response: Response? = nil) {
        self.isEditMode = response != nil
        title = isEditMode ? "Edit response" : "Add response"
        editResponse = Response(incidentNumber: response?.incidentNumber  ?? "",
                                              details: response?.details ?? "",
                                              date: response?.date ?? Date())
        self.response = response ?? Response(incidentNumber: "", details: "", date: Date())
        self.emergency = emergencyType
    }

    func setupViews() {
        deleteResponse.isHidden = !isEditMode
        changeDate.isHidden = !isEditMode
        datePickerHeught.constant = isEditMode ? 0 : kDatePickerHeight

        emergencyType.text = emergency?.type ?? ""

        incidentNumber.delegate = self
        incidentNumber.text = response?.incidentNumber

        incidentDate.text = response?.date.toString()

        incidentDetails.delegate = self
        incidentDetails.text = response?.details
        incidentDetails.layer.borderColor = UIColor.lightGray.cgColor

        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneButton(_:)))
        accessory.items = [doneButton]
        incidentDetails.inputAccessoryView = accessory
    }

    //MARK: - Actions
    @IBAction func onSave(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        guard let emergency = emergency, let editResponse = editResponse else { return }
        view.endEditing(true)
        if !isEditMode {
            emergency.add(response: editResponse)
        } else {
            response?.incidentNumber = editResponse.incidentNumber
            response?.details = editResponse.details
            response?.date = editResponse.date
        }

        _ = EmergencyTypeDataSource.update(emergency: emergency)

    }

    @IBAction func onDatePicker(_ datePicker: UIDatePicker) {
        incidentDate.text = datePicker.date.toString()
        editResponse?.date = datePicker.date
    }

    @objc func onDoneButton(_ button: UIButton) {
        incidentDetails.resignFirstResponder()
    }

    @IBAction func onChangeDate(_ sender: UIButton) {
        if datePickerHeught.constant == 0 {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.datePickerHeught.constant = self?.kDatePickerHeight ?? 0
                self?.view.layoutIfNeeded()
                self?.changeDate.isHidden = true
            }
        }
    }

    @IBAction func onDelete(_ sender: UIButton) {
        AlertFactory.showOKCancelAlert(message: "Are you sure?") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            guard let response = self?.response, let emergency = self?.emergency else { return }
            emergency.remove(response: response)
            _ = EmergencyTypeDataSource.update(emergency: emergency)
        }
    }
}

extension ResponseDetailsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        editResponse?.incidentNumber = textField.text ?? ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension ResponseDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        editResponse?.details = textView.text
    }
}

