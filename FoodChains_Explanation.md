# Food Chains Exercise: Explanation

This document explains the file `FoodChains.p`. The file encodes the exercise "Encoding and Solving a Problem" (TUW 184.774, 2026W) in TPTP TFF syntax. The file has two parts: "Food Chains" and "Freshwater Pond".

This document uses Simplified Technical English. The sentences are short. Each term has only one meaning.

## 1. Terms

| Term | Meaning |
|---|---|
| Axiom | A formula that we accept as true. |
| Conjecture | A formula that we try to prove from the axioms. |
| Theorem | A conjecture that the ATP system proved from the axioms. |
| ATP system | An automated theorem prover. We used Vampire 5.0.0. |
| Negation | The opposite of a formula. In TPTP, the symbol is `~`. |
| Model | A "world" in which all the axioms are true. |
| Consistent | The axioms do not contradict each other. At least one model exists. |

## 2. Part 1: Food Chains

### 2.1 Types and symbols

The file declares all the types and symbols before the axioms.

| Symbol | Type | Meaning |
|---|---|---|
| `species` | `$tType` | The species in an ecosystem. |
| `food_link` | `$tType` | One feeding relation between two species. |
| `eaten(L)` | `food_link > species` | The species that is eaten in food link L. |
| `eater(L)` | `food_link > species` | The species that eats in food link L. |
| `eats(X,Y)` | `(species * species) > $o` | X eats Y. |
| `primary_producer(S)` | `species > $o` | S is a primary producer. |
| `apex_predator(S)` | `species > $o` | S is an apex predator. |
| `food_chain(X,Y)` | `(species * species) > $o` | There is a food chain from X to Y. |
| `complete_food_chain(X,Y)` | `(species * species) > $o` | There is a complete food chain from X to Y. |
| `depends(A,S)` | `(species * species) > $o` | Apex predator A depends on species S. |

Be careful with the order of the arguments. `eats(X,Y)` means "X eats Y". `depends(A,S)` means "A depends on S". A food chain goes in the direction of the food, from the eaten species to the eater species. Thus `food_chain(algae,heron)` is correct, and `food_chain(heron,algae)` is not.

### 2.2 How the file models a food chain

The exercise text says that a food chain is a sequence of food links. But the conjectures use only two properties of a chain: the start species and the end species. Thus the file does not keep each chain as an object. It uses the relation `food_chain(From,To)`, which means "there is a food chain from From to To".

Three axioms make this relation. A single food link is a food chain. Two food chains make a longer food chain if the first chain ends where the second chain starts. Every food chain starts with a food link, thus nothing else is a food chain.

An earlier version of the file kept food chains as objects, with the functions `start_of` and `end_of`. That version was correct, but Vampire did not prove pond conjecture 5 in 4 minutes. The relation version is simpler, and Vampire found all the proofs.

### 2.3 Axioms

The axioms are in this order in the file.

| Axiom | What it says | Why it is necessary |
|---|---|---|
| `eats_def` | X eats Y if and only if a food link goes from Y to X. | It connects `eats` to food links. |
| `primary_producer_def` | S is a primary producer if and only if S eats no species. | It defines primary producers. |
| `no_isolated_species` | Each species is the eater or the eaten in at least one food link. | Without it, a species can eat nothing and be eaten by nothing. Then it is a primary producer and an apex predator at the same time, and conjectures 2 and 5 are false. |
| `no_cannibalism` | In a food link, the eater and the eaten are different species. | Conjectures 3 and 6 say "another species". Without this axiom, a species can eat only itself. |
| `apex_predator_def` | S is an apex predator if and only if no species eats S. | It defines apex predators. |
| `complete_food_chain_def` | A complete food chain is a food chain from a primary producer to an apex predator. | It defines complete food chains. |
| `food_link_is_food_chain` | Each food link is a food chain. | It makes the shortest chains. |
| `join_food_chains` | A chain from X to Y and a chain from Y to Z give a chain from X to Z. | It makes the longer chains. |
| `food_chain_starts_with_link` | Each food chain starts with a food link. The link is the full chain, or the rest of the chain follows it. | It prevents false chains, for example a chain from heron to algae. In the pond, it makes the chains exactly the correct ones. |
| `food_chains_reach_down` | If a chain does not start at a primary producer, a chain from a primary producer to its start exists. | Food chains do not continue down forever. Section 2.5 gives the reason for this axiom. |
| `food_chains_reach_up` | If a chain does not end at an apex predator, a chain from its end to an apex predator exists. | Food chains do not continue up forever. |
| `depends_def` | A depends on S if and only if A is an apex predator and a food chain goes from S to A. | It defines dependency. Each species in a chain to A is the start of the remaining part of that chain, thus this definition includes all species in all chains to A. |

The definitions use "if and only if" (`<=>`). The exercise text gives definitions, not only conditions. Also, the prover needs the "only if" direction to prove negative facts. For example, "nothing eats a heron, thus the heron is an apex predator" needs the "if" direction of `apex_predator_def`, and "a snail is not an apex predator" needs the "only if" direction.

### 2.4 Conjectures

The exercise tells us to put each conjecture as early as possible. Thus each conjecture comes immediately after the last axiom that its proof needs. Vampire proved all 10 conjectures, each one from only the axioms above it.

| Conjecture | In words | Important axioms for the proof |
|---|---|---|
| `fc_1` | A primary producer is not the eater of a food link. | `eats_def`, `primary_producer_def` |
| `fc_2` | Another species eats each primary producer. | `no_isolated_species` |
| `fc_3` | A species that is not a primary producer eats another species. | `no_cannibalism` |
| `fc_4` | An apex predator is not the eaten of a food link. | `eats_def`, `apex_predator_def` |
| `fc_5` | Each apex predator eats another species. | `apex_predator_def`, `no_isolated_species` |
| `fc_6` | Another species eats each species that is not an apex predator. | `apex_predator_def`, `no_cannibalism` |
| `fc_7` | The start of a complete chain does not eat the end. | `complete_food_chain_def`, `primary_producer_def` |
| `fc_8` | A species that is not a primary producer and not an apex predator has a chain from a primary producer and a chain to an apex predator. | `food_link_is_food_chain`, `join_food_chains`, both "reach" axioms |
| `fc_9` | For each species that is not an apex predator, an apex predator depends on it. | `food_chains_reach_up`, `join_food_chains`, `depends_def` |
| `fc_10` | An apex predator depends on the primary producer of each complete chain that ends at it. | `complete_food_chain_def`, `depends_def` |

A short example of a proof: for `fc_2`, take a primary producer P. Axiom `no_isolated_species` gives a food link with P in it. P eats nothing, thus P is not the eater. Thus P is the eaten, and the eater eats P. The eater is not P, because P eats nothing.

### 2.5 Why the "reach" axioms are necessary

First-order logic cannot express "finite". Thus a model with an infinite number of species can exist. In such a model, a food chain can continue down forever and never get to a primary producer. Then conjecture `fc_8` is false.

Real food chains are finite. The two "reach" axioms state this fact in a form that first-order logic can express. They say that each food chain can extend down to a primary producer and up to an apex predator.

## 3. Part 2: Freshwater Pond

### 3.1 Types and symbols

There are nine constants of type `species`: `algae`, `duckweed`, `pondweed`, `zooplankton`, `insect`, `snail`, `fish`, `frog` and `heron`.

The predicate `trophic_level(S,N)` means "species S has trophic level N". N has the type `$int`. One species can have more than one trophic level.

### 3.2 Axioms

| Axiom | What it says |
|---|---|
| `pond_all_species` | Each species is one of the nine constants. No other species exists. |
| `pond_distinct_species` | The nine constants are all different (36 inequalities). |
| `algae_eats` to `heron_eats` | One axiom for each species. Each axiom lists exactly what the species eats. |
| `trophic_level_def` | A species has level N if and only if it is a primary producer and N = 0, or it eats a species at level N-1. |

The exercise says that the food chains capture everything that each species eats. Thus each "eats" axiom is an "if and only if". For example, `snail_eats` says that a snail eats S if and only if S is duckweed or pondweed. The three plants have axioms that say they eat nothing.

An earlier version used one large axiom for all of "who eats whom". That version was also correct, but Vampire did not prove the challenge version of conjecture 7 in 4 minutes. With one axiom for each species, Vampire found the proof.

Distinct constants are necessary. Without `pond_distinct_species`, `algae` and `heron` can be the same species in a model. Then the prover cannot prove many conjectures. For example, conjecture 5 needs `algae != duckweed`.

### 3.3 Trophic levels

The definition gives these levels in the pond. Each species in this pond has exactly one level.

| Level | Species |
|---|---|
| 0 | algae, duckweed, pondweed |
| 1 | zooplankton, insect, snail |
| 2 | fish, frog |
| 3 | heron |

A species gets two levels if it eats species at different levels. For example, if a heron also eats snails, the heron has levels 2 and 3.

### 3.4 Results

The conjectures come after all the axioms. Each theorem has the comment `%----Proved`. Each non-theorem has a comment that tells how we found the result.

| No. | Conjecture | Result | Reason |
|---|---|---|---|
| 1 | Algae is a primary producer. | Theorem | Algae eats nothing. |
| 2 | Heron is not an apex predator. | Not a theorem | Nothing eats a heron, thus a heron is an apex predator. Vampire proved the negation. |
| 3 | A fish is not a primary producer and not an apex predator. | Theorem | Fish eat zooplankton. Herons eat fish. |
| 4 | Frogs and fish eat the same species. | Theorem | Both eat exactly zooplankton, insects and snails. |
| 5 | Two complete chains end at heron and start at different species. | Theorem | For example, algae to zooplankton to fish to heron, and duckweed to snail to frog to heron. |
| 6 | Snails depend on herons. | Not a theorem | Only apex predators depend on species. A snail is not an apex predator. Vampire proved the negation. The opposite direction, "herons depend on snails", is true. |
| 7 | A level of fish is greater than a level of snail. | Theorem | Fish are at level 2. Snails are at level 1. |
| 7 (challenge) | All levels of fish are greater than all levels of snail. | Theorem | Fish have only level 2. Snails have only level 1. |
| 8 | A species has a level greater than a level of heron. | Not a theorem | Heron has only level 3. No species has a level above 3. See section 3.5. |

To show that a conjecture is not a theorem, we proved its negation. The axioms are consistent (section 4). Thus the axioms cannot prove a conjecture and its negation at the same time.

### 3.5 How we found that conjecture 8 is not a theorem

Vampire did not prove the negation of conjecture 8 in one step in 280 seconds. Thus we divided the proof into four steps. Vampire proved each step from the axioms and the steps before it. A step that the axioms prove does not add new information. Thus the negation follows from the axioms alone.

| Step | Statement | Uses | Time |
|---|---|---|---|
| 1 | No chain of four eating steps exists: `~ ? [A,B,C,D,E] : ( eats(A,B) & eats(B,C) & eats(C,D) & eats(D,E) )` | Axioms | 0.2 s |
| 2 | The heron has only level 3: `! [H] : ( trophic_level(heron,H) => H = 3 )` | Axioms | A few minutes |
| 3 | Each level is 3 or less: `! [S,N] : ( trophic_level(S,N) => $lesseq(N,3) )` | Axioms, step 1 | Less than 2 minutes |
| 4 | The negation of conjecture 8 | Axioms, steps 2 and 3 | 0.02 s |

Step 3 uses step 1 because each level above 0 needs one eating step. Thus a level of 4 or more needs four eating steps, and step 1 says that four eating steps do not exist.

## 4. Consistency checks

Consistent axioms are necessary. If the axioms contradict each other, the prover can prove each conjecture, and the results have no value.

For the Food Chains axioms, the Vampire finite model builder (`vampire -sa fmb`) found a model immediately. The model has one plant and one animal that eats the plant.

For all the axioms except `trophic_level_def`, the finite model builder was very slow. It increased the number of food links one at a time, and the pond needs 13 food links. After about 4 minutes, it was at 11 food links. Thus we made a separate check file. This file adds 13 named food links to the axioms. With this file, the finite model builder found a model in 0.1 seconds. A model of the larger set of formulas is also a model of the smaller set. Thus the axioms are consistent.

The finite model builder cannot use `$int`, thus it cannot check `trophic_level_def`. We used the Z3 solver for this axiom. Z3 found a model with exactly the levels in section 3.3. There is also a logical reason: `trophic_level_def` is a recursive definition on the "eats" relation. This relation has no cycles in the pond, thus the definition has exactly one solution.

The header of `FoodChains.p` records these results.

## 5. How to run the proofs

An ATP system processes only one conjecture at a time. For a Food Chains conjecture, use only the axioms above the conjecture. For a Freshwater Pond conjecture, use all the axioms. In both cases, remove all the other conjectures.

The script `split_conjectures.py` does this work. Run it in the folder that contains `FoodChains.p`:

```
python3 split_conjectures.py FoodChains.p
```

The script makes the folder `problems/`. This folder has one file for each conjecture, and one file with the negation of each conjecture (the name ends in `_negated`). Then run Vampire on a file, for example:

```
vampire --mode casc -t 300 problems/pond_5.p
vampire --mode casc -t 300 problems/pond_2_negated.p
```

The result "SZS status Theorem" tells you that Vampire found a proof. Most proofs take less than one second. Pond conjectures 5 and 7, the challenge version of 7 and step 2 of section 3.5 can take a few minutes. For the consistency check, use this command on a file that has only the axioms:

```
vampire -sa fmb -t 60 axioms.p
```

The result "SZS status Satisfiable" tells you that the axioms are consistent.

## 6. Questions that the tutor can ask

**Why do the definitions use "if and only if"?**
The text gives definitions. Also, the prover needs both directions. The "if" direction proves positive facts, for example "the heron is an apex predator". The "only if" direction proves negative facts, for example "a snail is not an apex predator".

**Why is `no_isolated_species` necessary?**
Without it, a species can eat nothing and be eaten by nothing. That species is a primary producer and an apex predator at the same time. Then conjectures 2 and 5 of Food Chains are false.

**Why is `no_cannibalism` necessary?**
Conjectures 3 and 6 say "another species". Without this axiom, a species can eat only itself.

**Why are the "reach" axioms necessary?**
First-order logic cannot express "finite". In an infinite model, a chain can continue down forever and never get to a primary producer. The "reach" axioms state that chains are finite, in a form that first-order logic can express.

**Why is a food chain a relation and not an object?**
The conjectures use only the start and the end of a chain. The relation is simpler, and the prover finds the proofs faster. A version with chain objects was correct, but the prover did not prove pond conjecture 5 in 4 minutes.

**Which axiom says that the food chains capture everything that each species eats?**
The nine "eats" axioms. Each one is an "if and only if" that lists exactly what one species eats.

**Why are `pond_all_species` and `pond_distinct_species` necessary?**
The exercise tells us to encode these facts. Without distinct constants, two names can refer to the same species in a model. Then the prover cannot prove many conjectures, for example conjecture 5.

**How do you know that a conjecture is not a theorem?**
We proved its negation, and the axioms are consistent. Consistent axioms cannot prove a formula and its negation.

**Why is pond conjecture 6 false?**
`depends(A,S)` means "A depends on S". Only apex predators depend on species. A snail is not an apex predator, because fish and frogs eat snails. The opposite statement, "herons depend on snails", is true.

**Why can a species have more than one trophic level?**
A species can eat species at different levels. In this pond, each species has only one level. If a heron also eats snails, the heron has levels 2 and 3.
