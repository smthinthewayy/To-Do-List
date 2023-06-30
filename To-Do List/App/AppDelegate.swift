//
//  AppDelegate.swift
//  To-Do List
//
//  Created by Danila Belyi on 11.06.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  )
    -> Bool {
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions
  )
    -> UISceneConfiguration {
    return UISceneConfiguration(
      name: "Default Configuration",
      sessionRole: connectingSceneSession.role
    )
  }

  func application(
    _: UIApplication,
    didDiscardSceneSessions _: Set<UISceneSession>
  ) {}
}
