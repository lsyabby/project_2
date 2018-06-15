//
//  EditViewController.swift
//  project_2
//
//  Created by 李思瑩 on 2018/5/18.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import ZHDropDownMenu
import UserNotifications
import RealmSwift
import Lottie

protocol EditViewControllerDelegate: class {

    func passFromEdit(data: ItemList)
}

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var categoryDropDownMenu: ZHDropDownMenu!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var enddateTextField: UITextField!
    @IBOutlet weak var alertdateTextField: UITextField!
    @IBOutlet weak var numTextField: UITextField!
    @IBOutlet weak var alertInstockSwitch: UISwitch!
    @IBOutlet weak var othersTextView: UITextView!
    weak var delegate: EditViewControllerDelegate?
    var ref: DatabaseReference!
    var list: ItemList?

    override func viewDidLoad() {

        super.viewDidLoad()

        setupOthersTextView()

        setupDropDownMenu()

        setupEditItems()

        setupDatePicker()

        setupSwitch()

        idTextField.delegate = self

        numTextField.delegate = self

        priceTextField.delegate = self
    }

    @IBAction func enddateAction(_ sender: UITextField) {

        setDatePicker(sender: sender, action: #selector(enddatePickerValueChanged(sender:)))
    }

    @IBAction func alertdateAction(_ sender: UITextField) {

        setDatePicker(sender: sender, action: #selector(alertdatePickerValueChanged(sender:)))
    }

    @IBAction func cancelAction(_ sender: UIButton) {

        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneAction(_ sender: UIButton) {

        // request for local notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in

            if granted {

                print("允許")

            } else {

                print("不允許")
            }
        }

        AnimationHandler.loadingAnimation(animationName: "little_balls", view: self.view) { [weak self] (_) in

            self?.ref = Database.database().reference()

            guard let item = self?.list else { return }

            guard let userId = Auth.auth().currentUser?.uid else { return }

            let updatedate = String(Int(Date().timeIntervalSince1970))

            guard let updateName = self?.nameTextField.text else { return }

            let name = updateName == "" ? item.name: updateName

            let editid = Int((self?.idTextField.text!)!) == nil ? 0: Int((self?.idTextField.text!)!)

            let category = self?.categoryDropDownMenu.contentTextField.text ?? item.createDate

            guard let updateenddate = self?.enddateTextField.text else { return }

            let enddate = updateenddate == "" ? item.endDate: updateenddate

            guard let updatealertdate = self?.alertdateTextField.text else { return }

            let alertdate = updatealertdate == "" ? "不提醒": updatealertdate

            let instock = Int((self?.numTextField.text!)!) ?? item.instock

            let isinstock = self?.alertInstockSwitch.isOn ?? item.isInstock

            let alertinstock = item.alertInstock

            let price = Int((self?.priceTextField.text!)!) ?? item.price

            let others = self?.othersTextView.text ?? item.others

            // "imageURL": "",
            let editValue = ["updatedate": updatedate, "name": name, "id": editid!, "category": category, "enddate": enddate, "alertdate": alertdate, "instock": instock, "isInstock": isinstock, "alertInstock": alertinstock, "price": price, "others": others] as [String: Any]

            self?.ref.child("items/\(userId)").queryOrdered(byChild: "createdate").queryEqual(toValue: item.createDate).observeSingleEvent(of: .value) { (snapshot) in

                let value = snapshot.value as? NSDictionary

                for info in (value?.allKeys)! {

                    self?.ref.child("items/\(userId)/\(info)").updateChildValues(editValue, withCompletionBlock: { (_, _) in

                        self?.setupLocalNotification(info: editValue, item: item)

                        self?.delegate?.passFromEdit(data: ItemList(createDate: item.createDate, imageURL: item.imageURL, name: name, itemId: editid!, category: category, endDate: enddate, alertDate: alertdate, instock: instock, isInstock: isinstock, alertInstock: item.alertInstock, price: price, others: others))

                        self?.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
}

extension EditViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard NSCharacterSet(charactersIn: "0123456789").isSuperset(of: NSCharacterSet(charactersIn: string) as CharacterSet) else {

            return false
        }

        return true
    }
}

extension EditViewController: ZHDropDownMenuDelegate {

    func dropDownMenu(_ menu: ZHDropDownMenu, didEdit text: String) {

        print(text)
    }

    func dropDownMenu(_ menu: ZHDropDownMenu, didSelect index: Int) {

        print(index)
    }
}

extension EditViewController {

    func setupLocalNotification(info: [String: Any], item: ItemList) {

        // MARK: - NOTIFICATION - send alert date
        guard let updatealertdate = self.alertdateTextField.text else { return }

        let editAlertdate = updatealertdate == "" ? "不提醒": updatealertdate

        if editAlertdate != "不提醒" {

            guard let itemInfo = ItemList.createForAlertDate(info: info) else { return }

            let content = UNMutableNotificationContent()

            content.title = itemInfo.name

            content.userInfo = ItemList.notiContentInfo(item: item, itemInfo: itemInfo)

            content.body = "有效期限到 \(itemInfo.endDate)"

            content.sound = UNNotificationSound.default()

            guard let imageData = NSData(contentsOf: URL(string: item.imageURL)!) else { return }

            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "img.jpeg", data: imageData, options: nil) else { return }

            content.attachments = [attachment]

            let dateformatter: DateFormatter = DateFormatter()

            dateformatter.dateFormat = "yyyy - MM - dd"

            let alertDate: Date = dateformatter.date(from: editAlertdate)!

            let gregorianCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!

            let components = gregorianCalendar.components([.year, .month, .day], from: alertDate)

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: item.createDate, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { (_) in

                print("build alertdate notificaion successful !!!")
            }

            // MARK: SAVE IN Realm
            do {

                let realm = try Realm()

                let order = ItemList.saveInRealm(item: item, itemInfo: itemInfo)

                try realm.write {

                    realm.add(order, update: true)
                }

                print("@@@ fileURL @@@: \(String(describing: realm.configuration.fileURL))")

            } catch let error as NSError {

                print(error)
            }
        }
    }

    func setupEditItems() {

        guard let item = list else { return }

        itemImageView.sd_setImage(with: URL(string: item.imageURL))

        nameTextField.text = item.name

        idTextField.text = String(describing: item.itemId)

        categoryDropDownMenu.contentTextField.text = item.category

        priceTextField.text = String(describing: item.price)

        enddateTextField.text = item.endDate

        alertdateTextField.text = item.alertDate

        numTextField.text = String(describing: item.instock)

        alertInstockSwitch.isOn = item.isInstock

        othersTextView.text = item.others
    }

    func setupOthersTextView() {

        othersTextView.layer.cornerRadius = 5

        othersTextView.layer.borderWidth = 1

        othersTextView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func setupDropDownMenu() {

        categoryDropDownMenu.options = [ListCategory.food.rawValue, ListCategory.medicine.rawValue, ListCategory.makeup.rawValue, ListCategory.necessary.rawValue, ListCategory.others.rawValue]

        categoryDropDownMenu.contentTextField.text = list?.category

        categoryDropDownMenu.editable = false

        categoryDropDownMenu.delegate = self
    }

    func setupDatePicker() {

        setDatePickerToolBar(dateTextField: enddateTextField)

        setDatePickerToolBar(dateTextField: alertdateTextField)
    }

    func setupSwitch() {

        alertInstockSwitch.setOn(false, animated: true)

        alertInstockSwitch.onTintColor = UIColor.darkGray
    }

    func setDatePickerToolBar(dateTextField: UITextField) {

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height / 6, width: self.view.frame.size.width, height: 40.0))

        toolBar.layer.position = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height - 20.0)

        toolBar.barStyle = UIBarStyle.blackTranslucent

        toolBar.tintColor = UIColor.white

        toolBar.backgroundColor = UIColor.black

        let okBarBtn = UIBarButtonItem(title: "確定", style: .done, target: self, action: #selector(donePressed(sender:)))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))

        label.font = UIFont(name: "Helvetica", size: 15)

        label.backgroundColor = UIColor.clear

        label.textColor = UIColor.white

        label.text = "請選擇日期"

        label.textAlignment = .center

        let textBtn = UIBarButtonItem(customView: label)

        toolBar.setItems([flexSpace, textBtn, flexSpace, okBarBtn], animated: true)

        dateTextField.inputAccessoryView = toolBar

        dateTextField.clearButtonMode = .whileEditing
    }

    @objc func donePressed(sender: UIBarButtonItem) {

        enddateTextField.resignFirstResponder()

        alertdateTextField.resignFirstResponder()
    }

    @objc func enddatePickerValueChanged(sender: UIDatePicker) {

        setDateFormatter(dateTextField: self.enddateTextField, sender: sender)
    }

    @objc func alertdatePickerValueChanged(sender: UIDatePicker) {

        setDateFormatter(dateTextField: self.alertdateTextField, sender: sender)
    }

    private func setDateFormatter(dateTextField: UITextField, sender: UIDatePicker) {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy - MM - dd"

        dateTextField.text = dateFormatter.string(from: sender.date)
    }

    private func setDatePicker(sender: UITextField, action: Selector) {

        let datePickerView: UIDatePicker = UIDatePicker()

        datePickerView.locale = Locale(identifier: "zh_TW")

        datePickerView.datePickerMode = UIDatePickerMode.date

        sender.inputView = datePickerView

        datePickerView.addTarget(self, action: action, for: .valueChanged)
    }
}
