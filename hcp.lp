% Legacy configuration facts
legacyConfig(person(1)).
legacyConfig(person(2)).
legacyConfig(thing(3)).
legacyConfig(thing(4)).
legacyConfig(thing(5)).
legacyConfig(thing(6)).
legacyConfig(thing(7)).
legacyConfig(thing(8)).
legacyConfig(personTOthing(1,3)).
legacyConfig(personTOthing(1,4)).
legacyConfig(personTOthing(1,5)).
legacyConfig(personTOthing(1,6)).
legacyConfig(personTOthing(1,7)).
legacyConfig(personTOthing(2,8)).

% New domains for cabinets and rooms
cabinetDomainNew(9..14).
roomDomainNew(15..20).

% Cost parameters
cabinetHighCost(1).
cabinetSmallCost(1).
roomCost(1).

% Define persons and things based on legacyConfig
person(P) :- legacyConfig(person(P)).
thing(T) :- legacyConfig(thing(T)).
owner(T, P) :- legacyConfig(personTOthing(P, T)).

% Define cabinets and rooms based on new domains
cabinet(C) :- cabinetDomainNew(C).
room(R) :- roomDomainNew(R).

% Decision variables
{cabinetInUse(C) : cabinet(C)}.  % Choose cabinets in use
{roomInUse(R) : room(R)}.        % Choose rooms in use

% Assign things to cabinets (each thing should be assigned to exactly one cabinet)
1 {storedIn(T, C) : cabinetInUse(C)} 1 :- thing(T).

% Assign cabinets to rooms (each cabinet should be assigned to exactly one room)
1 {cabinetInRoom(C, R) : roomInUse(R)} 1 :- cabinetInUse(C).

% Define the ownership relation between rooms and persons
1 {roomBelongsTo(R, P) : person(P)} 1 :- roomInUse(R).

% Constraints to ensure correct assignments
% A cabinet can hold up to 5 things
:- #count {T : storedIn(T, C)} > 5, cabinetInUse(C).

% A room can hold up to 4 cabinets
:- #count {C : cabinetInRoom(C, R)} > 4, roomInUse(R).

% Ensure that things are assigned to cabinets in rooms belonging to the correct person
:- storedIn(T, C), cabinetInRoom(C, R), roomBelongsTo(R, P), owner(T, P2), P != P2.

% Cost calculation - minimize the number of cabinets and rooms used
#minimize {
    1@1, C : cabinetInUse(C);  % Minimize cabinets used
    1@2, R : roomInUse(R)      % Minimize rooms used
}.

% Show only the relevant results
#show cabinetTOthing/2.
#show roomTOcabinet/2.

% Display results
cabinetTOthing(C, T) :- storedIn(T, C).
roomTOcabinet(R, C) :- cabinetInRoom(C, R).
