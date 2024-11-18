% Legacy configuration facts
legacyConfig(person(1)).
legacyConfig(person(2)).
legacyConfig(thing(3)).
legacyConfig(thing(4)).
legacyConfig(thing(5)).
legacyConfig(thing(6)).
legacyConfig(thing(7)).
legacyConfig(thing(8)).
legacyConfig(thing(21)).
legacyConfig(personTOthing(1,3)).
legacyConfig(personTOthing(1,4)).
legacyConfig(personTOthing(1,5)).
legacyConfig(personTOthing(1,6)).
legacyConfig(personTOthing(1,7)).
legacyConfig(personTOthing(1,21)).
legacyConfig(personTOthing(2,8)).

legacyConfig(room(15)).
legacyConfig(roomTOcabinet(15,9)).

legacyConfig(room(16)).
legacyConfig(roomTOcabinet(16,10)).

legacyConfig(cabinet(9)).
legacyConfig(cabinetTOthing(9,3)).
legacyConfig(cabinetTOthing(9,4)).
legacyConfig(cabinetTOthing(9,5)).
legacyConfig(cabinetTOthing(9,6)).
legacyConfig(cabinetTOthing(9,7)).

legacyConfig(cabinet(10)).
legacyConfig(cabinetTOthing(10,8)).

% Long-term storage things
thingLong(3).
thingLong(8).
thingLong(21).

% New domains for cabinets and rooms
cabinetDomainNew(22..23).
roomDomainNew(17..20).

% Reuse costs
reuseCabinetTOthingCost(0).
reuseRoomTOcabinetCost(0).
reusePersonTOroomCost(0).
reuseCabinetAsHighCost(3).
reuseCabinetAsSmallCost(0).
reuseRoomCost(0).

% Remove costs
removeCabinetTOthingCost(2).
removeRoomTOcabinetCost(2).
removePersonTOroomCost(2).
removeCabinetCost(2).
removeRoomCost(2).

% Create costs
cabinetHighCost(100).
cabinetSmallCost(10).
roomCost(5).

% Define persons and things based on legacyConfig
person(P) :- legacyConfig(person(P)).
thing(T) :- legacyConfig(thing(T)).
owner(T, P) :- legacyConfig(personTOthing(P, T)).

% New domains for cabinets and rooms
cabinet(C) :- cabinetDomainNew(C).
room(R) :- roomDomainNew(R).

% Assign things to cabinets
1 {storedIn(T, C) : cabinet(C)} 1 :- thing(T).

% Assign cabinets to rooms
1 {cabinetInRoom(C, R) : room(R)} 1 :- cabinet(C).

% Room assignment to a person
1 {roomBelongsTo(R, P) : person(P)} 1 :- room(R).

% Constraints
% A cabinet can hold up to 5 things
:- #count {T : storedIn(T, C)} > 5, cabinet(C).

% A room can hold up to 4 cabinets
:- #count {C : cabinetInRoom(C, R)} > 4, room(R).

% Ensure things are assigned to cabinets in rooms belonging to the correct person
:- storedIn(T, C), cabinetInRoom(C, R), roomBelongsTo(R, P), owner(T, P2), P != P2.

% Cost calculation - minimize the number of cabinets and rooms used
#minimize {
    1@1, C : cabinet(C); % Minimize cabinets used
    1@2, R : room(R)    % Minimize rooms used
}.

% Assign cabinets to rooms
1 {cabinetInRoom(C, R) : room(R)} 1 :- cabinet(C).

% High-Cost Cabinet Constraint
cabinetHigh(C) :- cabinet(C), reuseCabinetAsHighCost(C).

% Small-Cost Cabinet Constraint
cabinetSmall(C) :- cabinet(C), reuseCabinetAsSmallCost(C).

% Cost calculations (if optimization is needed)
#minimize { 1@1, C : cabinetHigh(C); 1@1, C : cabinetSmall(C); 1@1, R : roomCost(R) }.

% Show the assignments
#show cabinetTOthing/2.
#show roomTOcabinet/2.
#show cabinetHigh/1.
#show cabinetSmall/1.

% Display results
cabinetTOthing(C, T) :- storedIn(T, C).
roomTOcabinet(R, C) :- cabinetInRoom(C, R).
