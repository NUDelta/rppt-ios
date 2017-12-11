//
//  RPPTFlowViewController.swift
//  RPPTFlow
//
//  Created by Andrew Finke on 12/10/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit

class RPPTFlowViewController: UIViewController {

    // MARK: - Properties

    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }

    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }

    var continueText: String? {
        didSet {
            continueButton.setTitle(continueText, for: .normal)
        }
    }

    var cancelText: String? {
        didSet {
            cancelButton.setTitle(cancelText, for: .normal)
        }
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var isCancelButtonHidden: Bool = false {
        didSet {
            cancelButton.isHidden = isCancelButtonHidden
        }
    }

    // MARK: - User Interface

    let contentView = UIView()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let continueButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - User Interface

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)

        view.backgroundColor = .white

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(contentView)
        view.addSubview(imageView)
        view.addSubview(continueButton)
        view.addSubview(cancelButton)

        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 1.0),
            descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 1.0),

            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            cancelButton.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            cancelButton.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),

            continueButton.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            continueButton.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            continueButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -5),
            continueButton.heightAnchor.constraint(equalToConstant: 50),

            contentView.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -10),
            contentView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),

            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }

    // MARK: - Helpers

    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Buttons

    @objc
    func continueButtonPressed() {
        fatalError(#function + " not implemented by subclass")
    }

    @objc
    func cancelButtonPressed() {
        let message = "Are you sure you want to stop setting up McGonagall?"
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .actionSheet)

        let action = UIAlertAction(title: "Don't Setup", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(action)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

}
