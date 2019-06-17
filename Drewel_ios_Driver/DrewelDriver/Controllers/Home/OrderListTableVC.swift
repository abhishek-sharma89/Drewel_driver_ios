//
//  OrderListTableVC.swift
//  DrewelDriver
//
//  Created by Octal on 18/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import CoreLocation

class OrderListTableVC: UITableViewController {
    
    @IBOutlet weak var lblNoOrder: UILabel!
    
    var listType = Int()
    var arrOrders = Array<OrderListData>()
    var userData = UserData.sharedInstance;

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
        if self.listType == 3 {
            self.getOrderListApi()
        }
        self.lblNoOrder.isHidden  = self.arrOrders.count > 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
    }
    
    func setInitialValues() {
        self.view.tag = self.listType
        self.listType = self.listType == 0 ? 3 : self.listType
        self.navigationItem.title = languageHelper.LocalString(key: "completedOrder")
        if self.listType != 3 {
            self.getOrderListApi()
            NotificationCenter.default.addObserver(self, selector: #selector(getOrderListApi), name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
        }
    }
    
    
    @IBAction func btnDetailsAction(sender : UIButton) {
        self.performSegue(withIdentifier: "segueDetails", sender: self.arrOrders[sender.tag])
    }
    
    @IBAction func btnCallToDeliverAction(_ sender: UIButton) {
        guard let number = URL(string: "tel://" + (sender.titleLabel?.text)!) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func btnDeliverAction(_ sender: UIButton) {
        if self.arrOrders[sender.tag].payment_mode == "COD" {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "collectedCash"), preferredStyle: .alert)
            
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Confirm_Title"), style: UIAlertActionStyle.default) { _ in
                self.changeOrderStatusAPI(flag: 3, orderId: self.arrOrders[sender.tag].order_id)
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else {
            self.changeOrderStatusAPI(flag: 3, orderId: self.arrOrders[sender.tag].order_id)
        }
    }
    
    @IBAction func btnPickupAction(_ sender: UIButton) {
        self.changeOrderStatusAPI(flag: 2, orderId: self.arrOrders[sender.tag].order_id)
    }
    
    @IBAction func btnTrackCustomerAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FullMapVC") as! FullMapVC
        vc.destinationLat = Double(self.arrOrders[sender.tag].order_Lat) ?? 0.00
        vc.destinationLong = Double(self.arrOrders[sender.tag].order_Lng) ?? 0.00
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.arrOrders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)) as! OrderListTableCell
        let order = self.arrOrders[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let order_date = formatter.date(from: order.created_at)
        formatter.dateFormat = "yyyy-MM-dd"
        let del_date = formatter.date(from: order.delivery_date)
        formatter.dateFormat = "dd MMM''yy h:mm a"
        formatter.locale = languageHelper.getLocale()
        cell.lblOrderId.text = "#\(order.order_id.replaceEnglishDigitsWithArabic)"
        cell.lblOrderDate.text = formatter.string(from: (order_date ?? Date()))
        cell.lblStatus.text = languageHelper.LocalString(key: order.order_delivery_status)
        cell.lblPaymentType.text = languageHelper.LocalString(key: "\(order.payment_mode)")
        
        formatter.dateFormat = "EEE, dd MMM''yy"
        cell.lblDeliveryDate.text = formatter.string(from: (del_date ?? Date()))
        
        formatter.dateFormat = "HH:mm:ss"
        let del_strt = formatter.date(from: order.delivery_start_time)
        let del_end = formatter.date(from: order.delivery_end_time)
        formatter.dateFormat = "hh:mmaa"
        cell.lblDelvieryTime.text = "\(formatter.string(from: (del_strt ?? Date())))" + " \(languageHelper.LocalString(key: "To")) \(formatter.string(from: (del_end ?? Date())))"
        
        cell.lblOrderPrice.text = String(format: "%.3f", Double(order.total_amount)!).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        cell.lblDeliveryAddress.text = order.delivery_address
        cell.lblDeliveryToName.text = order.deliver_to
        cell.btnCallDeliveryPerson.setTitle(order.deliver_mobile, for: .normal)
        cell.btnCallDeliveryPerson.addTarget(self, action: #selector(self.btnCallToDeliverAction(_:)), for: .touchUpInside)
        cell.lblDeliveryDistance.text = String(format: "%.2f", Double(order.distance)!).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "miles"))"
        
        cell.viewAcceptOrder.isHidden = self.listType != 0
        cell.viewPickupOrder.isHidden = self.listType != 1
        cell.viewDeliverOrder.isHidden = self.listType != 2
        cell.lblStatus.textColor = order.order_delivery_status != "order_delivery_status" ? kThemeColor1 : UIColor.green
        
        cell.btnOrderDetails.addTarget(self, action: #selector(btnDetailsAction(sender:)), for: .touchUpInside)
        cell.btnOrderDetails.tag = indexPath.row
        cell.btnDeliver.addTarget(self, action: #selector(btnDeliverAction(_:)), for: .touchUpInside)
        cell.btnDeliver.tag = indexPath.row
        cell.btnPickup.addTarget(self, action: #selector(btnPickupAction(_:)), for: .touchUpInside)
        cell.btnPickup.tag = indexPath.row
        
        cell.const_delivery_option_height.constant = self.listType == 3 ? 0 : cell.const_delivery_option_height.constant
        
        cell.btnTrackCustomer.isHidden = self.listType == 1
        cell.btnTrackCustomer.tag = indexPath.row
        cell.btnTrackCustomer.addTarget(self, action: #selector(btnTrackCustomerAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 610.00
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "segueOrderDetails", sender: indexPath.row)
    }
    
    // MARK: - WebService Method
    @objc func getOrderListApi() {
        let param : NSDictionary = ["user_id"       : self.userData.user_id,
                                    "flag"          : self.listType,
                                    "language"      : languageHelper.isArabic() ? "ar" : "en"]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Order_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrOrders.removeAll()
                
                let arr = result.value(forKey: "Order") as? NSArray ?? NSArray()
                
                for i in 0..<arr.count {
                    let dict = (arr[i] as! NSDictionary).removeNullValueFromDict()
                    var order = OrderListData()
                    
                    order.delivery_date = "\(dict.value(forKey: "delivery_date") ?? "0")"
                    order.order_id = "\(dict.value(forKey: "order_id") ?? "0")"
                    order.order_delivery_status = "\(dict.value(forKey: "order_delivery_status") ?? "0")"
                    order.order_status = "\(dict.value(forKey: "order_status") ?? "0")"
                    order.delivery_start_time = "\(dict.value(forKey: "delivery_start_time") ?? "0")"
                    order.total_amount = "\(dict.value(forKey: "total_amount") ?? "0")"
                    order.is_cancelled = "\(dict.value(forKey: "is_cancelled") ?? "0")"
                    order.total_quantity = "\(dict.value(forKey: "total_quantity") ?? "0")"
                    order.delivery_end_time = "\(dict.value(forKey: "delivery_end_time") ?? "0")"
                    order.payment_mode = "\(dict.value(forKey: "payment_mode") ?? "0")"
                    order.deliver_mobile = "\(dict.value(forKey: "deliver_mobile") ?? "0")"
                    order.cancelled_before = "\(dict.value(forKey: "cancelled_before") ?? "0")"
                    order.deliver_to = "\(dict.value(forKey: "deliver_to") ?? "0")"
                    order.delivery_address = "\(dict.value(forKey: "delivery_address") ?? "0")"
                    order.created_at = "\(dict.value(forKey: "created_at") ?? "0")"
                    order.distance = "\(dict.value(forKey: "distance") ?? "0")"
                    
                    order.order_Lat = "\(dict.value(forKey: "delivery_latitude") ?? "0")"
                    order.order_Lng = "\(dict.value(forKey: "delivery_longitude") ?? "0")"
                    
                    self.arrOrders.append(order)
                }
                self.tableView.reloadData()
                self.lblNoOrder.isHidden  = self.arrOrders.count > 0
            }else {
                self.lblNoOrder.isHidden  = self.arrOrders.count > 0
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func changeOrderStatusAPI(flag : Int, orderId : String) {
        let cord1 = CLLocation(latitude: 23.5402489, longitude: 58.380247300000065)
        let cord2 = CLLocation(latitude: currentLat, longitude: currentLng)
        let distance = flag == 3 ? (cord2.distance(from: cord1)/1000) : 0
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "order_id"  : orderId,
                                    "status"    : "\(flag)",
                                    "delivery_km" : String.init(format: "%.3f", distance)]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Update_Order_Status, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                if self.listType == 3 {
                    self.navigationController?.popToRootViewController(animated: true)
                    HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
                }else {
                    NotificationCenter.default.post(name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
                }
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetails" {
            let vc = segue.destination as! OrderDetailsVC
            vc.orderData = sender as! OrderListData
            vc.listType = self.listType
        }
    }
 

}


class OrderListTableCell: UITableViewCell {
    
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDeliveryDate: UILabel!
    @IBOutlet weak var lblDelvieryTime: UILabel!
    @IBOutlet weak var lblOrderPrice: UILabel!
    @IBOutlet weak var lblPickupDistance: UILabel!
    @IBOutlet weak var lblPickupFromName: UILabel!
    @IBOutlet weak var lblPickupAddress: UILabel!
    @IBOutlet weak var lblDeliveryDistance: UILabel!
    @IBOutlet weak var lblDeliveryToName: UILabel!
    @IBOutlet weak var lblDeliveryAddress: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    
    @IBOutlet weak var viewPickupOrder: UIView!
    @IBOutlet weak var viewAcceptOrder: UIView!
    @IBOutlet weak var viewDeliverOrder: UIView!
    
    @IBOutlet weak var btnCallDeliveryPerson: UIButton!
    @IBOutlet weak var btnOrderDetails: UIButton!
    @IBOutlet weak var btnCallPickupPerson: UIButton!
    
    @IBOutlet weak var btnPickup: UIButton!
    @IBOutlet weak var btnDeliver: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var btnTrackCustomer: UIButton!
    
    
    @IBOutlet weak var const_delivery_option_height: NSLayoutConstraint!
    
}
