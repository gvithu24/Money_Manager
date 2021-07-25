//
//  DetailViewController.swift
//  masterDet
//
//  Created by Vithushan on 21/06/2020.
//  Copyright © 2020 Vithushan. All rights reserved.
//

import UIKit

class ExpenseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var budgetAmountLabel: UILabel!
    @IBOutlet weak var spentAmountLabel: UILabel!
    @IBOutlet weak var remainAmountLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var orangeLabel: UILabel!
    @IBOutlet weak var purpleLabel: UILabel!
    @IBOutlet weak var cyanLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var addExpenseBtn: UIBarButtonItem!
    @IBOutlet weak var pieChartViewContainer: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!

    var expenseItem:Category?
    var isEditView:Bool? = false
    var expensePlaceholder:Expense?
    var addEditExpenseController: AddEditExpenseViewController? = nil
    let pieChartView = PieChartView()
    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        categoryNameLabel.text = "\(expenseItem?.name ?? "Select Category")"
        budgetAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"
        spentAmountLabel.text = "£ 0.0"
        remainAmountLabel.text = "£ \(expenseItem?.budget ?? 0.00)"

        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        addcounter()

        expenseTableView.tableFooterView = UIView()

        let padding: CGFloat = 20
        let height = (pieChartViewContainer.frame.height - padding * 3)

        pieChartView.frame = CGRect(
            x: 0, y: padding, width: pieChartViewContainer.frame.size.width, height: height
        )

        pieChartView.segments = [
            LabelledSegment(color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), name: "Red",        value: 0),
            LabelledSegment(color: #colorLiteral(red: 1.0, green: 0.541176471, blue: 0.0, alpha: 1.0), name: "Orange",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), name: "Purple",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.0, green: 0.870588235, blue: 1.0, alpha: 1.0), name: "Light Blue", value: 0),
            LabelledSegment(color: UIColor(red: 0.0, green: 1, blue: 0, alpha: 1.0) , name: "Green", value: 0)
        ]

        pieChartView.segmentLabelFont = .systemFont(ofSize: 10)
        pieChartViewContainer.addSubview(pieChartView)

        if (expenseItem === nil){
            addExpenseBtn.isEnabled = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendCategory" {
            let controller = segue.destination as! AddEditExpenseViewController

            controller.category = self.expenseItem
            controller.expenseTable = self.expenseTableView
            controller.isEditView = self.isEditView
            controller.expensePlaceholder = self.expensePlaceholder
            addEditExpenseController = controller
        }
    }

    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//            self.navigationController?.navigationBar.shouldRemoveShadow(true)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.shouldRemoveShadow(true)
//    }
    
    
    

    func populatePyChart(exps : [Expense], spentAmount : Float){
        resetPieChart()
        let expsR = exps.sorted(by: {$0.amount > $1.amount})
        var other:Float = 0
        var labeltags: [String] = ["None", "None", "None","None","None"]

        for (index, element) in expsR.enumerated() {

            if(index < 4){
                pieChartView.segments[index].value = CGFloat(element.amount/spentAmount*100)
                labeltags[index] = element.title!
            }else{
                other += element.amount
            }
        }

        if other > 0  {
            pieChartView.segments[4].value = CGFloat(other/spentAmount*100)
            labeltags[4] = "Other"
        }

        redLabel.text = labeltags[0]
        orangeLabel.text = labeltags[1]
        purpleLabel.text = labeltags[2]
        cyanLabel.text = labeltags[3]
        greenLabel.text = labeltags[4]
    }

    func addcounter(){
        self.expenseItem?.setValue(self.expenseItem!.clickCount + 1, forKey: "clickCount")
        do {
            try self.context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exps = (self.expenseItem?.expenses?.allObjects) as? [Expense] {
            if exps.count == 0 {
                self.expenseTableView.setEmptyMessage("No expenses added for this category!")
            } else {
                resetPieChart()
                self.expenseTableView.restore()
            }
            return exps.count
        }
        return 0
    }

     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }

    func editAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.expenseItem?.expenses?.allObjects) as? [Expense]

        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.isEditView = true
            //            self.cate.image = UIImage(named: "edit")
            self.expensePlaceholder = expenseList![indexPath.row]

            self.performSegue(withIdentifier: "sendCategory", sender: expenseList![indexPath.row])
            self.isEditView = false
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemBlue
        return action
    }

    func deleteAction (at indexPath: IndexPath) -> UIContextualAction {
        let expenseList = (self.expenseItem?.expenses?.allObjects) as? [Expense]


        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            Utilities.showConfirmationAlert(title: "Are you sure?", message: "Delete expense: ", yesAction: {
                () in
                print("deleted",expenseList![indexPath.row])

//                let context = self.fetchedResultsController.managedObjectContext
//                context.delete(self.fetchedResultsController.object(at: indexPath))

//                self.performSegue(withIdentifier: "showDetail", sender: self)
//
                do {
                    let removingExpense = expenseList![indexPath.row]
                    self.expenseItem?.removeFromExpenses(removingExpense)
                    let context = self.context

                    try context.save()
                    self.expenseTableView.reloadData()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }, caller: self)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.image = action.image?.withTintColor(.white)
        action.backgroundColor = .systemRed
        return action
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expenseTableView.dequeueReusableCell(withIdentifier: "expenseCell") as! ExpenseTableViewCell
        if var e = (self.expenseItem?.expenses?.allObjects) as? [Expense] {
//            e = e.sorted { $0.amount > $1.amount }

            let datapoint = e[indexPath.row]
            cell.titleLbl.text = datapoint.title
            cell.amountLbl.text = "\(datapoint.amount)"
            cell.noteLbl.text = datapoint.notes
//            cell.occurenceLbl.text = "\(datapoint.occurence)"
//            check

            var totalSpent:Float = 0
            for exp in e {
                totalSpent += exp.amount
            }
            spentAmountLabel.text = "£ \(round(Double(totalSpent) * 100)/100.0)"
            remainAmountLabel.text = "£ \(round((expenseItem!.budget - totalSpent) * 100)/100.0)"
            cell.customProgressBar.progress = CGFloat(e[indexPath.row].amount/expenseItem!.budget)
            populatePyChart(exps :e, spentAmount : totalSpent)
        }
        return cell
    }

    func resetPieChart(){
        pieChartView.segments = [
            LabelledSegment(color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), name: "Red",        value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), name: "Orange",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), name: "Purple",     value: 0),
            LabelledSegment(color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), name: "Light Blue", value: 0),
            LabelledSegment(color: UIColor(red: 0.0, green: 1, blue: 0, alpha: 1.0) , name: "Green", value: 0)
            ]
            
            redLabel.text = "None"
            orangeLabel.text =  "None"
            purpleLabel.text = "None"
            cyanLabel.text =  "None"
            greenLabel.text = "None"
            
            
            
        
    }
}

//extension UINavigationBar {
//
//    func shouldRemoveShadow(_ value: Bool) -> Void {
//        if value {
//            self.setValue(true, forKey: "hidesShadow")
//        } else {
//            self.setValue(false, forKey: "hidesShadow")
//        }
//    }
//}

