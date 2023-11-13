//
//  ListenerNodePool.swift
//  Swash
//
//  Created by John Nyquist on 11/13/23.
//
final class ListenerNodePool {
    private var tail: ListenerNode?
    private var cacheTail: ListenerNode?

    /// Gets a ListenerNode, it creates one if it does not have one.
    /// - Returns: a ListenerNode
    func get() -> ListenerNode? {
        if tail != nil {
            let node: ListenerNode? = tail
            tail = tail?.previous
            node?.previous = nil
            return node
        } else {
            return ListenerNode()
        }
    }

    /// It removes the node’s lisenter, and puts this node at the tail of the pool so it can be reused.
    /// - Parameter node: A node to be disposed of.
    func dispose(_ node: ListenerNode?) {
        node?.listener = nil
        node?.once = false
        node?.next = nil
        node?.previous = tail
        tail = node
    }

    /// When a Signal is dispatching and it needs to remove a node, it will cache it.
    /// When it is done dispatching, it release the cache.
    /// - Parameter node: The node to be cached.
    func cache(_ node: ListenerNode?) {
        node?.listener = nil
        node?.previous = cacheTail
        cacheTail = node
    }

    /// When a Signal is done dispatching, it will release the cache. 
    func releaseCache() {
        while cacheTail != nil {
            let node = cacheTail
            cacheTail = node?.previous
            node?.next = nil
            node?.previous = tail
            tail = node
        }
    }
}
