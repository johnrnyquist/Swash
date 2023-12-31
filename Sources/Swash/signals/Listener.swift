import struct Foundation.TimeInterval

public typealias
    Entity_NoReturn =
    (Entity) -> Void
public typealias
    Entity_ComponentClassName_NoReturn =
    (Entity, ComponentClassName) -> Void
public typealias
    NoArg_NoReturn =
    () -> Void
public typealias
    Node_NoReturn =
    (Node) -> Void
public typealias
    Node_TimeInterval_NoReturn =
    (Node, TimeInterval) -> Void
public typealias
    TimeInterval_NoReturn =
    (TimeInterval) -> Void

/// Acts as a listener to a ``Signaler``.
public class Listener {
    //MARK:- Properties
    var entity_noReturn: Entity_NoReturn?
    var entity_componentClassName_noReturn: Entity_ComponentClassName_NoReturn?
    var noArg_noReturn: NoArg_NoReturn?
    var node_noReturn: Node_NoReturn?
    var node_timeInterval_noReturn: Node_TimeInterval_NoReturn?
    var timeInterval_noReturn: TimeInterval_NoReturn?
    //MARK: - Initializers
    public init(_ fun: @escaping NoArg_NoReturn) {
        noArg_noReturn = fun
    }

    public init(_ fun: @escaping Node_NoReturn) {
        node_noReturn = fun
    }

    public init(_ fun: @escaping Entity_NoReturn) {
        entity_noReturn = fun
    }

    public init(_ fun: @escaping Entity_ComponentClassName_NoReturn) {
        entity_componentClassName_noReturn = fun
    }

    public init(_ fun: @escaping Node_TimeInterval_NoReturn) {
        node_timeInterval_noReturn = fun
    }

    public init(_ fun: @escaping TimeInterval_NoReturn) {
        timeInterval_noReturn = fun
    }
}

extension Listener {
    //MARK:- Call As Function methods
    public func callAsFunction() {
        noArg_noReturn?()
    }

    public func callAsFunction(_ node: Node) {
        node_noReturn?(node)
    }

    public func callAsFunction(_ entity: Entity) {
        entity_noReturn?(entity)
    }

    public func callAsFunction(_ entity: Entity, _ componentClassName: ComponentClassName) {
        entity_componentClassName_noReturn?(entity, componentClassName)
    }

    public func callAsFunction(_ node: Node, _ time: TimeInterval) {
        node_timeInterval_noReturn?(node, time)
    }

    public func callAsFunction(_ time: TimeInterval) {
        timeInterval_noReturn?(time)
    }
}

extension Listener: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Listener: Equatable {
    static public func ==(lhs: Listener, rhs: Listener) -> Bool {
        lhs === rhs
    }
}
