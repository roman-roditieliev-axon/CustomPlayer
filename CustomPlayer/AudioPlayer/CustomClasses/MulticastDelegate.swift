//
//  MulticastDelegate.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import Foundation

class MulticastDelegate<T> {
    private class DelegateWrapper {
        weak var delegate: AnyObject?
        init(_ delegate: AnyObject) {
            self.delegate = delegate
        }
    }

    private var delegateWrappers: [DelegateWrapper] = []
    var delegates: [T] {
        delegateWrappers = delegateWrappers.filter { $0.delegate != nil }
        return delegateWrappers.map { $0.delegate! } as? [T] ?? []
    }

    func addDelegate(_ delegate: T) {
        let wrapper = DelegateWrapper(delegate as AnyObject)
        delegateWrappers.append(wrapper)
    }

    func removeDelegate(_ delegateToRemove: T) {
        guard let index = delegateWrappers.firstIndex(where: { $0.delegate === (delegateToRemove as AnyObject) }) else { return }
        delegateWrappers.remove(at: index)
    }

    func invokeDelegates(_ closure: (T) -> Void) {
        delegates.forEach { closure($0) }
    }
}
