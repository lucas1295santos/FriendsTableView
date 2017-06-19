# FriendsTableView

Friends list built using Xcode 8 and Swift 3, featuring table view, delegates and acessibility options like dynamic type fonts.

## Table View

Will write this section in a few days (promisse!)

## Dynamic Type

First things first, why would i want to use dynamic type fonts?

On the Accessibility menu on the device you have two key options regarding fonts: 
[Larger Text](https://www.imore.com/sites/imore.com/files/styles/xlarge/public/field/image/2016/03/Accessibility-large-text-iPhone-iPad-Screen-02.jpeg?itok=G6S4L5_9)
and [Bold Text](https://www.accessibility.barclays.com/wp-content/uploads/2014/01/iOS_iPhoneiPad_Accessibility_BoldText_1.png).
This options are really important for users with parcial vision loss, and it helps them adjusting all labels fonts on the
system. If your app can adapt with this settings, this users will be greatly benefited. 

For this task we will use this dynamic type fonts, and some auto layout. So, let's get started!


First, let's active the Dynamic Type option for the labels on the Attribute Inspector, and them you can choose a font style
that best fits your purpose on the Font option right above it.

And it's working, just like magic! Now, your text will scale acordingly to Larger Text and Bold Text accessibility options.
So now you can focus our efforts in scaling, and reshaping the containers so the bigger fonts will fit in, and smaller texts
won't create unwanted blank spaces. This autolayout settings change from project to project, depending on what you are building
this project has an example using cells on a tableview.

One small detail that is worth mentioning is how to resize the table cell height automatically.
On the viewDidLoad method, i added this two lines to prepare the table view to calculate the cell height.

`tableView.rowHeight = UITableViewAutomaticDimension`

`tableView.estimatedRowHeight = 50`

