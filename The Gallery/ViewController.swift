//
//  ViewController.swift
//  The Gallery
//
//  Created by Patrick Bellot on 8/16/17.
//  Copyright © 2017 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  @IBOutlet weak var collectionView: UICollectionView!
  
  var gallery = [Art]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    updateGallery()
    
    if gallery.count == 0 {
      createArt(title: "Hello", productIdentifier: "", imageName: "", purchased: true)
      createArt(title: "Hello", productIdentifier: "", imageName: "", purchased: true)
      createArt(title: "Hello", productIdentifier: "", imageName: "", purchased: true)
      updateGallery()
      self.collectionView.reloadData()
    }
  }
  
  func createArt(title: String, productIdentifier: String, imageName: String, purchased: Bool) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    if let entity = NSEntityDescription.entity(forEntityName: "Art", in: context){
      let art = NSManagedObject(entity: entity, insertInto: context) as! Art
      art.title = title
      art.productIdentifier = productIdentifier
      art.imageName = imageName
      art.purchased = NSNumber(value: purchased) as! Bool
    }
    do{
      try context.save()
    } catch {}
  }
  
  func updateGallery() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Art")
    
    do {
      let artPieces = try context.fetch(fetch)
      self.gallery = artPieces as! [Art]
    } catch {}
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.gallery.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artCell", for: indexPath)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.collectionView.bounds.size.width - 80, height: self.collectionView.bounds.size.height - 40)
  }

}

