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

thingLong(3).
thingLong(8).
thingLong(21).

cabinetDomainNew(22..23).
roomDomainNew(17..20).

% reuse costs
reuseCabinetTOthingCost(0).
reuseRoomTOcabinetCost(0).
reusePersonTOroomCost(0).
reuseCabinetAsHighCost(3).
reuseCabinetAsSmallCost(0).
reuseRoomCost(0).
% remove costs
removeCabinetTOthingCost(2).
removeRoomTOcabinetCost(2).
removePersonTOroomCost(2).
removeCabinetCost(2).
removeRoomCost(2).
% create costs
cabinetHighCost(100).
cabinetSmallCost(10).
roomCost(5).

% example solution:
%cabinet(9). cabinet(10). cabinet(22). room(15). room(16). cabinetTOthing(9,3). cabinetTOthing(9,4). cabinetTOthing(9,6). cabinetTOthing(9,7). cabinetTOthing(10,8).
cabinetTOthing(9,21). cabinetTOthing(22,5). roomTOcabinet(15,9). roomTOcabinet(16,10). roomTOcabinet(15,22). cabinetHigh(9). cabinetHigh(10). cabinetSmall(22).


% Solution constraints ...

% Derive short things
thingShort(T) :- legacyConfig(thing(T)), not thingLong(T).

% Generate cabinets and rooms
{ cabinet(C) : legacyConfig(cabinet(C)); cabinet(C) : cabinetDomainNew(C) }.
{ room(R) : legacyConfig(room(R)); room(R) : roomDomainNew(R) }.

% Assign each cabinet to be either small or high
1 { cabinetSmall(C); cabinetHigh(C) } 1 :- cabinet(C).

% Assign things to cabinets
1 { cabinetTOthing(C,T) : cabinet(C) } 1 :- legacyConfig(thing(T)).

% Assign cabinets to rooms
1 { roomTOcabinet(R,C) : room(R) } 1 :- cabinet(C).

% Define
person(P) :- legacyConfig(person(P)).
thing(T) :- legacyConfig(thing(T)).
owns(P,T) :- legacyConfig(personTOthing(P,T)).

% Long items must go in high cabinets
:- thingLong(T), cabinetTOthing(C,T), not cabinetHigh(C).

% Short items should prefer small cabinets when possible
preferSmall(T) :- thingShort(T).
:- preferSmall(T), cabinetTOthing(C,T), cabinetHigh(C).

% Cabinets can hold a maximum of 5 items
:- cabinetTOthing(C,T1), cabinetTOthing(C,T2), T1 != T2, #count { T : cabinetTOthing(C,T) } > 5.

% Room capacity constraint for cabinets: up to 4 capacity units per room
:- roomTOcabinet(R,C1), roomTOcabinet(R,C2), C1 != C2,
   #sum { 1,C : roomTOcabinet(R,C), cabinetSmall(C);
          2,C : roomTOcabinet(R,C), cabinetHigh(C) } > 4.

% Ownership constraint: things belonging to different people cannot be in the same cabinet
:- cabinetTOthing(C,T1), cabinetTOthing(C,T2), owns(P1,T1), owns(P2,T2), P1 != P2.

:- cabinet(C), thing(T), not cabinetTOthing(C,T), #sum { 1,C : cabinetTOthing(C,T) } > 3.
:- cabinet(23), not cabinetSmall(23), preferSmall(_).

% Optimization
#minimize {
    3@2,C : cabinetHigh(C), legacyConfig(cabinet(C));
    5@1,C : cabinetSmall(C), legacyConfig(cabinet(C));
    1@3,C : cabinet(C), not legacyConfig(cabinet(C)), cabinetSmall(C);
    10@2,C : cabinet(C), not legacyConfig(cabinet(C)), cabinetHigh(C);
    100@2,C : cabinet(C), not legacyConfig(cabinet(C)), cabinetHigh(C);
    1@4,R : room(R), not legacyConfig(room(R));
    5@2,R : room(R), not legacyConfig(room(R))
}.

% Output
#show cabinet/1.
#show cabinetSmall/1.
#show cabinetHigh/1.
#show room/1.
#show cabinetTOthing/2.
#show roomTOcabinet/2.
