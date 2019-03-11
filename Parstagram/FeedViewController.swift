//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Luis Valencia on 3/3/19.
//  Copyright © 2019 Luis Valencia. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import Toast_Swift
import MessageInputBar
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var selectedPost: PFObject!
    var posts = [PFObject]()
    var showsCommentBar = false
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section];
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
                    if success {
                        self.view.makeToast("Comment uploaded!")
                    } else {
                        self.view.makeToast("Something went wrong...")
                    }
                }
        tableView.reloadData()
        commentBar.inputTextView.text = nil
        showsCommentBar = false;
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
           
            let user = post["author"] as! PFUser
            cell.username.text = user.username
            cell.caption.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            return cell
        }
        else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row-1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments","comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            } else {
                self.view.makeToast("Something went wrong...")
            }
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
       let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWIllBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
            return posts.count
    }
    @objc func keyboardWIllBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false;
        becomeFirstResponder()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []

        if indexPath.row == comments.count + 1{
            showsCommentBar = true;
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
             selectedPost = post
        }
    
    }
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut();
        let main = UIStoryboard(name: "main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delagate = UIApplication.shared.delegate as! AppDelegate
        
        delagate.window?.rootViewController = loginViewController
    }
    
}
