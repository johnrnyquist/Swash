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
        if let listenerNode = tail {
            tail = tail?.previous
            listenerNode.previous = nil
            return listenerNode
        } else {
            return ListenerNode()
        }
    }

    /// It removes the node’s lisenter, and puts this node at the tail of the pool so it can be reused.
    /// - Parameter node: A node to be disposed of.
    func dispose(_ listenerNode: ListenerNode?) {
        listenerNode?.listener = nil
        listenerNode?.once = false
        listenerNode?.next = nil
        listenerNode?.previous = tail
        tail = listenerNode
    }

    /// When a Signal is dispatching and it needs to remove a node, it will cache it.
    /// When it is done dispatching, it release the cache.
    /// - Parameter node: The node to be cached.
    func cache(_ listenerNode: ListenerNode?) {
        listenerNode?.listener = nil
        listenerNode?.previous = cacheTail
        cacheTail = listenerNode
    }

    /// When a Signal is done dispatching, it will release the cache. 
    func releaseCache() {
        while let listenerNode = cacheTail {
            cacheTail = listenerNode.previous
            listenerNode.next = nil
            listenerNode.previous = tail
            tail = listenerNode
        }
    }
}
