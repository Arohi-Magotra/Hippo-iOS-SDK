//
//  HippoDataCollectorController.swift
//  Hippo
//
//  Created by Vishal on 14/02/19.
//

import UIKit

protocol HippoDataCollectorControllerDelegate: class {
    func userUpdated()
}

class HippoDataCollectorController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var datasource: HippoDataCollectorDataSource?
    var forms: [FormData] = []
    weak var delegate: HippoDataCollectorControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.navigationController?.setTheme()
        HippoKeyboardManager.shared.enable = true
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         HippoKeyboardManager.shared.enable = false
    }
    
    override func viewWillLayoutSubviews() {
        self.tabBarController?.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func setUI() {
        title = HippoProperty.current.formCollectorTitle
//        if HippoConfig.shared.theme.leftBarButtonImage != nil {
//            backButton.image = HippoConfig.shared.theme.leftBarButtonImage
//            backButton.tintColor = HippoConfig.shared.theme.headerTextColor
//        }
        backButton.image = nil
        backButton.tintColor = nil
        backButton.isEnabled = false
    }
    func setupTableView() {
        datasource = HippoDataCollectorDataSource(forms: forms)
        tableView.dataSource = datasource
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        let bundle = FuguFlowManager.bundle
        
        tableView.register(UINib(nibName: "BroadCastTitleCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTitleCell")
        tableView.register(UINib(nibName: "BroadcastButtonCell", bundle: bundle), forCellReuseIdentifier: "BroadcastButtonCell")
        tableView.register(UINib(nibName: "BroadCastTextFieldCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTextFieldCell")
        tableView.register(UINib(nibName: "ContactNumberTableCell", bundle: bundle), forCellReuseIdentifier: "ContactNumberTableCell")
        
        
        tableView.tableFooterView = UIView()
    }
    
    class func get(forms: [FormData]) -> HippoDataCollectorController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "HippoDataCollectorController") as! HippoDataCollectorController
        vc.forms = forms
        return vc
    }
    
    
    func validateFormData() -> Bool {
        var isValid: Bool = true
        
        for each in forms {
            each.validate()
            if !each.errorMessage.isEmpty {
                isValid = false
            }
        }
        
        return isValid
    }
}
extension HippoDataCollectorController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let form = forms[indexPath.row]
        let type = form.type
        switch type {
        case .none:
            return 0.01
        default:
            return UIView.tableAutoDimensionHeight
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case let customCell as BroadcastButtonCell:
            customCell.delegate = self
        case let customCell as BroadCastTextFieldCell:
            customCell.delegate = self
        default:
            return
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
extension HippoDataCollectorController: BroadCastTextFieldCellDelegate {
    func textFieldTextChanged(newText: String) {
        
    }
}
extension HippoDataCollectorController: BroadcastButtonCellDelegate {
    func previousMessageButtonClicked() {
        
    }
    
    func sendButtonClicked() {
        guard validateFormData() else {
            tableView.reloadData()
            return
        }
        self.view.endEditing(true)
        guard let user = HippoConfig.shared.userDetail  else {
            return
        }
        let email = findEmailInForms()
        if !email.isEmpty {
            HippoConfig.shared.userDetail?.email = email
        }
        
//        user.customRequest = createRequestJson()
        user.customRequest = createRequestJson()
        user.botAttributesCustomRequest = createBotAttributesJson()
        
        //user.phoneNumber = user.phoneNumber?.fullNumber ?? ""//
        if let appUserData = UserDefaults.standard.value(forKey: "customer_login_data") as? [String: Any]{
            if let phoneNumberLocal = appUserData["phoneNumberLocal"] as? [String: Any] {
                let number = phoneNumberLocal["phone_number"] as? String ?? ""
                let countryCode = phoneNumberLocal["country_code"] as? String ?? ""
                if !number.isEmpty && !countryCode.isEmpty {
                    let fullNumber = countryCode + number
                    user.phoneNumber = fullNumber
                }
            }
        }else{}
        delegate?.userUpdated()
        self.navigationController?.popViewController(animated: false)
    }
    
    
//    func createRequestJson() -> [String: Any] {
//        var json: [String: Any] = [:]
//
//        for each in forms {
//            json += each.getRequestJson()
//        }
//        return json
//    }
    func createRequestJson() -> [String: Any] {
        var json: [String: Any] = [:]
        //var botAttributesJson: [String: Any] = [:]
        for each in forms {
            if each.isBotAttributes != nil && each.isBotAttributes == 1{
                //botAttributesJson += each.getRequestJson()
            }else{
                json += each.getRequestJson()
            }
        }
        return json
    }
    func createBotAttributesJson() -> [String: Any] {
        var botAttributesJson: [String: Any] = [:]
        for each in forms {
            if each.isBotAttributes != nil && each.isBotAttributes == 1{
                botAttributesJson += each.getRequestJson()
            }else{
            }
        }
        return botAttributesJson
    }
    
    func findEmailInForms() -> String {
        var email: String = ""
        for each in forms {
           if each.validationType == .email {
             email = each.value
            break
           }
        }
        
        return email
    }
}

