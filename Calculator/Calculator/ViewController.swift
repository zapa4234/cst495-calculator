//
//  ViewController.swift
//  Calculator
//
//  Created by Gabriel Zapata on 9/2/16.
//  Copyright © 2016 CSUMB. All rights reserved.
//

import UIKit
import Foundation



class ViewController: UIViewController {

    
    
    @IBOutlet weak var historyDisplay: UILabel!
   
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
    
    
    @IBAction func pi(sender: UIButton) {
        
        if display.text != "0"{
            enter()
            display.text = "\(M_PI)"
            enter()
            
        }else{
            display.text = "\(M_PI)"
            enter()
        }
        
        userIsInTheMiddleOfTypingANumber = true
        
    }
    
    
    @IBAction func clear(sender: UIButton) {
        
        if display.text != "0"{
            display.text = "0"
            operandStack.removeAll()
        }
        else{
            operandStack.removeAll()
        }
        
        
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
        case "√": performOperation { sqrt($0)} //need to do sin, cos, pi
        case "sin": performOperation { Double(sin($0))} // need help with layout bugs
        case "cos": performOperation { Double(cos($0))} // assignment 1 due: sept 15
        //case "π": displayValue = M_PI
            //enter()
        //var theCosOfZero: Double = Double(cos(0))
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
            if operandStack.count >= 1 {
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
    
    @IBAction func decimal(sender: UIButton) {
        //figure out how to add the decimal to make it a double to allow the user
        //to add decimals to the previous number
        
        if(display.text!.containsString("."))
        {
            return
        }else{
        
        display.text = display.text! + "."
        }
        
        
        
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

