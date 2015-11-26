//
//  ViewController.swift
//  MemeMe v1.0
//
//  Created by Kevin Lu on 5/09/2015.
//  Copyright (c) 2015 Kevin Lu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickAnImageFromAlbum: UIBarButtonItem!
    @IBOutlet weak var pickAnImageFromCamera: UIBarButtonItem!
    @IBOutlet weak var cancelMemeButton: UIBarButtonItem!
    @IBOutlet weak var shareMemeButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    var lastTouchBottomTextField: Bool!
    var lastTouchTopTextField: Bool!
    
// MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Declaring the dictionary attributes for the Meme text
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        topTextField.textAlignment = NSTextAlignment.Center
        topTextField.delegate = self
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.delegate = self
    }


    override func viewWillAppear(animated: Bool) {
        
        // Checking if there is an image
        if (imageView.image == nil) {
             shareMemeButton.enabled = false
        }
        else {
            shareMemeButton.enabled = true
        }
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        self.view.addGestureRecognizer(tapView)
        lastTouchBottomTextField = false
        lastTouchTopTextField = false
        
        // Seeing whether or not to disable the camera button
        pickAnImageFromCamera.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        pickAnImageFromAlbum.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)
        
        self.subscribeToKeyboardWillShowNotifications()
        self.subscribeToKeyboardWillHideNotifications()
    }
    
    
    // Unsubscribe from the notifications
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardWillShowNotifications()
        self.unsubscribeFromKeyboardHideShowNotifications()
    }
    
    // This is what is called when the user taps the text field as the system automatically brings up the keyboard view
    func subscribeToKeyboardWillShowNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardWillHideNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func unsubscribeFromKeyboardHideShowNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    
    
    func unsubscribeFromKeyboardWillShowNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    

// MARK: Button methods
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        // Accessing the ImagePickerController
        let imagePicker = UIImagePickerController()
        // Delegates the act of getting the photos to UIImagePickerControllerDelegate, UINavigationControllerDelegate which is why these protocols are added in the class declaration
        imagePicker.delegate = self
        // Note that this sets the controller's sourceType variable to PhotoLibrary there are other things that it can be set to e.g. Camera
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelMemeButton (sender: AnyObject) {
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    @IBAction func shareMemeButton (sender: AnyObject) {
        let meme : UIImage = generateMemedImage()
        let activityVC : UIActivityViewController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
// MARK: Keyboard movement
    // this is what gets called when the user taps the view
    func keyboardHide() {
        // endEditing iterates through the subviews of our view and dismisses the keyboard which is a subview?
        view.endEditing(true)
    } 
    


    // then this will get called as subscribeToKeyboardWillHideNotifications is called when the keyboard disappears
    func keyboardWillHide(notification: NSNotification) {
        if (topTextField.isFirstResponder() && lastTouchBottomTextField == true) {
            // need to move the screen down as touching the bottomTextField moves the screen up
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
        else if (topTextField.isFirstResponder() && lastTouchBottomTextField == false) {
            // do nothing as the screen as touched view first then touched topTextField
        }
        else if (bottomTextField.isFirstResponder() && lastTouchTopTextField == false){
            // need to move the screen down as we move the screen up when touching bottomTextField
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
        else if (bottomTextField.isFirstResponder() && lastTouchTopTextField == true) {
            // do nothing as if the last touched thing was topTextField then the screen would have already moved so don't need to move it up again
            
        }
        lastTouchBottomTextField = false
        lastTouchTopTextField = false
    }
    
    

    // This is called when the user touches one of the textFields
    func keyboardWillShow(notification: NSNotification) {
        if(topTextField.isFirstResponder()) {
            lastTouchTopTextField = true
        }
        else if (bottomTextField.isFirstResponder() && lastTouchTopTextField == false) {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            lastTouchBottomTextField = true
        }
        else if (bottomTextField.isFirstResponder() && lastTouchTopTextField == true) {
            lastTouchTopTextField = false
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
// MARK: Saving Meme
    func saveMeme() -> Meme {
        let meme = Meme(topTextFieldString: topTextField.text!, bottomTextFieldString: bottomTextField.text!, originalImage: imageView.image!, memeImage: generateMemedImage())
        let savedMeme : UIImage = meme.memeImage
        UIImageWriteToSavedPhotosAlbum(savedMeme, nil, nil, nil)
        return meme

    }
    func generateMemedImage() -> UIImage {
        let newImageViewOriginAndDimension = self.view.frame
        let originalImageViewOriginAndDimension = imageView.frame
        // Rescaling imageView first to avoid showing self.view
        rescaleImageView(newImageViewOriginAndDimension)
        hideBars()
        let memedImage = screenShot()
        rescaleImageView(originalImageViewOriginAndDimension)
        showBars()
        return memedImage
        
    }
    func hideBars() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    func rescaleImageView(originAndDimension : CGRect) {
        imageView.frame = originAndDimension
        print(imageView.frame)
    }
    func screenShot() -> UIImage{
        // Pushes the size of the view onto the stack
        UIGraphicsBeginImageContext(self.view.frame.size)
        // Essentially takes a screenshot of the area of view.frame
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Cropping the image so that self.view won't show
        let cropRect = CGRectMake(0, 30, memedImage.size.width, memedImage.size.height)
        let newMemedImageCGI = CGImageCreateWithImageInRect(memedImage.CGImage, cropRect)
        let newMemedImage = UIImage(CGImage: newMemedImageCGI!)
        return newMemedImage
    }
    func showBars() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
// MARK: Protocols for UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text != "TOP" && textField.text != "BOTTOM") {
            // do nothing
        }
        else {
            textField.text = ""
        }
    }
    func textFieldDidEndEditing(textField: UITextField) {
        
        if (textField.text == "") {
            if (textField == topTextField) {
                textField.text = "TOP"
            }
            else if (textField == bottomTextField) {
                textField.text = "BOTTOM"
            }
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        keyboardHide()
        return false
    }
// MARK: Protocols for UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

