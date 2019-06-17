//
//  ProfileVC.swift
//  Drewel
//
//  Created by Octal on 26/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtVehicle: UITextField!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var viewProfilePic: UIView!
    
    
    
    var isProfilePicChanged = false
    let userData = UserData.sharedInstance
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "myProfile")
        self.setDataOnTextFields()
        DispatchQueue.main.async {
            self.viewProfilePic.cornerRadius = self.viewProfilePic.frame.size.height/2
        }
    }
    
    func setDataOnTextFields() {
        self.txtFirstName.text = self.userData.first_name
        self.txtLastName.text = self.userData.last_name
        self.txtPhoneNumber.text = self.userData.mobile_number
        self.txtEmail.text = self.userData.email
        self.txtVehicle.text = self.userData.vehicle_number
        self.imgProfile.kf.setImage(with:
            URL.init(string: self.userData.img)!,
                                   placeholder: #imageLiteral(resourceName: "loc_icon.png"),
                                   options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                   progressBlock: nil,
                                   completionHandler: nil)
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnSaveAction(_ sender: UIButton) {
        if (self.txtFirstName.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "FNAME_LENGTH"), title: kAPPName)
        }else if (self.txtLastName.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "LNAME_LENGTH"), title: kAPPName)
        }else if (self.txtPhoneNumber.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_LENGTH"), title: kAPPName)
        }else if !(self.txtPhoneNumber.text?.isPhoneNumber)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_VALID"), title: kAPPName)
        }else if (self.txtVehicle.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "VEHICHLE_LEGTH_MSG"), title: kAPPName)
        }else {
            self.saveUpdatedProfileAPI()
        }
    }
    
    @IBAction func btnChangeProfilePicAction(_ sender: UIButton) {
        self.selectMedia()
    }
    
    
    // MARK: - UITextfield Delegate Method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == self.txtFirstName || textField == self.txtLastName {
            if range.location >= 35 && string != "" {
                return false
            }
            if string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil || string == "" {
                if !string.canBeConverted(to: String.Encoding.ascii){
                    return false
                }
                return true
            }else {
                return false
            }
        }else if textField == txtVehicle {
            if range.location >= 35 && string != "" {
                return false
            }else if string == " " {
                return false
            }else if !string.canBeConverted(to: String.Encoding.ascii){
                return false
            }
        }
        return true;
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(paste(_:)) {
            return false
        }
        return true
    }
    
    // MARK: - WebService Method
    func saveUpdatedProfileAPI() {
        
        let param : NSDictionary = ["user_id"   :   self.userData.user_id,
                                    "language"  :   languageHelper.language,
                                    "first_name":   (self.txtFirstName.text)!,
                                    "last_name" :   (self.txtLastName.text)!,
                                    "vehicle_number":(self.txtVehicle.text)!]
        
        HelperClass.formRequestApiWithBody(param: param,
                                           urlString: kURL_Update_Profile as NSString,
                                           mediaData: (isProfilePicChanged ? self.imgProfile.image : nil),
                                           isHeader: true,
                                           showAlert: true,
                                           showHud: true,
                                           vc: self)
        { (result, message, status) in
            
            if status == "1" {
                self.isProfilePicChanged = false
                
                let dict = result.removeNullValueFromDict()
                
                self.userData.first_name = (self.txtFirstName.text)!
                self.userData.last_name = (self.txtLastName.text)!
                self.userData.vehicle_number = (self.txtVehicle.text)!
                self.userData.img = "\(dict.value(forKey: "img") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.first_name, forKey: "first_name")
                userDict.setValue(self.userData.last_name, forKey: "last_name")
                userDict.setValue(self.userData.vehicle_number, forKey: "vehicle_number")
                userDict.setValue(self.userData.img, forKey: "img")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension ProfileVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imgProfile.image = pickedImage
                self.isProfilePicChanged = true
            }
        picker.dismiss(animated: true, completion: nil);
        //        self.collectionImages.reloadData();
    }
    
    func selectMedia() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self;
        imagePicker.allowsEditing = false;
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = kThemeColor1;
        let action1 = UIAlertAction(title: languageHelper.LocalString(key: "selectExisting"), style: .default) { (action:UIAlertAction) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = ["public.image"];
            alertController.dismiss(animated: true, completion: nil)
            self.present(imagePicker, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: languageHelper.LocalString(key: "camera"), style: .default) { (action:UIAlertAction) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = ["public.image", "public.movie"];
            alertController.dismiss(animated: true, completion: nil)
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: languageHelper.LocalString(key:"Cancel_Title"), style: .cancel){ action -> Void in
        }
        
        alertController.addAction(action1)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            alertController.addAction(action2)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}




