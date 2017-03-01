//
//  KBTextField.swift
//  TURNSTR
//
//  Created by Apple on 21/02/16.
//  Copyright © 2016 Neophyte. All rights reserved.
//

import UIKit

enum KBTextFiledTypeOf{
    case required
    case optional
}

enum KBTextFiledValidations : NSInteger{
    case none = 0
    case email = 1
}

@IBDesignable

class KBTextField: UITextField {
    
    var isValidFor : KBTextFiledValidations = .none{
        didSet{
            if isValidFor != .none{
                NotificationCenter.default.addObserver(self, selector: #selector(KBTextField.textFieldEndEditing(_:)), name: NSNotification.Name.UITextFieldTextDidEndEditing, object:self)
                
                NotificationCenter.default.addObserver(self, selector: #selector(KBTextField.textFieldBeginEditing(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object:self)
            }
        }
    }
    
    var showCopyPasteOptions = true
    @IBInspectable var enableCopypasteOptions : Bool = false{
        didSet{
            showCopyPasteOptions = enableCopypasteOptions
        }
    }
    
    var textFieldIsTypeOf = false
    @IBInspectable var isRequired : Bool = false{
        didSet{
            textFieldIsTypeOf = isRequired
        }
    }
    
    @IBInspectable var padding : CGFloat = 0.0
    @IBInspectable var borderColor  : UIColor?{
       
        didSet{
            layer.borderColor = borderColor?.cgColor;
        }
    }
    @IBInspectable var borderWidth  : CGFloat = 1.0{
        didSet{
            layer.borderWidth = borderWidth;
        }
    }
    @IBInspectable var cornerRadius : CGFloat = 1.0{
        didSet{
            layer.cornerRadius = cornerRadius;
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var placeholderTextColor : UIColor? = UIColor.white{
        didSet{
            let color: UIColor = placeholderTextColor != nil ? placeholderTextColor! : UIColor.clear
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName : color]);
            tintColor = placeholderTextColor
        }
    }
    @IBInspectable var image : UIImage? = UIImage(named: "username"){
        didSet{
            leftViewMode = .always
            let imageView : UIImageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 10.0, y: 0.0, width: 30.0, height: 30.0)
            imageView.contentMode = .center
            leftView = imageView
        }
    }
    
    override public var placeholder: String?{
        didSet{
            let color: UIColor = placeholderTextColor != nil ? placeholderTextColor! : UIColor.clear
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName : color]);
            tintColor = placeholderTextColor
        }
    }
    
//    var textFieldIsTypeOf = false
    @IBInspectable var placeholderPreviewEnable : Bool = false{
        didSet{
            self.addSubView(placeholderPreview)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        return textRect(forBounds: bounds)
    }
    
    //MARK Check assigned validations
    func checkAssignedValidations(_ superView: UIView) -> Bool{
        
        for index in superView.subviews.enumerated(){
            if (index.element.isKind(of: KBTextField.self)){
                let txf = index.element as! KBTextField
                if (txf.isRequired){
                    if (txf.text?.characters.count == 0){
                        self.emptyFileds(txf)
                        return false
                    }
                }
                if (txf.isValidFor == KBTextFiledValidations.email){
                    if !self.emailFormat(txf: txf){
                        self.shakeField(txf)
                        return false
                    }
                }
            }
        }
        return true
    }
    internal override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        if !showCopyPasteOptions{
            
            if action == #selector(self.paste)
            {
                
            }
        }
        return super.target(forAction: action, withSender: sender)
    }
    
    //MARK Custom Methods
    func emptyFileds(_ txf: KBTextField){
        
        let placeholder = txf.placeholder
        print(placeholder! + " cannot be empty")
        shakeField(txf)
    }
    
    func shakeField(_ txf: KBTextField){
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: txf.center.x - 5, y: txf.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: txf.center.x + 5, y: txf.center.y))
        txf.layer.add(animation, forKey: "position")
    }
    
    func placeholderPreview() -> UILabel{
        let lbl = UILabel(frame: self.bounds)
        lbl.text = self.placeholder
        return lbl
    }
    
//  class  func shakeFieldMS(_ txf: KBTextField){
//        let animation = CABasicAnimation(keyPath: "position")
//        animation.duration = 0.05
//        animation.repeatCount = 5
//        animation.autoreverses = true
//        animation.fromValue = NSValue(cgPoint: CGPoint(x: txf.center.x - 5, y: txf.center.y))
//        animation.toValue = NSValue(cgPoint: CGPoint(x: txf.center.x + 5, y: txf.center.y))
//        txf.layer.add(animation, forKey: "position")
//    }


    @objc func textFieldEndEditing(_ notification: Notification){
        
        if self.isEqual(notification.object){
            switch (self.isValidFor){
            case .email : _ = emailFormat(txf: self)
                
            default : break
            }
        }
    }
    
    @objc func textFieldBeginEditing(_ notification: Notification){
        
        if self.isEqual(notification.object){
            switch (self.isValidFor){
            case .email : self.emailInput(self)
                
            default : break
            }
        }
    }
    
    func emailInput(_ txf: KBTextField){
        txf.keyboardType = .emailAddress
    }
    
    func emailFormat(txf: UITextField) -> Bool{
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = txf.text!.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    //MARK UITextFieldDelegate Methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
    
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
    
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return true
    }
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
