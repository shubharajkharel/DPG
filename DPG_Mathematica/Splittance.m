(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


BeginPackage["Splittance`"];


findSplittance::usage =
"Calculates splittance of graph.
https://link.springer.com/article/10.1007/BF02579333
Definition of m[d] is changed (Refer to Nature Physics paper)
and relabeled by s[d].";


(* ::Input::Initialization:: *)
Begin["`Private`"];


(* ::Section:: *)
(*Splittance of graph*)


(*calculates splittance of graph*)
findSplittance[g_]:=
Module[{d},
d=Sort[VertexDegree[g],Greater];
\[Sigma][s[d],d]]


(*Calculates the point where the minimal edges needs to be added for the graph to be made split*)
(*d= SORTED degree list in ascending order*)
s[d_]:=
Module[{output},
(*finding maxm k for which dk\[GreaterEqual] k*)
output=1; (*in case degree sequence contains only one node*)
Do[
If[d[[k]]<k,output=k-1;Break[]];
,{k,Length[d]}];
output]


(*calcualtes splittance of deg. seq. if first k is taken to be formed a clique*)
\[Sigma][k_,d_]:=If[Length[d]==1,0,1/2 (k (k-1)-Total[d[[1;;k]]]+Total[d[[k+1;;All]]])]


End[];(*`Private*)
EndPackage[];
