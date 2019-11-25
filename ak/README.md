# twitter-clone-elixir
The goal of this project is to implement a Twitter Clone and a client tester/simulator. The problem statement is to implement an engine that can be paired up with WebSockets to provide full functionality. The client part (send/receive tweets) and the engine (distribute tweets) were simulated in separate OS processes.

Authors

Aniketh Sukhtankar (UF ID 7819 9584) asukhtankar@ufl.edu
Shikha Mehta (UF ID 4851 9256) shikha.mehta@ufl.edu

-------------------------------------------------------
 COP5615 : DISTRIBUTED SYSTEMS - TWITTER CLONE 
-------------------------------------------------------
The goal of this project is to:
 - Implement a Twitter like engine with the following functionality:
	* Register account
	* Send tweet. Tweets can have hashtags (e.g. #COP5615isgreat) and mentions (@bestuser)
	* Subscribe to user's tweets
	* Re-tweets (so that your subscribers get an interesting tweet you got by other means)
	* Allow querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned (my mentions)
	* If the user is connected, deliver the above types of tweets live (without querying)
 - Implement a tester/simulator to test the above
	* Simulate as many users as possible
	* Simulate periods of live connection and disconnection for users
	* Simulate a Zipf distribution on the number of subscribers. For accounts with a lot of subscribers, increase the number of tweets. Make some of these messages re-tweets
 - Measure various aspects of the simulator and report performance 


INSTRUCTIONS FOR EXECUTION 
------------------
 * Introduction
 * Pre-requisites
 * Client Simulator Program inputs
 * Running project4.tgz


INTRODUCTION
------------
The project folder contains:
 - Main.ex
 - Server.ex
 - Client.ex

PRE-REQUISITES
--------------
The following need to be installed to run the project:
 - Elixir
 - Erlang

Two terminals are required to execute Twitter server and clients simulator separately.

CLIENTS SIMULATOR PROGRAM INPUTS
--------------------------------
 - numClients: 		the number of clients to simulate
 - maxSubscribers: 	the maximum number of subscribers a Twitter account can have in the simulation (must be < numClients)
 - disconnectClients: 	the percentage of clients to disconnect to simulate periods of live connection and disconnection

RUNNING project4.tgz
--------------------
1. Go to the folder 'project4' in both terminals using command line. 
2. Start the Twitter engine in one by executing this command: escript project4 
3. Start the clients simulator in the other terminal using the following command: escript project4 <numClients> <maxSubscribers> <disconnectClients>
   e.g. escript project4 10 5 20   
4. Note that both programs do not terminate by themselves. 
   a. Twitter engine is designed to always stay on-line to handle incoming client connections.
   b. Clients simulator simulates recurring periods of live connection and disconnection.
5. To simulate the system with different parameter values, please restart both the programs and repeat the steps above.

OUTPUT
------
1. On the simulator's console we print query results for all the 3 types of queries, prefixed with the corresponding user's ID.
2. The simulator's console also prints live tweets for every user. User ID is prefixed to this output as well to identify which user's live view is getting updated.
3. If <disconnectClients> parameter is 0, the clients simulator console displays the performance statistics at the end. Otherwise, it prints the statistics and continues to simulate periods of live connection and disconnection.




Updated Running instructions:
mix escript.build
epmd -daemon
escript project4
escript project4 10 5 20

