(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


BeginPackage["DPGAssortativity`"];


DPGrowAssortativity::usage ="
[g0_,dList_,[increaseQ_:True] [,phantomV_:Infinity]]
Adds nodes with degrees in dList into seed graph g0 
through DPG process selecting matching such that to 
maximize assortativty. increaseQ flag can be set to 
False to decrease assortativity instead. phantomV 
holds the neighbour vertex of phantom vertex if any
present in seed graph g0.";


Begin["`Private`"];


Needs["DPG`"];
Needs["WeightedMatching`"];


(* ::Section:: *)
(*DPG Assortativity*)


DPGrowAssortativity[g0_,dList_,increaseQ_:True,phantomV_:Infinity]:=
Module[{WAssortativity,fMaxMatchingAssortativity,newG,newPhantomV},

(*Assortativity based*)
WAssortativity[g_,d_]:=Module[{A,u,v,i,j,d1,d2},
Table[
{u,v}=e/.UndirectedEdge->List;
{d1,d2}=VertexDegree[g,#]&/@{u,v};
((d1-d)^2+(d2-d)^2-(d1-d2)^2)
,{e,EdgeList[g]}]
];

fMaxMatchingAssortativity[g_,edgeCountRequired_,d_]:=
findWeightedIndpendentEdges[g,WAssortativity,edgeCountRequired,d,increaseQ];

newG=g0;
newPhantomV=phantomV;
Do[
{newG,newPhantomV}=DPG`Private`DPGStep[newG,d,newPhantomV,fMaxMatchingAssortativity];
Sow[newG];
,{d,dList}];

{newG,newPhantomV}
]


End[]; (*Private*)


EndPackage[];
