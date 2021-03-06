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
    var unorderedPicNotes = [PicNote]()
    var orderedPicNotes = [PicNote]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
        
        collectionView?.backgroundColor = .white
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.title = "PicNotes"
        
        collectionView?.register(GridViewCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchPicNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPicNotes()
        collectionView?.reloadData()
    }
    
    fileprivate func fetchPicNotes(){
        let realm = try! Realm()
        unorderedPicNotes = Array(realm.objects(PicNote.self))
        orderedPicNotes = unorderedPicNotes.reversed()
    }
    
    @objc func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    //setup actual square size for each view in collection.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (view.frame.width - 48) / 3
        return CGSize(width: width, height: width)

    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GridViewCell
        
        cell.picNote = orderedPicNotes[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return unorderedPicNotes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GridViewCell
        
        let detailedNotesVC = DetailedNotesViewController()
        detailedNotesVC.image = cell.imageView.image
        
        guard let picNote = cell.picNote else {return}
        detailedNotesVC.picNote = picNote
        print(picNote.filename)
        present(detailedNotesVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

}
