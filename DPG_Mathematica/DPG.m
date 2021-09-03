(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


BeginPackage["DPG`"];


DPGrow::usage = 
"DPGrow[g,dList [,phantomV] [,fMaxMatching] [,validateQ]]
Grows the graph form seed graph g which may have phantom node 
attached with the node phantomV) by adding nodes of degrees dList
through DPG process using function fMaxMatching to find the matching.
Results can be validated by using the flag validateQ.";


Begin["`Private`"];


(* ::Section:: *)
(*Functions to find Maximum Matching*)


(*(*Needs["IGraphM`"]
(*IGMaximumMatching[graph]*)
(*FindIndependentEdgeSet[graph]*)*)*)


(*Randomizes graph labels. Useful to find different matchings*)
randomizeGraphLabels[g_]:=Graph[RandomSample[VertexList[g]],EdgeList[g]];


(*Wraps function f to find matching around function that randomizes graph labels*)
rndMatching[f_]:=(f[randomizeGraphLabels[#]]&)


(*finds matchings in graph g of size count.
d is dummy variable used for genralization in weighted matching.*)
findMatching[g_,count_,d_]:=Module[{ie},
ie=rndMatching[FindIndependentEdgeSet][g];
If[Length[ie]<count,Throw["Matching of size "<>ToString[count]<>" not found."]];
RandomSample[ie,count]];


(* ::Section:: *)
(*DPG*)


DPGrow[g_,dList_,phantomV_:Infinity,fMaxMatching_:findMatching,validateQ_:False]:=
Module[{newG,newPhantomV},
newG=g;
newPhantomV=phantomV;
Do[
{newG,newPhantomV}=DPGStep[newG,d,newPhantomV,fMaxMatching,validateQ]
,{d,dList}];
{newG,phantomV}]


(* ::Section:: *)
(*A single DPG step*)


DPGStep[g_,d_,phantomV_:Infinity,fMaxMatching_:findMatching,validateQ_:False]:=Module[{newG,newPhantomV},

(*INPUT CHECK*)
If[d<0,Throw["Error: input degree smaller than one"]];
If[(phantomV=!=\[Infinity]) && (VertexDegree[g,phantomV]!=1),Throw["Error: phantom vertex's degree is more than one."]];

(*EVEN INCOMING DEGREE WITH/OUT PHANTOM VERTEX IN EXISTING GRAPH*)
If[EvenQ[d],
{newG,newPhantomV}=DPGStepEvenD[g,phantomV,d,fMaxMatching]];

(*ODD INCOMING DEGREE WITH PHANTOM VERTEX IN EXISTING GRAPH*)
If[OddQ[d]&&phantomV=!=\[Infinity],
{newG,newPhantomV}=DPGStepOddDWithPhantomV[g,phantomV,d,fMaxMatching]];

(*ODD INCOMING DEGREE WITHOUT PHANTOM VERTEX IN EXISTING GRAPH*)
If[OddQ[d]&&phantomV===\[Infinity],
{newG,newPhantomV}=DPGStepOddDWithoutPhantomV[g,phantomV,d,fMaxMatching]];

(*VALIDATION CHECK*)
If[validateQ,
If[SimpleGraphQ[newG]==False,Throw["Error: Graph not simple."]];
If[VertexDegree[newG,VertexList[g]]!=VertexDegree[g],Throw["Error: Existing degrees not preserved"]];
If[ConnectedGraphQ[newG]==False,Print["Warning: Disconnected Graph"]]];

{newG,newPhantomV}];


DPGStepEvenD[graph_,phantomV_,d_,fMaxMatching_]:=Module[{g,newPhantomV,MSize,M,newNode,newEdges},
g=graph;

(*find matching*)
MSize=d/2;
M=fMaxMatching[g,MSize,d];

(*new edges to add*)
(*newNode=VertexCount[g]+1;*)
newNode=Max[VertexList[g]]+1;
newEdges=UndirectedEdge[#,newNode]&/@VertexList[M];

(*update edges*)
g=EdgeAdd[EdgeDelete[g,M],newEdges];

(*phantomV is unchanged in case of even d*)
newPhantomV=phantomV;

{g,newPhantomV}]


DPGStepOddDWithPhantomV[graph_,phantomV_,d_,fMaxMatching_]:=
Module[{g,newPhantomV,MSize,M,newNode,newEdges,u},
g=graph;

(*find matching*)
MSize=Floor[d/2];
(*matching should not include neighbour of phantom vertex*)
u=First[AdjacencyList[g,phantomV]];
M=fMaxMatching[VertexDelete[g,{u,phantomV}],MSize,d];

(*new edges to add*)
(*newNode=VertexCount[g]+1;*)
newNode=Max[VertexList[g]]+1;
newEdges=(newNode\[UndirectedEdge]#1&)/@VertexList[M];
(*also include edge with neighbour of phantom node*)
AppendTo[newEdges,newNode\[UndirectedEdge]u];

(*update edges*)
g=EdgeAdd[EdgeDelete[g,M],newEdges];

(*remove phantom vertex*)
g=VertexDelete[g,phantomV];
newPhantomV=Infinity;

{g,newPhantomV}]


DPGStepOddDWithoutPhantomV[graph_,phantomV_,d_,fMaxMatching_]:=
Module[{g,r,v,newPhantomV,MSize,M,newNode,newEdges,u},
g=graph;

(*decide wheter to put stub in new node or not*)
r=RandomChoice[{1/(d+2),1-1/(d+2)}->{0,1}];

(*find matching*)
MSize=If[r==0,Floor[d/2],Ceiling[d/2]];
M=fMaxMatching[g,MSize,d];

(*new edges to add*)
(*newNode=VertexCount[g]+1;*)
newNode=Max[VertexList[g]]+1;
newPhantomV=newNode+1;
If[r==0,
newEdges=(newNode\[UndirectedEdge]#1&)/@VertexList[M];
AppendTo[newEdges,newNode\[UndirectedEdge]newPhantomV];
,
M=RandomSample[M]; (*randomizing stub placement*)
newEdges=(newNode\[UndirectedEdge]#1&)/@VertexList[Drop[M,-1]];
{u,v}=Last[M]/. UndirectedEdge->List;
AppendTo[newEdges,u\[UndirectedEdge]newNode];
AppendTo[newEdges,v\[UndirectedEdge]newPhantomV]];

(*update edges*)
g=EdgeAdd[EdgeDelete[g,M],newEdges]; (*adds phantomV as well*)

{g,newPhantomV}]


End[] (*`Private`*);


EndPackage[]
