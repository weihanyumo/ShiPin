//
//  MainViewController.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 16/8/17.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

let certificate1 = "905bf4badb2e4d0cb383a6451a969c7b"
let enableMediaCertificate = 1

class MainViewController: UIViewController {
    
    //var inst : AgoraAPI!
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var encryptionTextField: UITextField!
    @IBOutlet weak var encryptionButton: UIButton!
    
    //new
    @IBOutlet weak var txtAccount1:UITextField!
    @IBOutlet weak var txtAccount2:UITextField!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnCallUser:UIButton!
    @IBOutlet weak var btnJoin:UIButton!
    @IBOutlet weak var btnAccept:UIButton!
    
    //add
    var isLogin:Bool = false
    var isJoined:Bool  = false
    var isInCall:Bool = false
    var msg_count:Int64!
    var my_uid:UInt32 = 123
    var mCer1:String!
    
    var inst:AgoraAPI!
    
    var signal: SignalManager!
    
    
    
    fileprivate var videoProfile = AgoraRtcVideoProfile.defaultProfile()
    fileprivate var encryptionType = EncryptionType.xts128 {
        didSet {
            encryptionButton?.setTitle(encryptionType.description(), for: UIControlState())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "mainToSettings":
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.videoProfile = videoProfile
            settingsVC.delegate = self
        case "mainToRoom":
            let roomVC = segue.destination as! RoomViewController
            roomVC.roomName = (sender as! String)
            roomVC.encryptionSecret = encryptionTextField.text
            roomVC.encryptionType = encryptionType
            roomVC.videoProfile = videoProfile
            roomVC.delegate = self
            roomVC.mCer = mCer1
            roomVC.my_uid = my_uid
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        loadAgora()
    }
    @IBAction func doRoomNameTextFieldEditing(_ sender: UITextField) {
        if let text = sender.text , !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(from: text)
            sender.text = legalString
        }
    }
    
    @IBAction func doEncryptionTextFieldEditing(_ sender: UITextField) {
        if let text = sender.text , !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(from: text)
            sender.text = legalString
        }
    }
    
    @IBAction func doEncryptionTypePressed(_ sender: UIButton) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for encryptionType in EncryptionType.allValue {
            let action = UIAlertAction(title: encryptionType.description(), style: .default) { [weak self] _ in
                self?.encryptionType = encryptionType
            }
            sheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancel)
        sheet.popoverPresentationController?.sourceView = encryptionButton
        sheet.popoverPresentationController?.permittedArrowDirections = .up
        present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func doJoinPressed(_ sender: UIButton) {
        enter(roomName: roomNameTextField.text)
    }
    
    //add
    @IBAction func btnLoginPress(_ sender: UIButton){
        if isLogin {
            self.set_state_logout()
            inst.logout()
        }else{
            self.set_state_login()
            
            let name = self.txtAccount1.text;
            let uid = 0;
            let now = NSDate()
            let timeInterval = now.timeIntervalSince1970
            let expiredTime = timeInterval + 3600;
            
            let token = signal.calcToken(KeyCenter.AppId, certificate: certificate1, account: name, expiredTime: UInt32(expiredTime))
            
            inst.login2(KeyCenter.AppId, account: name, token: token, uid: UInt32(uid), deviceID: "", retry_time_in_s: 60, retry_count: 5)
        }
    }
    
    @IBAction func btnCallPress(_ sender:UIButton){
        if !isLogin {
            return
        }
        
        let name = self.txtAccount2.text;
        let uid = 0;
        
        let channelName = self.roomNameTextField.text;
        
        if isInCall{
            set_state_not_in_call()
            doLeave()
            inst.channelInviteEnd(channelName, account: name, uid: UInt32(uid))
        }else{
            set_state_not_in_call()
            doJoin()
            inst.channelInviteUser(channelName, account: name, uid: UInt32(uid))
            
        }
    }
    
    @IBAction func btnJoinPress(_ sender: UIButton){
        if !isLogin {
            return
        }
        if isJoined {
            doLeave()
        }else{
            doJoin()
        }
    }
}

private extension MainViewController {
    func enter(roomName: String?) {
        guard let roomName = roomName , !roomName.isEmpty else {
            return
        }
        performSegue(withIdentifier: "mainToRoom", sender: roomName)
    }
}

extension MainViewController: SettingsVCDelegate {
    func settingsVC(_ settingsVC: SettingsViewController, didSelectProfile profile: AgoraRtcVideoProfile) {
        videoProfile = profile
        dismiss(animated: true, completion: nil)
    }
}

extension MainViewController: RoomVCDelegate {
    func roomVCNeedClose(_ roomVC: RoomViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case roomNameTextField:     enter(roomName: textField.text)
        case encryptionTextField:   textField.resignFirstResponder()
        default: break
        }
        
        return true
    }
}

private extension MainViewController{
    func loadAgora()
    {
        signal = SignalManager.share();
        inst = AgoraAPI.getInstanceWithoutMedia(KeyCenter.AppId)

        inst.onLoginSuccess = {(uid:UInt32, fd:Int32)->Void in
            self.my_uid = uid;
            self.btnLogin.setTitle("Logout", for: UIControlState.normal)
        }
        
        inst.onLogout = {(e:AgoraEcode)in
            self.set_state_logout()
            self.set_state_not_in_call()
            self.doLeave()
        }
        
        inst.onLoginFailed = {(e:AgoraEcode) in
            self.set_state_logout()
            self.set_state_not_in_call()
        }
        
        inst.onChannelJoined = {(name:String?) in
            
        }
        
        inst.onChannelLeaved = {(name:String?, ecode:AgoraEcode)in
            if ecode == AgoraEcode.LEAVECHANNEL_E_BYUSER{
            }else{
            }
        }
        
        inst.onInviteReceived = {(channel:String?, name:String?, uid:UInt32, extra:String?) in
            self.roomNameTextField.text = channel
            self.set_state_in_call()
            self.doJoin()
            self.inst.channelInviteAccept(channel, account: name, uid: uid)
        }
        
        inst.onInviteReceivedByPeer = {(channel:String?, name:String?, uid:UInt32)in
            let log = NSString.localizedStringWithFormat("onInviteReceiveByPeer to %s from %s:%u", channel!, name!, uid)
            self.log(txt: log as String)
        }
        
        inst.onInviteAcceptedByPeer = {(channel:String?, name:String?, uid:UInt32)in
           
        }
        
        inst.onInviteEndByPeer = {(channel:String?, name:String?, uid:UInt32)in
            self.set_state_not_in_call()
            self.doLeave()
        }
        
        inst.onInviteFailed = {(channelID:String?, account:String?, uid:UInt32, ecode:AgoraEcode)in
            self.set_state_not_in_call()
            self.doLeave()
        };
    }
    
    
    func set_state_logout()
    {
        isLogin = false;
        DispatchQueue.main.async {
            self.btnLogin.setTitle("Login", for: UIControlState.normal)
        }
    }
    
    func set_state_login()
    {
        isLogin = true;
        DispatchQueue.main.async {
            self.btnLogin.setTitle("Logout", for: UIControlState.normal)
        }
    }
    
    func set_state_in_call(){
        isInCall = true;
        DispatchQueue.main.async {
            self.btnCallUser.setTitle("Bye", for: UIControlState.normal)
        }
    }
    
    func set_state_not_in_call(){
        isInCall = false;
        
        DispatchQueue.main.async {
            self.btnCallUser.setTitle("Call", for: UIControlState.normal)
        }
    }
    
    func doJoin()
    {
        DispatchQueue.main.async {
            self.isJoined = true;
            self.btnJoin.setTitle("Leave", for: UIControlState.normal)
            self.inst.channelJoin(self.roomNameTextField.text)
            if enableMediaCertificate == 1{
                self.mCer1 = self.signal.getKey(KeyCenter.AppId, certificate1, self.roomNameTextField.text, uid: UInt32(self.my_uid))
            }
            self.enter(roomName: self.roomNameTextField.text)
        }
    }
    
    func doLeave()
    {
        DispatchQueue.main.async {
            self.isJoined = false;
            self.btnJoin.setTitle("Join", for: UIControlState.normal)
            self.inst.channelLeave(self.roomNameTextField.text)
        }
    }
    
    
    func log(txt:String)
    {
        NSLog("%s", txt)
    }
}



