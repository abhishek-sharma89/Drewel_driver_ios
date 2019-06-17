//
//  MoreVC.swift
//  Drewel
//
//  Created by Octal on 12/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import MessageUI
import Kingfisher
import SafariServices

class MoreVC: UIViewController {
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var tblSettings: UITableView!
    
    var arrTitle = [languageHelper.LocalString(key:"myAccount"),
                    languageHelper.LocalString(key:"notificationSettings"),
                    languageHelper.LocalString(key:"changePassword"),
                    languageHelper.LocalString(key:"aboutApp"),
                    languageHelper.LocalString(key:"changeLanguage"),
                    languageHelper.LocalString(key:"contactUs"),
                    languageHelper.LocalString(key:"aboutUs"),
                    languageHelper.LocalString(key:"rateus"),
                    languageHelper.LocalString(key:"signOut")];
    
    var arrImages = ["myaccount",
                     "settings",
                     "password",
                     "aboutapp",
                     "changelanguage",
                     "contactus",
                     "aboutus",
                     "rateapp",
                     "logout"]
    
    var isSwitchOn : Bool = true;
    
    var emailTitle = "Feedback"
    var messageBody = "Feature request or bug report?"
    var toRecipents = ["support@drewel.om"]
    
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
        self.navigationItem.title = languageHelper.LocalString(key: "settings")
        self.isSwitchOn = UserData.sharedInstance.is_notification == "1"
    }
    
    //MARK: - Action Method
    @IBAction func btnSwitchNotificaiton(_ sender: UISwitch) {
        let alert = UIAlertController(title: kAPPName, message: self.isSwitchOn ? languageHelper.LocalString(key: "Notifications_Off") : languageHelper.LocalString(key: "Notifications_On"), preferredStyle: .alert)
        
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
            self.isSwitchOn = sender.isOn;
            self.changeNotificatonStatusAPI()
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: { _ in
            sender.isOn = self.isSwitchOn
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - WebService Method
    func logoutUserAPI() {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Logout_User, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                UserDefaults.standard.set(false, forKey: kAPP_SOCIAL_LOG)
                UserDefaults.standard.set(false, forKey: kAPP_IS_LOGEDIN)
                UserDefaults.standard.removeObject(forKey: kDefaultAddress)
                UserDefaults.standard.synchronize()
                let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "ViewController")
                UIApplication.shared.keyWindow?.rootViewController = vc
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func changeNotificatonStatusAPI() {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "is_notification" : self.isSwitchOn ? "on" : "off"]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Notification_Status, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.tblSettings.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                
                UserData.sharedInstance.is_notification = self.isSwitchOn ? "1" : "0"
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.isSwitchOn ? "1" : "0", forKey: "is_notification")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
            }else {
                self.isSwitchOn = !self.isSwitchOn
                self.tblSettings.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
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

// MARK: -
//UITableView Delegate & Datasource
extension MoreVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.row == 1 {
            (cell.contentView.viewWithTag(4) as! UISwitch).isOn = self.isSwitchOn
            (cell.contentView.viewWithTag(4) as! UISwitch).addTarget(self, action: #selector(btnSwitchNotificaiton(_:)), for: .valueChanged)
        }
        (cell.contentView.viewWithTag(11) as! UIButton).setImage(UIImage.init(named: self.arrImages[indexPath.row]), for: .normal)
        (cell.contentView.viewWithTag(4) as! UISwitch).isHidden = (indexPath.row <= 0 || indexPath.row > 1)
        (cell.contentView.viewWithTag(2) as! UILabel).text = arrTitle[indexPath.row];
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell.contentView.viewWithTag(4) as! UISwitch).transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "ProfileVC")
            self.navigationController?.show(vc, sender: nil)
        }else if indexPath.row == 2 {
            let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "ChangePasswordVC")
            self.navigationController?.show(vc, sender: self)
        }else if indexPath.row == 3 {
            let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "AboutUsVC")
            self.navigationController?.show(vc, sender: self)
        }else if indexPath.row == 4 {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "selectLanguage"), preferredStyle: .actionSheet)
            
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "English"), style: UIAlertActionStyle.default) { _ in
                if languageHelper.isArabic() {
                    languageHelper.changeLanguageTo(lang: "en")
                    UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Arabic"), style: UIAlertActionStyle.default) { _ in
                if !languageHelper.isArabic() {
                    languageHelper.changeLanguageTo(lang: "ar")
                    UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else if indexPath.row == 5 {
            
            let mc: MFMailComposeViewController? = MFMailComposeViewController()
            mc?.mailComposeDelegate = self
            mc?.setSubject(emailTitle)
            mc?.setMessageBody(messageBody, isHTML: false)
            mc?.setToRecipients(toRecipents)
            
            if (mc != nil) {
              self.present(mc!, animated: true, completion: nil)
            }
            
        }else if indexPath.row == 6 {
            let svc = SFSafariViewController(url: URL.init(string: "https://56.octallabs.com/drewel/")!)
            self.present(svc, animated: true, completion: nil)
        }else if indexPath.row == 8 {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "MESSAGE_LOGOUT"), preferredStyle: .alert)
            
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
                self.logoutUserAPI()
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            print("alert")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension MoreVC : MFMailComposeViewControllerDelegate  {
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error?.localizedDescription ?? "error")")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
