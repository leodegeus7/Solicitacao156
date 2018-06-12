//
//  MainTabBarController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 05/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()


        
        let firstViewController = SolicitacoesNavigationTableViewController()
       
        let item1 = UITabBarItem(title: "Solicitações", image: UIImage(named: "list-fat-7.png"), selectedImage : UIImage(named: "list-fat-7-full.png"))

        
        item1.badgeColor = Constants.color
        
        firstViewController.tabBarItem = item1
        

        let secondViewController = ContatosNavigationTableViewController()
        
        secondViewController.tabBarItem =  UITabBarItem(title: "Contatos Úteis", image: UIImage(named: "telephone-7.png"),  selectedImage : UIImage(named: "telephone-7-full.png"))
        
        let thirdViewController = DicionarioNavigationTableViewController()
        
        thirdViewController.tabBarItem =  UITabBarItem(title: "Dicionário", image: UIImage(named: "book-cover-7.png"), selectedImage : UIImage(named: "book-cover-7-full.png"))
        
        let fourthViewController = SobreNavigationTableViewController()
        
        fourthViewController.tabBarItem =  UITabBarItem(title: "Sobre", image: UIImage(named: "about.png"), selectedImage : UIImage(named: "about-full.png"))
        
        
        
        
        let tabBarList = [firstViewController,secondViewController,thirdViewController,fourthViewController]
        viewControllers = tabBarList
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
