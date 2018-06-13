//
//  ItemListTableViewCell.swift
//  project_2
//
//  Created by 李思瑩 on 2018/5/1.
//  Copyright © 2018年 李思瑩. All rights reserved.
//

import UIKit

class ItemListTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemIdLabel: UILabel!
    @IBOutlet weak var itemEnddateLabel: UILabel!
    @IBOutlet weak var itemCategoryLabel: UILabel!
    @IBOutlet weak var itemGivePresentBtn: UIButton!
    @IBOutlet weak var itemRemaindayLabel: UILabel!
    @IBOutlet weak var itemInstockImageView: UIImageView!
    @IBOutlet weak var itemInstockLabel: UILabel!
    @IBOutlet weak var itemInstockStackView: UIStackView!
    @IBOutlet weak var itemBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupBackgrouncView()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupBackgrouncView() {

        itemBackgroundView.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.8)

        itemBackgroundView.layer.masksToBounds = false

        itemBackgroundView.layer.shadowOffset = CGSize(width: -1, height: 1)

        itemBackgroundView.layer.shadowOpacity = 0.2

    }

    func setupInstockCell(item: ItemList) {

        setupCellInfo(item: item)

        itemInstockStackView.isHidden = false

        itemInstockLabel.text = "x \(item.instock)"

    }

    func setupNotInstockCell(item: ItemList) {

        setupCellInfo(item: item)

        itemInstockStackView.isHidden = true

    }

    private func setupCellInfo(item: ItemList) {

        let remainday = DateHandler.calculateRemainDay(enddate: item.endDate)

        itemNameLabel.text = item.name

        itemIdLabel.text = String(describing: item.itemId)

        itemImageView.sd_setImage(with: URL(string: item.imageURL))

        itemEnddateLabel.text = item.endDate

        itemCategoryLabel.text = "# \(item.category)"

        itemRemaindayLabel.text = "還剩 \(remainday) 天"

    }

}