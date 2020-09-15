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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?
    private var lastForegroundActivity: Date?

    @UBUserDefault(key: "isFirstLaunch", defaultValue: true)
    var isFirstLaunch: Bool

    var tabBarController: NSTabBarController? {
        window?.rootViewController as? NSTabBarController
    }

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Pre-populate isFirstLaunch for users which already installed the app before we introduced this flag
        if UserStorage.shared.hasCompletedOnboarding {
            isFirstLaunch = false
        }

        // Reset keychain on first launch
        if isFirstLaunch {
            Keychain().deleteAll()
            isFirstLaunch = false
        }

        // setup sdk
        TracingManager.shared.initialize()

        // defer window initialization if app was launched in
        // background because of location change
        if shouldSetupWindow(application: application, launchOptions: launchOptions) {
            TracingLocalPush.shared.resetBackgroundTaskWarningTriggers()
            setupWindow()
            willAppearAfterColdstart(application, coldStart: true, backgroundTime: 0)
        }

        return true
    }

    private func shouldSetupWindow(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if application.applicationState == .background {
            return false
        }

        guard let launchOptions = launchOptions else {
            return true
        }

        let backgroundOnlyKeys: [UIApplication.LaunchOptionsKey] = [.location]

        for k in backgroundOnlyKeys {
            if launchOptions.keys.contains(k) {
                return false
            }
        }

        return true
    }

    private func setupWindow() {
        KeychainMigration.migrate()

        window = UIWindow(frame: UIScreen.main.bounds)

        TracingManager.shared.beginUpdatesAndTracing()

        window?.makeKey()
        window?.rootViewController = NSTabBarController()

        setupAppearance()

        window?.makeKeyAndVisible()

        if !UserStorage.shared.hasCompletedOnboarding {
            let onboardingViewController = NSOnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(onboardingViewController, animated: false)
        }
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Start sync after app became active
        TracingManager.shared.updateStatus(shouldSync: true, completion: nil)
    }

    private func willAppearAfterColdstart(_: UIApplication, coldStart: Bool, backgroundTime: TimeInterval) {
        // Logic for coldstart / background

        // if app is cold-started or comes from background > 30 minutes,
        if coldStart || backgroundTime > 30.0 * 60.0 {
            if !jumpToMessageIfRequired(onlyFirst: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    _ = self.jumpToMessageIfRequired(onlyFirst: true)
                }
            }
            NSSynchronizationPersistence.shared?.removeLogsBefore14Days()

            // if app was longer than 1h in background make sure to select homescreen in tabbar
            if backgroundTime > 60.0 * 60.0 {
                tabBarController?.currentTab = .homescreen
            }
        } else {
            _ = jumpToMessageIfRequired(onlyFirst: false)
        }

        startForceUpdateCheck()

        FakePublishManager.shared.runTask()

        NSSynchronizationPersistence.shared?.appendLog(eventType: .open, date: Date(), payload: nil)
    }

    func jumpToMessageIfRequired(onlyFirst: Bool) -> Bool {
        let shouldJump: Bool
        if onlyFirst {
            shouldJump = UIStateManager.shared.uiState.shouldStartAtReportsDetail
        } else {
            shouldJump = UIStateManager.shared.uiState.shouldStartAtReportsDetail && UIStateManager.shared.uiState.reportsDetail.showReportWithAnimation
        }
        if shouldJump,
            let tabBarController = tabBarController {
            tabBarController.currentTab = .homescreen

            let navigationController = tabBarController.currentNavigationController

            // no need to present NSReportsDetailViewController if its already showing
            if let homescreenVC = tabBarController.currentViewController as? NSHomescreenViewController,
                !(navigationController.viewControllers.last is NSReportsDetailViewController) {
                navigationController.popToRootViewController(animated: false)
                homescreenVC.presentReportsDetail(animated: false)
            }
            return true
        } else {
            return false
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        lastForegroundActivity = Date()

        // App should not have badges
        // Reset to 0 to ensure a unexpected badge doesn't stay forever
        application.applicationIconBadgeNumber = 0
        TracingLocalPush.shared.clearNotifications()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // If window was not initialized (e.g. app was started cause
        // by a location change), we need to do that
        if window == nil {
            setupWindow()
            willAppearAfterColdstart(application, coldStart: true, backgroundTime: 0)

        } else {
            let backgroundTime = -(lastForegroundActivity?.timeIntervalSinceNow ?? 0)
            willAppearAfterColdstart(application, coldStart: false, backgroundTime: backgroundTime)
            application.applicationIconBadgeNumber = 0
            TracingLocalPush.shared.clearNotifications()
        }
    }

    // MARK: - Force update

    private func startForceUpdateCheck() {
        ConfigManager().startConfigRequest(window: window)
    }

    // MARK: - Appearance

    private func setupAppearance() {
        UIBarButtonItem.appearance().tintColor = .ns_text

        UINavigationBar.appearance().titleTextAttributes = [
            .font: NSLabelType.textBold.font,
            .foregroundColor: UIColor.ns_text,
        ]

        UITabBarItem.appearance().setTitleTextAttributes([
            .font: NSLabelType.smallBold.font,
            .foregroundColor: UIColor.ns_text,
        ], for: .normal)

        UITabBarItem.appearance().setTitleTextAttributes([
            .font: NSLabelType.smallBold.font,
            .foregroundColor: UIColor.ns_blue,
        ], for: .selected)
    }
}
