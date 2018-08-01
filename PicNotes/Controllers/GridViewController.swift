//
//  GridViewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/31/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Firebase
import Hero
import RealmSwift

class GridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var picNotes = [PicNote]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        self.navigationItem.leftBarButtonItems = [backButton]
        
        collectionView?.register(GridViewCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchPicNotes()
    }
    
    fileprivate func fetchPicNotes(){
        let realm = try! Realm()
        picNotes = Array(realm.objects(PicNote.self))
    }
    
    @objc func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    //setup actual square size for each view in collection.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)

    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GridViewCell
        
        cell.picNote = picNotes[indexPath.item]
        
        return cell
    }
    
    
    //setup line spacing between each view to be 1. Effects being able to divide views equally
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top:1, left: 10, bottom: 10, right:10)
//    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picNotes.count
    }
    
}
