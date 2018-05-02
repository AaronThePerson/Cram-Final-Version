//
//  ChatLogViewController.swift
//  Cram Final Version
//
//  Created by Aaron Speakman on 4/26/18.
//  Copyright © 2018 Aaron Speakman. All rights reserved.
//
// A modified implementation of MessagesViewController from MessageKit
//

import UIKit
import MessageKit
import MapKit
import Firebase

class ChatLogViewController: MessagesViewController {
    
    @IBOutlet weak var chatTitle: UINavigationItem!
    var selectedGroup: Group?
    
    let ref = Database.database().reference(fromURL: "https://cram-capstone.firebaseio.com/")
    
    //let refreshControl = UIRefreshControl()
    var isTyping = false
    var messages: [Message] = []
    var setCurrentSender: Sender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self as? MessagesDataSource
        messagesCollectionView.messagesLayoutDelegate = self as? MessagesLayoutDelegate
        messagesCollectionView.messagesDisplayDelegate = self as? MessagesDisplayDelegate
        messagesCollectionView.messageCellDelegate = self as? MessageCellDelegate
        messageInputBar.delegate = self as? MessageInputBarDelegate
        
        self.iMessage()
        chatTitle.title = selectedGroup?.groupName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let num: Int = (selectedGroup?.members?.count)!
        for i in 0..<num{
            if selectedGroup?.members?[i].uid == Auth.auth().currentUser?.uid{
                setCurrentSender = Sender(id: (selectedGroup?.members?[i].uid)!, displayName: (selectedGroup?.members?[i].username)!)
                break
            }
        }
        getMessages()
    }
    
    func handleSend(sender: Sender, text: String){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let timestamp = dateFormatter.string(from: Date())
        
        let dict: [String: Any] = ["senderName": sender.displayName, "senderId": sender.id, "timestamp": timestamp, "messageData": text]
        print(dict)
        
        //ref.child("chats").child(selectedGroup?.groupID).child("messages").childByAutoId().setValuesForKeys(dict)
    }
    
    func sendMessage(text: String){
        let messageLocation = ref.child("chats").child((selectedGroup?.groupID)!).child("messages").childByAutoId()
        let messageToSend = Message(text: text, sender: currentSender(), messageId: messageLocation.key, date: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let timestamp = dateFormatter.string(from: messageToSend.sentDate)
        
        let messageValues = ["senderName": messageToSend.sender.displayName, "senderID": messageToSend.sender.id, "timestamp": timestamp, "text": text] as [String : Any]
        let groupValue = ["timestamp": timestamp, "lastMessage": text]
        
        messageLocation.setValue(messageValues)
        ref.child("groups").child((selectedGroup?.groupID)!).updateChildValues(groupValue)
    }
    
    func getMessages(){
        let queryMessages = ref.child("chats").child((selectedGroup?.groupID)!).child("messages").queryLimited(toLast: 50)
        
        queryMessages.observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
                let messageID = snapshot.key
                let senderID = dictionary["senderID"] as! String
                let senderName = dictionary["senderName"] as! String
                let text = dictionary["text"] as! String
                let timestamp = dictionary["timestamp"] as! String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: timestamp)
                
                let message = Message(text: text, sender: Sender(id: senderID, displayName: senderName), messageId: messageID, date: date!)
                
                self.messages.append(message)
                self.messagesCollectionView.insertSections([self.messages.count - 1])
            }
            
        }
        
    }
    
    func iMessage() {
        defaultStyle()
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(red: 63/255, green: 183/255, blue: 216/255, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: true)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "send icon")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.sendButton.backgroundColor = .clear
        messageInputBar.textViewPadding.right = -38
    }
    
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 63/255, green: 183/255, blue: 216/255, alpha: 1)
        newMessageInputBar.delegate = self as? MessageInputBarDelegate
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
    }
    
}

extension ChatLogViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return setCurrentSender!
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter
            }()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatLogViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 63/255, green: 183/255, blue: 216/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 0)
    }

    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions()
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatLogViewController: MessagesLayoutDelegate {
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }
    
    // MARK: - Location Messages
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    
}

// MARK: - MessageCellDelegate

extension ChatLogViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if cell.cellBottomLabel.isHidden{
            cell.cellBottomLabel.isHidden = false
        }
        else{
            cell.cellBottomLabel.isHidden = true
        }
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatLogViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                
                let imageMessage = Message(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messages.append(imageMessage)
                messagesCollectionView.insertSections([messages.count - 1])
                
            } else if let text = component as? String {
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                
                let message = Message(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                sendMessage(text: text)
                
                //messages.append(message)
                //messagesCollectionView.insertSections([messages.count - 1])
            }
            
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
