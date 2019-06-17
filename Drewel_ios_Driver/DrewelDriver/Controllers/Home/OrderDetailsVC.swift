//
//  OrderDetailsVC.swift
//  DrewelDriver
//
//  Created by Octal on 22/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class OrderDetailsVC: UITableViewController {
    
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblItemsCount: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDeliveryDate: UILabel!
    @IBOutlet weak var lblDelvieryTime: UILabel!
    @IBOutlet weak var lblOrderPrice: UILabel!
    @IBOutlet weak var lblDeliveryDistance: UILabel!
    @IBOutlet weak var lblDeliveryToName: UILabel!
    @IBOutlet weak var lblDeliveryAddress: UILabel!
    @IBOutlet weak var lblTotalItems: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    
    @IBOutlet weak var viewPickupOrder: UIView!
    @IBOutlet weak var viewDeliverOrder: UIView!
    
    @IBOutlet weak var btnCallDeliveryPerson: UIButton!
    
    @IBOutlet weak var collectionProducts: UICollectionView!
    
    var orderData = OrderListData()
    var arrProducts = [ProductsData]()
    var listType = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tag = 0
        self.navigationItem.title = "#\(orderData.order_id.replaceEnglishDigitsWithArabic)"
        self.getOrderListApi()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 240
        
        NotificationCenter.default.addObserver(self, selector: #selector(getOrderListApi), name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.tableView.tag == 1 ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.listType == 3 ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }else if indexPath.row == 1 {
            return 232
        }
        return 81
    }
    
    @IBAction func btnCallToDeliverAction(_ sender: UIButton) {
        guard let number = URL(string: "tel://" + (sender.titleLabel?.text)!) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func btnDeliverAction(_ sender: UIButton) {
        if self.orderData.payment_mode == "COD" {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "collectedCash"), preferredStyle: .alert)
            
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Confirm_Title"), style: UIAlertActionStyle.default) { _ in
                self.changeOrderStatusAPI(flag: 3)
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else {
            self.changeOrderStatusAPI(flag: 3)
        }
    }
    
    @IBAction func btnPickupAction(_ sender: UIButton) {
        self.changeOrderStatusAPI(flag: 2)
    }
    
    // MARK: - WebService Method
    @objc func getOrderListApi() {
        let param : NSDictionary = ["user_id"       : UserData.sharedInstance.user_id,
                                    "order_id"      : self.orderData.order_id,
                                    "language"      : languageHelper.isArabic() ? "ar" : "en"]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Order_Details, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                
                let dict = (result.object(forKey: "Order") as! NSDictionary).removeNullValueFromDict()
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
                order.created_at = "\(dict.value(forKey: "order_date") ?? "0")"
                order.distance = "\(dict.value(forKey: "distance") ?? "0")"
                order.delivery_charges = "\(dict.value(forKey: "delivery_charges") ?? "0")"
                order.net_amount = "\(dict.value(forKey: "net_amount") ?? "0")"
                
                self.orderData = order
                
                self.arrProducts.removeAll()
                var qtys = 0
                let arr = result.value(forKey: "Products") as! NSArray
                for i in 0..<arr.count {
                    let dict = (arr[i] as! NSDictionary).removeNullValueFromDict()
                    var product = ProductsData()
                    
                    product.product_id = "\(dict.value(forKey: "product_id") ?? "0")"
                    product.quantity = "\(dict.value(forKey: "quantity") ?? "0")"
                    product.product_image = "\(dict.value(forKey: "product_image") ?? "0")"
                    product.product_name = "\(dict.value(forKey: (languageHelper.isArabic() ? "ar_product_name" : "product_name")) ?? "0")"
                    product.price = "\(dict.value(forKey: "product_price") ?? "0")"
                
                    self.arrProducts.append(product)
                    
                    qtys += Int(product.quantity) ?? 0
                }
                self.showData()
                self.tableView.tag = 1
                self.tableView.reloadData()
                self.collectionProducts.reloadData()
                self.lblTotalItems.text = "\(qtys)".replaceEnglishDigitsWithArabic
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func changeOrderStatusAPI(flag : Int) {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "order_id"  : self.orderData.order_id,
                                    "status"    : "\(flag)"]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Update_Order_Status, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.navigationController?.popToRootViewController(animated: true)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func showData() {
        let order = self.orderData
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let order_date = formatter.date(from: order.created_at)
        formatter.dateFormat = "yyyy-MM-dd"
        let del_date = formatter.date(from: order.delivery_date)
        formatter.dateFormat = "dd MMM''yy h:mm a"
        formatter.locale = languageHelper.getLocale()
        self.lblOrderDate.text = formatter.string(from: (order_date ?? Date()))
        self.lblStatus.text = languageHelper.LocalString(key: order.order_delivery_status)
        self.lblPaymentType.text = languageHelper.LocalString(key: "\(order.payment_mode)")
        
        formatter.dateFormat = "EEE, dd MMM''yy"
        formatter.locale = languageHelper.getLocale()
        self.lblDeliveryDate.text = formatter.string(from: (del_date ?? Date()))
        
        formatter.dateFormat = "HH:mm:ss"
        let del_strt = formatter.date(from: order.delivery_start_time)
        let del_end = formatter.date(from: order.delivery_end_time)
        formatter.dateFormat = "hh:mmaa"
        self.lblDelvieryTime.text = "\(formatter.string(from: (del_strt ?? Date())))" + " \(languageHelper.LocalString(key: "To")) \(formatter.string(from: (del_end ?? Date())))"
        
        self.lblOrderPrice.text = String(format: "%.3f", Double(order.total_amount)!).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        self.lblDeliveryAddress.text = order.delivery_address
        self.lblDeliveryToName.text = order.deliver_to
        self.btnCallDeliveryPerson.setTitle(order.deliver_mobile, for: .normal)
        self.lblDeliveryDistance.text = String(format: "%.2f", Double(order.distance)!).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "miles"))"
        
        self.viewPickupOrder.isHidden = self.listType != 1
        self.viewDeliverOrder.isHidden = self.listType != 2
        self.lblStatus.textColor = order.order_delivery_status != "order_delivery_status" ? kThemeColor1 : UIColor.green
        
        self.lblItemsCount.text = "\(self.arrProducts.count)".replaceEnglishDigitsWithArabic
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

extension OrderDetailsVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let product = self.arrProducts[indexPath.row]
        (cell.viewWithTag(11) as! UIImageView).kf.setImage(with: URL.init(string: self.arrProducts[indexPath.row].product_image),
                                                           placeholder: #imageLiteral(resourceName: "splash.png"),
                                                           options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                                           progressBlock: nil,
                                                           completionHandler: nil)
        (cell.viewWithTag(2) as! UILabel).text = product.product_name
        (cell.viewWithTag(3) as! UILabel).text = "Qty : " + product.quantity
        return cell
    }
}



