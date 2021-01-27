/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSTitleView: UIView {
    public weak var viewController: NSTitleViewScrollViewController?

    public func updateConstraintsForAnimation() {}

    public func startInitialAnimation() {}

    @objc public func scrollViewDidScroll(_: UIScrollView) {}
}

class NSTitleViewScrollViewController: NSViewController {
    // MARK: - Views

    public let stackScrollView = NSStackScrollView()

    public var titleView: NSTitleView? {
        didSet { titleView?.viewController = self }
    }

    private let spacerView = UIView()

    public var titleHeight: CGFloat {
        return 153
    }

    public var useTitleViewHeight: Bool = false

    public var startPositionScrollView: CGFloat {
        return 118
    }

    public var useFullScreenHeaderAnimation: Bool {
        return false
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupLogic()
    }

    // MARK: - Logic

    private func setupLogic() {
        stackScrollView.scrollView.delegate = self
    }

    // MARK: - API

    public func startHeaderAnimation() {
        guard let tv = titleView else { return }

        updateClosedConstraints()
        tv.updateConstraintsForAnimation()

        UIView.animate(withDuration: 0.55, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            tv.startInitialAnimation()
        }, completion: nil)
    }

    // MARK: - Setup

    private func setupLayout() {
        guard let tv = titleView else { return }

        view.addSubview(tv)

        tv.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()

            if !useFullScreenHeaderAnimation {
                if self.useTitleViewHeight {
                    make.height.equalTo(tv)
                } else {
                    make.height.equalTo(self.titleHeight)
                }
            } else {
                make.height.equalToSuperview()
            }
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.addArrangedView(spacerView)

        spacerView.snp.makeConstraints { make in
            make.height.equalTo(self.view)
        }

        if !useFullScreenHeaderAnimation {
            updateClosedConstraints()
            tv.updateConstraintsForAnimation()
            tv.startInitialAnimation()
        }
    }

    func updateClosedConstraints() {
        guard let tv = titleView else { return }

        tv.snp.remakeConstraints { make in
            make.left.right.top.equalToSuperview()
            if self.useTitleViewHeight {
                make.height.equalTo(tv)
            } else {
                make.height.equalTo(self.titleHeight)
            }
        }

        spacerView.snp.remakeConstraints { make in
            if self.useTitleViewHeight {
                make.height.equalTo(tv).inset(NSPadding.medium)
            } else {
                make.height.equalTo(self.startPositionScrollView)
            }
        }
    }
}

extension NSTitleViewScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleHeight: CGFloat
        if useTitleViewHeight {
            titleHeight = titleView?.frame.height ?? startPositionScrollView
        } else {
            titleHeight = startPositionScrollView
        }

        let coveringScreenPercentage = (titleHeight - scrollView.contentOffset.y) / scrollView.frame.height

        let threshold = min(titleHeight / scrollView.frame.height, 0.5)

        let maxYLinearOffset = max((titleHeight / scrollView.frame.height) * scrollView.frame.height - scrollView.frame.height / 2, 0)

        var yOffset: CGFloat = min(scrollView.contentOffset.y, maxYLinearOffset)

        if scrollView.contentOffset.y > maxYLinearOffset {
            yOffset += max((scrollView.contentOffset.y - yOffset) * 0.4, 0)
        }

        titleView?.transform = CGAffineTransform(translationX: 0, y: -max(yOffset, 0))

        let alpha = max(0.0, min(1.0, coveringScreenPercentage / threshold))

        titleView?.alpha = pow(alpha, 0.8)

        titleView?.scrollViewDidScroll(scrollView)
    }
}
