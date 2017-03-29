//
//  TodayViewController.swift
//  BTC Widget
//
//  Created by Dmitry Roytman on 29.03.17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit
import NotificationCenter
import CryptoCurrencyKit

class TodayViewController: CurrencyDataViewController, NCWidgetProviding {
    
    @IBOutlet weak var vibrancyView: UIVisualEffectView!
    @IBOutlet weak var priceSelectionVibrancyView: UIVisualEffectView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        vibrancyView.effect = UIVibrancyEffect.widgetPrimary()
        priceSelectionVibrancyView.effect = UIVibrancyEffect.widgetSecondary()
        
        lineChartView.delegate = self
        lineChartView.dataSource = self
        
        priceLabel.text = "--"
        priceChangeLabel.text = "--"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPrices { [weak self] error in
            guard error == nil, let sself = self else { return }
            sself.updatePriceLabel()
            sself.updatePriceChangeLabel()
            sself.updatePriceHistoryLineChart()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePriceHistoryLineChart()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        fetchPrices { [weak self] error in
            guard error == nil, let sself = self else {
                completionHandler(.failed)
                return
            }
            sself.updatePriceLabel()
            sself.updatePriceChangeLabel()
            sself.updatePriceHistoryLineChart()
            
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200) : maxSize
        toggleLineChart()
    }
    
    override func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return lineChartView.tintColor
    }
    
    override func lineChartView(_ lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return extensionContext!.widgetActiveDisplayMode == .expanded ? 4 : 2
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAt lineIndex: UInt, horizontalIndex: UInt) {
        guard let prices = prices else { return }
        let price = prices[Int(horizontalIndex)]
        updatePriceOnDayLabel(price)
    }
    
    func didUnselectLine(in lineChartView: JBLineChartView!) {
        priceOnDayLabel.text = ""
    }
    
    private func toggleLineChart() {
        let expanded = extensionContext?.widgetActiveDisplayMode == .expanded
        priceOnDayLabel.isHidden = !expanded
        priceOnDayLabel.text = ""
    }
}
