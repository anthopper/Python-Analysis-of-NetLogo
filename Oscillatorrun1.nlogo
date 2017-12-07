extensions [csv]
breed [rants rant]
breed [redqueens redqueen]
breed [nests nest]
breed [queens queen]
breed [males male]


turtles-own [
  paint-color ;; turtles prefered food color (or could think of these digital agents eating paint)
  max-size ;the max size this ant can't reach
  age ;ant's age
  foraging-time  ;the time an ant spends foraging
  inbred? ; bolean to check if inbred, the phenomena is theorized to explain why ants send our their reproductives together ;; UJW - fixed spelling
  birth-number ; reproductive cue: a random time to reproduce reproductives
]


patches-own [
  chemical             ;; amount of chemical on this patch
  chemicalkill         ;; attack pheremone
  chemicalload         ;; total amount of chemical on patch
  nest?                ;; true on nest patches, false elsewhere

]
rants-own [
  antergy               ;; when it runs out, the ant is no more
  mother                ;; stores the ant's mother nest
  startColor            ;; the color of the ants home nest
  startNest             ;; the ants home colony
]

nests-own [
  foodstore            ;; the total food stored inside the nest
  timing-distance
  mother                ;;stores the ant's mother nest
]

queens-own [
  foodstore ;; queens carry some food with them in fat on their body to found the new nest
]

globals [
  bareGround
  inediblePlant#1
  inediblePlant#2
  inediblePlant#3
  Sample
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedure ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setupring ;; sets up a number of colonies in random locations on the map, each with 10 ants that belong to each nest
  clear-all
  ;csv:to-file "myfile.csv" [[][]]
  ;csv:to-row ["one" 2 true "/n"]
  ask patches
  [ set nest?  false
    set pcolor green
  ]
  ask n-of 500 patches
    [ set pcolor random 140
    ]

    create-colony-ring 1
  create-colony-ring 1

  set-default-shape rants "bug"
  set-default-shape redqueens "bug"



  if number-of-colonies > 0
    [ ;; if there are any colonies, hatch some rants in those colonies (check because possible to run model for understanding the environmental parts without ants
      ask nests
        [
          hatch-rants 10
          [
            set size 1
            set mother myself
            set startColor color
            ;set color red
            set paint-color yellow
            set antergy 2000
            set label ""

          ]
        ]
    ]

  ask nests [ set label birth-number set label-color black ] ;; give each nest at start a hard coded randam number, that if called on, they reproduce.  Then set labels to show the birth number
                                                                   ;;Overtime, we'll see a synchonization on a small set of emergence times.
  ask turtles
    [ set age  1 ]
  set bareGround 35      ;; the color we define as "open ground"
  set inediblePlant#1 45 ;; three types of undible plants
  set inediblePlant#2 55 ;; this undeible plant is used as a ubiquetous plant "grass" that with high regrow rates, will dominate the simulation. Tryi Changing it to blue (95), It will make rain
  set inediblePlant#3 115
  reset-ticks
end

to setup ;; sets up a number of colonies in random locations on the map, each with 10 ants that belong to each nest
  clear-all
  ask patches
  [ set nest?  false
    set pcolor green
  ]
  ask n-of 500 patches
    [ set pcolor random 140
    ]
  create-nests number-of-colonies
  [
    setxy random max-pxcor - random min-pxcor random max-pycor - random min-pycor
    set size 10
    set shape"circle"
    set inbred? false
    set nest? true
    set timing-distance 0
    ask neighbors

    [ set nest? true ]

    set mother self ;; a way to compare to their foragers to see if they are of the same nest (something real ants do with hydrocarbons on their skin)
  ]
  set-default-shape rants "bug"
  set-default-shape redqueens "bug"



  if number-of-colonies > 0
    [ ;; if there are any colonies, hatch some rants in those colonies (check because possible to run model for understanding the environmental parts without ants
      ask nests
        [
          hatch-rants 10
          [
            set size 1
            set mother myself
            set startColor color
            ;set color red
            set paint-color yellow
            set antergy 2000
            set label ""

          ]
        ]
    ]

  ask nests [ set birth-number random 364 set label birth-number set label-color black ] ;; give each nest at start a hard coded randam number, that if called on, they reproduce.  Then set labels to show the birth number
                                                                   ;;Overtime, we'll see a synchonization on a small set of emergence times.
  ask turtles
    [ set age  1 ]
  set bareGround 35      ;; the color we define as "open ground"
  set inediblePlant#1 45 ;; three types of undible plants
  set inediblePlant#2 55 ;; this undeible plant is used as a ubiquetous plant "grass" that with high regrow rates, will dominate the simulation. Tryi Changing it to blue (95), It will make rain
  set inediblePlant#3 115
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;
;;; Go procedure ;;;
;;;;;;;;;;;;;;;;;;;;;

to go ;; every time step move ants, and reproductives, while changing the environment, killoff ants who don't have food, and kill off nests who don't have ants
      ;;asks red ants, if they are not carrying food, to look for food, otherwise follow the nest-scent back to the nest along the way regardless wiigle,
      ;;and move forward 1.
 ;if ticks = 4137 [stop]
  ask rants
    [
      ifelse color = startColor
        [ look-for-food  ]       ;; not carrying food? look for it
        [ return-to-nest ]       ;; carrying food? take it back to nest
      wiggle
      fd 1
      ifelse hide-ants? = true [ht][show-turtle]
    ]
  ask nests with [foodstore > 3]
    [ produce-gynes 1 1 set foodstore foodstore - 2
      hatched-rant 1 set foodstore foodstore - 1
      ask rants-here with [ mother = [ mother ] of myself ]
      [ if random 100 < 15
        [ set color startcolor ]

      ]
    ]


  diffusion ;; 3 out of 1000s of the time, divide patch color by eight and diffues it to neighbors
  diffusion-pheremone             ;; slowly evaporate pheramone trails
  grow                           ;;  ask all ants to grow, if their size is less than 4
  check-death
  ask turtles
  [ set age age + 1 ] ;; increment ant age by 1 each time step

  move-gametes



  regrow-grass regrowth ;; regrows grass at a particular rate 15, 7 and 25 are interesting rates
  issue-of-inbreeding   ;; if the switch of inbreeding is switched on, kill inbred colonies
  kill-empty-nest
  if ticks mod 364 = winter-time [ask n-of 500 patches [set pcolor bareGround]]
  if ticks mod 364 = Spring-Time [ask  patches  [set pcolor 55]]
  sampledata
  tick
end

to check-death ; check to see if turtles will die,
               ;; A grim reaper function to simulate mortality
  ask rants
    [ ; check ant death
      set antergy antergy - 0.1
      if antergy - (age / 1000) <= 0
        [ die ] ]
    ask queens [if random age > 60 [die]]
     ask males [if random age > 60 [die]]
     ask n-of (random count rants * .01) rants  [die]
end

to diffusion
  diffuse pcolor plant-seeding ;;both worked, but added a plant-seeding slider for your clarity
end


to return-to-nest  ;; red ant procedure that when having food teach other ants food preferences while walking back to nest.
  tandem-running
  ifelse nest? ; if at a nest, drop it off
    [ set color startColor
      let delevery-point one-of nests in-radius 2
      if delevery-point != nobody
        [

          ask delevery-point [set foodstore foodstore + 1]
          rt 180
        ]
    ];; drop food and head out again

  [set chemical chemical + 60  ;; else, drop some chemical
    if mother != nobody [face mother] ;; go back toward the location of the home nest with the possibility of stopping at another nest if it interupts the path
  ]
end

to reproduce-ants ;; makes new colonies of ants. When a female meets a male of a different color, they mate.
                  ;;The males dies and the queen burrows into the ground and makes a nest.
 ask queens [
  let prey one-of males in-radius 1
  if prey != nobody [
    ask prey [
      face myself

    if [breed] of prey = males
    [

    if myself != nobody [
;      [
       if [birth-number] of prey = [birth-number] of myself + 1 or  [birth-number] of prey = [birth-number] of myself - 1 [
           ; if [birth-number] of prey != [birth-number] of myself [


        hatch-nests 1
        [
          set mother self ;; sets the colony's ID to the hatched agent so that its workers can check belonging against the mother

                set age 0
          set color [color] of prey
          hatched-rant 4


          set shape "anthill"
           set size 20
          set timing-distance emergence-time-distance ([birth-number] of myself) ([birth-number] of prey) ;; makes sure the colony ring holds
          ask patch-here
          [set nest? true
            ask neighbors [set nest? true] ]
        set size 10
        ]
          ask prey[die] die]


    ]
  ]
 ]
 ]
 ]

end

to look-for-food
  ;;Turtle procedure teaches other turtles good food sources with tandum running,
  ;;then checks if the current patch is a shade of the prefered food patch,
  ;;if so set energy +250, if not, and the patch isn't black, 10% of the time,
  ;;change preferences and set food + 20, then go right 180 degrees, and head for the nest.
  set foraging-time foraging-time + 3

  if not shade-of? bareGround pcolor and shade-of? pcolor paint-color
    [ set color startColor + 3
      set paint-color pcolor     ;; pick up food
      set pcolor bareGround
      set antergy antergy + 250
      rt 180                   ;; and turn around
      stop
    ]
  if random 1000 < 1
  [ if not shade-of? pcolor bareGround and pcolor != inediblePlant#3 and pcolor != inediblePlant#2 and pcolor != inediblePlant#1
    [
      set color startColor + 3
      set paint-color pcolor     ;; pick up food
      set pcolor bareGround
      set antergy antergy + 20
      rt 180                   ;; and turn around
      stop
    ]
  ]
  ;; go in the direction where the chemical smell is strongest
  if (chemical >= 0.05) ;and (chemical < 2)
  [ uphill-chemical ]
end

;; sniff left and right, and go where the strongest smell is
to uphill-chemical  ;; turtle procedure
  let scent-ahead chemical-scent-at-angle   0
  let scent-right chemical-scent-at-angle  45
  let scent-left  chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
    [ ifelse scent-right > scent-left
      [ rt 45 ]
      [ lt 45 ] ]
end

to wiggle  ;; turtle procedure which randomly moves ants
  rt random 40
  lt random 40
  ;; BCH - You have world wrapping on, so `can-move?` will always return true.
  if not can-move? 1 [ rt 180 ]
end

to birth
      Produce-gynes 1 1
      hatched-rant 1
end

to hatched-rant [sumant] ; this procedure hatches some rants
  hatch-rants sumant
  [
    if Hide-ants? = true [ht]
    set antergy 2000
    set mother myself
    set startColor color
    set shape "bug"
    set size 1
    set label ""
    set age 0
  ]
end

to-report chemical-scent-at-angle [angle] ; reports the amount of pheramone in a certain direction
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical] of p
end

to diffusion-pheremone ;; UJW - spell "pheromome"
  diffuse chemical (diffusing / 100)
  ask patches
    [ set chemical chemical * (100 - evaporation-rate) / 100 ]  ;; slowly evaporate chemical
end

to grow ; if size is less than 4, increment size by .05%, elsewise keep the size 4
  ask turtles [ifelse size < 4 [ set size size * 1.005 ]
    [ set size 4 ] ]
end


to make-nest [x y aColor]
  create-nests 1 [ setxy x y set size 10 ask patch-here
    [set nest? true ask neighbors
      [ set nest? true]
    ]
  set shape"circle" set color aColor
  ] ;; creates a nest and puts the signal of nest on the patch
end

to produce-Fgynes [sumFemales] ;produces female reproductives
  ask nests[
    if count rants with [color = [color] of myself] > 5
      [ ;; BCH - You can simplify this to:
        ;; ifelse finger-of-god?
        ;; (dropping the `= true`).
        ifelse finger-of-god? = true
        [ hatch-queens sumFemales
          [ set shape "Queens" set size 10
          ]
      set foodstore foodstore - 50
        ]
        ;;meets virtgin queen
        [ if ticks mod 364 = birth-number ;; change to if random 100 for drift
          [ hatch-queens sumFemales
            [ set shape "queens" set size 10]
          set foodstore foodstore - 50
          set birth-number birth-number ;;+ (random 1 - random 1)


          ]
        ] ; checks if the birth cue has happen,
                                      ;that tree bloomed or that weather changed, and then reproduced

      ]
  ]
end


to produce-Mgynes [sumMales] ;produces male reproductives
  ask nests
    [ if count rants with
      [ color = [color] of myself] > 5
      [ ifelse finger-of-god? = true
        [ hatch-males sumMales
          [ set shape "butterfly" set size 2 set age 0]
        set foodstore foodstore - 50
        ]
        [ if ticks mod 364 = birth-number ;; change to if random 100 for drift
          [hatch-males sumMales
            [set shape "butterfly" set size 5 set birth-number [birth-number] of myself ]
          set foodstore foodstore - 50
          ;;+ (random 1 - random 1)
          ]

        ]
      ]
    ]
end

to Produce-gynes [sumMales sumFemales]

      if ticks mod 364 = birth-number ;; change to if random 100 for drift
    [  hatch-males sumMales [set shape "butterfly" set size 5 set age 0 ]
      hatch-queens sumFemales [ set shape "queens" set size 10 set age 0]
      set foodstore foodstore - 50
    ]
end

to regrow-grass [sumGrass]
  ;Ants pioneer into new environments. As a result, they usually do not have the enzymes to break down many types of well defended foods.
  ;I simulate this by having grass (a majority plant type) regrow. So I special case three out of 14 colors to simulate this situation.
  ask n-of sumGrass patches [set pcolor inediblePlant#2] ;added a regrowth slider so can play with the rate of regrowth
end

to-report inbred-ratio ; reports ratio of inbreeding
  let return 0 ;; BCH - You don't need to set `return` to 0. Actually, you don't need the `return` variable at all.
  set return (count turtles with [inbred? = true] / count turtles with [inbred? = true])
  report return
end

to issue-of-inbreeding ;provides negative selection of inbred colonies, potentially showing their high disease rate, lack of robustness,
                       ;or other deleterous outcomes of sharing alleles
  if inbred-consequence? = true
    [ if any? turtles with [inbred? = true]
      [ ask one-of turtles with [inbred? = true]
        [die]
      ]
    ]
end

to tandem-running ; teach another ant here my food preference
  let student one-of other turtles-here
  if student != nobody
  [ if [breed] of student = breed
    [ ask student
      [ set paint-color [paint-color] of myself
      ]
    ]
  ]
end

to kill-empty-nest ;; if the ants of the new nest don't return food before they all die (fail to establish) the colony dies
  ask nests
    [ set foodstore foodstore - 0.1
      if foodstore < -100
      [ ask rants  with [ mother = [ mother ] of myself ]
        [die]
        ask patch-here
          [ set nest? false ask neighbors
            [ set nest? false] ]
        die ]
  ]

  ask nests
    [ if not any? rants with [mother = [mother] of myself]
      [ask rants with [ mother = [ mother ] of myself ]
        [die]
        ask patch-here
          [ set nest? false ask neighbors
            [ set nest? false] ] die
      ]
      if constrained = true [
        if not any? nests with [birth-number = [birth-number] of myself + 1 or birth-number = [birth-number] of myself - 1]
      ;;becuase if there are no nests for this colony to mate with in the ring, than they, evolutionarily speaking are dead, I just prune them. this does not mean they could not
      ;ecologically survive for quite some time, it just means from my analysis standpoint, they are no longer relevent.

        [ask rants-here with [ mother = [ mother ] of myself ]
       [die]
        ask patch-here
          [ set nest? false ask neighbors
            [ set nest? false] ] die
      ]
      ]
      if age / 364 > 25
      [ ask rants-here with [ mother = [ mother ] of myself ]
        [die]
        ask patch-here
          [ set nest? false ask neighbors
            [ set nest? false] ] die
      ]
    ]
end

to-report emergence-time-distance [cue1 cue2]
  let return 0
  set return abs ( cue1 -  cue2)
  report return
end

to-report average-emergence-distance
  let return 0

  if count nests > number-of-colonies [set return mean [timing-distance] of nests with [timing-distance != 0]]

report return
end

to create-colony-ring [asum]
  let birthy-number 1
  let ccolor 5

  repeat number-of-colonies
  [
    create-nests asum
    [
      ;setxy random-pxcor random-pycor
      set birth-number birthy-number
      setxy (birthy-number) (birthy-number + birthy-number + 1)
      fd birth-number
      ;set color birthy-number
      set size 10
      set shape"anthill"
      set inbred? false
      set nest? true
      set timing-distance 1
      ask neighbors
      [ set nest? true ]

      set birthy-number birthy-number + 1
      set color ccolor
      ;if any? other nests with  [birth-number = [birth-number] of myself] [create-links-to other nests with [birth-number = [birth-number] of myself]]
       ;setxy birthy-number (birthy-number * - 1)




      set mother self ;; a way to compare to their foragers to see if they are of the same nest (something real ants do with hydrocarbons on their skin)
    ]

  set ccolor ccolor + 10
  ]
end

to-report MatingDay [aDay]

  ask nests [show birth-number]

end

to move-gametes
   ask queens
    [ wiggle
       ; makes workers
      fd 1 ]
reproduce-ants
  ask males
    [ wiggle
      fd 1 ]
end

to sampledata
  let time ticks
  if ticks = 0 [set Sample 0]
  Set Sample Sample + 1
  ;show csv:to-row [(list ticks birth-number)] of nests
  csv:to-file (word "Osciliation" Ticks".csv") [(list ticks birth-number xcor ycor color foodstore )] of nests


end
@#$#@#$#@
GRAPHICS-WINDOW
0
45
518
564
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
22
10
88
43
setup
setupring
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
10
153
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
485
925
660
958
show-food-preference?
show-food-preference?
1
1
-1000

SLIDER
890
815
1062
848
number
number
0
200
200.0
1
1
NIL
HORIZONTAL

SLIDER
153
815
327
848
energy-from-grass
energy-from-grass
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
335
818
507
851
birth-energy
birth-energy
0
100
92.0
1
1
NIL
HORIZONTAL

SLIDER
165
10
257
43
regrowth
regrowth
0
40
40.0
1
1
NIL
HORIZONTAL

SLIDER
517
818
689
851
regrow
regrow
0
1000
24.0
1
1
NIL
HORIZONTAL

SLIDER
695
925
867
958
diffusing
diffusing
0
1
0.0
.01
1
NIL
HORIZONTAL

SLIDER
695
890
867
923
evaporation-rate
evaporation-rate
0
100
83.0
1
1
NIL
HORIZONTAL

SWITCH
310
885
473
918
show-chemicals?
show-chemicals?
0
1
-1000

SLIDER
515
855
687
888
evaporationrate
evaporationrate
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
310
925
482
958
murderer
murderer
0
100
0.0
.01
1
NIL
HORIZONTAL

SLIDER
715
815
887
848
foodbonus
foodbonus
0
200
199.0
1
1
NIL
HORIZONTAL

SLIDER
265
10
435
43
number-of-colonies
number-of-colonies
0
364
54.0
1
1
NIL
HORIZONTAL

INPUTBOX
127
922
282
982
Red-colony-x
0.0
1
0
Number

INPUTBOX
220
922
301
983
red-colony-y
0.0
1
0
Number

INPUTBOX
130
855
216
917
blue-colony-x
7.0
1
0
Number

INPUTBOX
220
855
302
915
blue-colony-y
25.0
1
0
Number

PLOT
520
45
985
330
Populations by Colony Color
Time
Population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Grey" 1.0 0 -7500403 true "" "plot count rants with [startcolor = 5]"
"Yellow" 1.0 0 -987046 true "" "plot count rants with [startcolor = 45]"
"Brown" 1.0 0 -6459832 true "" "plot count rants with [startcolor = 35]"
"Teal" 1.0 0 -11221820 true "" "plot count rants with [startcolor = 85]"
"Magenta" 1.0 0 -5825686 true "" "plot count rants with [startcolor = 125]"
"Violet" 1.0 0 -8630108 true "" "plot count rants with [startcolor = 115]"
"Turquois" 1.0 0 -14835848 true "" "plot count rants with [startcolor = 75]"
"Red" 1.0 0 -2674135 true "" "plot count rants with [startcolor = 15]"
"Sky" 1.0 0 -13791810 true "" "plot count rants with [startcolor = 95]"
"pink" 1.0 0 -2064490 true "" "plot count rants with [startcolor = 135]"
"Lime" 1.0 0 -13840069 true "" "plot count rants with [startcolor = lime]"
"Orange" 1.0 0 -955883 true "" "plot count rants with [startcolor = orange]"
"Green" 1.0 0 -10899396 true "" "plot count rants with [startcolor = green]"
"blue" 1.0 0 -13345367 true "" "plot count rants with [startcolor = blue]"

SWITCH
1695
10
1828
43
nest-friend?
nest-friend?
1
1
-1000

SWITCH
1695
80
1860
113
inbred-consequence?
inbred-consequence?
0
1
-1000

SWITCH
1695
45
1825
78
finger-of-god?
finger-of-god?
1
1
-1000

PLOT
525
340
990
650
Distribution of Emergence Cues
Emergence Cue
Percent
0.0
364.0
0.0
50.0
true
false
"" ""
PENS
"Birth-number" 1.0 1 -16777216 true "" "histogram [birth-number] of nests"

PLOT
-1
588
229
738
Prefered Food Color
NIL
NIL
0.0
140.0
0.0
10.0
true
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram [paint-color] of rants"

PLOT
229
588
519
738
Color of Food Sources
NIL
NIL
0.0
140.0
0.0
10.0
true
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "Histogram [pcolor] of patches"

SLIDER
445
10
617
43
plant-seeding
plant-seeding
0
1
0.01
.01
1
NIL
HORIZONTAL

PLOT
1010
50
1210
200
Number of Nests
Time
Nests
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count nests"

MONITOR
1010
210
1067
255
Queens
count Queens
17
1
11

MONITOR
1070
210
1202
255
Male Reproductives
Count males
17
1
11

PLOT
1011
262
1329
552
Gynes
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Males" 1.0 0 -16777216 true "" "plot count males"
"Queens" 1.0 0 -7500403 true "" "plot count queens"

PLOT
1009
556
1254
706
Food of Nests
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "Histogram [foodstore] of nests"

MONITOR
565
700
660
745
NIL
average-emergence-distance
17
1
11

PLOT
925
710
1125
860
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"How Close" 1.0 0 -16777216 true "" "plot average-emergence-distance"

PLOT
705
710
905
860
How much time is between Nests Emergence time?
NIL
NIL
0.0
100.0
0.0
400.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "Histogram [timing-distance] of nests"

MONITOR
565
765
650
810
Max-Emergence-Difference
max-one-of nests [timing-distance]
2
1
11

SWITCH
635
10
757
43
Hide-ants?
Hide-ants?
0
1
-1000

SLIDER
775
10
947
43
Spring-Time
Spring-Time
1
300
28.0
1
1
NIL
HORIZONTAL

SLIDER
955
10
1127
43
Winter-Time
Winter-Time
1
300
228.0
1
1
NIL
HORIZONTAL

PLOT
1210
50
1410
200
Emergence Cue
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ticks mod 300"

MONITOR
1140
0
1197
45
Year
ticks / 364
0
1
11

SWITCH
1210
20
1337
53
constrained
constrained
1
1
-1000

@#$#@#$#@
## Instructors' Comments - BCH & UJW

UJW has some comments also in the body of the info tab

This is much improved over the old version. The removal of the wolf/sheep component helped focus the code quite a bit, while your general reformatting, use of global variables to store important constants, and so forth have made the code much easier to read.

However, there are a couple rather significant bugs that prevent the model from what (I think) you want it to do. The primary problem is that the actual value of `birth-number` does not matter at all, as each check of `birth-number` uses a different random number. This means that multiple nests having the same `birth-number` does not result in any kind of synchronization between the nests. The only reason you end up with all nests having a single `birth-number` is drift. Furthermore, the fact that birth just occurs based on a random number check means that it doesn't actually end up being oscillatory at all; it simply has a 1% chance of happening when the nest has enough resources. Given the talk of oscillation here and in the paper, I assume this is not how it's supposed to work. Perhaps you meant to use something like `ticks mod 100 = birth-number` as the condition for production. That *would* result in oscillatory production as well as synchronization between nests (though I would guess that drift is still the primary mechanism behind any synchronization). Also, I would think that `birth-number` would mutate slightly for new nests. I apologize for not spotting these and other problems before.

You're gyne generation code also ends up being called too many times due to some nested asks.

Besides those problems, there are a few more minor bugs and areas that could use a little cleanup. See code tab for details.

A few other points:

- Rather than commenting every line with a restatement of what a line does, it's a good idea to write comments with the intention behind possibly ambiguous code. For instance, in the food drop off code, a comment stating that it's intentional that an ant can drop off at the wrong nest (as a source of noise) would help clarify why the code is the way it is. Writing good comments is surprisingly difficult, but they are extremely helpful, both for when working with others and when coming back to code you haven't looked at in a while.

- While a histogram for "Distribution of Emergence Cues" is convenient, it makes it harder to see the shift in cues over time that is central to your model. You might try creating a temporary plot pen for each `birth-number`, and then plot the prevalence of each of the birth numbers over time. This is definitely a more complicated plotting technique, so let me know if you're interested and would like to go over the details. Just to be clear, this point isn't a criticism of your model, but rather a suggested algernative visualization to highlight the phenomenon you're interested in.

- The `energy-from-grass`, `birth-energy`, `regrow`, `number`, `murderer`, `show-chemicals?`, `show-food-preference?`, `blue-colony-x`, `blue-colony-y`, `red-colony-x`, and `red-colony-y` widgets are not used and should be removed. As is, they clutter the interface, making it quite difficult to use.

## WHAT IS IT?

In this simulation, we show how the time of year when ants emerge to reproduce is an evolutionary oscillator. Colonies of ants forage for food in a changing world. Though each ant follows a set of simple rules, the colonies act in a sophisticated way to reproduce the nest superorganism.
;; UJW - this section needs some expansion and clarification. It is cryptic and the result would be unclear to most readers.

## HOW IT WORKS

The model works at three levels. At the lowest level, fourteen species of plants, each marked by a color, disseminate their seeds and grow in the world, hybridizing with nearby plants to form the environment. At the meso individual ant level, ants go out in the world, learn to select food from amongst this environment, and teach other ants their food preferences and thus learn to supply the nest with food to raise young and make more ants in a changing world. At the highest level, the macro-level, nests gather food using workers, in order to gather enough resources to produce reproductive ants who fly around, and when a male reproductive meets a female reproductive, they mate and a new colony is founded. Together this model shows, that in a changing world, the cue that releases ants to take nuptial flights at the same time in each ecosystem is an emergent oscillator.

## HOW TO USE IT

Click the SETUP button to set up the ant nests (circles dotting the map in various colors). Click the GO button to start the simulation.

;; UJW - remember to capitalize UI elements
To affect how many colonies the simulation starts with, change the “number-of-colonies”  slider. To increase how many patches will regrow grass, increase the “regrowth” slider. To effect the rate at which plants disseminate seed to their neighbors, move the “plant-seeding” slider.

## THINGS TO NOTICE

When the model starts take note of the “Distribution of Emergence Cues” histogram. You should see one column for each colony. But hold on, in 5,000 ticks this graph will show the surprising emergent outcome of this simulation. While you wait take notice of two micro and meso level interactions that simulate the real world of ants.

1.	At the plant level, notice that as you change the “plant-seeding” slider that the ecosystem changes more or less rapidly. At what rate do ant colonies grow the fastest? Make a hypothesis and test it using the “Population by Colony Color" graph. At which rates do the graphs increase most rapidly? Least rapidly?

2.	To inquire why they are behaving that way inspect the histograms “preferred food color” which shows the ants' favorite kinds of food. Imagine each color is a flavor of icecream. While a child can change its prefered flavor, it can only have one favorite at a time. Likewise, an ant's preference changes based on what food she finds, too. Compare the ants' preferred color to what color of food are available as shown by the histogram “Color of Food Sources”, which shows the distribution of patches of different colors.

Finally, after the model has run for more than 5,000 ticks, notice that the graph  “Distribution of Emergence Cues” goes from many different cues when the model began to just a few.Try running the model several times and notice how many bars you notice.
## THINGS TO TRY

Before starting the model, try different values of the “number-of-colonies" slider. While running the model, try increasing or decreasing the “regrowth” and “plant-seeding” sliders. What changes on the population graph? On the “Preferred Food Color” histogram? On the “Color of Food” histogram? on the "The Distrubution of Emergence Cues" histogram?

## EXTENDING THE MODEL

To extend the model go to the setup procedure in the code tab. Try changing the color value of inediblePlant#1-#3. Try changing the value of barenGround from 35 (brown) to some other color. How does placing different colors off limits {UJW - "off limits?"} affect the model? Does it affect the distribution of emergence cues? Try introducing two new breeds, they will be a pollinator agent, and a predator for it. Define how they move. Do they affect the outcome of the distrubtion of emergence cues? Finally, try changing colonies random emergence cue held in their variable “birth-number.” Does increasing or decreasing the range of values affect the range after 5,000 ticks? Why or why not? Add in a function so that ants of different colors kill each other. How does ant war change the outcoume? How about the outcome of the distribution cues? Do you find that the outcome is robust to changes in variables? What would you conclude about the claim that “regardless of the underlying ecosystem, emergence cues synchonize"?

## NETLOGO FEATURES

The built-in `diffuse` primitive lets us diffuse the plant life easily without complicated code.

The hatch primitives allows us to complete agent inheritance without complicated code.


## RELATED MODELS

* Wilensky, U. (1997).  NetLogo Ants model.  http://ccl.northwestern.edu/netlogo/models/Ants.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.


## COPYRIGHT AND LICENSE

Copyright 2016 Kit Martin


## Built with NetLogo
Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

anthill
false
1
Polygon -6459832 true false 60 225 105 105 135 120 165 120 195 105 240 210 150 225
Polygon -6459832 false false 107 106 135 94 162 93 191 103 165 120 137 123
Polygon -16777216 true false 112 109 134 99 162 98 185 105 162 122 135 122
Line -7500403 false 195 105 195 30
Rectangle -2674135 true true 116 30 191 60

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 90 206 90
Circle -7500403 true true 120 137 60
Circle -7500403 true true 110 60 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30
Circle -7500403 true true 135 180 30
Line -16777216 false 120 150 75 120
Line -16777216 false 135 165 90 165
Line -16777216 false 135 180 60 195
Line -16777216 false 165 150 210 105
Line -16777216 false 165 165 240 135
Line -16777216 false 165 180 210 210
Line -16777216 false 210 210 225 195

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 124 148 85 105 40 90 15 105 0 150 -5 135 10 180 25 195 70 194 124 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60
Circle -16777216 true false 116 221 67

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

queens
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 124 148 85 105 40 90 15 105 0 150 -5 135 10 180 25 195 70 194 124 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60
Circle -16777216 true false 116 221 67
Polygon -1184463 true false 140 105 117 82 143 95 135 68 148 90 167 64 154 101 188 74 168 108

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment 200 x food bonus, .64% intra-competition" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="0.64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="5.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 1% murder rate" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <enumeratedValueSet variable="bluestart">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 100% murder rate" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <enumeratedValueSet variable="bluestart">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 50% murder rate" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <enumeratedValueSet variable="bluestart">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-100x-food-bonus" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment Blue colony does not kill, located max-pcor from red" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="foodbonus">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment Blue colony does not kill, located 10 patches from red" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="foodbonus">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment both colonies, located10 from red" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <enumeratedValueSet variable="foodbonus">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment both colonies kill, located 10 patches from red food bonus times 50" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment Blue colony does not kill, located 10 patches from red food bonus times 50" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="-3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="2" runMetricsEveryStep="true">
    <setup>setup
create-sheep 500</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="murderer" first="10" step="30" last="100"/>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="94"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment bot colonies learn kill 0-10 m 6000 steps 5 reps" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-output "competition"</final>
    <timeLimit steps="6000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <steppedValueSet variable="murderer" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Impact of learning" repetitions="4" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
if ticks = 10000 [set redfood 0 set bluefood 0]</go>
    <timeLimit steps="16000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>redfoods</metric>
    <metric>bluefoods</metric>
    <metric>redforagingtime</metric>
    <metric>blueforagingtime</metric>
    <enumeratedValueSet variable="murderer">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Impact of learning age and foraging time measured" repetitions="16" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
if ticks = 10000 [set redfood 0 set bluefood 0]</go>
    <timeLimit steps="16000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>redfoods</metric>
    <metric>bluefoods</metric>
    <metric>redforagingtime</metric>
    <metric>blueforagingtime</metric>
    <metric>redage</metric>
    <metric>blueage</metric>
    <enumeratedValueSet variable="murderer">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Impact of learning age and foraging time measured, varying m" repetitions="16" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
if ticks = 10000 [set redfood 0 set bluefood 0]</go>
    <timeLimit steps="16000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>redfoods</metric>
    <metric>bluefoods</metric>
    <metric>redforagingtime</metric>
    <metric>blueforagingtime</metric>
    <metric>redage</metric>
    <metric>blueage</metric>
    <steppedValueSet variable="murderer" first="0" step="10" last="20"/>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="higher m reduces foraging efficency?" repetitions="1" runMetricsEveryStep="true">
    <setup>setup
create-sheep 6
ask patches [set pcolor random 200]</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>redforagingtime</metric>
    <metric>blueforagingtime</metric>
    <metric>redage</metric>
    <metric>blueage</metric>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="murderer" first="10" step="30" last="100"/>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="higher m reduces foraging efficency with mortality" repetitions="1" runMetricsEveryStep="true">
    <setup>setup
create-sheep 6</setup>
    <go>go</go>
    <timeLimit steps="5000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>redforagingtime</metric>
    <metric>blueforagingtime</metric>
    <metric>redage</metric>
    <metric>blueage</metric>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="murderer" first="10" step="30" last="100"/>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="New Code 2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup
ask patches [set pcolor random 139.9]
create-sheep 10</setup>
    <go>go
if ticks &gt; 200 [ set murderer 5]</go>
    <timeLimit steps="2000"/>
    <metric>count bants</metric>
    <metric>count rants</metric>
    <metric>%redmurderer</metric>
    <metric>redmurders</metric>
    <metric>%bluemurderer</metric>
    <metric>murders</metric>
    <metric>agedeaths</metric>
    <metric>redagedeaths</metric>
    <metric>stdbantfoodpref</metric>
    <metric>stdrantfoodpref</metric>
    <metric>mostavailablefood</metric>
    <metric>rantfoodpreference</metric>
    <metric>bantfoodpreference</metric>
    <metric>redage</metric>
    <metric>blueage</metric>
    <metric>redforagingtime</metric>
    <metric>blueforagingtime</metric>
    <metric>redfoods</metric>
    <metric>bluefoods</metric>
    <enumeratedValueSet variable="murderer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="killer-coefficient">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluegression">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aggression">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="season">
      <value value="&quot;summer&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="foodbonus" first="5" step="15" last="105"/>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redgress">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bluestart">
      <value value="92"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="No Competiontion food calamity" repetitions="4" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="16000"/>
    <metric>count rants</metric>
    <metric>count bants</metric>
    <metric>redfood</metric>
    <metric>bluefood</metric>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-colony-y">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-colony-x">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Red-colony-x">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-colonies">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-food-preference?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-colony-y">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="-10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="inbred 2" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5000"/>
    <metric>count nests with [inbred? = true]</metric>
    <metric>count nests</metric>
    <enumeratedValueSet variable="diffusing">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementx">
      <value value="-10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-colony-x">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-colonies">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Red-colony-x">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-colony-y">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-colony-y">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-food-preference?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movementy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nest-friend?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Distrubution of Emergence" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count nests with [birth-number = 0]</metric>
    <metric>count nests with [birth-number = 1]</metric>
    <metric>count nests with [birth-number = 2]</metric>
    <metric>count nests with [birth-number = 3]</metric>
    <metric>count nests with [birth-number = 4]</metric>
    <metric>count nests with [birth-number = 5]</metric>
    <metric>count nests with [birth-number = 6]</metric>
    <metric>count nests with [birth-number = 7]</metric>
    <metric>count nests with [birth-number = 8]</metric>
    <metric>count nests with [birth-number = 9]</metric>
    <enumeratedValueSet variable="red-colony-y">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="199"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-colony-x">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-colonies">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-colony-y">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Red-colony-x">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nest-friend?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-food-preference?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="finger-of-god?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="average-emergence distance" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="301"/>
    <metric>MatingDay 300</metric>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="murderer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inbred-consequence?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-chemicals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foodbonus">
      <value value="199"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporationrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plant-seeding">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blue-colony-y">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="83"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nest-friend?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="finger-of-god?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Red-colony-x">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-food-preference?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusing">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
