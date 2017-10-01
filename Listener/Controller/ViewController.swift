//
//  ViewController.swift
//  Listener
//
//  Created by Fei Liang on 9/30/17.
//  Copyright © 2017 Fei Liang. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {


    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!

    @IBOutlet weak var transcriptionTextField: UITextView!

    @IBOutlet weak var button: RoundButton!

    private let speechRecognizer = SFSpeechRecognizer(locale:Locale.init(identifier: "en-US") )!

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var buttonColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        speechRecognizer.delegate = self
//        activitySpinner.isHidden = true
        button.isEnabled = false
        buttonColor = button.backgroundColor

        SFSpeechRecognizer.requestAuthorization { (authStatus) in

            var isButtonEnabled = false

            switch authStatus {
            case .authorized:
                isButtonEnabled = true

            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")

            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")

            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }

            OperationQueue.main.addOperation() {
                self.button.isEnabled = isButtonEnabled
            }
        }


    }

    @IBAction func buttonTapped(_ sender: RoundButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            button.isEnabled = false
            button.backgroundColor = buttonColor
        } else {
            startRecording()
            button.backgroundColor = UIColor.red

        }
    }

    func startRecording(){

        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properities werent set because of an error")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            var isFinal = false
            if result != nil {
                self.transcriptionTextField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.button.isEnabled = true
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }

    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }
    

}

