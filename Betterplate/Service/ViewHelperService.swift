//
//  ViewHelperService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-21.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit

class ViewHelperService {
    
    func updateTableviewSize(tableView: UITableView, tableViewHeightConstraint: NSLayoutConstraint) {
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableViewHeightConstraint.constant = 1000
        UIView.animate(withDuration: 0, animations: {
            tableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            // Get visible cells and sum up their heights
            let cells = tableView.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
            }
            tableViewHeightConstraint.constant = heightOfTableView
        }
    }
    
    func updateScrollviewSize(scrollView: UIScrollView) {
        var contentRect = CGRect.zero
        for view in scrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        scrollView.contentSize = contentRect.size
    }
    
}
