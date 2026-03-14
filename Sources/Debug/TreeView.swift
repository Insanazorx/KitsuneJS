public struct TreeBox {
    let label: String
    var children: [TreeBox] = []
}

public func renderTree(_ node: TreeBox) -> String {
    var lines: [String] = [node.label]

    func walk(_ n: TreeBox, _ prefix: String, _ isLast: Bool) {
        let connector = isLast ? "└─ " : "├─ "
        lines.append(prefix + connector + n.label)

        let nextPrefix = prefix + (isLast ? "   " : "│  ")
        for (i, child) in n.children.enumerated() {
            walk(child, nextPrefix, i == n.children.count - 1)
        }
    }

    for (i, child) in node.children.enumerated() {
        walk(child, "", i == node.children.count - 1)
    }

    return lines.joined(separator: "\n")
}

public func box(_ label: String, _ children: [TreeBox] = []) -> TreeBox {
    TreeBox(label: label, children: children)
}

public func boxOpt(_ name: String, _ value: TreeBox?) -> TreeBox {
    box(name, [value ?? box("<nil>")])
}

public func boxList(_ name: String, _ values: [TreeBox]) -> TreeBox {
    box(name, values.isEmpty ? [box("<empty>")] : values)
}

public func boxOptList(_ name: String, _ values: [TreeBox?]) -> TreeBox {
    let rendered = values.map { $0 ?? box("<nil>") }
    return boxList(name, rendered)
}

public func boxListOpt(_ name: String, _ values: [TreeBox]?) -> TreeBox {
    if let values = values {
        return boxList(name, values)
    } else {
        return box(name, [box("<nil>")])
    }
}