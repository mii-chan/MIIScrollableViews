//
//  ViewController.swift
//  Demo
//
//  Created by Miida Yuki on 2017/12/18.
//

import UIKit
import MIIScrollableViews

class ViewController: UIViewController {
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var scrollableViews: MIIScrollableViews!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let imageNames = ["img1", "img2", "img3", "img4", "img5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup MIIScrollableViewsDelegate
        scrollableViews.svDelegate = self
        
        // Add All Gestures
        scrollableViews.addAllGesturesToViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Add Initial Image
        scrollableViews.append(generateRandomImageView())
    }
    
    // MARK: - UIBarButtonItem Actions
    @IBAction func addImage(_ sender: UIBarButtonItem) {
        let index = scrollableViews.count != 0 ? pageControl.currentPage + 1 : 0
        
        scrollableViews.insert(generateRandomImageView(), at: index)
        
        actionLabel.text = "Add Image to index : \(index)"
    }
    
    @IBAction func removeImage(_ sender: UIBarButtonItem) {
        if scrollableViews.count > 0 {
            let index = pageControl.currentPage
            
            scrollableViews.remove(at: index)
            
            actionLabel.text = "Remove Image from index : \(index)"
        } else {
            actionLabel.text = ""
        }
    }
    
    // MARK: - UISwitch Actions
    @IBAction func tapSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            scrollableViews.shouldAddTapGesture = true
        } else {
            scrollableViews.shouldAddTapGesture = false
            actionLabel.text = ""
        }
    }
    
    @IBAction func doubleTapSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            scrollableViews.shouldAddDoubleTapGesture = true
        } else {
            scrollableViews.shouldAddDoubleTapGesture = false
            actionLabel.text = ""
        }
    }

    @IBAction func panSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            scrollableViews.shouldAddPanGesture = true
        } else {
            scrollableViews.shouldAddPanGesture = false
            actionLabel.text = ""
        }
    }
    
    @IBAction func pinchSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            scrollableViews.shouldAddPinchGesture = true
        } else {
            scrollableViews.shouldAddPinchGesture = false
            actionLabel.text = ""
        }
    }
    
    @IBAction func longPressSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            scrollableViews.shouldAddLongPressGesture = true
        } else {
            scrollableViews.shouldAddLongPressGesture = false
            actionLabel.text = ""
        }
    }
    
    // MARK: - Private Methods
    private func generateRandomImageView() -> UIImageView {
        return UIImageView(image: UIImage(named: imageNames[Int(arc4random_uniform(UInt32(imageNames.count)))]))
    }
}

extension ViewController: MIIScrollableViewsDelegate {
    func didViewsCountChange(count: Int) {
        pageControl.numberOfPages = count
    }
    
    func didViewDisplayedChange(viewDisplayed: UIView, index: Int) {
        pageControl.currentPage = index
    }
    
    func didTap(view: UIView, index: Int, gesture: UITapGestureRecognizer) {
        actionLabel.text = "Tap index : \(index)"
    }
    
    func didDoubleTap(view: UIView, index: Int, gesture: UITapGestureRecognizer) {
        actionLabel.text = "Double Tap index : \(index)"
    }
    
    func didPan(view: UIView, index: Int, gesture: UIPanGestureRecognizer) {
        actionLabel.text = "Pan index : \(index)"
    }
    
    func didPinch(view: UIView, index: Int, gesture: UIPinchGestureRecognizer) {
        actionLabel.text = "Pinch index : \(index)"
    }
    
    func didLongPress(view: UIView, index: Int, gesture: UILongPressGestureRecognizer) {
        actionLabel.text = "Long Press index : \(index)"
    }
}
