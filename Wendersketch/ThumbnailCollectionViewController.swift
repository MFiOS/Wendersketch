/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import PencilKit

class ThumbnailCollectionViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  private let sketchDataSource = SketchDataSource()
  private let reuseIdentifier = "ThumbnailCell"
  private let itemsPerRow: CGFloat = 3
  private let sectionInsets = UIEdgeInsets(top: 50.0,
                                           left: 20.0,
                                           bottom: 50.0,
                                           right: 20.0)
  private var thumbnailSize: CGSize?
  private var selectedIndexPath: IndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem =
      UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addDrawing(_:)))
    let width = (view.frame.size.width - (sectionInsets.left * 2 + 20.0)) / 3
    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = CGSize(width: width, height: width * 4 / 3)
    thumbnailSize = layout.itemSize

  }
  
  @objc
  func addDrawing(_ sender: UIBarButtonItem) {
    sketchDataSource.addDrawing()
    collectionView.reloadData()
  }
}

extension ThumbnailCollectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sketchDataSource.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SketchCell
    cell.backgroundColor = UIColor.lightGray
    
    return cell
  }
}

extension ThumbnailCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow

    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    guard let drawingViewController = storyboard?.instantiateViewController(identifier: "DrawingViewController") as? DrawingViewController,
      let navigationController = navigationController else {
        return
    }
    drawingViewController.sketch = sketchDataSource.sketches[indexPath.row]
    drawingViewController.sketchDataSource = sketchDataSource
    navigationController.pushViewController(drawingViewController, animated: true)
  }
}
