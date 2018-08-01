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
        
        self.hero.isEnabled = true
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picNotes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GridViewCell
        
        let detailedNotesVC = DetailedNotesViewController()
        detailedNotesVC.image = cell.imageView.image
        
        guard let picNote = cell.picNote else {return}
        detailedNotesVC.picNote = picNote
        
        present(detailedNotesVC, animated: true, completion: nil)
    }
    
}
