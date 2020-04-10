# BillCalculationEngine

BillCalculationEngine is a Swift package created for the purpose of:
1. Showcase my experience and skills with Swift and general software engineering process for potential new job opportunities.
2. Play with Swift Package Manager, which is a relatively new and native tool for distributing Swift code and managing dependencies with Xcode.
3. Learn and play with GitHub Actions with different workflows.

## Functionalities:
Giving the input of an array of products, an array of taxes and an array of discounts, a bill will be generated with subtotal before tax, total of tax, discounts that has been applied, discounted amount, and total with tax.

### Assumptions used in the implementation:
1. Currency is built into the `Amount` struct, to reenforce that a bill is only calculated for products, taxes and discounts with same currency. I think this is a good precaution for corrupted data. When different currency is detected, corresponding errors/exceptions will be thrown.
2. Tax is calculated based on the subtotal, before any discounts.
3. Each tax has `applicableCategories`, so it will only be applied to products in the corresponding categories. 
4. Discounted amount are calculated after taxes, i.e. discounts are applied to subtotal + tax.
5. Discounts are applied in the same order of how they are passed into the bill calculation method. If any number of discounts at the top of the array, have already brought the total of the bill to 0, then the remaining discount(s) won't be applied, and won't be included in `appliedDiscounts` of the returned `Bill` object. 


## Highlights:
1. This package has unit test with 100% test coverage. Plus, key parts of the logic (such as how discounts are applied to a bill) are tested beyond the sake of test coverage. However, frankly speaking, unit test is truly one of my weak points. So if possible, please feel free to leave me feedbacks.
2. In-code documentation is provided for most of the `public` classes, structs, methods and properties.
3. All models in the package conforms to `Codable`.
4. Protocol-orieneted approach is used in models, such as `Identifiable` and `CaseDefaultCodable`.

## Note:
### Use of Swift Package Manager
I recently learnt about Swift Package Manager. As of early 2020, as for as I know, CocoaPods and Carthage are still most popular for dependency management tool for iOS project. However, Swift Package Manger seems very promising and competitive for the following reasons: 

1. Swift Package Manager has been fully integrated into Xcode, so no extra tool needs to be installed to use it. To me, this could be a potential advantage for CI/CD purpose, because it basically removes an extra dependency, which is the dependency management tool itself.
2. There are several exciting new features that are coming soon to Swift Package Manager, such as [SE-0271](https://github.com/apple/swift-evolution/blob/master/proposals/0271-package-manager-resources.md) and [SE-0272](https://github.com/apple/swift-evolution/blob/master/proposals/0272-swiftpm-binary-dependencies.md). With the community working hard to bring all those useful features to it, I think Swift Package Manager could become mainstream pretty soon.

To me, functionality-wise, a Swift package is very similar to a framework (although technically, it's not): it defines a module, so proper access level needs to be specified for its content; it also packs codes into a modular package, although right now resource files cannot be included in a Swift package, and it cannot have Objective-C code mixed in it. The product of the Swift package after compile is a library, and during my test with my sample app so far, it's statically linked.
