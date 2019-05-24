h:- dynamic my_location/1, object/2, path/3, pathListAI/3, pathVisitedAI/1, mapListAI/2, pathFinishedAI/1, visitRoomAI/1, useObjectLocAI/2, pickupObjectLocAI/2, completeTravel/1, finishedAI/1, object_useAI/2. object_use/2.
:- set_prolog_stack(local, limit(5000000)).

/* TYPE START. TO BEGIN GAME */
/* CREATED BY JORDAN ISAACS - 2019 */
/* V1.0->V1.1 --Removed all ";", cleaned up code*/

/*Creating paths to the rooms */
path(mainCave,south,mainCaveSouthWall).
path(mainCaveSouthWall,north,mainCave).

path(mainCave,east,bathroom).
path(bathroom,west,mainCave).

path(mainCave,west,storageDoor).
path(storageDoor,east,mainCave).

path(storageDoor,west,storageCloset).
path(storageCloset,east,storageDoor).

path(mainCave,north,tunnel).
path(tunnel,south,mainCave).

path(tunnel,north,stream).
path(stream,south,tunnel).

path(stream,north,stairs).
path(stairs,south,stream).

path(stairs,west,exit).

/* Game Start */
start :-
    /* remove all locations/objects */
    retractall(my_location(_)), retractall(object(_,_)), retractall(usedAllObjects(_)), retractall(object_use(_,_)),

    /* Initialize current location */
    assert(my_location(mainCave)),

    /* Initalize object locations */
    assert(object(bathroom,key)),
    assert(object(storageCloset,plank)),

    /* Places objects can be used */
    assert(object_use(storageDoor,key)),
    assert(object_use(stream,plank)),

    /* Prolog Intro */
    write("--IMPORTANT NOTE: PROLOG INTRO--"), nl,
    write("Prolog is the language this game is based on."), nl,
    write("Prolog requires '.' at the end of all commands."), nl,
    write("For example 'north' would be an invalid command."), nl,
    write("But 'north.' is. Make sure to put a '.' at the end of every command."), nl, nl, nl, nl,

    /* Begin game descriptions */
    write("--BEGIN GAME--"), nl, nl,
    write("You wake up and look around. You have no recollection of how you got to this dark cave."), nl,
    write("Looking down you see you were sleeping on a pristine bed. Checking your pockets, you find a compass."), nl,
    write("Not knowing what to do, you decide to explore."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(mainCave), nl, nl,
    describe(inventory).

/* Movement Actions */
north :- go(north).
south :- go(south).
east :- go(east).
west :- go(west).
n :- go(north).
s :- go(south).
e :- go(east).
w :- go(west).

/* Pick up Logic*/
pickup(X) :-
    /* If something to pick up, pick up */
    my_location(Place),
    object(Place,X),
    retract(object(Place,X)),
    assert(object(in_hand,X)),
    write("Picked up "),
    write(X), nl, nl,
    action(Place), nl, nl,
    describe(inventory), !.

pickup(_) :-
    my_location(Place),
    /* if nothing to pick up, let player know */
    write("There is nothing to pick up"), nl, nl,
    action(Place), nl, nl,
    describe(inventory), !.

/* Use item logic */
use(X) :-
    my_location(Place),
    object_use(Place, X),
    retract(object(in_hand, X)),
    assert(object(used, X)),
    usePlankLogic(X),
    useKeyLogic(X), !.

/* Logic for using the key */
useKeyLogic(X) :-
    ==(X,key),
    write("You insert the key into the door. It fits perfectly."), nl, nl,
    action(storageDoor), nl, nl,
    describe(inventory), !.

useKeyLogic(_) :-
    !, true.

/* Text description of placing the plank */
usePlankLogic(X) :-
    ==(X,plank),
    write("You place the plank across the stream. You can now cross"), nl, nl,
    action(stream), nl, nl,
    describe(inventory), !.

usePlankLogic(_) :-
    !, true.

/* If path goes over the stream, ensure the user placed the plank for successful movement */
plankMoveLogic(Place,Direction,Destination) :-
    ==(path(Place,Direction,Destination), path(stream,north,stairs)),
    plankMoveLogic2, !.

plankMoveLogic(Place,Direction,Destination) :-
    not(==(path(Place,Direction,Destination),path(stream,north,stairs))),
    true, !.

plankMoveLogic2 :-
    object(used,plank),
    !, true, !.

plankMoveLogic2 :-
    !, false.

/* can't go into the storageCloset without a used key */
keyMoveLogic(Place,Direction,Destination) :-
    ==(path(Place,Direction,Destination), path(storageDoor,west,storageCloset)),
    keyMoveLogic2, !.

keyMoveLogic(Place,Direction,Destination) :-
    not(==(path(Place,Direction,Destination),path(storageDoor,west,storageCloset))),
    true, !.

keyMoveLogic2 :-
    object(used,key),
    !, true, !.

keyMoveLogic2 :-
    !, false.

/* Movement/Path Logic */
go(Direction) :-
    /* Change location based on path */
    my_location(Place),
    path(Place,Direction,Destination),
    /* Go to plankMoveLogic/keyMoveLogic */
    plankMoveLogic(Place,Direction,Destination),
    keyMoveLogic(Place,Direction,Destination),
    /* Change location to destination */
    retract(my_location(Place)),
    assert(my_location(Destination)),
    describe(Destination), !.

/* If no path exists, let user know they can't go that way */
go(_) :-
    my_location(Place),
    write("You can't go that way."), nl, nl,
    action(Place), nl, nl,
    describe(inventory), !.


/* Text description for main cave (calls description of actions and current inventory) */
describe(mainCave) :-
    write("Back to where you started... Where shall you go next."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(mainCave), nl, nl,
    describe(inventory).

/* Text description + Logic for storage door */
describe(storageDoor) :-
    object(used,key),
    write("You run across a steel door. Ornate symbols line the framing."), nl,
    write("The door is unlocked."), nl, nl,
    action(storageDoor), nl, nl,
    describe(inventory), !.

describe(storageDoor) :-
    object(in_hand,key),
    write("You run across a steel door. Ornate symbols line the framing."), nl,
    write("The key you have can unlock the door."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(storageDoor), nl, nl,
    describe(inventory), !.

describe(storageDoor) :-
    write("You run across a steel door. Ornate symbols line the framing."), nl,
    write("You try and knock the door down but it is made of solid steel. You need the key."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(storageDoor), nl, nl,
    describe(inventory), !.

/* Text description for tunnel (calls description of actions and current inventory) */
describe(tunnel) :-
    write("You see torches north of you and head towards them."), nl,
    write("The torches line a damp tunnel. Water drips on your head."),nl,
    write("Etched art lines the walls. They depict a beast guarding a cave."), nl, nl,
    write("There is nothing to pick up here"), nl, nl,
    action(tunnel), nl, nl,
    describe(inventory).

/* Text desription/text logic for the stream + (calls description of actions and current inventory) */
describe(stream) :-
    object(in_hand,plank),
    write("You encounter a fast moving stream. It is too wide to jump."), nl,
    write("The plank you already picked up can be used as a makeshift bridge."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(stream), nl, nl,
    describe(inventory), !.

describe(stream) :-
    object(used,plank),
    write("You encounter a fast moving stream. It is too wide to jump."), nl,
    write("You already layed down a plank to help you cross."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(stream), nl, nl,
    describe(inventory), !.

describe(stream) :-
    write("You encounter a fast moving stream. It is too wide to jump."), nl,
    write("You need something to help you cross it."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(stream), nl, nl,
    describe(inventory).


/* Text description for stairs (calls available actions and current inventory) */
describe(stairs) :-
    write("You arrive at stairs that go to your west. At the end of those stairs is light."), nl,
    write("You are relieved. But you are scared to go up the stairs."), nl,
    write("You remember the etching of a beast guarding a cave on the wall of the tunnel."), nl,
    write("It is up to you..."), nl, nl,
    write("There is nothing to pick up here."), nl, nl,
    action(stairs), nl, nl,
    describe(inventory).

/* Description of storageCloset */
describe(storageCloset) :-
    write("The room you enter is dusty storage closet, no one has been in it for a while."), nl,
    write("It looks like a storage room."), nl, nl,
    describe(objects), nl, nl,
    action(storageCloset), nl, nl,
    describe(inventory).

/* Description of mainCaveSouthWall */
describe(mainCaveSouthWall) :-
    write("You blindly walk south. You can't see more than a few feet in front of you."), nl,
    write("After a few seconds you run into a wall."), nl, nl,
    write("You can't explore further and return back to the main cave."), nl, nl,
    north.

/* Description of bathroom */
describe(bathroom) :-
    write("You walk east for a minute and see an open door to a lit room."), nl,
    write("After you enter you realize it is a bathroom."), nl, nl,
    describe(objects), nl, nl,
    action(bathroom), nl, nl,
    describe(inventory).

describe(exit) :-
    write("You inch up the stairs and go out into the light."), nl,
    write("You see a figure in the distance. It is coming towards you..."), nl, nl,
    write("You freak out, the figure is holding something"), nl,
    write("As they get closer you see it is fire wood. Is the figure going to eat you???"), nl, nl,
    write("You now can discern it is a him. There is nowhere for you to hide."), nl,
    write("He yells out, 'Oh howdy! You are awake.'"), nl, nl,
    write("Now you are thoroughly confused. What is the meaning of this."), nl,
    write("You stand there paralyzed as the man approaches. He asks if you are alright."), nl, nl,
    write("You say that you don't remember anything. You can't make sense of the situation."), nl, nl,
    write("The man lets you know that you were in a plane crash. He found you and brought you back to his home in the cave."), nl,
    write("He had been living off the grid for the past few years. You ask about the stream."), nl, nl,
    write("He says has a few planks to cross it but always removes them so animals can't get into the living quarters."), nl, nl,
    write("You then ask about the beast guarding the cave."), nl,
    write("He lets out a bellowing laugh. He motions for you to turn around. There is a stuffed bear's head guarding the cave entrance."), nl, nl,
    write("Its just decoration he says."), nl,
    write("He tells you that a helicopter is coming in the next few days to bring you back to civilization."), nl, nl, nl,
    write("===================================================="),nl,
    write("======================YOU WON======================="),nl,
    write("===================================================="),nl,
    write("            WRITE start. TO PLAY AGAIN              "),nl.

/* Description of what is in inventory */
describe(inventory) :-
    object(in_hand,X),
    write("Inventory:"), nl,
    forall(object(in_hand,X),invwrite(X)), !.

describe(inventory) :-
    write("Inventory:"), nl,
    write("Nothing"), !.

/* Describe what objects are available in current room */
describe(objects) :-
    my_location(Place),
    object(Place, X),
    write("There is "),
    write(X),
    write(" to pick up."), !.

describe(objects) :-
    write("There is nothing more to pick up here."), !.

/* Text descriptions of available actions in main cave */
action(mainCave) :-
    write("Your available actions:"),nl,
    write("north            --Go North"), nl,
    write("south            --Go South"), nl,
    write("east             --Go East"), nl,
    write("west             --Go West").

/* Text descriptions of available actions in bathroom */
action(bathroom) :-
    object(bathroom, key),
    write("Your available actions:"), nl,
    write("west.             --Return to the main cave"), nl,
    write("pickup(key).      --Pick up the key."), !.

action(bathroom) :-
    write("Your available actions:"), nl,
    write("west.             --Return to the main cave"), !.

/* Text descriptions of available actions in storage door */
action(storageDoor) :-
    object(in_hand,key),
    write("Your available actions:"), nl,
    write("east.             --Return to the main cave"), nl,
    write("use(key).         --Insert key into door"), !.

action(storageDoor) :-
    object(used,key),
    write("Your available actions:"), nl,
    write("east.             --Return to the main cave"), nl,
    write("west.             --Go through the door"), !.

action(storageDoor) :-
    write("Your available actions:"), nl,
    write("east.             --Return to the main cave"), !.


/* Text descriptions+text logic of available actions in storageCloset */
action(storageCloset) :-
    object(storageCloset, plank),
    write("Your available actions:"), nl,
    write("east.             --Return to the main cave"), nl,
    write("pickup(plank).    --Pickup the plank"), !.

action(storageCloset) :-
    write("Your available actions:"), nl,
    write("east.             --Return to the main cave"), !.

/* Text descriptions of available actions in tunnel */
action(tunnel) :-
    write("Your available actions:"), nl,
    write("north.            --Continue north"), nl,
    write("south.            --Return to the main cave").

/* Text descriptions+text logic of available actions in stream*/
action(stream) :-
    object(in_hand,plank),
    write("Your available actions:"),nl,
    write("south.            --Return to the tunnel"), nl,
    write("use(plank).       --Lay down the plank to allow crossing"), !.

action(stream) :-
    object(used,plank),
    write("Your available actions:"), nl,
    write("north.            --Continue north"), nl,
    write("south.            --Return to the tunnel"), !.

action(stream) :-
    write("Your available actions:"), nl,
    write("south.            --Return to the tunnel"), !.

/* Text descriptions of available actions in stairs */
action(stairs) :-
    write("south            --Return to stream"), nl,
    write("west             --Go up the stairs").

/* Found in describe(inventory), prints out inventory */
invwrite(X) :-
    write(X), nl.




/* AI */

/* Start AI */
startAI :-
	start,
	pickupUseStartAI.

/* Start the brain AI, retract that the AI may have already finished and object use states */
pickupUseStartAI :-
	retractall(object_useAI(_,_)),
        assert(object_useAI(storageDoor,key)),
        assert(object_useAI(stream,plank)),
	retractall(finishedAI(_)),
	pickupUseAI.

/* The brain of the AI */
pickupUseAI :-
	/* If the plank still exists to be used (final object), then run the pickup and use logic */
	object_useAI(_,plank),
	/* Generate a map from current location */
	my_location(PickupCurrentLocation),
	mapGeneratorStartAI(PickupCurrentLocation),
	/* Get location of an object to pickup, then generate a path to it */
	pickupObjectLocAI(PickupDestination, Object),
	pathGeneratorStartAI(PickupCurrentLocation, PickupCurrentLocation, PickupDestination),
	/* Actually travel to that location using the path generated and pick it up */
	travelStartAI(PickupCurrentLocation, PickupDestination),
	nl, nl, pickup(Object),
	/* Get location of the object that you picked up is used */
	useObjectLocAI(UseDestination, Object),
	/* Get current location and remap */
	my_location(UseCurrentLocation),
	mapGeneratorStartAI(UseCurrentLocation),
	/* Generate a path to the location where object is used */
	pathGeneratorStartAI(UseCurrentLocation, UseCurrentLocation, UseDestination),
	/* Travel to the place and use the object */
	travelStartAI(UseCurrentLocation, UseDestination),
	nl, nl, use(Object),
	/* Retract the object, (aka it has been used) */
	retract(object_useAI(UseDestination, Object)),
	/* Runs recursion */
	pickupUseAI.

/* If the last object has been used (the plank), go to the exit */
pickupUseAI :-
	my_location(CurrentLocation),
	mapGeneratorStartAI(CurrentLocation),
	pathGeneratorStartAI(CurrentLocation,CurrentLocation,exit),
	travelStartAI(CurrentLocation,exit),
	assert(finishedAI(yes)),
	nl, nl, write("------------AI WON-------------"), nl.

/* Start the travelAI, retract that travel has been completed */
travelStartAI(CurrentLocation, FinalDestination) :-
	retractall(completeTravel(_)),
	travelAI(CurrentLocation,FinalDestination).

/* Actually moves the AI bot */
travelAI(CurrentLocation, FinalDestination) :-
	/* If travel is not complete then grab the necessary path from the paths generated by pathGeneratorAI */
	not(completeTravel(yes)),
	pathListAI(CurrentLocation, Direction, Destination),
	/* If the destination is the final destination, travel there, assert travel is complete, and don't do recursion */
	==(Destination, FinalDestination),
	nl, nl, write("-----Initating travelAI at "), write(CurrentLocation), write("--------"),
	nl, write("Going from "), write(CurrentLocation), write(" to "), write(Destination), write(" in direction "), write(Direction), nl, nl,
	go(Direction),
	assert(completeTravel(yes)),
	nl, nl, write("----COMPLETED TRAVEL----").

/* If the final destination is not the curent destination */
travelAI(CurrentLocation, FinalDestination) :-
	not(completeTravel(yes)),
	/* Grab the destination and go there then do recursion */
	pathListAI(CurrentLocation, Direction, Destination),
	nl, nl, write("-----Initating travelAI at "), write(CurrentLocation), write("--------"),
	nl, write("Going from "), write(CurrentLocation), write(" to "), write(Destination), write(" in direction "), write(Direction), nl, nl,
	go(Direction),
	travelAI(Destination, FinalDestination).

/* Start the map generator and retract all of the previously used data */
mapGeneratorStartAI(CurrentLocation) :-
        retractall(visitRoomAI(_)),
	retractall(mapListAI(_,_)),
        retractall(useObjectLocAI(_,_)),
        retractall(pickupObjectLocAI(_,_)),
	/* Don't run if AI is finished */
	not(finishedAI(yes)),
	nl,nl,write("-------MAPPING FROM "), write(CurrentLocation), write("--------"),
	/* Initalize current location as a visited room */
        assert(visitRoomAI(CurrentLocation)),
	/* mapGenerator fails when complete, not makes it so it doesn't fail the entire AI */
        not(mapGeneratorAI(CurrentLocation)).

/* Generate map from current location*/
mapGeneratorAI(CurrentLocation) :-
	/* Start by grabbing the actual path from current location */
	path(CurrentLocation, _, NewLocation),
	nl, nl, write("Try from: "), write(CurrentLocation), write(" to "), write(NewLocation),
	/* If there is nothing to be used at location */
        not(useMapAI(CurrentLocation)),
        nl, write("No object to use in "), write(CurrentLocation),
	/* If the path is not already in mapListAI, assert it */
	not(mapListAI(CurrentLocation, NewLocation)),
	assert(mapListAI(CurrentLocation, NewLocation)),
	/* run the pickupMapAI rule */
        pickupMapAI(CurrentLocation),
        nl, write("Success from: "), write(CurrentLocation), write(" to "), write(NewLocation),
	/* If the path leads to somewhere that has not been visited yet, assert that it has been visited then do recursion with that as current location*/
        not(visitRoomAI(NewLocation)),
        nl, write("Next iteration is in: "), write(NewLocation),
        assert(visitRoomAI(NewLocation)),
        mapGeneratorAI(NewLocation).

/* Checks if there is something to use at location when mapping, returns false if there is nothing */
useMapAI(CurrentLocation) :-
	/* Checks if there is an object at location*/
        object_useAI(CurrentLocation, Object),
        nl, write("Object to use in: "), write(CurrentLocation),
        useLocAssertAI(CurrentLocation, Object).

/* Documents the object and current location if not already documented */
useLocAssertAI(CurrentLocation, Object) :-
        not(useObjectLocAI(CurrentLocation, Object)),
        nl, write("Documenting it"),
        assert(useObjectLocAI(CurrentLocation, Object)).

/* Even if object is documented, still return yes because an object exists to be used in that room */
useLocAssertAI(_,_) :-
        true.

/* When mapping check if there is anything to pick up */
pickupMapAI(CurrentLocation) :-
	object(CurrentLocation, Object),
        nl, write("Object to pickup in: "), write(CurrentLocation),
	pickupLocAssertAI(CurrentLocation, Object).

/* Return true if nothing to pick up as the mapping of that room and its path should continue */
pickupMapAI(_) :-
	true.

/* When asserting that there is something to pickup in the room, make sure it has not already been asserted */
pickupLocAssertAI(CurrentLocation, Object) :-
	not(pickupObjectLocAI(CurrentLocation, Object)),
	assert(pickupObjectLocAI(CurrentLocation, Object)),
	nl, write("Document pickup of "), write(Object).

/* If object to pickup has already been documented, still return true as mapping should continue */
pickupLocAssertAI(_, Object) :-
	nl, write("Already documented pickup of "), write(Object),
	true.

/* Start the path generation with all the data it used previously deleted*/
pathGeneratorStartAI(CurrentLocation, CurrentLocation, Destination) :-
	retractall(pathVisitedAI(_)),
	retractall(pathListAI(_,_,_)),
	retractall(pathFinishedAI(_)),
	/* Don't run if the AI is finished, reduces unnecessary runs */
	not(finishedAI(yes)),
	nl, nl, write("------GENERATING PATH FROM "), write(CurrentLocation), write(" to "), write(Destination), write("---------"), nl,
	pathGeneratorAI(CurrentLocation, CurrentLocation, Destination).

/* Generates the path from startlocation to destination */
pathGeneratorAI(StartLocation, CurrentLocation, Destination) :-
	/* If the path isn't finished */
	not(pathFinishedAI(yes)),
	/* See if there is a path that goes from start to destination immediately */
	mapListAI(StartLocation, Destination),
	/* If that path exists then document it with a direction and assert that the AI is finished generating path */
	nl, write("Finished path: "), write(CurrentLocation), write(" to "), write(Destination),
	assert(pathFinishedAI(yes)),
	path(CurrentLocation, Direction, Destination),
	pathListAssertAI(CurrentLocation, Direction, Destination), !.

/* If there is no path from StartLocation to Destination */
pathGeneratorAI(StartLocation, CurrentLocation, Destination) :-
	/* Ensure path isn't finished, reduces unnecesary recursions */
	not(pathFinishedAI(yes)),
	/* Get path from current location */
	mapListAI(CurrentLocation, NextLocation),
	/* If a path leads to desination */
	==(NextLocation, Destination),
	/* Retract all the paths tested by the generator, assert the path with direction into the final path list, and recurse currentlocation as the new destination */
	nl, write("Found path element: "), write(CurrentLocation), write(" to "), write(Destination),
	retractall(pathVisitedAI(_)),
	path(CurrentLocation, Direction, Destination),
	pathListAssertAI(CurrentLocation, Direction, Destination),
	pathGeneratorAI(StartLocation, StartLocation, CurrentLocation).

/* If there is no path from StartLocation to Destination and from CurrentLocation to destination  */
pathGeneratorAI(StartLocation, CurrentLocation, Destination) :-
	/* Ensure path isn't finished, reduces unnecessary recursions */
	not(pathFinishedAI(yes)),
	/* Grab the paths from current location */
	mapListAI(CurrentLocation, NextLocation),
	/* Ensures the AI isn't finished, reduces unnecessary recursions */
	not(finishedAI(yes)),
	/* Assert that this location has been visited and if we have not visited the next location, recurse with that as the new current location */
	nl, write(Destination), write(": Eliminated path: "), write(CurrentLocation), write(" to "), write(NextLocation),
	pathVisitedAssertAI(CurrentLocation),
	not(pathVisitedAI(NextLocation)),
	pathGeneratorAI(StartLocation, NextLocation, Destination).

/* Only asserts that AI have visited the path if it hasn't been asserted before */
pathVisitedAssertAI(CurrentLocation) :-
	not(pathVisitedAI(CurrentLocation)),
	assert(pathVisitedAI(CurrentLocation)).

/* Returns true if already asserted as recursion needs to continue */
pathVisitedAssertAI(_) :-
	true.


/* Only asserts the path into the final path list if not been asserted before */
pathListAssertAI(CurrentLocation, Direction, Destination) :-
	not(pathListAI(CurrentLocation, Direction, Destination)),
	assert(pathListAI(CurrentLocation, Direction, Destination)).

/* Want recursion to continue so even if already asserted returns true */
pathListAssertAI(_,_,_) :-
	true.

