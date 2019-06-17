//
//  HomeVC.swift
//  DrewelDriver
//
//  Created by Octal on 18/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import CoreLocation

class HomeVC: UIViewController {

    @IBOutlet weak var viewPageFrame: UIView!
    @IBOutlet weak var viewIndicator: UIView!
    
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var btnAccepted: UIButton!
    @IBOutlet weak var btnOutForDelivery: UIButton!
    
    @IBOutlet weak var switchAvailability: UISwitch!
    
    var pageViewController : UIPageViewController!
    var arrVCs = Array<UIViewController>()
    var loc_manager = CLLocationManager()
    
    var timer = Timer()
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
      
//        if UserDefaults.standard.bool(forKey: "isAvailable")
//        {
//            self.changeDriverStatusAPI(status: "1")
//        }
//        else
//        {
//            self.changeDriverStatusAPI(status: "2")
//        }
        
        self.changeDriverStatusAPI(status: "1")
        
        self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.updateDriverLocation(_:)), userInfo: nil, repeats: true)
        self.timer.fire()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
    }
    
    deinit {
        self.loc_manager.stopUpdatingLocation()
        self.loc_manager.disallowDeferredLocationUpdates()
        self.timer.invalidate()
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "order")
        self.switchAvailability.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
        DispatchQueue.main.async {
            self.setupPageController()
        }
        self.startLocationService()
    }
    
    @objc func updateDriverLocation(_ sender : Any?) {
        self.updaeDriverLocationAPI()
    }
    
    func startLocationService() {
        loc_manager.delegate = self
        loc_manager.requestAlwaysAuthorization()
        loc_manager.desiredAccuracy = kCLLocationAccuracyBest
        loc_manager.pausesLocationUpdatesAutomatically = false
        loc_manager.allowsBackgroundLocationUpdates = true
        loc_manager.stopMonitoringSignificantLocationChanges()
        loc_manager.startUpdatingLocation()
    }
    
    private func setupPageController() {
        //        let vc1 = kStoryboard_Main.instantiateViewController(withIdentifier: "OrderListTableVC") as! OrderListTableVC
        //        vc1.listType = 0
        let vc2 = kStoryboard_Main.instantiateViewController(withIdentifier: "OrderListTableVC") as! OrderListTableVC
        vc2.listType = 1
        let vc3 = kStoryboard_Main.instantiateViewController(withIdentifier: "OrderListTableVC") as! OrderListTableVC
        vc3.listType = 2
        arrVCs = [vc2, vc3]
        
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        pageViewController.setViewControllers([arrVCs[0]], direction: .forward, animated: true, completion: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        self.pageViewController.view.frame = self.viewPageFrame.frame
        //  pageViewController.didMove(toParentViewController: self)
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        // Add the page view controller's gesture recognizers to the view controller's view so that the gestures are started more easily.
        view.gestureRecognizers = pageViewController.gestureRecognizers
    }
    
    @IBAction func switchAvailablilityAction(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "isAvailable")
            self.changeDriverStatusAPI(status: "1")
        }else {
            UserDefaults.standard.set(false, forKey: "isAvailable")
            self.changeDriverStatusAPI(status: "2")
        }
    }
    
//    @IBAction func btnSwipeOrderListAction(_ sender: UIButton) {
//        if let vcs = self.pageViewController.viewControllers {
//            if vcs.count > 0 {
//                self.pageViewController.setViewControllers([arrVCs[sender.tag - 101]], direction: (((vcs.last?.view.tag)! - 1) > (sender.tag - 100) ? .reverse : .forward), animated: true, completion: nil)
//                var basketTopFrame = self.viewIndicator.frame;
//                basketTopFrame.origin.x = sender.frame.origin.x
//                basketTopFrame.size.width = sender.frame.size.width
//
//                UIView.animate(withDuration: 0.3) {
//                    self.viewIndicator.frame = basketTopFrame
//                }
//            }
//        }
//    }
    
    @IBAction func btnSwipeOrderListAction(_ sender: UIButton) {
        //        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "OrderListTableVC") as! OrderListTableVC
        if let vcs = self.pageViewController.viewControllers {
            if vcs.count > 0 {
                if sender.tag == 101 && vcs[0].view.tag == 2 {
                    if languageHelper.isArabic() {
                        self.pageViewController.setViewControllers([arrVCs[0]], direction: .forward, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = self.viewPageFrame.frame.size.width/2;
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }else {
                        self.pageViewController.setViewControllers([arrVCs[0]], direction: .reverse, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = 0
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }
                    self.btnOutForDelivery.setTitleColor(UIColor.darkGray, for: .normal)
                    self.btnAccepted.setTitleColor(kThemeColor1, for: .normal)
                }else if sender.tag == 102 && vcs[0].view.tag == 1 {
                    //                    vc.listType = 1
                    if languageHelper.isArabic() {
                        self.pageViewController.setViewControllers([arrVCs[1]], direction: .reverse, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = 0
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }else {
                        self.pageViewController.setViewControllers([arrVCs[1]], direction: .forward, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = self.viewPageFrame.frame.size.width/2;
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }
                    self.btnAccepted.setTitleColor(UIColor.darkGray, for: .normal)
                    self.btnOutForDelivery.setTitleColor(kThemeColor1, for: .normal)
                }
            }
        }
    }
    
    // MARK: - WebService Method
    func changeDriverStatusAPI(status : String) {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "status"    : status]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Update_Driver_Status, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
//                self.navigationController?.popToRootViewController(animated: true)
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
                

            }else {
                self.switchAvailability.isOn = (status == "2")
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
                
            }
        }
    }
    
    func updaeDriverLocationAPI() {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "latitude"  : "\(currentLat)",
                                    "longitude" : "\(currentLng)"]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Update_Driver_Location, showAlert: false, showHud: false, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                
            }else {
                
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetails" {
            let vc = segue.destination as! OrderDetailsVC
            vc.orderData = sender as! OrderListData
        }
    }
}



extension HomeVC : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.view.tag == 1 {
            return arrVCs[1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.view.tag == 2 {
            return arrVCs[0]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            self.btnNew.setTitleColor(UIColor.darkGray, for: .normal)
            self.btnAccepted.setTitleColor(UIColor.darkGray, for: .normal)
            self.btnOutForDelivery.setTitleColor(UIColor.darkGray, for: .normal)
            
            var basketTopFrame = viewIndicator.frame;
            if (pageViewController.viewControllers?.last?.view.tag)! == 0 {
                basketTopFrame.origin.x = self.btnNew.frame.origin.x
                basketTopFrame.size.width = self.btnNew.frame.size.width
                self.btnNew.setTitleColor(kThemeColor1, for: .normal)
            }else if (pageViewController.viewControllers?.last?.view.tag)! == 1 {
                basketTopFrame.origin.x = self.btnAccepted.frame.origin.x
                basketTopFrame.size.width = self.btnAccepted.frame.size.width
                self.btnAccepted.setTitleColor(kThemeColor1, for: .normal)
            }else {
                basketTopFrame.origin.x = self.btnOutForDelivery.frame.origin.x
                basketTopFrame.size.width = self.btnOutForDelivery.frame.size.width
                self.btnOutForDelivery.setTitleColor(kThemeColor1, for: .normal)
            }
            UIView.animate(withDuration: 0.3) {
                self.viewIndicator.frame = basketTopFrame
            }
        }
    }
}

extension HomeVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLat = location.coordinate.latitude
            currentLng = location.coordinate.longitude
            print("Current Location: \(location)")
        }
        manager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistance(100.0), timeout: TimeInterval(10.0))
//        var arr = UserDefaults.standard.object(forKey: "loc") as? Array<Date> ?? Array<Date>()
//        arr.append(Date())
//        UserDefaults.standard.set(arr, forKey: "loc")
//        print(arr)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if error != nil {
            print("Failed to defer location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location")
    }
}


