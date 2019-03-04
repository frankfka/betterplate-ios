//
//  ViewHelperService.swift
//  Betterplate
//
//  Created by Frank Jia on 2018-12-21.
//  Copyright © 2018 Frank Jia. All rights reserved.
//

import UIKit
import Charts
import SVProgressHUD

class ViewHelperService {
    
    // Shows error with the given message
    static func showErrorHUD(withMessage: String) {
        SVProgressHUD.showError(withStatus: withMessage)
        SVProgressHUD.dismiss(withDelay: 2)
    }
    
    // Allows no-scroll tableviews within a ViewController
    static func updateTableviewSize(tableView: UITableView, tableViewHeightConstraint: NSLayoutConstraint) {
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
    
    // Updates the size of the scrollview so that it fits all the content inside
    static func updateScrollViewSize(scrollView: UIScrollView, minHeight: CGFloat = CGFloat(integerLiteral: 0)) {
        var contentRect = CGRect.zero
        for view in scrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        if minHeight > contentRect.size.height {
            scrollView.contentSize.height = minHeight
        } else {
            scrollView.contentSize = contentRect.size
        }
    }
    
    // Initialize the nutritional pie chart, so that we have uniformity
    // in charts for current meal & individual menu items
    static func initializeNutritionPieChart(for pieChart: PieChartView, percentageProtein: Double, percentageCarbs: Double, percentageFat: Double) {
        
        // Data entries corresponding to the percentages
        let proteinDataEntry = PieChartDataEntry(value: percentageProtein, label: "Protein")
        let carbsDataEntry = PieChartDataEntry(value: percentageCarbs, label: "Carbs")
        let fatDataEntry = PieChartDataEntry(value: percentageFat, label: "Fat")
        
        // Chart setup - define the list of entries
        let chartDataEntries = [proteinDataEntry, carbsDataEntry, fatDataEntry]
        
        // Define data set (just the 3 percentages)
        let chartDataSet = PieChartDataSet(values: chartDataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.material()
        chartDataSet.selectionShift = CGFloat(0)
        
        // Define the chart data
        let chartData = PieChartData(dataSet: chartDataSet)
        // This prevents label values from being squished together
        // We just stop showing values if a food is predominantly carbs/fat/protein
        if((percentageCarbs < 0.1 && percentageFat < 0.1) || (percentageCarbs < 0.1 && percentageProtein < 0.1) || (percentageFat < 0.1 && percentageProtein < 0.1)) {
            chartData.setDrawValues(false)
        }
        let percentFormatter = NumberFormatter() // We want to format with percentages
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 0
        percentFormatter.multiplier = 1
        percentFormatter.percentSymbol = "%"
        chartData.setValueFormatter(DefaultValueFormatter(formatter: percentFormatter))
        chartData.setValueFont(.systemFont(ofSize: 14, weight: .regular))
        chartData.setValueTextColor(.white)
        
        // Legend settings
        let chartLegend = pieChart.legend
        chartLegend.font = .systemFont(ofSize: 14, weight: .regular)
        chartLegend.formSize = CGFloat(integerLiteral: 14)
        chartLegend.wordWrapEnabled = true
        chartLegend.horizontalAlignment = .center
        chartLegend.verticalAlignment = .bottom
        chartLegend.orientation = .horizontal
        
        // Pie Chart Settings
        pieChart.data = chartData
        pieChart.drawEntryLabelsEnabled = false
        pieChart.chartDescription?.enabled = true
        pieChart.holeRadiusPercent = CGFloat(0.2)
        pieChart.entryLabelColor = .white
        pieChart.transparentCircleRadiusPercent = CGFloat(0)
        pieChart.usePercentValuesEnabled = true
        
    }
    
}
