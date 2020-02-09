//
//  SJPageCollectionView.swift
//  SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

internal class SJPageCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let delegate = self.delegate as? SJPageCollectionViewDelegate {
            return delegate.collectionView(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
        }
        return false
    }
}

@objc internal protocol SJPageCollectionViewDelegate: UICollectionViewDelegate {
   @objc func collectionView(_ collectionView: SJPageCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

internal class SJPageCollectionViewCell: UICollectionViewCell {
    var viewController: UIViewController?
}
