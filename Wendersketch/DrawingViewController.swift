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

class DrawingViewController: UIViewController {

  var sketch: Sketch?
  var canvasView: PKCanvasView!
  private var selectedPenIndex = 0
  var sketchDataSource: SketchDataSource?

  @IBOutlet weak var allowFingerButton: UIBarButtonItem!
  @IBOutlet weak var undoButton: UIBarButtonItem!
  @IBOutlet weak var redoButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftItemsSupplementBackButton = true

    let canvasView = PKCanvasView(frame: view.bounds)
    self.canvasView = canvasView
    canvasView.allowsFingerDrawing = false
    view.addSubview(canvasView)

    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    canvasView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    canvasView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

    canvasView.backgroundColor = UIColor.lightGray

//    setupSimpleTools()
    setupToolPicker()
  }

  @IBAction func togglePencil(_ sender: UIBarButtonItem) {
    canvasView.allowsFingerDrawing.toggle()
    allowFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
  }

  func setupSimpleTools() {
    let segmentedControl = UISegmentedControl(items: ["Black", "Red"])
    segmentedControl.selectedSegmentIndex = 0
    let barButtonItem = UIBarButtonItem(customView: segmentedControl)
    segmentedControl.addTarget(self, action: #selector(penChanged(_:)), for: .valueChanged)
    navigationItem.rightBarButtonItems?.append(barButtonItem)
    updatePen()
  }

  @objc
  func penChanged(_ sender: UISegmentedControl) {
    selectedPenIndex = sender.selectedSegmentIndex
    updatePen()
  }

  func updatePen() {
    if selectedPenIndex == 0 {
      canvasView.tool = PKInkingTool(.pen, color: .systemFill, width: 10)
    } else {
      canvasView.tool = PKInkingTool(.pen, color: .systemRed, width: 10)
    }
  }

  func setupToolPicker() {
    if let window = self.parent?.view.window,
      let toolPicker = PKToolPicker.shared(for: window) {
      toolPicker.setVisible(true, forFirstResponder: canvasView)
      toolPicker.addObserver(canvasView)
      canvasView.becomeFirstResponder()
      toolPicker.addObserver(self)
      updateTools(toolPicker)
    }
  }

  @IBAction func undo(_ sender: UIBarButtonItem) {
    undoManager?.undo()
  }

  @IBAction func redo(_ sender: UIBarButtonItem) {
    undoManager?.redo()
  }

}

extension DrawingViewController: PKToolPickerObserver {
  func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
    if let tool = toolPicker.selectedTool as? PKEraserTool {
      print("Eraser: \(tool.eraserType)")
    } else if let tool = toolPicker.selectedTool as? PKInkingTool {
      print("Ink: \(tool.inkType) Color: \(tool.color) Width: \(tool.width)")
    } else if let _ = toolPicker.selectedTool as? PKLassoTool {
      print("Lasso tool")
    }
  }

  func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {
    print("Ruler active: \(toolPicker.isRulerActive)")
  }

  func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
    updateTools(toolPicker)
  }

  func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
    updateTools(toolPicker)
  }
  
  func updateTools(_ toolPicker: PKToolPicker) {
    let obscuredFrame = toolPicker.frameObscured(in: view)
    if obscuredFrame.isNull {
      navigationItem.leftBarButtonItems = []
    } else {
        if let unwrappedValue = undoButton {
            navigationItem.leftBarButtonItems = [undoButton, redoButton]
            print(unwrappedValue)
        } else {
            navigationItem.leftBarButtonItems = []
            print("Optional value is nil")
        }
      
    }
  }
}
