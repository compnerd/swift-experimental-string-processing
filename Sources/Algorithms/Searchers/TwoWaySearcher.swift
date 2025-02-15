public struct TwoWaySearcher<Searched: BidirectionalCollection>
  where Searched.Element: Comparable, Searched.SubSequence == Searched
{
  // TODO: Be generic over the pattern?
  let pattern: [Searched.Element]
  let criticalIndex: Int
  let period: Int
  let periodIsExact: Bool
  
  init?(pattern: [Searched.Element]) {
    guard !pattern.isEmpty else { return nil }
    
    let (criticalIndex, periodOfSecondPart) = pattern._criticalFactorization(<)
    let periodIsExact = pattern[criticalIndex...]
      .prefix(periodOfSecondPart)
      .ends(with: pattern[..<criticalIndex])
    
    self.pattern = pattern
    self.criticalIndex = criticalIndex
    self.period = periodIsExact
      ? periodOfSecondPart
      : max(criticalIndex, pattern.count - criticalIndex) + 1
    self.periodIsExact = periodIsExact
  }
}

extension TwoWaySearcher: CollectionSearcher {
  public struct State {
    var index: Searched.Index
    var criticalIndex: Searched.Index
    var memory: (offset: Int, index: Searched.Index)?
  }
  
  public func state(startingAt index: Searched.Index, in searched: Searched) -> State {
    let criticalIndex = searched.index(index, offsetBy: criticalIndex)
    return State(index: index, criticalIndex: criticalIndex, memory: nil)
  }

  public func search(_ searched: Searched, _ state: inout State) -> Range<Searched.Index>? {
    while state.criticalIndex != searched.endIndex {
      if let end = _searchRight(searched, &state),
         let start = _searchLeft(searched, &state, end)
      {
        state.index = end
        state.criticalIndex = searched.index(end, offsetBy: criticalIndex)
        state.memory = nil
        return start..<end
      }
    }
    
    return nil
  }
  
  func _searchRight(
    _ searched: Searched,
    _ state: inout State
  ) -> Searched.Index? {
    let rStart: Int
    var rIndex: Searched.Index
    
    if let memory = state.memory, memory.offset > criticalIndex {
      rStart = memory.offset
      rIndex = memory.index
    } else {
      rStart = criticalIndex
      rIndex = state.criticalIndex
    }
    
    for i in rStart..<pattern.count {
      if rIndex == searched.endIndex {
        state.criticalIndex = searched.endIndex
        return nil
      }
      
      if pattern[i] != searched[rIndex] {
        state.criticalIndex = searched.index(after: rIndex)
        state.memory = nil
        return nil
      }
      
      searched.formIndex(after: &rIndex)
    }
    
    return rIndex
  }
  
  func _searchLeft(
    _ searched: Searched,
    _ state: inout State,
    _ end: Searched.Index
  ) -> Searched.Index? {
    let lStart = min(state.memory?.offset ?? 0, criticalIndex)
    var lIndex = state.criticalIndex
    
    for i in (lStart..<criticalIndex).reversed() {
      searched.formIndex(before: &lIndex)
      
      if pattern[i] != searched[lIndex] {
        searched.formIndex(&state.criticalIndex, offsetBy: period)
        if periodIsExact { state.memory = (pattern.count - period, end) }
        return nil
      }
    }
    
    return searched.index(lIndex, offsetBy: -lStart)
  }
}

// TODO: implement BackwardCollectionSearcher

extension Array {
  func _criticalFactorization(
    _ isOrderedBefore: (Element, Element) -> Bool
  ) -> (index: Int, periodOfSecondPart: Int) {
    let less = _maximalSuffix(isOrderedBefore)
    let greater = _maximalSuffix({ isOrderedBefore($1, $0) })
    return less.index > greater.index ? less : greater
  }
  
  func _maximalSuffix(
    _ isOrderedBefore: (Element, Element) -> Bool
  ) -> (index: Int, periodOfSecondPart: Int) {
    var left = 0
    var right = 1
    var offset = 0
    var period = 1
    
    while right + offset < count {
      let a = self[right + offset]
      let b = self[left + offset]
      
      if isOrderedBefore(a, b) {
        // Suffix is smaller, period is entire prefix so far.
        right += offset + 1
        offset = 0
        period = right - left
      } else if isOrderedBefore(b, a) {
        // Suffix is larger, start over from current location.
        left = right
        right += 1
        offset = 0
        period = 1
      } else {
        // Advance through repetition of the current period.
        offset += 1
        if offset + 1 == period {
          right += offset + 1
          offset = 0
        } else {
          offset += 1
        }
      }
    }
    
    return (left, period)
  }
}
