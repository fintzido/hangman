//
//  ViewController.swift
//  Hangman Game
//
//  Created by Ben Clarke on 09/04/2020.
//  Copyright © 2020 Ben Clarke. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var guessesRemainingLabel: UILabel!
    @IBOutlet var letterButtons: [UIButton]!
    var player: AVAudioPlayer?
    
    let defaults = UserDefaults.standard
    var totalScore = 0 {
        didSet {
            defaults.set(totalScore, forKey: K.scoreKey)
            //print(totalScore)
        }
    }
        
    var wordLetterArray = [String]()
    var word = ""
    
    var maskedWord = ""
    var maskedWordArray = [String]()
    
    var wordStrings = [String]()
    var level = 1
    var levelCompleted = false
    var usedLetters = ""
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var livesRemaining = 10 {
        didSet {
            guessesRemainingLabel.text = "\(livesRemaining) guesses left"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = K.appName
        navigationController?.navigationBar.prefersLargeTitles =  true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clue", style: .plain, target: self, action: #selector(giveClue))
        
        totalScore = defaults.integer(forKey: K.scoreKey)
        
        loadGame()
    }
    
    @objc func giveClue() {
        
        let filteredLetters = wordLetterArray.filter { !$0.contains(usedLetters) }
        guard let randomElement = filteredLetters.randomElement()?.capitalized else { return }
        
        let wordLen = wordLetterArray.count
        
        showAlertAction(title: "🕵️", message: "The current word is \(wordLen) characters, have you considered using the letter '\(randomElement)'?", actionClosure: {})
        
        score -= 1
        livesRemaining -= 1
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    @IBAction func letterTapped(_ sender: UIButton) {
        guard let letterChosen = sender.currentTitle?.lowercased() else { return }
        
        usedLetters.append(letterChosen)
        
        if wordLetterArray.contains(letterChosen) {
            
            for (index, letter) in wordLetterArray.enumerated() {
                if letterChosen == letter {
                    maskedWordArray[index] = letter
                }
            }
            
            maskedWord = maskedWordArray.joined()
            score += 1
            totalScore += 1
            playSound(sound: K.Audio.correctAnswerSound)
            
        } else {
            score -= 1
            totalScore -= 1
            livesRemaining -= 1
            playSound(sound: K.Audio.wrongAnswerSound)
        }
        
        sender.isEnabled = false
        wordLabel.text = maskedWord
        
        // check to see if the game is completed + reset
        checkToSeeIfCompleted()
        
        if levelCompleted {
            for button in letterButtons {
                button.isEnabled = true
            }
            levelCompleted = false
        }
        
    }
    
    func loadGame() {
        if let fileURL = Bundle.main.url(forResource: K.wordsURL.fileName, withExtension: K.wordsURL.fileExtension) {
            if let wordContents = try? String(contentsOf: fileURL) {
                var lines = wordContents.components(separatedBy: "\n")
                lines.shuffle()
                
                wordStrings += lines
            }
        } else {
            showAlertAction(title: "Error", message: "There was an error fetching data, please try again!", actionClosure: {
                [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            })
            return
        }
        loadWord()
    }
    
    
    func checkToSeeIfCompleted() {
        
        if livesRemaining > 0 {
            
            if maskedWord == word {
                showAlertAction(title: "Congratualtions 🎉", message: "You've beat the hangman", actionTitle: "Restart", actionClosure: self.loadWord)
                playSound(sound: K.Audio.gameWonSound)
                nextLevel()
            }
            
        } else {
            showAlertAction(title: "💀", message: "The hangman caught you", actionTitle: "Restart", actionClosure: self.loadWord)
            nextLevel()
        }
        
    }
    
    func loadWord() {
        
        wordLetterArray = [String]()
        word = ""
        maskedWord = ""
        maskedWordArray = [String]()
        
        livesRemaining = 10
        
        //  Save word into an array + string
        word = wordStrings[level]
        for letter in wordStrings[level] {
            wordLetterArray.append(String(letter))
        }
        
        print(wordLetterArray)
        print(word)
        
        for _ in 0..<wordLetterArray.count {
            maskedWord += "?"
            maskedWordArray.append("?")
        }
        
        wordLabel.text = maskedWord
        wordLabel.typingTextAnimation(text: maskedWord, timeInterval: 0.2)
    }
    
    func nextLevel() {
        level += 1
        levelCompleted = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func playSound(sound: String) {
        MusicPlayer.sharedHelper.playSound(soundURL: sound)
    }
    
}
