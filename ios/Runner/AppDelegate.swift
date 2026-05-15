import Flutter
import UIKit
import SoundAnalysis
import AVFoundation
import Speech

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    let soundChannel = FlutterMethodChannel(name: "com.nazmul.petapp1/sound_classifier",
                                            binaryMessenger: engineBridge.pluginRegistry.registrar(forPlugin: "SoundClassifier")!.messenger())
    
    soundChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "classifyAudio" {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "FilePath missing", details: nil))
          return
        }
        
        let audioURL = URL(fileURLWithPath: filePath)
        if #available(iOS 15.0, *) {
            do {
                let classifier = try SoundClassifier(audioURL: audioURL)
                classifier.classify { results in
                    result(results)
                }
            } catch {
                result(FlutterError(code: "ANALYSIS_FAILED", message: error.localizedDescription, details: nil))
            }
        } else {
            result([:])
        }
      } else if call.method == "recognizeSpeech" {
          guard let args = call.arguments as? [String: Any],
                let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "FilePath missing", details: nil))
            return
          }
          
          let audioURL = URL(fileURLWithPath: filePath)
          self.recognizeSpeech(url: audioURL) { text in
              result(text)
          }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
  }

  private func recognizeSpeech(url: URL, completion: @escaping (String?) -> Void) {
      let recognizer = SFSpeechRecognizer()
      let request = SFSpeechURLRecognitionRequest(url: url)
      
      recognizer?.recognitionTask(with: request) { (result, error) in
          if let error = error {
              print("Speech recognition error: \(error)")
              completion(nil)
              return
          }
          
          if let result = result {
              if result.isFinal {
                  completion(result.bestTranscription.formattedString)
              }
          } else {
              completion(nil)
          }
      }
  }
}

@available(iOS 15.0, *)
class SoundClassifier: NSObject, SNResultsObserving {
    private let analyzer: SNAudioFileAnalyzer
    private var results: [String: Double] = [:]
    private var completion: (([String: Double]) -> Void)?

    init(audioURL: URL) throws {
        self.analyzer = try SNAudioFileAnalyzer(url: audioURL)
        super.init()
    }

    func classify(completion: @escaping ([String: Double]) -> Void) {
        self.results = [:]
        self.completion = completion
        
        do {
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            try analyzer.add(request, withObserver: self)
            analyzer.analyze()
        } catch {
            print("Sound Analysis error: \(error)")
            completion([:])
        }
    }

    func request(_ request: SNRequest, didProduce results: SNResult) {
        guard let result = results as? SNClassificationResult else { return }
        for classification in result.classifications {
            let label = classification.identifier
            let confidence = classification.confidence
            if confidence > (self.results[label] ?? 0) {
                self.results[label] = confidence
            }
        }
    }

    func requestDidComplete(_ request: SNRequest) {
        let filtered = results.filter { $0.value > 0.05 }
        completion?(filtered)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        completion?([:])
    }
}

