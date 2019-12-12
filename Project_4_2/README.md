# Twitter

Team Members(1): Anirudh Pathak

#Link to demo video
https://youtu.be/7Dk2QOyWk30

#How to run
1. Go to root directory of the mix umbrella project
2. type 'mix phx.server'
3. Go to http://0.0.0.0:4000/ to look at the website

#Overview
I have created a website with minimal UI to demonstrate the usage of websockets in Phoenix. The backend of the UI is the Twitter engine I created in Project-4. I have also included the simulator from Project-4 but it is not being used anywhere. The clients are the webpages now with the Phoenix acting as an interface to implement websockets between clients and the twitter engine. All important user-related log messages are printed on the webpage itself (tweeting, feed, retweeting, getting hashtags, etc.). The feed of the user is also of course printed on the webpage 

#How to operate the website
You should see 6 buttons and 1 textbox in the website:

Button-1: Register
Button-2: Tweet
Button-3: Subscribe to
Button-4: Get Hashtag
Button-5: Get mention
Button-6: Retweet
TEXT-BOX

**Register**: First and foremost, click on Register button. This will assign a userid to your session. You can start another session in a different tab and click register again to start another session. You cannot do anything unless you have registered

**Tweet**: Once registered, you can start tweeting. Type something in the TEXT-BOX and click on Tweet button. This will tweet what you wrote in the textbox. It prints 'You tweeted: [TWEET]' if the tweet was tweeted successfully

**Subscribe to**: You can subscribe to another user by:
1. Entering the userid of the user you want to subscribe to in the TEXT-BOX
2. Hit the 'Subscribe to' button
Now anytime the user you have subscribed to tweets, you will see it in your feed
After you have subscribed, you will see 'You are subscribed to feed of [USERID]' printed. Now anytime USERID tweets, you will see it in your feed

**Get Hashtag**: You can get all tweets that contain a particular hashtag by:
1. Entering the value of the hashtag in the TEXT-BOX
2. Hit the 'Get Hashtag' button
All the tweets will be printed in your feed

**Get Mention**: You can get all tweets that contain a particular mention by:
1. Entering the value of the mention in the TEXT-BOX
2. Hit the 'Get Mention' button
All the tweets will be printed in your feed

**Retweet**: You can retweet a tweet of one of the users you are subscribed to by using the tweet's id:
1. Get the tweet's id. Everytime a user tweets, all it's subscribers feeds get the tweet along with the tweet id. The id can be used to retweet. I have included how to do this in the demo
2. Enter the tweet-id in the TEXT-BOX
3. Hit Retweet
If you have something like this: 'UserId 0 tweeted: 'mellow'. You can use id 2 to retweet' in your feed. You can input '0' in TEXT-BOX and hit retweet


#Implementation and Error handling

#twitter_web.ex
Starts the application and the twitter engine

##index.html
It contains the Ui logic

##socket.js (API usage on client end)
It contains the API logic. Phoenix takes care of serializing and deserializing the javascript objects. Hence, it is not required to be done by hand. Every button has a listener associated with it. In accordance with what button was pressed, I send the relevant information to the appriopiate handle_in() function in the Channel. 
##using API endpoints
1. "register" - registering a userid
2. "tweet" - tweeting by a user
3. "subscribe" = subscribing to a user by a user
4. "tag" - getting all tweets that have a particular hashtag or a particular mention
5. "retweet" - retweeting a tweet that came in a user's feed from another user.
A typical API usage call looks like this:
//retweet
retweet.addEventListener("click", function(){
  channel.push("retweet", {body: chatInput.value}) //push to channel
  chatInput.value = "" //to reset it
})
It sends the relevant information to the handle_in function that matches with 'retweet'

##room_channel.ex (API endpoints in Phoenix)
This is the primary interface between Twitter engine and client. It has methods that ping the engine. It is also pinged by the engine for sending feed information
###API endpoints
0. join() - A new user joined a websocket connection
1. "register" - registering a userid
2. "tweet" - tweeting by a user
3. "subscribe" = subscribing to a user by a user
4. "tag" - getting all tweets that have a particular hashtag or a particular mention
5. "retweet" - retweeting a tweet that came in a user's feed from another user.
A typical endpoint looks like this:
    #tweet
    def handle_in("tweet", %{"body" => body}, socket) do
        userid = socket.assigns[:userid]
        . . . .
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end
More information in the demo

#modifications to the engine (Changes in engine using Phoenix)
I had to do a few modifications to the engine to work with channels
1. I added a new table that saves mapping of userid to channel-pid. This helps in efficient forwarding of feed information to subscribers of a user that just tweeted
2. Addition of a subscribers column to userid-subscribedto table for efficient retreival of subscribers for a user

##ERROR Handling and Logging
**Logging**: After every query on the webpage, I print the user specific log, along with the timestamp, on the webpage itself. It is helpful for the user to see if its query went through
**Error**
I have done error handling at 2 levels:
1. Channel Level
At channel level, I am handling errors that do not require querying the database such as a user being already registered, an empty tweet. More demonstration can be found in the video
2. Engine Level
I handle queries that require database (table) access in the engine and forward it to the Channel which then forwards it to the UI.

