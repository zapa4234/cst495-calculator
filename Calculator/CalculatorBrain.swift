//  CalculatorBrain.swift
//  gabriel z.


import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double, ((Double)->String?)?)
        case BinaryOperation(String, (Double, Double) -> Double, ((Double,Double)->String?)?)
        case ClearOperation(String)
        case PiOperation(String)
        case Variable(String, (String->String?))
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                case .ClearOperation(let symbol):
                    return symbol
                case .PiOperation(let symbol):
                    return symbol
                case .Variable(let symbol, _):
                    return symbol
                }
            }
        }
        
        var precedence: Int {
            switch self {
            case .BinaryOperation(let symbol, _, _):
                switch symbol {
                case "+": fallthrough
                case "-":
                    return 0
                case "×": fallthrough
                case "÷":
                    return 1
                default:
                    return Int.max
                }
            default:
                return Int.max
            }
        }
    }
    
    let noOperandStr = "not enough operands"
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *, nil))
        learnOp(Op.BinaryOperation("÷", {$1 / $0 }, testDivByZero))
        learnOp(Op.BinaryOperation("+", +, nil))
        learnOp(Op.BinaryOperation("-", {$1 - $0}, nil))
        learnOp(Op.UnaryOperation("√", sqrt, testSqrt))
        learnOp(Op.UnaryOperation("sin", sin, nil))
        learnOp(Op.UnaryOperation("cos", cos, nil))
        learnOp(Op.UnaryOperation("ᐩ/-", -, nil))
        learnOp(Op.ClearOperation("C"))
        learnOp(Op.PiOperation("π"))
    }

    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return opStack.map{ $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        var describeString: [String] = []
        var described = describe(opStack, TOS: true)

        if let firstDescriptor = described.descriptor {
            describeString.append(firstDescriptor)
        }
        while !described.remainingOps.isEmpty {
            described = describe(described.remainingOps, TOS: true)
            if let anotherDescriptor = described.descriptor {
                describeString.append(anotherDescriptor)
            }
        }
        return describeString.reverse().joinWithSeparator(",") ?? " "
    }
    
    private func describe(ops: [Op], TOS: Bool) -> (remainingOps: [Op], descriptor: String?, prevOp: Op?) {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Variable(let symbol, _):
                return (remainingOps, symbol, op)
            case .Operand(let operand):
                return (remainingOps, "\(operand)", op)
            case .UnaryOperation(let symbol, _, _):
                let described = describe(remainingOps, TOS: false)
                let retStr = op.precedence > described.prevOp?.precedence ?
                    "\(symbol)(\(described.descriptor ?? "?"))" :
                    "\(symbol)\(described.descriptor ?? "?")"
                return (described.remainingOps, retStr, op)
                
            case .BinaryOperation(let symbol, _, _):
                
                let op1Described = describe(remainingOps, TOS: false)
                let op2Described = describe(op1Described.remainingOps, TOS: false)
                
                var binaryDescription: String
                var prefix: String
                var suffix: String
                
                let opPrecedence = op.precedence
                let op1Precedence = op1Described.prevOp?.precedence
                let op2Precedence = op2Described.prevOp?.precedence
                
                if opPrecedence > op2Precedence {
                    prefix = "(\(op2Described.descriptor ?? "?"))"
                } else {
                    prefix = "\(op2Described.descriptor ?? "?")"
                }
                if opPrecedence > op1Precedence {
                    suffix = "(\(op1Described.descriptor ?? "?"))"
                } else if opPrecedence < op1Precedence {
                    suffix = "\(op1Described.descriptor ?? "?")"
                } else {
                    if !TOS {
                        suffix = "\(op1Described.descriptor ?? "?")"
                    } else {
                        if symbol == "-" || symbol == "÷" {
                            suffix = "(\(op1Described.descriptor ?? "?"))"
                        } else {
                            suffix = "\(op1Described.descriptor ?? "?")"
                        }
                    }
                }
                
                
                binaryDescription = "\(prefix)\(symbol)\(suffix)"
                return (op2Described.remainingOps, binaryDescription, op)
            case .ClearOperation(_):
                return (ops, nil, op)
            case .PiOperation(_):
                return (remainingOps, "π", op)
            }
        }
        return (ops, nil, nil)
    }
    
    private func evaluateAndReportErrors(ops: [Op]) -> (String?, result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Variable(let operand, let errmsg):
                if let variableValue = variableValues[operand] {
                    return (errmsg(operand), variableValue, remainingOps)
                }
                return (errmsg(operand), nil, remainingOps)
                
            case .Operand(let operand):
                return (nil, operand, remainingOps)
                
            case .UnaryOperation(_, let operation, let errmsg):
                let operandEvaluation = evaluateAndReportErrors(remainingOps)
                if let operand = operandEvaluation.result {
                    return (errmsg?(operand), operation(operand), operandEvaluation.remainingOps)
                } else {
                    return (noOperandStr, nil, ops)
                }
            case .BinaryOperation(_, let operation, let errmsg):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (errmsg?(operand1, operand2), operation(operand1, operand2), op2Evaluation.remainingOps)
                    } else {
                        return (noOperandStr, nil, ops)
                        
                    }
                } else {
                    return (noOperandStr, nil, ops)
                }
            case .ClearOperation(_):
                opStack = []
                variableValues = [:]
                return (nil, 0, [])
            case .PiOperation(_):
                return (nil, M_PI, remainingOps) //no .removeLast() since we need to wait for an operation to operate on pi
            }
        }
        return ("ready", nil, ops)
    }
    
    private func testDivByZero(op1: Double, op2: Double) -> String? {
        return op1 == 0.0 ? "div by 0" : nil
    }
    
    
    private func testSqrt(op1: Double) -> String? {
        return op1 < 0.0 ? "no img num" : nil
    }
    
    private func testVariableExistence(key: String) -> String? {
        if let _ = variableValues[key] {
            return nil
        } else {
            return "\(key) not set"
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Variable(let operand, _):
                if let variableValue = variableValues[operand] {
                    return (variableValue, remainingOps)
                }
                
                return (nil, remainingOps)
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation, _):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation, _):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        print("op1: \(operand1); op2: \(operand2)")
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                
                
            case .ClearOperation(_):
                opStack = []
                variableValues = [:]
                return (0, [])
            case .PiOperation(_):
                return (M_PI, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }

    func evaluateAndReportErrors() -> String? {
        let (errmsg, _, _) = evaluateAndReportErrors(opStack)
        return errmsg
    }
    
    func pushOperand(operand: Double?) -> Double? {
        if let validOperand = operand {
            opStack.append(Op.Operand(validOperand))
        }
        return evaluate()
    }
    
    func pushOperand(variableSymbol: String) -> Double? {
        opStack.append(Op.Variable(variableSymbol, testVariableExistence))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func opStackRemoveLast() {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
    }
}
