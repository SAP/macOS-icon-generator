/*
    MTImagePlayground.swift
    Copyright 2016-2026 SAP SE

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

import AppKit
import ImagePlayground

@available(macOS 15.1, *)
@objc public protocol ImageGenerationViewControllerDelegate: AnyObject {
    @objc optional func imagePlaygroundViewController(_ controller: ImagePlaygroundViewController, didCreateImageAt imageURL: URL)
    @objc optional func imagePlaygroundViewControllerDidCancel(_ controller: ImagePlaygroundViewController)
}

@MainActor
@available(macOS 15.1, *)
@objc public class MTImagePlayground: NSObject {

    @objc public weak var delegate: (any ImageGenerationViewControllerDelegate)?
    
    @objc public func show(withPresenter presenter: NSViewController)
    {
        let playground = ImagePlaygroundViewController()
        playground.delegate = self
        presenter.presentAsSheet(playground)
    }
}

@available(macOS 15.1, *)
extension MTImagePlayground: ImagePlaygroundViewController.Delegate
{
    public func imagePlaygroundViewController(_ controller: ImagePlaygroundViewController, didCreateImageAt imageURL: URL)
    {
        controller.dismiss(self)
        delegate?.imagePlaygroundViewController?(controller, didCreateImageAt: imageURL)
    }

    public func imagePlaygroundViewControllerDidCancel(_ controller: ImagePlaygroundViewController)
    {
        controller.dismiss(self)
        delegate?.imagePlaygroundViewControllerDidCancel?(controller)
    }
}

