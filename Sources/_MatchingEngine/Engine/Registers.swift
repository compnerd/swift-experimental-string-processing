extension Processor {
  /// Our register file
  struct Registers {
    // currently, these are static readonly
    var elements: [Element]

    // currently, hold output of assertions
    var bools: [Bool] // TODO: bitset

    // currently, these are static readonly
    var consumeFunctions: [Program<Input>.ConsumeFunction]

    // currently, these are for comments and abort messages
    var strings: [String]

    // unused
    var ints: [Int] = []

    // unused
    var floats: [Double] = []

    // unused
    //
    // Unlikely to be static, as that means input must be bound
    // at compile time
    var positions: [Position] = []

    // unused
    var instructionAddresses: [InstructionAddress] = []

    // unused, any application?
    var classStackAddresses: [CallStackAddress] = []

    // unused, any application?
    var positionStackAddresses: [PositionStackAddress] = []

    // unused, any application?
    var savePointAddresses: [SavePointStackAddress] = []

    subscript(_ i: StringRegister) -> String {
      strings[i.rawValue]
    }
    subscript(_ i: BoolRegister) -> Bool {
      get { bools[i.rawValue] }
      set { bools[i.rawValue] = newValue }
    }
    subscript(_ i: ElementRegister) -> Element {
      elements[i.rawValue]
    }
    subscript(_ i: ConsumeFunctionRegister) -> Program<Input>.ConsumeFunction {
      consumeFunctions[i.rawValue]
    }
  }
}

extension Processor.Registers {
  init(
    _ program: Program<Input>,
    _ sentinel: Input.Index
  ) {
    let info = program.registerInfo

    self.elements = program.staticElements
    assert(elements.count == info.elements)

    self.consumeFunctions = program.staticConsumeFunctions
    assert(consumeFunctions.count == info.consumeFunctions)

    self.strings = program.staticStrings
    assert(strings.count == info.strings)

    self.bools = Array(repeating: false, count: info.bools)

    self.ints = Array(repeating: 0, count: info.ints)

    self.floats = Array(repeating: 0, count: info.floats)

    self.positions = Array(repeating: sentinel, count: info.positions)

    self.instructionAddresses = Array(repeating: 0, count: info.instructionAddresses)

    self.classStackAddresses = Array(repeating: 0, count: info.classStackAddresses)

    self.positionStackAddresses = Array(repeating: 0, count: info.positionStackAddresses)

    self.savePointAddresses = Array(repeating: 0, count: info.savePointAddresses)
  }
}

extension Program {
  struct RegisterInfo {
    var elements = 0
    var bools = 0
    var strings = 0
    var consumeFunctions = 0
    var ints = 0
    var floats = 0
    var positions = 0
    var instructionAddresses = 0
    var classStackAddresses = 0
    var positionStackAddresses = 0
    var savePointAddresses = 0
  }
}

extension Processor.Registers: CustomStringConvertible {
  var description: String {
    func formatRegisters<T>(
      _ name: String, _ regs: [T]
    ) -> String {
      // TODO: multi-line if long
      if regs.isEmpty { return "" }

      return "\(name): \(regs)\n"
    }

    return """
      \(formatRegisters("elements", elements))\
      \(formatRegisters("bools", bools))\
      \(formatRegisters("strings", strings))\
      \(formatRegisters("ints", ints))\
      \(formatRegisters("floats", floats))\
      \(formatRegisters("positions", positions))\
      \(formatRegisters("instructionAddresses", instructionAddresses))\
      \(formatRegisters("classStackAddresses", classStackAddresses))\
      \(formatRegisters("positionStackAddresses", positionStackAddresses))\
      \(formatRegisters("savePointAddresses", savePointAddresses))\

      """    
  }
}

