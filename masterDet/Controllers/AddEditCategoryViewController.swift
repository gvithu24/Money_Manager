//
//  AddEditCategoryViewController.swift
//  masterDet
//
//  Created by Vithushan   on 21/06/2020.
//  Copyright © 2020 Vithushan  . All rights reserved.
//

import UIKit

class AddEditCategotyViewController: UIViewController {

    @IBOutlet weak var moduleTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var markAwardedTextField: UITextField!

    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var levelSegmentControl: UISegmentedControl!
    @IBOutlet weak var addToCalendarToggle: UISwitch!
    @IBOutlet weak var dateSegmentControl: UISegmentedControl!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var addNotesTextField: UITextField!
    @IBOutlet weak var colorSegmentControl: UISegmentedControl!

    var saveFunction: Utilities.saveFunctionType?
    var resetToDefaults: Utilities.resetToDefaultsFunctionType?
    var categoryPlaceholder: Category?
    var isEditView:Bool?
    var categories:[Category]?
    var categoryTable:UITableView?
    weak var delegate: ItemActionDelegate?

    let context = (UIApplication.shared.delegate as!
                    AppDelegate).persistentContainer.viewContext

    let colorsArray = ["Red","Green","Blue","Yellow", "Cyan","Purple"]

    override func viewDidDisappear(_ animated: Bool) {
        isEditView=false
        categoryPlaceholder=nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if (isEditView!) {
            if let category = categoryPlaceholder {
                nameTextField.text = category.name
                budgetTextField.text = "\(category.budget)"
                addNotesTextField.text = category.note
                colorSegmentControl.selectedSegmentIndex = colorsArray.firstIndex(of: category.color ?? "Red") ?? 0
            }
        }
        nameTextField.becomeFirstResponder()
    }

    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true);
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        if nameTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Name of the Category can't be empty", caller: self)
        } else if budgetTextField.text == "" {
            Utilities.showInformationAlert(title: "Error", message: "Budget can't be empty", caller: self)
        } else {
            var newCategory:Category
            if(self.isEditView ?? false){
                newCategory = self.categoryPlaceholder!
            }else{
                newCategory = Category(context: self.context)
                cancelButtonPressed("new")
            }
            newCategory.name = nameTextField.text!
            newCategory.budget = (budgetTextField.text! as NSString).floatValue
            newCategory.note = addNotesTextField.text!
            let color = colorSegmentControl.titleForSegment(at: colorSegmentControl.selectedSegmentIndex)
            newCategory.categoryId = UUID().uuidString
            newCategory.color = color
            newCategory.clickCount = 0

            do {
                try self.context.save()
                categoryTable?.reloadData()
                cancelButtonPressed("working")

            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let reset = resetToDefaults {
            reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
