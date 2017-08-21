//
//  ViewController.swift
//  The Gallery
//
//  Created by Patrick Bellot on 8/16/17.
//  Copyright © 2017 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SKProductsRequestDelegate, SKPaymentTransactionObserver {

  @IBOutlet weak var collectionView: UICollectionView!
  
  var gallery = [Art]()
  var products = [SKProduct]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    updateGallery()
    
    if gallery.count == 0 {
      createArt(title: "Fish", productIdentifier: "", imageName: "fish.jpeg", purchased: true)
      createArt(title: "Horse", productIdentifier: "", imageName: "horse.jpeg", purchased: true)
      createArt(title: "Kittens", productIdentifier: "com.patrickBellot.The_Gallery.kittens", imageName: "kittens.jpeg", purchased: false)
      createArt(title: "Puppy", productIdentifier: "com.patrickBellot.The_Gallery", imageName: "puppy.jpeg", purchased: false)

      updateGallery()
      self.collectionView.reloadData()
    }
    
    requestProducts()
  }
  
  func requestProducts() {
    let ids: Set<String> = ["com.patrickBellot.The_Gallery.kittens", "com.patrickBellot.The_Gallery"]
    let productsRequest = SKProductsRequest(productIdentifiers: ids)
    productsRequest.delegate = self
    productsRequest.start()
  }
  
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    print("Products ready: \(response.products.count)")
    print("Products not ready: \(response.invalidProductIdentifiers.count)")
    self.products = response.products
    self.collectionView.reloadData()
  }
  
  @IBAction func restoreTapped(_ sender: Any) {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }

  
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        print("Purchased")
        unlockArt(productIdentifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        break
      case .failed:
        print("Failed")
        SKPaymentQueue.default().finishTransaction(transaction)
        break
      case .restored:
        print("Restored")
        unlockArt(productIdentifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        break
      case .purchasing:
        print("Purchasing")
        break
      case .deferred:
        print("Deferred")
        break
      }
    }
  }
  
  func unlockArt(productIdentifier: String) {
    
    for art in self.gallery {
      if art.productIdentifier == productIdentifier {
        art.purchased = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do{
          try context.save()
        } catch {}
        self.collectionView.reloadData()
      }
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artCell", for: indexPath) as! ArtCollectionViewCell
    let art = self.gallery[indexPath.row]
    
    cell.imageView.image = UIImage(named: art.imageName!)
    cell.titleLabel.text = art.title!
    
    for subview in cell.imageView.subviews {
      subview.removeFromSuperview()
    }
    
    if art.purchased == true {
      cell.purchasedLabel.isHidden = true
    } else {
      cell.purchasedLabel.isHidden = false
      
      let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
      let blurView = UIVisualEffectView(effect: blurEffect)
      cell.layoutIfNeeded()
      blurView.frame = cell.imageView.bounds
      cell.imageView.addSubview(blurView)
      
      for product in self.products {
        if product.productIdentifier == art.productIdentifier {
          
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          formatter.locale = product.priceLocale
          if let price = formatter.string(from: product.price){
            cell.purchasedLabel.text = "Buy for \(price)"
          }
        }
      }
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let art = self.gallery[indexPath.row]
    
    if !art.purchased == true {
      for product in self.products {
        if product.productIdentifier == art.productIdentifier{
          SKPaymentQueue.default().add(self)
          let payment = SKPayment(product: product)
          SKPaymentQueue.default().add(payment)
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.collectionView.bounds.size.width - 80, height: self.collectionView.bounds.size.height - 40)
  }

}

