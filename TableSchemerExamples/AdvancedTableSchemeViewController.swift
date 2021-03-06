//
//  AdvancedTableSchemeViewController.swift
//  TableSchemer
//
//  Created by James Richard on 7/2/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import TableSchemer
import UIKit

class AdvancedTableSchemeViewController: UITableViewController {
    let SwitchReuseIdentifier = "SwitchCell"
    let InputReuseIdentifier = "InputCell"
    let BasicReuseIdentifier = "BasicCell"
    var tableScheme: TableScheme!
    var firstSwitchScheme: Scheme!
    var secondSwitchScheme: Scheme!
    var firstFieldScheme: Scheme!
    var secondFieldScheme: Scheme!
    var buttonsScheme: ArrayScheme<String, SchemeCell>!
    
    var wifiEnabled = false
    var bluetoothEnabled = false
    
    var firstFieldValue = ""
    var secondFieldValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advanced"
        tableView.rowHeight = 44.0

        buildAndSetTableScheme()
    }

    func buildAndSetTableScheme() {
        tableScheme = TableScheme(tableView: tableView) { builder in
            builder.buildSchemeSet { builder in
                builder.headerText = "Switches"
                
                firstSwitchScheme = builder.buildScheme { (scheme: BasicSchemeBuilder) in
                    scheme.configurationHandler = { [unowned self] cell in
                        cell.textLabel?.text = "First Switch"
                        cell.selectionStyle = .none
                        let switchView = UISwitch()
                        switchView.isOn = self.wifiEnabled
                        switchView.addTarget(self, action: #selector(AdvancedTableSchemeViewController.switcherUpdated(_:)), for: .valueChanged) // Don't worry about this being reapplied on reuse; it has checks =)
                        cell.accessoryView = switchView
                    }
                }
                
                secondSwitchScheme = builder.buildScheme { (scheme: BasicSchemeBuilder) in
                    scheme.configurationHandler = { [unowned self] cell in
                        cell.textLabel?.text = "Second Switch"
                        cell.selectionStyle = .none
                        let switchView = UISwitch()
                        switchView.isOn = self.bluetoothEnabled
                        switchView.addTarget(self, action: #selector(AdvancedTableSchemeViewController.switcherUpdated(_:)), for: .valueChanged)
                        cell.accessoryView = switchView
                    }
                }
                
            }
            
            builder.buildSchemeSet { builder in
                builder.headerText = "Text Input"
                builder.footerText = "Section footer text"
                
                firstFieldScheme = builder.buildScheme { (scheme: BasicSchemeBuilder<InputFieldCell>) in
                    scheme.configurationHandler = { [unowned self] cell in
                        cell.selectionStyle = .none
                        cell.label.text = "First Input:"
                        cell.input.text = self.firstFieldValue
                        cell.input.keyboardType = .default // Since the other input cell changes this value, this cell must define what it wants to avoid reuse issues.
                        cell.input.addTarget(self, action: #selector(AdvancedTableSchemeViewController.controlResigned(_:)), for: .editingDidEndOnExit)
                        cell.input.addTarget(self, action: #selector(AdvancedTableSchemeViewController.textFieldUpdated(_:)), for: .editingDidEnd)
                    }
                }
                
                secondFieldScheme = builder.buildScheme { (scheme: BasicSchemeBuilder<InputFieldCell>) in
                    scheme.configurationHandler = { [unowned self] cell in
                        cell.selectionStyle = .none
                        cell.label.text = "Email:"
                        cell.input.text = self.secondFieldValue
                        cell.input.keyboardType = .emailAddress
                        cell.input.addTarget(self, action: #selector(AdvancedTableSchemeViewController.controlResigned(_:)), for: .editingDidEndOnExit)
                        cell.input.addTarget(self, action: #selector(AdvancedTableSchemeViewController.textFieldUpdated(_:)), for: .editingDidEnd)
                    }
                }
            }
            
            builder.buildSchemeSet { builder in
                builder.headerText = "Buttons!"
                
                buttonsScheme = builder.buildScheme { (scheme: ArraySchemeBuilder<String, SchemeCell>) in
                    scheme.objects = ["First", "Second", "Third", "Fourth"]
                    
                    scheme.configurationHandler = { [unowned self] cell, object in
                        cell.selectionStyle = .none
                        cell.textLabel?.text = object
                        let button = UIButton(type: .infoDark)
                        button.addTarget(self, action: #selector(AdvancedTableSchemeViewController.buttonPressed(_:)), for: .touchUpInside)
                        cell.accessoryView = button
                    }
                }
            }
        }
    }

    // MARK: Target-Action
    func switcherUpdated(_ switcher: UISwitch) {
        if let scheme = tableScheme.scheme(containing: switcher) {
            if scheme === self.firstSwitchScheme {
                print("Toggle some feature, like allowing wifi!")
                self.wifiEnabled = switcher.isOn
            } else if scheme === self.secondSwitchScheme {
                print("Toggle some other feature, like bluetooth!")
                self.bluetoothEnabled = switcher.isOn
            }
        }
    }
    
    func textFieldUpdated(_ textField: UITextField) {
        if let scheme = tableScheme.scheme(containing: textField) {
            if scheme === self.firstFieldScheme {
                print("Storing \"\(textField.text)\" for first text field!")
                self.firstFieldValue = textField.text ?? ""
            } else if scheme === self.secondFieldScheme {
                print("Storing \"\(textField.text)\" for the email!")
                self.secondFieldValue = textField.text ?? ""
            }
        }
    }
    
    func buttonPressed(_ button: UIButton) {
        if let tuple = tableScheme.schemeWithIndex(containing: button) {
            if tuple.scheme === buttonsScheme {
                let object = buttonsScheme.objects[tuple.index]
                print("You pressed the button with object: \(object)")
            }
        }
    }
    
    func controlResigned(_ control: UIResponder) {
        control.resignFirstResponder()
    }
}

class InputFieldCell: SchemeCell {
    let label = UILabel()
    let input = UITextField()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        label.translatesAutoresizingMaskIntoConstraints = false
        input.translatesAutoresizingMaskIntoConstraints = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(input)
        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        let views = ["label": label, "input": input]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[label]-5-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[input]-5-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-20-[label]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[input(150)]-20-|", options: [], metrics: nil, views: views))
        
        super.updateConstraints()
    }
    
}
