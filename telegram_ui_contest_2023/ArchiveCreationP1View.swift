//
//  ArchiveCreationP1View.swift
//  telegram_ui_contest_2023
//
//  Created by Artem Shuneyko on 26.08.23.
//

import UIKit
import RxSwift

class ArchiveCreationP1View: UIView {
    var changes = PublishSubject<CGFloat>()
    let bag = DisposeBag()
    
    var overlay: UIView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView(0)
        subscribe()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView(0)
        subscribe()
    }
    
    private func subscribe(){
        changes.subscribe { change in
            self.setupView(change)
        }
        .disposed(by: bag)
    }
    
    private func setupView(_ yOffset: CGFloat) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Background Gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.gray.cgColor, UIColor.lightGray.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
        
        // Rounded Rectangle
        let roundedRectWidth: CGFloat = 20
        let roundedRectXOffset: CGFloat = 10 + 30 - roundedRectWidth / 2
        let roundedRectYOffset: CGFloat = bounds.height > 15 ? 15 - roundedRectWidth / 2 : 0
        var roundedRectHeight: CGFloat = roundedRectYOffset == 0 ? 0 : -yOffset - roundedRectWidth / 2 - 10
        roundedRectHeight = roundedRectHeight > 0 ? roundedRectHeight : 0
        
        let cgRect = CGRect(x: roundedRectXOffset, y: roundedRectYOffset, width: roundedRectWidth, height: roundedRectHeight)
        let rectView = UIView(frame: cgRect)
        let roundedRectPath = UIBezierPath(roundedRect: cgRect, cornerRadius: 20)
        let roundedRectLayer = CAShapeLayer()
        roundedRectLayer.path = roundedRectPath.cgPath
        roundedRectLayer.fillColor = UIColor.clear.withAlphaComponent(0.5).cgColor
        rectView.frame = roundedRectLayer.frame
        rectView.layer.addSublayer(roundedRectLayer)
        addSubview(rectView)
        
        // Arrow
        let circleSize: CGFloat = roundedRectWidth
        let arrowImage = UIImage(systemName: "arrow.down.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.backgroundColor = .clear
        let sizeForArrowAndOverlay = CGRect(x: roundedRectXOffset, y: -yOffset - circleSize - 10, width: circleSize, height: circleSize)
        arrowImageView.frame = sizeForArrowAndOverlay
        
        // Label1
        let label1 = UILabel()
        label1.text = "Swipe down for archive"
        label1.textColor = .white
        label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label1.textAlignment = .center
        let label1Size = label1.sizeThatFits(CGSize.zero)
        let label1X = frame.width / 2 - label1Size.width / 2
        let label1Y = arrowImageView.frame.minY
        let label1Frame = CGRect(x: label1X, y: label1Y, width: label1Size.width, height: label1Size.height)
        label1.frame = label1Frame
        
        // Label2
        let label2 = UILabel()
        label2.text = ""
        label2.textColor = .white
        label2.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label2.textAlignment = .center
        let label2Size = label2.sizeThatFits(CGSize.zero)
        let label2X = roundedRectXOffset + circleSize
        let label2Y = arrowImageView.frame.minY
        let label2Frame = CGRect(x: label2X, y: label2Y, width: label2Size.width, height: label2Size.height)
        label2.frame = label2Frame
    
        overlay = UIView()
        overlay.backgroundColor = yOffset < -120 ? UIColor.systemBlue : .clear
        overlay.frame = sizeForArrowAndOverlay
        if yOffset < -120 {
            var thresholdAndOffsetDiff = -120 - yOffset
            thresholdAndOffsetDiff = thresholdAndOffsetDiff > 30 ? 30 : thresholdAndOffsetDiff
            let multiplier = bounds.size.width / circleSize
            overlay.transform = CGAffineTransform(scaleX: thresholdAndOffsetDiff * multiplier / 15, y: thresholdAndOffsetDiff * multiplier / 15)
            
            let angleStep = CGFloat.pi / 30
            let rotationAngle = -angleStep * thresholdAndOffsetDiff
            arrowImageView.transform = CGAffineTransform(rotationAngle: rotationAngle < -CGFloat.pi ? CGFloat.pi : rotationAngle)
            
            
            let textForLabel2 = getTextForLabel2(Int(thresholdAndOffsetDiff))
            label2.text = textForLabel2
            let newLabel2Size = label2.sizeThatFits(CGSize.zero)
            
            let alfaLength = 0.7
            let alfaStep = alfaLength / 30
            label1.textColor = .white.withAlphaComponent(1 - alfaStep * thresholdAndOffsetDiff)
            label2.textColor = .white.withAlphaComponent(0.3 + alfaStep * thresholdAndOffsetDiff)
            
            let distance = frame.width - label1X + 1
            let label1Step = distance / 20
            let newLabel1Frame = CGRect(x: label1X + label1Step * thresholdAndOffsetDiff, y: label1Y, width: label1Size.width, height: label1Size.height)
            label1.frame = newLabel1Frame

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
        
        overlay.layer.cornerRadius = overlay.bounds.width / 2

        addSubview(overlay)
        addSubview(arrowImageView)
        addSubview(label1)
        addSubview(label2)
        
        overlay.layer.zPosition = 1
        label2.layer.zPosition = 2
        rectView.layer.zPosition = 2
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
