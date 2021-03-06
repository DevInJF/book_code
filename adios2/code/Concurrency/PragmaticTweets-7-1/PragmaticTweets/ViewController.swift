//
//  ViewController.swift
//  PragmaticTweets
//
//  Created by Chris Adamson on 10/19/14.
//  Copyright (c) 2014 Pragmatic Programmers, LLC. All rights reserved.
//

import UIKit
import Social
import Accounts

// nasty global
let defaultAvatarURL = NSURL(string:
  "https://abs.twimg.com/sticky/default_profile_images/" +
  "default_profile_6_200x200.png")

public class ViewController: UITableViewController {

  var parsedTweets : Array <ParsedTweet> = []
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    reloadTweets()
    var refresher = UIRefreshControl()
    refresher.addTarget(self,
      action: "handleRefresh:",
      forControlEvents: UIControlEvents.ValueChanged)
    self.refreshControl = refresher
  }


  override public func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

 @IBAction func handleTweetButtonTapped(sender: UIButton) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let tweetVC = SLComposeViewController (forServiceType: SLServiceTypeTwitter)
      let message = NSLocalizedString(
        "I just finished the first project in iOS 8 SDK Development. #pragsios8",
        comment:"")
        tweetVC.setInitialText(message)
      self.presentViewController(tweetVC, animated: true, completion: nil)
    } else {
      println ("Can't send tweet")
    }
  }
  
  func reloadTweets() {
    let accountStore = ACAccountStore()
    let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(
      ACAccountTypeIdentifierTwitter)
    accountStore.requestAccessToAccountsWithType(twitterAccountType,
      options: nil,
      completion: {
        (Bool granted, NSError error) -> Void in
        if (!granted) {
          println ("account access not granted")
        } else {
          let twitterAccounts = accountStore.accountsWithAccountType(twitterAccountType)
          if twitterAccounts.count == 0 {
            println ("no twitter accounts configured")
            return
          } else {
            let twitterParams = [
              "count" : "100"
            ]
            let twitterAPIURL = NSURL(string:
              "https://api.twitter.com/1.1/statuses/home_timeline.json")
            let request = SLRequest(forServiceType: SLServiceTypeTwitter,
              requestMethod:SLRequestMethod.GET,
              URL:twitterAPIURL,
              parameters:twitterParams)
            request.account = twitterAccounts[0] as ACAccount
            request.performRequestWithHandler ( {
              (NSData data, NSHTTPURLResponse urlResponse, NSError error) -> Void in
            self.handleTwitterData(data, urlResponse: urlResponse, error: error)
            })
        }
      }
    })
  }
  
  /* Here's a little recipe to figure out if you're on the main thread/queue,
    at least until we get to breakpoints in the debugging chapter, which will
    let you do so without a code-and-recompile. The main queue is run by the
    main thread, and NSThread provides class method isMainThread() to see if
    you're on the meain thread. So put this line of code anywhere to see
    if you're on main or not:
  
    println (NSThread.isMainThread() ? "On main thread" : "Not on main thread");
  
  */
  
  // This is the non-concurrent version that just hangs for 10 seconds after
  // parsing the data. In Obj-C/iOS7, making the reloadData() call would actually
  // be a crasher. Point being: since we don't know what thread calls us back,
  // we must explicitly put our UIKit work back on the main queue, with dispatch_async()
  /*
  func handleTwitterData (data: NSData!,
      urlResponse: NSHTTPURLResponse!,
      error: NSError!) {
    if let dataValue = data {
      let jsonString = NSString (data: data, encoding:NSUTF8StringEncoding)
      println ("Raw JSON: \(jsonString)\n\n\n\n")
      var parseError : NSError? = nil
      let jsonObject : AnyObject? =
        NSJSONSerialization.JSONObjectWithData(dataValue,
        options: NSJSONReadingOptions(0),
        error: &parseError)
      println("JSON error: \(parseError)\nJSON response: \(jsonObject)")
      if parseError != nil {
        return
      }
      if let jsonArray = jsonObject as? Array<Dictionary<String, AnyObject>> { 
        self.parsedTweets.removeAll(keepCapacity: true)
        for tweetDict in jsonArray { 
          let parsedTweet = ParsedTweet() 
          parsedTweet.tweetText = tweetDict["text"]  as? NSString 
          parsedTweet.createdAt = tweetDict["created_at"]  as? NSString 
          let userDict = tweetDict["user"] as NSDictionary 
          parsedTweet.userName = userDict["name"] as? NSString 
          parsedTweet.userAvatarURL = NSURL (string: 
          userDict ["profile_image_url"] as NSString!)  
          self.parsedTweets.append(parsedTweet) 
        }
        self.tableView.reloadData()
      }
    } else {
      println ("handleTwitterData received no data")
    }
  }
  */

  func handleTwitterData (data: NSData!,
      urlResponse: NSHTTPURLResponse!,
      error: NSError!) {
    if let dataValue = data {
      let jsonString = NSString (data: data, encoding:NSUTF8StringEncoding)
      var parseError : NSError? = nil
      let jsonObject : AnyObject? =
        NSJSONSerialization.JSONObjectWithData(dataValue,
        options: NSJSONReadingOptions(0),
        error: &parseError)
      if parseError != nil {
        return
      }
      if let jsonArray = jsonObject as? Array<Dictionary<String, AnyObject>> {
        self.parsedTweets.removeAll(keepCapacity: true)
        for tweetDict in jsonArray {
          let parsedTweet = ParsedTweet()
          parsedTweet.tweetText = tweetDict["text"]  as? NSString
          parsedTweet.createdAt = tweetDict["created_at"]  as? NSString
          let userDict = tweetDict["user"] as NSDictionary
          parsedTweet.userName = userDict["name"] as? NSString
          parsedTweet.userAvatarURL = NSURL (string:
          userDict ["profile_image_url"] as NSString!)
          self.parsedTweets.append(parsedTweet)
        }
        dispatch_async(dispatch_get_main_queue(),
          { () -> Void in
            self.tableView.reloadData()
          })
        }
      } else {
        println ("handleTwitterData received no data")
      }
    }

  override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override public func tableView(_tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      return parsedTweets.count
  }
 
  override public func tableView (_tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell =
      tableView.dequeueReusableCellWithIdentifier("CustomTweetCell")
        as ParsedTweetCell
      let parsedTweet = parsedTweets[indexPath.row]
      cell.userNameLabel.text = parsedTweet.userName
      cell.tweetTextLabel.text = parsedTweet.tweetText
      cell.createdAtLabel.text = parsedTweet.createdAt
      if parsedTweet.userAvatarURL != nil {
        if let imageData = NSData (contentsOfURL: parsedTweet.userAvatarURL!)  {
          cell.avatarImageView.image = UIImage (data: imageData)
        }
      }
      return cell
  }

  @IBAction func handleRefresh (sender : AnyObject?) {
    reloadTweets()
    refreshControl!.endRefreshing()
  }
  
}

