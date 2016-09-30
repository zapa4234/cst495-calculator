//
//  ViewController.swift
//  Calculator
//  gabriel z.

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var opHistory: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()


    @IBAction func appendDigit(sender: UIButton) {

        let digit = sender.currentTitle!
        let dupDecimal = decimalDupCheck(inputDigit: digit, stringToCheck: display.text)
        if userIsInTheMiddleOfTypingANumber {
            if !dupDecimal {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit == "." ? "0" + digit : digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    func decimalDupCheck(inputDigit digit: String, stringToCheck text: String?) -> Bool {
        if userIsInTheMiddleOfTypingANumber {
            return digit == "." && text?.containsString(".") == true
        } else {
            return false
        }
    }

    @IBAction func valueManip(sender: UIButton) {

        let manipulator = sender.currentTitle!
        switch manipulator {
        case "⌫":
            if userIsInTheMiddleOfTypingANumber {
                delDispLastChar()
                if display.text!.isEmpty {
                    display.text! = "0.0"
                    userIsInTheMiddleOfTypingANumber = false
                } else {
                    userIsInTheMiddleOfTypingANumber = true
                }
            } else {
                //undo case when user is not typing
                brain.opStackRemoveLast()
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = nil
                }
                opHistory.text = brain.description
            }
        default: break
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if let operation = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber && operation != "→M"{
                enter() //add to stack if say "6 enter 3 times"
            }
            if operation == "→M" {
                brain.variableValues["M"] = displayValue
                userIsInTheMiddleOfTypingANumber = false
            }
            if operation == "M" {
                brain.pushOperand(operation)
            }
            
            updateDispVal(operation)
            if operation != "π" && operation != "C"{
                appendDispEquals()
            }
        }
        opHistory.text = brain.description
        

    }

    
    
    
    @IBAction func enter() {

        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    var errmsg: String? {
        get {
            return brain.evaluateAndReportErrors()
        }
    }
    
    var displayValue: Double? {
        get {
            if display.text!.characters.last == "=" {
                delDispLastChar()
            }
            if let strNumber = NSNumberFormatter().numberFromString(display.text!) {
                return strNumber.doubleValue
            } else {
                //special case of PI and the spec to clear the display if N/A
                if (display.text! != "π") {
                    display.text = errmsg

                    resetCalc()
                    return 0
                }
                return M_PI
            }
        }
        set {
            if let num = newValue {
                let dispText = num == M_PI ? "π" : "\(num)"
                display.text = errmsg ?? dispText
            } else {
                display.text = errmsg ?? "?"
            }
            
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    private func delDispLastChar() {
        display.text! = String(display.text!.characters.dropLast())
    }
    private func appendDispEquals() {
        if (display.text!.characters.last != "=" && display.text! != errmsg) {
            display.text! += "="
        }
    }
    private func resetCalc() {
        userIsInTheMiddleOfTypingANumber = false
        opHistory.text! = ""
    }
    private func updateDispVal(operation: String) {
        if let result = brain.performOperation(operation) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
}

