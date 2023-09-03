//
//  ArchiveCreationP2View.swift
//  telegram_ui_contest_2023
//
//  Created by Artem Shuneyko on 29.08.23.
//

import UIKit
import Lottie

class ArchiveCreationP2View: UIView {
    var value: CGFloat = 150.0
    var targetValue: CGFloat = 1.0
    var duration: TimeInterval = 0.5
    var timer: Timer?
    var startTime: TimeInterval = 0.0
    let animationUpdateInterval: TimeInterval = 0.01
    
    var start = false
    var arrowIsHidden = false
    
    private var animationView: LottieAnimationView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        startTimer()
        animationView = .init(name: "archive")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation(){
        start = true
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    func startTimer() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.timer = Timer.scheduledTimer(timeInterval: self.animationUpdateInterval, target: self, selector: #selector(self.updateValue), userInfo: nil, repeats: true)
            RunLoop.current.run()
        }
    }
    
    @objc func updateValue() {
        guard start else { return }
        
        let currentTime = Date.timeIntervalSinceReferenceDate - startTime
        if currentTime >= duration {
            value = targetValue
            timer?.invalidate()
            timer = nil
        } else {
            let percentage = currentTime / duration
            value = interpolate(from: 150.0, to: 1.0, withPercentage: percentage)
        }
        
        DispatchQueue.main.async {
            self.setupView(-self.value)
        }
    }
    
    func interpolate(from startValue: CGFloat, to endValue: CGFloat, withPercentage percentage: CGFloat) -> CGFloat {
        return startValue + (endValue - startValue) * percentage
    }
    
    private func setupView(_ yOffset: CGFloat) {
        guard start else { return }

        let progress = (yOffset + 150) / 149
        
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let roundedRectWidth: CGFloat = 20
        let roundedRectXOffset: CGFloat = 10 + 30 - roundedRectWidth / 2
        let roundedRectYOffset: CGFloat = bounds.height > 15 ? frame.minY + 10 + 15 : 0
        var roundedRectHeight: CGFloat = roundedRectYOffset == 0 ? 0 : -yOffset - roundedRectWidth / 2 - 10
        roundedRectHeight = roundedRectHeight > 0 ? roundedRectHeight : 0

        let rectSize = CGSize(width: roundedRectWidth, height: -yOffset - 20)
        let rectY = yOffset/2 + 10 + (-yOffset + 15) * progress
        let roundedRectOrigin = CGPoint(x: roundedRectXOffset, y: rectY)
        let roundedRect1View = RoundedRectView(color: UIColor.clear.withAlphaComponent(0.5), frame: CGRect(origin: roundedRectOrigin, size: rectSize))
        roundedRect1View.backgroundColor = .clear
        if rectSize.height >= roundedRectWidth {
            addSubview(roundedRect1View)
        }
        
        let circleSize: CGFloat = roundedRectWidth
        let arrowImage = UIImage(systemName: "arrow.down.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.backgroundColor = .clear
        var circleY = roundedRectOrigin.y + rectSize.height - circleSize
        circleY = circleY <= 0 + circleSize / 2 + 20 ? 0 + circleSize / 2 + 20 : circleY
        let sizeForArrowAndOverlay = CGRect(x: roundedRectXOffset, y: circleY, width: circleSize, height: circleSize)
        arrowImageView.frame = sizeForArrowAndOverlay
        
        if progress == 1.0 && sizeForArrowAndOverlay.minY == 0 + roundedRectWidth + 10 {
            animationView!.logHierarchyKeypaths()
            arrowIsHidden = true
            animationView!.frame = CGRect(x: 10, y: 0 + 10, width: 60, height: 60)
            animationView!.loopMode = .playOnce
            animationView!.animationSpeed = 0.5
            addSubview(animationView!)
            animationView!.layer.zPosition = 100
            let white = UIColor.white.lottieColorValue
            let black = UIColor.black.lottieColorValue
            let whiteColorValueProvider = ColorValueProvider(white)
            let blackColorValueProvider = ColorValueProvider(black)
            let keyPath1 = AnimationKeypath(keypath: "Box.box1.Fill 1.Color")
            animationView!.setValueProvider(whiteColorValueProvider, keypath: keyPath1)
            let keyPath2 = AnimationKeypath(keypath: "Cap.**.Fill 1.Color")
            animationView!.setValueProvider(whiteColorValueProvider, keypath: keyPath2)
            let keyPath3 = AnimationKeypath(keypath: "Arrow 1.Arrow 1.Stroke 1.Color")
            animationView!.setValueProvider(blackColorValueProvider, keypath: keyPath3)
            let keyPath4 = AnimationKeypath(keypath: "Arrow 2.Arrow 2.Stroke 1.Color")
            animationView!.setValueProvider(blackColorValueProvider, keypath: keyPath4)
            animationView!.play{ finished in
                self.subviews.forEach { $0.removeFromSuperview() }
            }

        }
        arrowImageView.isHidden = arrowIsHidden
        roundedRect1View.isHidden = arrowIsHidden
        
        let label2 = UILabel()
        label2.text = ""
        label2.textColor = .white
        label2.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label2.textAlignment = .center
        let label2Size = label2.sizeThatFits(CGSize.zero)
        let label2X = roundedRectXOffset + circleSize
        let label2Y = circleY
        let label2Frame = CGRect(x: label2X, y: label2Y, width: label2Size.width, height: label2Size.height)
        label2.frame = label2Frame
        
        let rectangleSize = CGSize(width: 1000, height: 150)
        let minSize = CGSize(width: 60, height: 60)
        var newSize = rectangleSize
        
        let width = rectangleSize.width - (rectangleSize.width - minSize.width) * progress
        let height = rectangleSize.height - (rectangleSize.height - minSize.height) * progress * (1.5 - 0.5 * progress)
        newSize = CGSize(width: width, height: height)
        
        let rectangleOriginY = width < 100 ? yOffset/2 + (-yOffset + 10) * progress : yOffset/2 + (-yOffset) * progress
        let rectangleOrigin = CGPoint(x: 10 + 30 - newSize.width / 2, y: rectangleOriginY)
        let roundedRectView = RoundedRectView(color: .systemBlue, frame: CGRect(origin: rectangleOrigin, size: newSize))
        roundedRectView.backgroundColor = .clear
        addSubview(roundedRectView)
        
        if yOffset < -120 {
            var thresholdAndOffsetDiff = -120 - yOffset
            thresholdAndOffsetDiff = thresholdAndOffsetDiff > 30 ? 30 : thresholdAndOffsetDiff
            
            let textForLabel2 = getTextForLabel2(Int(thresholdAndOffsetDiff))
            label2.text = textForLabel2
            let newLabel2Size = label2.sizeThatFits(CGSize.zero)
            
            let alfaLength = 0.7
            let alfaStep = alfaLength / 30
            label2.textColor = .white.withAlphaComponent(0.3 + alfaStep * thresholdAndOffsetDiff)
            
            if thresholdAndOffsetDiff > 15 {
                let distance = frame.width / 2 - newLabel2Size.width / 2 - label2X + 30
                let label2Step = distance / 15
                let label2Frame = CGRect(x: label2X + label2Step * (thresholdAndOffsetDiff - 15), y: label2Y, width: newLabel2Size.width, height: newLabel2Size.height)
                label2.frame = label2Frame
            } else {
                let label2Frame = CGRect(x: label2X, y: label2Y, width: newLabel2Size.width, height: newLabel2Size.height)
                label2.frame = label2Frame
            }
        }
        
        addSubview(arrowImageView)
        addSubview(label2)
        
        label2.layer.zPosition = 2
        roundedRect1View.layer.zPosition = 2
        arrowImageView.layer.zPosition = 3
    }
    
    private func getTextForLabel2(_ step: Int) -> String {
        switch step {
        case 0:
            return ""
        case 1:
            return ""
        case 2:
            return "e"
        case 3:
            return "ve"
        case 4:
            return "ive"
        case 5:
            return "hive"
        case 6:
            return "chive"
        case 7:
            return "rchive"
        case 8:
            return " archive"
        case 9:
            return "r archive"
        case 10:
            return "or archive"
        case 11:
            return " for archive"
        case 12:
            return "se for archive"
        case 13:
            return "ease for archive"
        case 14:
            return "lease for archive"
        case 15:
            return "Release for archive"
        default:
            return "Release for archive"
        }
    }
}

class RoundedRectView: UIView {
    var color:UIColor
    
    init(color: UIColor, frame: CGRect) {
        self.color = color
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 100, height: 100))
        path.lineWidth = 1.0
        color.setFill()
        path.fill()
    }
}
