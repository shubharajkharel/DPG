(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


BeginPackage["DPR`"];


DPROptimize::usage =
"DPROptimize[g_,optimizationFun_ 
	[,optimizationDirection_:+1] [,maxSwapTest_:1] [,connectedQ_:False]]
Does degree preserving rewiring in graph gand accepts 
the swaps only if value give by optimizationFun 
increased or decreases depending upon the direction
specified by optimizationDirection.conenctedQ flag is 
used to retrict swaps that disconnects the graphs."


Begin["`Private`"];


(* ::Section:: *)
(*DPR Optimize*)


DPROptimize[g_,optimizationFun_,optimizationDirection_:+1,maxSwapTest_:1,connectedQ_:False]:=
Module[{e1,e2,newE1,newE2,g1,p1,p0,newG,attempts,swapTest},

(*initializations*)
newG=g;
swapTest=0;
p0=optimizationFun[newG];

(*try optimization swaps*)
While[swapTest< maxSwapTest,

(*find independent edges to swap*)
{e1,e2}=RandomSample[EdgeList[newG],2];
attempts=1;
While[IndependentEdgeSetQ[newG,{e1,e2}]==False,
{e1,e2}=RandomSample[EdgeList[newG],2];
If[attempts++>50,
Print["Independent Edges not difficult to find."];
Quit[]]];

(*swap attempt 1*)
newE1=e1[[1]]\[UndirectedEdge]e2[[1]];
newE2=e1[[2]]\[UndirectedEdge]e2[[2]];
If[(EdgeQ[newG,newE1]||EdgeQ[newG,newE2])==False,
swapTest++;
g1=EdgeAdd[EdgeDelete[newG,{e1,e2}],{newE1,newE2}];
If[connectedQ && Not[ConnectedGraphQ[g1]],Continue[]];
p1=optimizationFun[g1];
If[(p1-p0)optimizationDirection >0,
newG=g1;p0=p1;Continue[]]];

(*swap attempt 2*)
newE1=e1[[1]]\[UndirectedEdge]e2[[2]];
newE2=e1[[2]]\[UndirectedEdge]e2[[1]];
If[(EdgeQ[newG,newE1]||EdgeQ[newG,newE2])==False,
swapTest++;
g1=EdgeAdd[EdgeDelete[newG,{e1,e2}],{newE1,newE2}];
If[connectedQ && Not[ConnectedGraphQ[g1]],Continue[]];
p1=optimizationFun[g1];
If[(p1-p0)optimizationDirection >0,
newG=g1;p0=p1]]

];

newG]


End[]; (*Private*)


EndPackage[];
