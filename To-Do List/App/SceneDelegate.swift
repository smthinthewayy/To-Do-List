//
//  SceneDelegate.swift
//  To-Do List
//
//  Created by Danila Belyi on 11.06.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo _: UISceneSession,
    options _: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    let taskListVC = TaskListVC()
    let navigationController = UINavigationController(rootViewController: taskListVC)
    window.rootViewController = navigationController
    window.makeKeyAndVisible()

    self.window = window
  }

  func sceneDidDisconnect(_: UIScene) {}

  func sceneDidBecomeActive(_: UIScene) {}

  func sceneWillResignActive(_: UIScene) {}

  func sceneWillEnterForeground(_: UIScene) {}

  func sceneDidEnterBackground(_: UIScene) {}
}
