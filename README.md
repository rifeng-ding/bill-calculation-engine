# BillCalculationEngine

BillCalculationEngine is a Swift package created for the iOS Developer Challenge IV from TouchBistro. The accept criteria of its functionality can be found [here](https://docs.google.com/document/d/1Fu6OEUmapG62yyZSBPNmaVmB9wkapibBJJvlF3UzmpI/edit#heading=h.6aqeshkn0n0n).

## Note:
I am full aware that in the challenge requirement, it asks to use Carthage for dependency management. However, I decided to Swift Package Manger for this project for two main reasons: 

1. Swift Package Manager has been fully integrated into Xcode, so no extra tool needs to be installed to use it (I assume at least part of the reason that Carthage is specified is because it would add extra complexity if any other 3rd part dependency management tool is used).
2. I recently learnt about Swift Package Manager, and there are several exciting new features coming soon, such as [SE-0271](https://github.com/apple/swift-evolution/blob/master/proposals/0271-package-manager-resources.md) and [SE-0272](https://github.com/apple/swift-evolution/blob/master/proposals/0272-swiftpm-binary-dependencies.md). So I think it may become mainstream soon and this is a perfect opportunity to try it out.

I am also aware that the challenge asks to "create a Swift iOS Framework". Technically, Swift package is not a "framework", but functionality-wise, I think it's very similar to a framework: it defines a module, so proper access level needs to be specified for its content; it also packs codes into a modular package, although right now resource files cannot be included in a Swift package, and it cannot have Object-C code mixed in it. The product of the Swift package after compile is a library, and for this project, it's statically linked to the app.

## Highlights:
1. This package has unit test with 100% test coverage. Plus, key parts of the logic are tested beyond the concern of test coverage. However, frankly speaking, unit test is truly one of my weak points. So if possible, please give me some feedbacks about this part, even if I don't pass the challenge/interview.
2. In-code documentation is provided for most of the `public` classes, structs, methods and properties.
3. All models in the package conforms to `Codable` (and they are actually used in the app as `Codable`).


## Assumptions used in the implementation:
1. Tax is calculated based on the subtotal, before any discounts.
2. Discounted amount are calculated after taxes, i.e. discounts are applied to subtotal + tax.
3. Discounts are applied in the same order of how they are passed into the bill calculation method. If any number of discounts at the top of the array, have already brought the total of the bill to 0, then the remaining discount(s) won't be applied, and won't be included in `appliedDiscounts` of the returned `Bill` object. 
4. Currency is built into the `Amount` struct, to reenforce bill is only calculated for products, taxes and discount with same currency. When different currency is detected, correponding errors/exceptions will be thrown.
