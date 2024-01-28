//
//  WelcomeViewController.swift
//  Hangman Game
//
//  Created by Ben Clarke on 17/04/2020.
//  Copyright © 2020 Ben Clarke. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit
import StoreKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var howToPlayBtn: UIButton!
    @IBOutlet weak var leaderboardBtn: UIButton!
    
    var player: AVAudioPlayer?
    
    let defaults = UserDefaults.standard
    
    var reviewPopupShown = false
    
    var totalScore = 0 {
        didSet {
            totalScoreLabel.text = "Total Points: \(totalScore)"
        }
    }
    
    var soundFXOn = true
    var buttonClicked = false
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        
        buttonClicked = false
        
        if let score = defaults.integer(forKey: K.scoreKey) as? Int {
            totalScore = score
        } else {
            totalScore = 0
        }
        
        if let soundFXStatus = defaults.bool(forKey: K.Audio.fxSoundKey) as? Bool {
            soundFXOn = soundFXStatus
        } else {
            soundFXOn = true
        }
        
        requestReview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the  line below if you want to play Background music
        // MusicPlayer.sharedHelper.playBGMusic()
        
        authenticUserGameCenter()
        
        formatUI()
        
        animateViewController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle  {
        .lightContent
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = " "
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton) {
        //playButtonSound()
        sender.pulsateBtn()
        
        Vibration.light.vibrate()
        
        if !buttonClicked {
            DispatchQueue.main.asyncAfter(deadline: .now()  + 0.6) {
                [weak self] in
                self?.performSegue(withIdentifier: K.gameSeugue, sender: self)
            }
        }
        
        buttonClicked = true
    }
    
    @IBAction func settingsBtnPressed(_ sender: UIButton) {
        //playButtonSound()
        sender.pulsateBtn()
        
        Vibration.light.vibrate()
        
        if !buttonClicked {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                [weak self] in
                self?.performSegue(withIdentifier: K.settingsSegue, sender: self)
            }
        }
        
        buttonClicked = true
        
    }
    
    @IBAction func howToPlayPressed(_ sender: UIButton) {
        //playButtonSound()
        sender.pulsateBtn()
        
        Vibration.light.vibrate()
        
        if !buttonClicked {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                [weak self] in
                self?.performSegue(withIdentifier: K.howToPlaySegue, sender: self)
            }
        }
        
        buttonClicked = true
    }
    
    // Uncomment for button sound
    /*func playButtonSound() {
     MusicPlayer.sharedHelper.playSound(soundURL: K.Audio.buttonPressedSound)
     }*/
    
    @IBAction func leaderBoardBtnPressed(_ sender: Any) {
        let vc = GKGameCenterViewController()
        vc.gameCenterDelegate = self
        vc.viewState = .leaderboards
        vc.leaderboardIdentifier = GameCenterID.id
        present(vc, animated: true, completion: nil)
    }
    
    private func authenticUserGameCenter() {
        let player = GKLocalPlayer.local
        
        player.authenticateHandler = { [weak self] vc, error in
            guard error == nil else {
                
                let ac = UIAlertController(title: "Error 😔", message: "\(error?.localizedDescription ?? "Error authentication Game Center!")", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
                
                self?.present(ac, animated: true, completion: nil)
                
                
                return
            }
            
            guard let vc = vc else { return }
            
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
    
    private func requestReview() {
        let noTimesAppOpened = defaults.integer(forKey: K.UserDefaultsKeys.noOfTimesAppOpened)
                
        if noTimesAppOpened == 15 || noTimesAppOpened == 30 || noTimesAppOpened == 70 || noTimesAppOpened == 140 {
            
            if !reviewPopupShown {
                
                if #available(iOS 14.0, *) {
                    if let windowScene = UIApplication.shared.windows.first?.windowScene { SKStoreReviewController.requestReview(in: windowScene)
                    }
                } else {
                    SKStoreReviewController.requestReview()
                }
                reviewPopupShown.toggle()
            }
        }
        
        if noTimesAppOpened == 141 {
            defaults.setValue(0, forKey: K.UserDefaultsKeys.noOfTimesAppOpened)
        }
        
    }
    
    
    private func animateViewController() {
        // Button animations
        titleLabel.typingTextAnimation(text: K.appName.uppercased(), timeInterval: 0.2)
        playBtn.fadeInBtn(duration: 1.0)
        settingsBtn.fadeInBtn(duration: 1.0)
        leaderboardBtn.fadeInBtn(duration: 1.0)
        howToPlayBtn.fadeInBtn(duration: 1.0)
    }
    
    private func formatUI() {
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
        
        titleLabel.textColor = UIColor(named: K.Colours.labelColour)
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 2.0
        titleLabel.layer.shadowOpacity = 1.0
        titleLabel.layer.masksToBounds = false
        titleLabel.layer.shouldRasterize = true
        titleLabel.font = UIFont(name: K.Fonts.retroGaming, size: 46.0)
        
        totalScoreLabel.font = UIFont(name: K.Fonts.rainyHearts, size: 22)
        totalScoreLabel.textColor = UIColor(named: K.Colours.labelColour)
        
        let buttons: [UIButton] = [playBtn, settingsBtn, howToPlayBtn, leaderboardBtn]
        
        buttons.forEach { button in
            button.titleLabel?.font = UIFont(name: K.Fonts.retroGaming, size: 20.0)
            button.setTitleColor(UIColor(named: K.Colours.labelColour), for: .normal)
        }
    }
    
}

//MARK: - GameCenterViewControllerDelegate Method
extension WelcomeViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
