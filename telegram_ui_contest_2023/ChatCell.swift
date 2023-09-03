//
//  ChatCell.swift
//  telegram_ui_contest_2023
//
//  Created by Artem Shuneyko on 26.08.23.
//

import UIKit
import Lottie

class ChatCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let backgroundViewForAnimation: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.backgroundColor = .systemBlue
        view.isHidden = true
        
        return view
    }()
    
    private let animationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "archive")
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.5
        let white = UIColor.white.lottieColorValue
        let black = UIColor.black.lottieColorValue
        let whiteColorValueProvider = ColorValueProvider(white)
        let blackColorValueProvider = ColorValueProvider(black)
        let keyPath1 = AnimationKeypath(keypath: "Box.box1.Fill 1.Color")
        animationView.setValueProvider(whiteColorValueProvider, keypath: keyPath1)
        let keyPath2 = AnimationKeypath(keypath: "Cap.**.Fill 1.Color")
        animationView.setValueProvider(whiteColorValueProvider, keypath: keyPath2)
        let keyPath3 = AnimationKeypath(keypath: "Arrow 1.Arrow 1.Stroke 1.Color")
        animationView.setValueProvider(blackColorValueProvider, keypath: keyPath3)
        let keyPath4 = AnimationKeypath(keypath: "Arrow 2.Arrow 2.Stroke 1.Color")
        animationView.setValueProvider(blackColorValueProvider, keypath: keyPath4)
        animationView.isHidden = true
        
        return animationView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(messageLabel)
        addSubview(backgroundViewForAnimation)
        addSubview(animationView)
        backgroundViewForAnimation.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        animationView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        animationView.play()
        
        // Add constraints
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Avatar Image View
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
//            animationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
//            animationView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//            animationView.widthAnchor.constraint(equalToConstant: 60),
//            animationView.heightAnchor.constraint(equalToConstant: 60),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            // Message Label
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: avatarImageView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with chat: ChatInfo) {
        avatarImageView.image = chat.image
        nameLabel.text = chat.name
        messageLabel.text = chat.messages.last
        
        if chat.name == "archive"{
            backgroundViewForAnimation.isHidden = false
            animationView.isHidden = false
            avatarImageView.isHidden = true
        }
    }
}
