//
//  ViewController.swift
//  Calculator
//
//  Created by Gabriel Zapata on 9/2/16.
//  Copyright © 2016 CSUMB. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

   
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    @IBAction func appendDigit(sender: UIButton) {
        //let is basically var however, just constant
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber{
            display.text = display.text! + digit
        }else{
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
        //print("digit = \(digit)")
        
        
    }
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
         enter()
        }
        
        switch operation{
        case "x": performOperation {$0 * $1}
        case "÷": performOperation {$0 / $1}
        case "+": performOperation {$0 + $1}
        case "-": performOperation {$0 - $1}
        case "√": performOperation { sqrt($0)}
        case "sin": performOperation { sqrt($0)}
        case "cos": performOperation { sqrt($0)}
        //case "π":
        default: break
        }
    }
        
        func performOperation(operation: (Double, Double) ->  Double){
            if operandStack.count >= 2 {
                displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
                enter()
            }
        }
        private func performOperation(operation: Double ->  Double){
            if operandStack.count >= 2 {
                displayValue = operation(operandStack.removeLast())
                enter()
            }
        }
        
        
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        print("operandstack = \(operandStack)")
    }
    
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
        }
}

