%----Food Chains
tff(species_type, type, species: $tType).
tff(foodlink_type, type, foodlink: $tType).  

tff(is_apex_predator_decl, type, is_apex_predator: species > $o).
tff(is_primary_producer_decl, type, is_primary_producer: species > $o).

tff(eats_decl, type, eats: (species * species) > $o).
tff(eater_decl, type, eater: foodlink > species).
tff(eaten_decl, type, eaten: foodlink > species).

tff(depends_on_decl, type, depends_on: (species * species) > $o).
tff(food_chain_exists_decl, type, food_chain_exists: (species * species) > $o).
tff(complete_food_chain_decl, type, complete_food_chain: (species * species) > $o).


tff(foodlink_definition, axiom,
    ! [A: species, B: species] : 
      (eats(A, B) <=> ? [F: foodlink] : ((eaten(F) = B) & (eater(F) = A)))
    ).

tff(primary_producer_definition, axiom,
    ! [P: species]:
    (is_primary_producer(P) <=> ~ (? [S: species]: eats(P, S)))).

%----1.
% tff(primary_producer_no_foodlink, conjecture,
%     ! [S: species] : 
%       (is_primary_producer(S) => ~ ? [F: foodlink] : (eater(F) = S))
%     ).


%---- every species has at least one foodlink, i.e. consumer or producer
tff(no_isolated_species, axiom,
    ![S:species]:
    ?[F: foodlink]:
    (eater(F) =  S | eaten(F) = S)
    ).

% nobody eats their species
tff(no_canibalism, axiom,
    ! [S: species]:
    ~ eats(S, S)).

%----2.
% tff(every_primary_producer_eaten, conjecture,
%     ! [P: species]:
%     (is_primary_producer(P) => ? [S: species]: eats(S, P))
%     ).

%----3.
% tff(not_prim_prod_eats, conjecture,
%     ! [S : species] :
%     (~is_primary_producer(S) => ? [P: species]: eats(S, P))
%     ).

tff(apex_predator_definition, axiom,
    ! [A: species]:
    (is_apex_predator(A) <=>  ~ (? [S: species]: eats(S, A))) ).

%----4. Proved
% tff(apex_not_eaten_of_foodlink, conjecture,
%     ! [A: species]:
%     (is_apex_predator(A) => ~(? [F: foodlink]: eaten(F) = A))
%     ).

%----5. Proved
% tff(every_apex_eats_something, conjecture,
%     ![A:species]:
%     (is_apex_predator(A) => ? [S: species]: eats(A, S))
%     ).

%----6. Proved
% tff(not_apex_eaten, conjecture,
%     ! [S : species]:
%     ((~ is_apex_predator(S)) =>  ? [P: species]: eats(P, S))
%     ).

tff(food_chain_def_axiom, axiom,
    ! [A: species]:
    ! [B: species]:
    (food_chain_exists(A, B) => 
    (
        eats(B, A) |
        ? [X: species]: (eats(X, A) & food_chain_exists(X, B))
    ))
    ).

tff(food_chains_reach_down,axiom,
    ! [X: species,Y: species] :
      ( ( food_chain_exists(X,Y)
        & ~ is_primary_producer(X) )
     => ? [W: species] :
          ( is_primary_producer(W)
          & food_chain_exists(W,X) ) ) ).

tff(food_chains_reach_up,axiom,
    ! [X: species,Y: species] :
      ( ( food_chain_exists(X,Y)
        & ~ is_apex_predator(Y) )
     => ? [Z: species] :
          ( is_apex_predator(Z)
          & food_chain_exists(Y,Z) ) ) ).

tff(food_chain_inital_axiom, axiom,
    ! [A: species]:
    ! [B: species]:
    ((? [F: foodlink]: (eater(F) = B & eaten(F) = A)) => food_chain_exists(A, B))).

% tff(food_chain_recursive_axiom, axiom,
%     ! [A: species]:
%     ! [B: species]:
%     ? [X: species]:
%     ((food_chain_exists(A, X) & food_chain_exists(X, B)) => food_chain_exists(A, B))
%     ).

tff(complete_food_chain_axiom, axiom,
    ! [A: species]: 
    ! [B: species]:
    ((food_chain_exists(A, B) & is_primary_producer(A) & is_apex_predator(B)) <=> complete_food_chain(A, B))
    ).

%----7. Proved
% tff(foodchain_start_not_eats_end, conjecture,
%     ! [S: species, E: species]:
%     (complete_food_chain(S, E) => ~ eats(S, E))
%     ).

%----8. Proved
% tff(middle_species_food_chains, conjecture,
%     ! [M: species]:
%     ((~is_primary_producer(M) & ~is_apex_predator(M)) => 
%     (
%         (? [P: species]: food_chain_exists(P, M)) &
%         (? [A: species]: food_chain_exists(M, A))
%     ))
%     ).

%----dependence is only defined for the apex predator
tff(dependent_axiom, axiom,
    ! [A: species]:
    ! [B:species]:
    (depends_on(A, B) <=> (is_apex_predator(A) & food_chain_exists(B, A)))).

%---9. Proved
% tff(apex_depends_on_not_apex, conjecture,
%     ! [S: species]:
%     (~is_apex_predator(S) => ? [A: species]: depends_on(A, S))).

%----10. Proved
% tff(apex_depends_on_all_primary_producers, conjecture,
%     ! [A:species]:
%     (is_apex_predator(A) => 
%     (! [P: species]:  (complete_food_chain(P, A) => depends_on(A, P))))
%     ).

%----Freshwater Pond

%----declare the species
tff(algae_decl, type, algae: species).
tff(zooplankton_decl, type, zooplankton: species).
tff(fish_decl, type, fish: species).
tff(heron_decl, type, heron: species).
tff(frog_decl, type, frog: species).
tff(insect_decl, type, insect: species).
tff(duckweed_decl, type, duckweed: species).
tff(snail_decl, type, snail: species).
tff(pondweed_decl, type, pondweed: species).
tff(trophic_level_decl, type, trophic_level: (species * $int) > $o).

tff(all_species_axiom, axiom,
    ! [S: species]:
    (S = algae | S = zooplankton | S = fish | S = heron | S = frog | S = insect |  S = duckweed | S = snail | S = pondweed)
    ).

tff(distinct_species_axiom, axiom,
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

% %----declare food links
tff(algae_eats,axiom,
    ! [S: species] : ~ eats(algae,S) ).

tff(duckweed_eats,axiom,
    ! [S: species] : ~ eats(duckweed,S) ).

tff(pondweed_eats,axiom,
    ! [S: species] : ~ eats(pondweed,S) ).

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

% tff(trophic_level_initial_axiom, axiom,
%     ! [S: species]:
%     (is_primary_producer(S) => trophic_level(S, 0))
%     ).

% tff(trophic_level_recursive_axiom, axiom,
%     ! [S: species]:
%     ? [P: species]:
%     (eats(S,P) => ? [L: $int]: (trophic_level(P, L) => trophic_level(S, $sum(L, 1))))
%     ).
tff(trophic_level_def,axiom,
    ! [S: species,N: $int] :
      ( trophic_level(S,N)
    <=> ( ( is_primary_producer(S)
          & N = 0 )
        | ? [T: species,M: $int] :
            ( eats(S,T)
            & trophic_level(T,M)
            & N = $sum(M,1) ) ) ) ).

%----conjectures

%---1
%----Proved
% tff(algae_primary_producer, conjecture, is_primary_producer(algae)).

%---2
%---- Not a theorem: there are no species that eat the heron, it is an apex predator
% tff(heron_not_apex, conjecture, ~is_apex_predator(heron)).

%---3
%----Proved
% tff(fish_not_primary_or_apex, conjecture, (~is_primary_producer(fish) & ~is_apex_predator(fish))).

%----4
%----Proved
% tff(frogs_fish_eat_same, conjecture, 
%     ![S:species]: (eats(frog, S) <=> eats(fish, S))).

%----5
tff(two_complete_food_chains, conjecture,
    ? [S: species, P: species]:
    (complete_food_chain(S, heron) & complete_food_chain(P, heron) & S != P)
    ).

%----6
%----Not a theorem: snails only depend on duckweed and pondweed
% tff(snails_depend_heron, conjecture, depends_on(snail, heron)).

%----7
tff(fish_snail_trophic_level, conjecture,
    ?[F: $int, S: $int]:
    (trophic_level(fish, F) & trophic_level(snail, S) & $greater(F,S))
    ).

%----8
tff(trophic_level_gt_heron, conjecture,
    ? [S: species]:
    ? [L: $int, H: $int]:
    (trophic_level(S, L) & trophic_level(heron, H) & $greater(L,H))
    ).