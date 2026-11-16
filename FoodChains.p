%------------------------------------------------------------------------------
% File     : FoodChains.p
% Domain   : Ecology (food chains)
% Problem  : Food chains in general, and a freshwater pond in particular
% Version  : TUW 184.774 2026W, "Encoding and Solving a Problem"
% English  : Part 1 encodes food links, food chains, primary producers, apex
%            predators and dependency. Its 10 conjectures are placed directly
%            after the axioms they need. Part 2 encodes one freshwater pond
%            and trophic levels. Its 8 conjectures (plus the challenge
%            version of 7) come after all the axioms.
% Note     : ATP systems process one conjecture at a time. To prove a Food
%            Chains conjecture, keep only the axioms above it. To prove a
%            Freshwater Pond conjecture, keep all the axioms. In both cases
%            comment out all the other conjectures.
% Status   : Food Chains axioms: Satisfiable (Vampire finite model builder).
%            All axioms except trophic_level_def: Satisfiable (Vampire
%            finite model builder, with the 13 pond food links given names
%            to make the model search fast). trophic_level_def: Satisfiable
%            in the pond (Z3 found levels 0,0,0,1,1,1,2,2,3).
% Modelling: A food chain is a sequence of food links. The conjectures only
%            ever use where a chain starts and where it ends, so a food chain
%            is modelled by the relation food_chain(From,To): "there is a
%            food chain from From to To". Longer chains are built from food
%            links by joining.
%------------------------------------------------------------------------------
%----Food Chains
%----Types
tff(species_type,type,
    species: $tType ).

tff(food_link_type,type,
    food_link: $tType ).

%----A food link goes from the eaten species to the eater species
tff(eaten_type,type,
    eaten: food_link > species ).

tff(eater_type,type,
    eater: food_link > species ).

%----eats(Eater,Eaten)
tff(eats_type,type,
    eats: ( species * species ) > $o ).

tff(primary_producer_type,type,
    primary_producer: species > $o ).

tff(apex_predator_type,type,
    apex_predator: species > $o ).

%----food_chain(From,To): there is a food chain from From to To
tff(food_chain_type,type,
    food_chain: ( species * species ) > $o ).

%----complete_food_chain(From,To): there is a complete food chain from From
%----to To
tff(complete_food_chain_type,type,
    complete_food_chain: ( species * species ) > $o ).

%----depends(Apex,Species): the apex predator depends on the species
tff(depends_type,type,
    depends: ( species * species ) > $o ).

%----Axioms and conjectures
%----One species eats another iff there is a food link from the eaten to
%----the eater
tff(eats_def,axiom,
    ! [Eater: species,Eaten: species] :
      ( eats(Eater,Eaten)
    <=> ? [L: food_link] :
          ( eater(L) = Eater
          & eaten(L) = Eaten ) ) ).

%----Primary producers are the species that do not eat any species
tff(primary_producer_def,axiom,
    ! [S: species] :
      ( primary_producer(S)
    <=> ~ ? [T: species] : eats(S,T) ) ).

%----Proved
tff(fc_1,conjecture,
    ! [S: species] :
      ( primary_producer(S)
     => ~ ? [L: food_link] : eater(L) = S ) ).

%----Every species takes part in some food link (no isolated species)
tff(no_isolated_species,axiom,
    ! [S: species] :
    ? [L: food_link] :
      ( eater(L) = S
      | eaten(L) = S ) ).

%----Proved
tff(fc_2,conjecture,
    ! [S: species] :
      ( primary_producer(S)
     => ? [T: species] :
          ( T != S
          & eats(T,S) ) ) ).

%----No species eats itself
tff(no_cannibalism,axiom,
    ! [L: food_link] : eater(L) != eaten(L) ).

%----Proved
tff(fc_3,conjecture,
    ! [S: species] :
      ( ~ primary_producer(S)
     => ? [T: species] :
          ( T != S
          & eats(S,T) ) ) ).

%----Apex predators are the species that are not eaten by any species
tff(apex_predator_def,axiom,
    ! [S: species] :
      ( apex_predator(S)
    <=> ~ ? [T: species] : eats(T,S) ) ).

%----Proved
tff(fc_4,conjecture,
    ! [S: species] :
      ( apex_predator(S)
     => ~ ? [L: food_link] : eaten(L) = S ) ).

%----Proved
tff(fc_5,conjecture,
    ! [S: species] :
      ( apex_predator(S)
     => ? [T: species] :
          ( T != S
          & eats(S,T) ) ) ).

%----Proved
tff(fc_6,conjecture,
    ! [S: species] :
      ( ~ apex_predator(S)
     => ? [T: species] :
          ( T != S
          & eats(T,S) ) ) ).

%----A complete food chain is a food chain that starts at a primary producer
%----and ends at an apex predator
tff(complete_food_chain_def,axiom,
    ! [From: species,To: species] :
      ( complete_food_chain(From,To)
    <=> ( food_chain(From,To)
        & primary_producer(From)
        & apex_predator(To) ) ) ).

%----Proved
tff(fc_7,conjecture,
    ! [From: species,To: species] :
      ( complete_food_chain(From,To)
     => ~ eats(From,To) ) ).

%----A single food link is a food chain
tff(food_link_is_food_chain,axiom,
    ! [L: food_link] : food_chain(eaten(L),eater(L)) ).

%----Two food chains can be joined if the first ends where the second starts
tff(join_food_chains,axiom,
    ! [X: species,Y: species,Z: species] :
      ( ( food_chain(X,Y)
        & food_chain(Y,Z) )
     => food_chain(X,Z) ) ).

%----Nothing else is a food chain: every food chain starts with a food link,
%----which is either the whole chain or is followed by the rest of the chain
tff(food_chain_starts_with_link,axiom,
    ! [X: species,Z: species] :
      ( food_chain(X,Z)
     => ( eats(Z,X)
        | ? [Y: species] :
            ( eats(Y,X)
            & food_chain(Y,Z) ) ) ) ).

%----Food chains do not go on forever. First order logic cannot say
%----"finite", so this is said as: a food chain that does not start at a
%----primary producer can be extended backwards to one ...
tff(food_chains_reach_down,axiom,
    ! [X: species,Y: species] :
      ( ( food_chain(X,Y)
        & ~ primary_producer(X) )
     => ? [W: species] :
          ( primary_producer(W)
          & food_chain(W,X) ) ) ).

%----... and a food chain that does not end at an apex predator can be
%----extended forwards to one
tff(food_chains_reach_up,axiom,
    ! [X: species,Y: species] :
      ( ( food_chain(X,Y)
        & ~ apex_predator(Y) )
     => ? [Z: species] :
          ( apex_predator(Z)
          & food_chain(Y,Z) ) ) ).

%----Proved
tff(fc_8,conjecture,
    ! [S: species] :
      ( ( ~ primary_producer(S)
        & ~ apex_predator(S) )
     => ( ? [P: species] :
            ( primary_producer(P)
            & food_chain(P,S) )
        & ? [A: species] :
            ( apex_predator(A)
            & food_chain(S,A) ) ) ) ).

%----An apex predator depends on every species in every food chain that
%----leads to it. Each species in such a chain is the start of a food chain
%----(the rest of the chain) that ends at the apex predator.
tff(depends_def,axiom,
    ! [A: species,S: species] :
      ( depends(A,S)
    <=> ( apex_predator(A)
        & food_chain(S,A) ) ) ).

%----Proved
tff(fc_9,conjecture,
    ! [S: species] :
      ( ~ apex_predator(S)
     => ? [A: species] :
          ( apex_predator(A)
          & depends(A,S) ) ) ).

%----Proved
tff(fc_10,conjecture,
    ! [A: species,P: species] :
      ( complete_food_chain(P,A)
     => depends(A,P) ) ).

%------------------------------------------------------------------------------
%----Freshwater Pond
%----Types
tff(algae_type,type,
    algae: species ).

tff(duckweed_type,type,
    duckweed: species ).

tff(pondweed_type,type,
    pondweed: species ).

tff(zooplankton_type,type,
    zooplankton: species ).

tff(insect_type,type,
    insect: species ).

tff(snail_type,type,
    snail: species ).

tff(fish_type,type,
    fish: species ).

tff(frog_type,type,
    frog: species ).

tff(heron_type,type,
    heron: species ).

%----trophic_level(Species,Level). A species can have several levels.
tff(trophic_level_type,type,
    trophic_level: ( species * $int ) > $o ).

%----Axioms
%----The food chains capture all the species that exist
tff(pond_all_species,axiom,
    ! [S: species] :
      ( S = algae
      | S = duckweed
      | S = pondweed
      | S = zooplankton
      | S = insect
      | S = snail
      | S = fish
      | S = frog
      | S = heron ) ).

%----All the species are different
tff(pond_distinct_species,axiom,
    ( algae != duckweed & algae != pondweed & algae != zooplankton
    & algae != insect & algae != snail & algae != fish & algae != frog
    & algae != heron
    & duckweed != pondweed & duckweed != zooplankton & duckweed != insect
    & duckweed != snail & duckweed != fish & duckweed != frog
    & duckweed != heron
    & pondweed != zooplankton & pondweed != insect & pondweed != snail
    & pondweed != fish & pondweed != frog & pondweed != heron
    & zooplankton != insect & zooplankton != snail & zooplankton != fish
    & zooplankton != frog & zooplankton != heron
    & insect != snail & insect != fish & insect != frog & insect != heron
    & snail != fish & snail != frog & snail != heron
    & fish != frog & fish != heron
    & frog != heron ) ).

%----Who eats whom. The food chains capture everything that each species
%----eats, so for each species there is an "if and only if" that lists
%----exactly what it eats.
%----  Algae    -> Zooplankton -> Fish -> Heron
%----  Algae    -> Zooplankton -> Frog -> Heron
%----  Algae    -> Insect      -> Frog -> Heron
%----  Duckweed -> Snail       -> Frog -> Heron
%----  Pondweed -> Insect      -> Fish -> Heron
%----  Pondweed -> Snail       -> Fish -> Heron
% tff(algae_eats,axiom,
%     ! [S: species] : ~ eats(algae,S) ).

% tff(duckweed_eats,axiom,
%     ! [S: species] : ~ eats(duckweed,S) ).

% tff(pondweed_eats,axiom,
%     ! [S: species] : ~ eats(pondweed,S) ).

tff(zooplankton_eats,axiom,
    ! [S: species] :
      ( eats(zooplankton,S)
    <=> S = algae ) ).

tff(insect_eats,axiom,
    ! [S: species] :
      ( eats(insect,S)
    <=> ( S = algae
        | S = pondweed ) ) ).

tff(snail_eats,axiom,
    ! [S: species] :
      ( eats(snail,S)
    <=> ( S = duckweed
        | S = pondweed ) ) ).

tff(fish_eats,axiom,
    ! [S: species] :
      ( eats(fish,S)
    <=> ( S = zooplankton
        | S = insect
        | S = snail ) ) ).

tff(frog_eats,axiom,
    ! [S: species] :
      ( eats(frog,S)
    <=> ( S = zooplankton
        | S = insect
        | S = snail ) ) ).

tff(heron_eats,axiom,
    ! [S: species] :
      ( eats(heron,S)
    <=> ( S = fish
        | S = frog ) ) ).

%----Primary producers are at trophic level 0. A species that eats a species
%----at level N is at level N+1.
tff(trophic_level_def,axiom,
    ! [S: species,N: $int] :
      ( trophic_level(S,N)
    <=> ( ( primary_producer(S)
          & N = 0 )
        | ? [T: species,M: $int] :
            ( eats(S,T)
            & trophic_level(T,M)
            & N = $sum(M,1) ) ) ) ).

%----Conjectures
%----Proved
tff(pond_1,conjecture,
    primary_producer(algae) ).

%----Not a theorem. Nothing eats a heron, so a heron is an apex predator.
%----Vampire proved the negation, apex_predator(heron), from the axioms.
%----The axioms are consistent, so the conjecture cannot also be proved.
tff(pond_2,conjecture,
    ~ apex_predator(heron) ).

%----Proved
tff(pond_3,conjecture,
    ( ~ primary_producer(fish)
    & ~ apex_predator(fish) ) ).

%----Proved
tff(pond_4,conjecture,
    ! [S: species] :
      ( eats(frog,S)
    <=> eats(fish,S) ) ).

%----Proved
tff(pond_5,conjecture,
    ? [P1: species,P2: species] :
      ( complete_food_chain(P1,heron)
      & complete_food_chain(P2,heron)
      & P1 != P2 ) ).

%----Not a theorem. depends(A,S) means "A depends on S", and only apex
%----predators depend on species. A snail is not an apex predator (fish and
%----frogs eat snails). Vampire proved the negation, ~ depends(snail,heron).
%----The reverse, depends(heron,snail), is true.
tff(pond_6,conjecture,
    depends(snail,heron) ).

%----Proved
tff(pond_7,conjecture,
    ? [F: $int,S: $int] :
      ( trophic_level(fish,F)
      & trophic_level(snail,S)
      & $greater(F,S) ) ).

%----Proved
tff(pond_7_challenge,conjecture,
    ! [F: $int,S: $int] :
      ( ( trophic_level(fish,F)
        & trophic_level(snail,S) )
     => $greater(F,S) ) ).

%----Not a theorem. The trophic levels are: algae, duckweed, pondweed 0;
%----zooplankton, insect, snail 1; fish, frog 2; heron 3. So no species
%----has a level greater than the heron's. Vampire did not prove the
%----negation directly in 280s, so it was done in steps, each proved by
%----Vampire. Each step uses the axioms plus the steps before it, so the
%----negation follows from the axioms alone:
%----  1. No four eating steps (0.2s):
%----     ~ ? [A,B,C,D,E: species] :
%----         ( eats(A,B) & eats(B,C) & eats(C,D) & eats(D,E) )
%----  2. The heron's only level is 3:
%----     ! [H: $int] : ( trophic_level(heron,H) => H = 3 )
%----  3. Every level is at most 3 (uses step 1):
%----     ! [S: species,N: $int] : ( trophic_level(S,N) => $lesseq(N,3) )
%----  4. The negation of this conjecture (uses steps 2 and 3, 0.02s)
tff(pond_8,conjecture,
    ? [S: species,N: $int,H: $int] :
      ( trophic_level(heron,H)
      & trophic_level(S,N)
      & $greater(N,H) ) ).

%------------------------------------------------------------------------------
