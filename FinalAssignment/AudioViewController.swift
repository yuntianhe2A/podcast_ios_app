//
//  AudioViewController.swift
//  FinalAssignment
//
//  Created by Yanepisode Li on 3/6/20.
//  Copyright © 2020 Yanepisode Li. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
class AudioViewController: UIViewController,URLSessionDelegate,URLSessionDownloadDelegate,UNUserNotificationCenterDelegate {
    var player:AVPlayer?
    var indexOfEpisode: Int=0
    var episodeList:[Episode]=[]
    var currentEpisode:Episode?
    var urlString:String?
    var audioUrl=""
    var podcastName=""
    var currentTimeString=""
    var totalTimeString=""
    var managedObjectContext: NSManagedObjectContext?
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var episodeDescription: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
     let appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
           super.viewDidLoad()
        
        
        
       
        managedObjectContext = appDelegate?.persistantContainer?.viewContext
        
        let episode = episodeList[indexOfEpisode]
        artistName.text = episode.episodeTitle
        episodeDescription.text = episode.episodeDescription
        //player current time
      
        
        
        imageView.image=UIImage(named: "cover1")
        let audioFileUrl = episode.enclosure?.url
        do {
                    try AVAudioSession.sharedInstance().setMode(.default)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

                    guard let audioFileUrl = audioFileUrl else {
                        print("urlstring is nil")
                        return
                    }
                   let url=URL(string: audioFileUrl)

                   player = try AVPlayer(url: url!)
            
            guard let player = player else {
                        print("player is nil")
                        return
                    }
           
                    player.volume = 0.5

                    player.play()
                }
                catch {
                    print("error occurred \(error).")
                }
       }
    
    
    @IBAction func lastEpisodeButton(_ sender: Any) {
        if indexOfEpisode > 0 {
                 indexOfEpisode = indexOfEpisode - 1
                 player?.pause()
                 viewDidLoad()
             }
    }
    @IBAction func nextEpisodeButton(_ sender: Any) {
        if indexOfEpisode < (episodeList.count - 1) {
                   indexOfEpisode = indexOfEpisode + 1
                   player?.pause()
                   viewDidLoad()
               }
    }
    
    @IBAction func playOrPauseButton(_ sender: Any) {
        if player?.timeControlStatus == .playing {
             // pause
             player?.pause()
            playPauseButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
         }
         else {
             // play
             player?.play()
             playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)

             // increase image size
             UIView.animate(withDuration: 0.2, animations: {
                 self.imageView.frame = CGRect(x: 20,
                                               y: 20,
                                               width: self.imageView.frame.size.width+20,
                                               height: self.imageView.frame.size.height+20)
             })
         }
    }
    
    @IBAction func slideSlider(_ sender: UISlider) {
        //print(progressSlider.value)
        if let duration=player?.currentItem?.duration{

            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let value=Float64(progressSlider.value)*totalTimeInSeconds
            let seekTime=CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: {(completedSeek) in
                self.getTotalTimeString(totalTimeInSeconds:Int(totalTimeInSeconds))
                                    
                self.getCurrentTimeString()
            })
        }
    }  

    //store in user collection
    @IBAction func addToFavouriteButton(_ sender: Any) {
    }
    //download to local
    @IBAction func downloadEpisodeButton(_ sender: Any) {
    }
    
   override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if let player = player {
                
                player.pause()
            }
        }
    //get current and total time for playback
    
    func getTotalTimeString(totalTimeInSeconds:Int){
               let secondText = Int(totalTimeInSeconds) % 60
                                let minutesText = Int(totalTimeInSeconds) / 60
        totalTimeString="\(minutesText):\(secondText)"
        currentTimeLabel.text=totalTimeString
            self.totalTimeLabel.text="\(minutesText):\(secondText)"
        }
    
    func getCurrentTimeString(){
        let interval = CMTime(value: 1, timescale: 2)
        _ = player!.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
                [weak self] time in
                // update player transport UI--block
            if let currentTime=self!.player?.currentTime(){
                let seconds = CMTimeGetSeconds(currentTime)
                let secondText = Int(seconds) % 60
                let minutesText = Int(seconds) / 60
                self!.currentTimeString="\(minutesText):\(secondText)"
                self!.currentTimeLabel.text=self?.currentTimeString
            }
        }
    }
    

 //download audio file to local
    
    let config = URLSessionConfiguration.default
         lazy var session = {
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
         }()
       
       @IBAction func downloadEpisode(_ sender: Any){
             
            
        currentEpisode=episodeList[indexOfEpisode]
        audioUrl = currentEpisode!.enclosure!.url!
            print(audioUrl)
            downloadEpisodeAudio(audioUrl: audioUrl)
        
           
         }
       
       
       func downloadEpisodeAudio(audioUrl: String) -> Int? {

           let audioUrl = URL(string: audioUrl)
           let task = session.downloadTask(with: audioUrl!)
                    task.resume()
                    return task.taskIdentifier
       }
  
       
       func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
           if totalBytesExpectedToWrite > 0 {
               let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
               print("Progress \(downloadTask.currentRequest!.description): \(progress)")
           }
       }
       
       func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
               
        let fileName="podcast:"+"\(podcastName)\n" + "episode:" + currentEpisode!.episodeTitle!
        
    //persist data into local storage
           do {
               let data = try Data(contentsOf: location)
            let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
            let documentsDirectory = paths[0]
            
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            print(fileURL)
            
            //
            do {
                try data.write(to: fileURL)
                
                //store data path into coredata for future retrieve
                let newEpisode = NSEntityDescription.insertNewObject(forEntityName: "EpisodeLocationPath", into: managedObjectContext!) as! DownloadedAudio 
                newEpisode.filePath = fileName
                try self.managedObjectContext?.save()
              //  advancedNotificationAction()
                
                self.navigationController?.popViewController(animated: true)
            }
               
           } catch {
               print(error.localizedDescription)
           }
       }
    
//    func advancedNotificationAction() {
//        guard appDelegate!.notificationsEnabled else {
//            print("Notifications not enabled")
//            return
//        }
//
//        let content = UNMutableNotificationContent()
//
//        content.title = "Download Finish"
//        content.body = "Play Now or Later"
//
//       content.categoryIdentifier = AppDelegate.CATEGORY_IDENTIFIER
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
//
//        let request = UNNotificationRequest(identifier: "foo", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//    }



}
