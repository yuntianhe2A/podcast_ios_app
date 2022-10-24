//
//  FirebaseController.swift
//  FinalAssignment
//
//  Created by Yansong Li on 22/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


class FirebaseController: NSObject, DatabaseProtocol {

  
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    //var storageReference=Storage.storage().reference()
   
    var podcastImage=UIImage()
    var imageId=""
    
    var snapshotListener: ListenerRegistration?
    var favouritePodcastRef: CollectionReference?
    var podcastList:[Podcast]
    
    
    
    override init() {
        
        
        FirebaseApp.configure()
        database = Firestore.firestore()
        authController=Auth.auth()
        favouritePodcastRef = database.collection("favouritePodcast")
        podcastList = [Podcast]()
        
        super.init()
        
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else { fatalError("Firebase authentication failed")
            }
            // Once we have authenticated we can attach our listeners to // the firebase firestore
            self.setUpPodcastListener()
            
            
        }
        
    }
    
      func addListener(listener: DatabaseListener) {
          listeners.addDelegate(listener)
          listener.onSavingChange(change: .update, savingPodcast: podcastList)
      }
      
      func removeListener(listener: DatabaseListener) {
          listeners.removeDelegate(listener)
      }
      
    
    func setUpPodcastListener() {
    
        favouritePodcastRef?.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else { print("Error fetching documents: \(error!)")
                return
            }
            self.parsePodcastsSnapshot(snapshot: querySnapshot)
            
        } }
    
    func parsePodcastsSnapshot(snapshot: QuerySnapshot) { snapshot.documentChanges.forEach { (change) in
        let podcastID = change.document.documentID
        print(podcastID)
        var parsedPodcast: Podcast?
        do {
            parsedPodcast = try change.document.data(as:
                Podcast.self)
            
        } catch {
            print("Unable to decode podcast,Is the podcast malformed?")
            return
        }
        guard let podcast = parsedPodcast else { print("Document doesn't exist")
            return
        }
      
        
        
        if change.type == .added {
            podcastList.append(podcast)
            
        }else if change.type == .removed {
            if let index = getPodcastIndexByID(podcastID) {
                podcastList.remove(at: index) }
        }
        
        }
    }
    
    func getPodcastIndexByID(_ id: String) -> Int? {
        if let podcast = getPodcastByID(id) {
            return podcastList.firstIndex(of: podcast) }
        return nil
    }
    
    func getPodcastByID(_ id: String) -> Podcast? {
        for podcast in podcastList {
            if podcast.podcastId == id {
                return podcast
            } }
        return nil
    }
    
    func cleanup() {
    }
    
    func addPodcast(podcastToBeSaved: Podcast) -> Podcast {
        let podcast=Podcast()
        podcast.artist=podcastToBeSaved.artist
        podcast.feedUrl=podcastToBeSaved.feedUrl
        podcast.podcastCoverImg=podcastToBeSaved.podcastCoverImg
        podcast.podcastName=podcastToBeSaved.podcastName
        podcast.image=podcastToBeSaved.image
        podcast.releaseDate=podcastToBeSaved.releaseDate
        
        
        do {
            if let podcastRef = try favouritePodcastRef?.addDocument(from: podcast) {
                podcast.podcastId = podcastRef.documentID
                //uploadImage(podcast: podcast)
            }
        } catch {
            print("Failed to serialize hero")
        }
        //uploadImage(podcast:podcastToBeSaved)
        return podcast
    }
//    func FetchFirebasePodcastImage(podcastId:String)->UIImage{
//
//        var podcastImage=UIImage()
//        let podcastId=podcastId
//        favouritePodcastRef = database.collection("favouritePodcast")
//        print(podcastId)
//        let podcastImageRef=favouritePodcastRef!.document("\(podcastId)")
//        snapshotListener = favouritePodcastRef!.addSnapshotListener{ (querySnapshot,
//
//            error) in
//            guard (querySnapshot?.documents) != nil else {
//                print("Error fetching documents: \(error!)")
//                return
//            }
//            querySnapshot!.documentChanges.forEach { change in
//
//                let imageName = change.document.documentID
//                print(imageName)
//                let imageURL = change.document.data()["imageDownloadUrl"] as! String
//
//
//                self.storageReference.reference(forURL:imageURL).getData(maxSize: 5 * 1024 * 1024,completion:{ (data,error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }else if let data = data, let image = UIImage(data: data){
//                        podcastImage=image
//                        print(podcastImage)
//                        self.saveImageData(filename: imageName,
//                                           imageData: data)
//
//                    }
//                } )
//
//            }
//
//
//        }
//
//        return podcastImage
//
//    }
    
//    func loadLocalImageData(filename: String) -> UIImage? {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//
//        let imageURL = documentsDirectory.appendingPathComponent(filename)
//        let image = UIImage(contentsOfFile: imageURL.path)
//
//        return image
//    }
//
//
//    func saveImageData(filename: String, imageData: Data) {
//        let paths = FileManager.default.urls(for: .documentDirectory, in:
//            .userDomainMask)
//        let documentsDirectory = paths[0]
//        let fileURL = documentsDirectory.appendingPathComponent(filename)
//        do {
//            try imageData.write(to: fileURL)
//        } catch {
//            print("Error writing file: \(error.localizedDescription)")
//        }
//    }
    
    
//
//    func uploadImage(podcast:Podcast){
//        guard let userID = Auth.auth().currentUser?.uid else {
//            print("Cannot upload image until logged in", "Error")
//            return
//        }
//        let podcastID = podcast.podcastId
////        guard podcast.podcastId != nil else {
////            print("error")
////            return
////        }
//        let imageRef = storageReference.child("\(podcastID)")
//        let metadata = StorageMetadata()
//
//        metadata.contentType = "image/jpg"
//        guard let data = podcast.image!.jpegData(compressionQuality: 0.8) else {
//            print("Image data could not be compressed.", "Error")
//            return
//        }
//        imageRef.putData(data, metadata: metadata) { (meta, error) in
//            if error != nil {
//                print("Could not upload image to firebase", "Error")
//            }else {
//                imageRef.downloadURL { (url, error) in
//                    guard let downloadURL = url else {
//                        print("Download URL not found")
//                        return
//                    }
//
//
//
//                    let podcastImageRef = self.favouritePodcastRef!.document("\(podcastID)")
//                    podcastImageRef.setData(["imageDownloadUrl": "\(downloadURL)"
//                    ],merge: true)
//                    podcastImageRef.setData(["podcastId": "\(podcastID)"
//                    ],merge: true)
//                    print("Image uploaded to Firebase", "Success")
//                    //collection("coverImage").document(podcastID).
//                }
//
//            }
//
//        }
//    }
    func deletePodcast(podcastToBeDeleted: Podcast) {
       
        if let podcastID = podcastToBeDeleted.podcastId{
            favouritePodcastRef?.document(podcastID).delete() }
        
    }
    
    
}
