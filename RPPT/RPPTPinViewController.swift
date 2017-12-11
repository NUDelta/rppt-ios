//
//  RPPTPinViewController.swift
//  RRPTPin
//
//  Created by Andrew Finke on 12/10/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit

class RPPTPinViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties

    private let textField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.contentVerticalAlignment = .center

        textField.placeholder = "WizardPin"
        textField.keyboardType = .numberPad
        textField.font = UIFont.systemFont(ofSize: 70.0, weight: .semibold)
        textField.translatesAutoresizingMaskIntoConstraints = false

        let attributes: [NSAttributedStringKey: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font : UIFont.systemFont(ofSize: 50.0, weight: .medium)
        ]

        textField.attributedPlaceholder = NSAttributedString(string: "WizardPin",
                                                             attributes: attributes)
        return textField
    }()

    private let connectButton: UIButton = {
        let button = UIButton()
        button.setTitle("Connect", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.purple.withAlphaComponent(0.5)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        connectButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textField)
        view.addSubview(connectButton)

        let constraints = [
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.heightAnchor.constraint(equalToConstant: 100),

            connectButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            connectButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            connectButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            connectButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .purple
        navigationController?.view.backgroundColor = .clear

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "SetupComplete") {
            textField.alpha = 1.0
            connectButton.alpha = 1.0
        } else {
            textField.alpha = 0.0
            connectButton.alpha = 0.0
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "SetupComplete") {
            textField.isEnabled = true
            textField.becomeFirstResponder()
        } else {
            let flowNav = UINavigationController(rootViewController: RPPTInitalFlowViewController())
            navigationController?.present(flowNav, animated: false, completion: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.alpha = 1.0
        connectButton.alpha = 1.0
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        guard let currentString = textField.text as NSString? else {
            return false
        }

        let newString = currentString.replacingCharacters(in: range, with: string) as NSString

        if newString.length >= 5 {
            connectButton.backgroundColor = .purple
            connectButton.isEnabled = true
        } else {
            connectButton.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
            connectButton.isEnabled = false
        }
        return newString.length <= 5
    }

    // MARK: - Actions

    @objc
    func connectButtonPressed() {
        textField.isEnabled = false
        textField.resignFirstResponder()

        UIView.animate(withDuration: 0.5, animations: {
            self.textField.alpha = 0.0
            self.connectButton.alpha = 0.0
        }) { _ in
            self.performSegue(withIdentifier: "connect", sender: self.textField.text!)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let syncCode = sender as? String,
            let destination = segue.destination as? RPPTController else {
            fatalError()
        }
        destination.syncCode = syncCode
    }

}
