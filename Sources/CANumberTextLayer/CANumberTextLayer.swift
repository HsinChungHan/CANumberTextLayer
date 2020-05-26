//
//  AnimationNumberTextLayer.swift
//  DisplayLink
//
//  Created by Chung Han Hsin on 2020/5/26.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

//MARK: - AnimationNumberTextLayerDataSource
public protocol CANumberTextLayerDataSource: AnyObject {
  
  func animationNumberTextLayerStartValue(_ animationNumberLabel: CANumberTextlayer) -> Int
  func animationNumberTextLayerEndValue(_ animationNumberLabel: CANumberTextlayer) -> Int
  
  func animationNumberTextLayerDuration(_ animationNumberLabel: CANumberTextlayer) -> TimeInterval
  
  func animationNumberTextLayerBackgroundColor(_ animationNumberLabel: CANumberTextlayer) -> UIColor
  
  func animationNumberTextLayerTextColor(_ animationNumberLabel: CANumberTextlayer) -> UIColor
  
  func animationNumberTextLayerLabelFont(_ animationNumberLabel: CANumberTextlayer) -> UIFont
  
  func animationNumberTextLayerLabelFontSize(_ animationNumberLabel: CANumberTextlayer) -> CGFloat
  
  func animationNumberTextLayerTextAlignment(_ animationNumberLabel: CANumberTextlayer) -> CATextLayerAlignmentMode
  
}

public class CANumberTextlayer: CATextLayer {
  
  //MARK: - Properties
  public weak var dataSource: CANumberTextLayerDataSource?
  
  var animationStartDate: Date?
  var displayLink: CADisplayLink?
  
  //MARK: - View life cycles
  override public func draw(in ctx: CGContext) {
    super.draw(in: ctx)
    guard let dataSource = dataSource else {
      fatalError("You have to set dataSource for AnimationNumberTextLayer")
    }
    
    font = dataSource.animationNumberTextLayerLabelFont(self)
    fontSize = dataSource.animationNumberTextLayerLabelFontSize(self)
    backgroundColor = dataSource.animationNumberTextLayerBackgroundColor(self).cgColor
    foregroundColor = dataSource.animationNumberTextLayerTextColor(self).cgColor
    alignmentMode = dataSource.animationNumberTextLayerTextAlignment(self)
    contentsScale = UIScreen.main.scale
  }
}

//MARK: - Public functions
extension CANumberTextlayer {
  
  public func launchDisplayLink() {
    animationStartDate = Date()
    displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
    displayLink?.add(to: .main, forMode: .default)
  }
}

//MARK: - Internal functions
extension CANumberTextlayer {
  func invalidateDisplayLink() {
    displayLink?.invalidate()
    displayLink = nil
  }
  
  @objc func handleDisplayLink() {
    guard let dataSource = dataSource else {
      fatalError("You have to set dataSource for AnimationNumberLabel")
    }
    let startValue = dataSource.animationNumberTextLayerStartValue(self)
    let endValue = dataSource.animationNumberTextLayerEndValue(self)
    let duration = dataSource.animationNumberTextLayerDuration(self)
    guard let animationStartDate = animationStartDate else {
      return
    }
    let now = Date()
    let elaspedTime = now.timeIntervalSince(animationStartDate)
    if elaspedTime > duration {
      string = "\(endValue)"
      invalidateDisplayLink()
    } else {
      let percentage = elaspedTime / duration
      let value = Int(Double(startValue) + percentage * Double(endValue - startValue))
      string = "\(value)"
    }
  }
}

