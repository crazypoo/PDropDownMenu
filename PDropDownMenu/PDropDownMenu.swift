//
//  PDropDownMenu.swift
//  PDropDownMenu
//
//  Created by 邓杰豪 on 2016/9/18.
//  Copyright © 2016年 邓杰豪. All rights reserved.
//

import UIKit

protocol PDropDownMenuDataSource {
    func menu(menu:PDropDownMenu,tableView:UITableView,numberOfRowsInSection:NSInteger)->NSInteger
    func menu(menu:PDropDownMenu,tableView:UITableView,titleForRowAtIndexPath:NSIndexPath)->NSString
}

protocol PDropDownMenuDelegate {
    func menu(menu:PDropDownMenu,tableView:UITableView,didSelectRowAtIndexPath:NSIndexPath)
}

class PDropDownMenu: UIView,UITableViewDelegate,UITableViewDataSource {
    var delegate:PDropDownMenuDelegate?
    var dataSource:PDropDownMenuDataSource?
    var show:Bool?
    var leftTableView:UITableView?
    var rightTableView:UITableView?
    var transformView:UIView?
    var origin:CGPoint?
    var height:CGFloat?
    var backgroundView:UIView?
    var cellIconName:NSString?
    var isOnlyOne:Bool?
    var showIcon:Bool?

    init(origin:CGPoint,height:CGFloat,showIcon:Bool,iconName:NSString) {
        super.init(frame: CGRect.init(x: origin.x, y: origin.y, width: UIScreen.main.bounds.size.width, height: 0))
        self.origin = origin
        self.show = false
        self.height = height
        self.showIcon = showIcon
        self.cellIconName = iconName

        self.leftTableView = UITableView.init(frame: CGRect.init(x: origin.x, y: self.frame.origin.y + self.frame.size.height, width: UIScreen.main.bounds.size.width * 0.4, height: 0), style: .plain)
        self.leftTableView = UITableView.init(frame: CGRect.init(x: origin.x + UIScreen.main.bounds.size.width * 0.4, y: self.frame.origin.y + self.frame.size.height, width: UIScreen.main.bounds.size.width * 0.6, height: 0), style: .plain)

        self.leftTableView?.rowHeight = 38
        self.leftTableView?.separatorStyle = .none
        self.leftTableView?.dataSource = self
        self.leftTableView?.delegate = self
        self.leftTableView?.backgroundColor = UIColor.init(white: 0.9, alpha: 1)

        self.rightTableView?.rowHeight = 38
        self.rightTableView?.separatorStyle = .singleLine
        self.rightTableView?.dataSource = self
        self.rightTableView?.delegate = self
        self.rightTableView?.backgroundColor = UIColor.white

        self.backgroundColor = UIColor.white

        self.backgroundView = UIView.init(frame: CGRect.init(x: origin.x, y: origin.y, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        self.backgroundView?.backgroundColor = UIColor.init(white: 0, alpha: 0)
        backgroundView?.isOpaque = false

        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTapped(ges:)))
        backgroundView?.addGestureRecognizer(gesture)

        let bottomShadow = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height - 0.5, width: UIScreen.main.bounds.size.width, height: 0.5))
        bottomShadow.backgroundColor = UIColor.lightGray
        self.addSubview(bottomShadow)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func menuTapped()
    {
        if !self.show!
        {
            let selectedIndexPath = NSIndexPath.init(row: 0, section: 0)
            self.leftTableView?.selectRow(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: .none)
        }

        animateBackGroundView(view: self.backgroundView!, show: !self.show!) { () in
            animateTableViewShow(show: !self.show!, complete: { () in
                if !self.isOnlyOne!
                {
                    tableView(self.leftTableView!, didSelectRowAt: NSIndexPath.init(row: 0, section: 0) as IndexPath)
                }
                self.show = !self.show!
            })
        }
    }

    func backgroundTapped(ges:UITapGestureRecognizer)
    {
        hideView()
    }

    func hideView()
    {
        animateBackGroundView(view: self.backgroundView!, show: false) { () in
            animateTableViewShow(show: false, complete: { () in
                self.show = false
            })
        }
    }

    func animateBackGroundView(view: UIView, show: Bool, complete: (Void) -> Void) {
        if show
        {
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)

            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
            })
        }
        else
        {
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
                }, completion: { (finish:Bool) in
                    view.removeFromSuperview()
            })
        }
        complete()
    }

    func animateTableViewShow(show: Bool, complete: (Void) -> Void) {
        if self.isOnlyOne!
        {
            if show
            {
                self.leftTableView?.frame = CGRect.init(x: (self.origin?.x)!, y: self.frame.origin.y, width: UIScreen.main.bounds.size.width, height: 0)
                self.superview?.addSubview(self.leftTableView!)
                self.leftTableView?.alpha = 1
                UIView.animate(withDuration: 0.2, animations: { 
                    self.leftTableView?.frame = CGRect.init(x: (self.origin?.x)!, y: self.frame.origin.y, width: UIScreen.main.bounds.size.width, height: self.height!)
                    if self.transformView != nil
                    {
                        self.transformView?.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI))
                    }

                    }, completion: { (finish:Bool) in
                })
            }
            else
            {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.leftTableView?.alpha = 0
                    if self.transformView != nil
                    {
                        self.transformView?.transform = CGAffineTransform.init(rotationAngle: 0)
                    }
                    }, completion: { (finish:Bool) in
                        self.leftTableView?.removeFromSuperview()
                })
                complete()
            }
        }
        else
        {
            if show
            {
                self.leftTableView?.frame = CGRect.init(x: (self.origin?.x)!, y: self.frame.origin.y, width: UIScreen.main.bounds.size.width * 0.4, height: 0)
                self.rightTableView?.frame = CGRect.init(x: (self.origin?.x)! + UIScreen.main.bounds.size.width * 0.4, y: self.frame.origin.y, width: UIScreen.main.bounds.size.width * 0.6, height: 0)

                self.superview?.addSubview(self.leftTableView!)
                self.superview?.addSubview(self.rightTableView!)

                self.leftTableView?.alpha = 1
                self.rightTableView?.alpha = 1
                UIView.animate(withDuration: 0.2, animations: {

                    self.leftTableView?.frame = CGRect.init(x: (self.origin?.x)!, y: self.frame.origin.y, width: UIScreen.main.bounds.size.width * 0.4, height: self.height!)
                    self.rightTableView?.frame = CGRect.init(x: (self.origin?.x)! + UIScreen.main.bounds.size.width * 0.4, y: self.frame.origin.y, width: UIScreen.main.bounds.size.width * 0.6, height: self.height!)

                    if self.transformView != nil
                    {
                        self.transformView?.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI))
                    }

                    }, completion: { (finish:Bool) in
                })
            }
            else
            {
                UIView.animate(withDuration: 0.2, animations: {
                    self.leftTableView?.alpha = 0
                    self.rightTableView?.alpha = 0
                    if self.transformView != nil
                    {
                        self.transformView?.transform = CGAffineTransform.init(rotationAngle: 0)
                    }
                    }, completion: { (finish:Bool) in
                        self.leftTableView?.removeFromSuperview()
                        self.rightTableView?.removeFromSuperview()
                })
            }
            complete()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if dataSource != nil
        {
            return (dataSource?.menu(menu: self, tableView: tableView, numberOfRowsInSection: section))!
        }
        else
        {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DropDownMenuCell")
        if cell != nil
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "DropDownMenuCell")
        }

        if dataSource != nil
        {
            cell?.textLabel?.text = dataSource?.menu(menu: self, tableView: tableView, titleForRowAtIndexPath: indexPath as NSIndexPath) as? String
        }

        if tableView == self.rightTableView
        {
            cell?.backgroundColor = UIColor.white
        }
        else
        {
            let sView = UIView.init()
            sView.backgroundColor = UIColor.white
            cell?.selectedBackgroundView = sView
            cell?.setSelected(true, animated: false)

            if self.showIcon!
            {
                cell?.imageView?.image = UIImage.init(named: self.cellIconName as! String)
            }
            else
            {
                if !self.isOnlyOne!
                {
                    cell?.accessoryType = .disclosureIndicator
                }
            }
        }

        if self.showIcon!
        {
            if tableView == self.leftTableView
            {
                cell?.textLabel?.font = UIFont.init(name: "AppleSDGothicNeo-Regular", size: 10)
            }
        }
        else
        {
            cell?.textLabel?.font = UIFont.init(name: "AppleSDGothicNeo-Regular", size: 14)
        }

        cell?.separatorInset = UIEdgeInsets.zero

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil
        {
            if self.isOnlyOne!
            {
                animateBackGroundView(view: self.backgroundView!, show: false, complete: { () in
                    animateTableViewShow(show: false, complete: { () in
                        self.show = false
                    })
                })
            }
            else
            {
                if tableView == self.leftTableView
                {
                }
                else
                {
                    animateBackGroundView(view: self.backgroundView!, show: false, complete: { () in
                        animateTableViewShow(show: false, complete: { () in
                            self.show = false
                        })
                    })
                }
                delegate?.menu(menu: self, tableView: tableView, didSelectRowAtIndexPath: indexPath as NSIndexPath)
            }
        }
    }
}
