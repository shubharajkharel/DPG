(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


s


BeginPackage["DPGModels`"];


maxDPG::usage = 
"maxDPG[graph_, n_ [,phantomV_:Infinity] [,fMaxMatching_:DPG`Private`findMatching]]
Adds n nodes into graph such that next node is twice the maximum matching size.
PhantomV is neighbour of phantom node, if present. fMaxMatching is the function used
to find matching.";


rndDPG::usage =
"rndDPG[graph_, n_ [,phantomV_:Infinity] [,fMaxMatching_:DPG`Private`findMatching]]
Adds n nodes to graph through random DPG process. Phantomv is neighbour of phantom 
node, if present. fmaxMatching is the function used to find matching.";


linearDPG::usage =
"linearDPG[graph_, n_, c_ 
[,phantomV_:Infinity] [,fMaxMatching_:DPG`Private`findMatching]]
Grow graph by adding n nodes through linear DPG process where c \[Epsilon] (0,1]
is the parameter for the model. phantomV is the neighbour of phantom 
node, if present.";


regularDPG::usage =
"Grow graph by adding n nodes of degree d through DPG process.
phantomV is the neighbour of the phantom node, if present. 
fMaxMatching is the function used to find matching.";


Begin["`Private`"]


Needs["DPG`"];


maxDPG[graph_,n_,phantomV_:Infinity,fMaxMatching_:DPG`Private`findMatching]:=
Module[{g,newPhantomV,newDegree},
g=graph;
newPhantomV=phantomV;
Do[
newDegree=2*Length@FindIndependentEdgeSet@g;
{g,newPhantomV}=DPGrow[g,{newDegree},newPhantomV,fMaxMatching]
,n];
{g,newPhantomV}
];


rndDPG[graph_,n_,phantomV_:Infinity,fMaxMatching_:DPG`Private`findMatching]:=
Module[{g,newPhantomV,newDegree},
g=graph;
newPhantomV=phantomV;
Do[
newDegree = RandomInteger[{1,2*Length@FindIndependentEdgeSet@g}];
{g,newPhantomV}=DPGrow[g,{newDegree},newPhantomV,fMaxMatching];
,n];
{g,newPhantomV}
];


linearDPG[graph_,n_,c_,phantomV_:Infinity,fMaxMatching_:DPG`Private`findMatching]:=
Module[{g,newPhantomV,newDegree},
g=graph;
newPhantomV=phantomV;
Do[
newDegree = Ceiling[c*2*Length@FindIndependentEdgeSet@g];
{g,newPhantomV}=DPGrow[g,{newDegree},newPhantomV,fMaxMatching];
,n];
{g,newPhantomV}
];


regularDPG[graph_,n_,d_,phantomV_:Infinity,fMaxMatching_:DPG`Private`findMatching]:=
DPGrow[graph,ConstantArray[d,n],phantomV,fMaxMatching]


End[]; (*`Private`*)


EndPackage[];
