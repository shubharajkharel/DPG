(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


BeginPackage["Blossom`"];


findIndependentEdges::usage =
"findIndependentEdges[g,initialM,count]
Finds independent edges in graph g using blossoms algorithm.
initialM holds the list of edges used for initialilization which
can be empty as well. It finds `count' number of independent edge.
count = Infinity corresponds to maximum matching.
Code is not optimized."


Begin["`Private`"];


(* ::Subsubsection:: *)
(*Finds k-independent edge set from graph*)


(*initialM can be empty as well*)
(*special case : count = Infinity corresponds to maximum  matching*)
findIndependentEdges=Function[{g,initialM,count},
Module[{successQ,M,newG,newM,e},

(*add independet edges to initialM by random choice*)
newG=g;
M=initialM;
(*remove vertices in matching*)
If[M!={},newG=VertexDelete[newG,VertexList[M]]];
While[EmptyGraphQ[newG]!= True && Length[M]<count,
e=RandomChoice[EdgeList[newG],1][[1]];
AppendTo[M,e];
newG=VertexDelete[newG,VertexList[{e}]]];

(*add independent edges to M by finding augmenting path*)
successQ=True;
While[successQ==True&&Length[M]<count,
{successQ,M}=extendMatching[g,M]];

(*CAN BE REMOVED LATER AFTER CONSISTENT TEST RESULTS*)
(*test if maximum matching is actually reached*)
If[successQ==False && Length[M]!=Length[FindIndependentEdgeSet[g]]
,Print["Warning : Maximum matching not reached by blosssom function."]];

M
]];


(* ::Subsubsection:: *)
(*Ends the matching of graph by 1 *)


extendMatching=Function[{g,M},
Module[{newM,augPath,end,successQ,pathEdges,oddEdges,evenEdges},
newM=M;
augPath=findAugPath[g,M];
If[augPath=={},successQ=False;Goto[end]];
successQ=True;
pathEdges=Table[augPath[[i]]\[UndirectedEdge]augPath[[i+1]],{i,Length[augPath]-1}];
oddEdges=pathEdges[[1;;All;;2]];
evenEdges=pathEdges[[2;;All;;2]]; (*works even when there is only 1 edge*)
newM=Join[EdgeList@EdgeDelete[newM,evenEdges],oddEdges];
(*Print[HighlightGraph[g,newM]];*)
Label[end];
{successQ,newM}]];


(* ::Subsubsection:: *)
(*Finds augmentation path using blossom's algorithm*)


(*HELPER FUNCTIONS*)
(*returns an unmarked edge containting v*)
unMarkedEdgeOfV[v_,unMarkedE_]:=Module[{e},e={}; 
Do[If[MemberQ[edge,v],e=edge;Break[]],{edge,unMarkedE}];e]

(*finds neighbour of a vertex in an edge*)
vNeighbour[edge_,v_]:=DeleteCases[VertexList[{edge}],v][[1]]
(*unmark Edge*)
(*markE[edge_]:=(unMarkedE=EdgeList[EdgeDelete[unMarkedE,edge]];)
markV[v_]:=(unMarkedV=DeleteCases[unMarkedV,v];unMarkedEvenV=DeleteCases[unMarkedEvenV,v];)*)



findAugPath=Function[{g,M},
Module[{rootV,forest,rootOfV,vType,unMarkedE,unMarkedV,unMarkedEvenV,counter
,augPath,v,e,w,x,rv,rw,p1,p2,blossomV,blossom,contractedV,newG,newM,end},

(*INITIALIZATIONS*)
(*create singleton forest of unmatched vertices*)
rootV=Complement[VertexList[g],VertexList[M]];
(*Randomization of root sequnce done so that 
same matching is not returned every time for sameinput of M*)
rootV=RandomSample[rootV];
forest=Graph[rootV,{},VertexLabels->"Name"];
(*set associated forest of all nodes to Infinity*)
rootOfV=Association[{#-> Infinity}&/@VertexList[g]];
(*assoticate root to even*)
vType=Association[(#->"even")&/@ rootV];
(*associate root with itself in root index*)
AppendTo[rootOfV,Association[(#1->#1&)/@rootV]];
(*create list of unmarked edges and assume all non roots as odd in begininig*)
unMarkedE=EdgeList[EdgeDelete[g,M]];
unMarkedV=VertexList[g];
unMarkedEvenV=rootV; (*MAKE SURE TO UPDATE THIS*)

(*SEARCHIHG AUGMENTING PATH RECURSIVELY*)
counter=0; (*remove later*)
augPath={};
(*while there is an unmarked vertex in Forest with distance to root even or 0*)
While[unMarkedEvenV!={},
v=unMarkedEvenV[[1]];

(*FOR ALL UNMARKED EDGE WITH v*)
While[e=unMarkedEdgeOfV[v,unMarkedE];Length[e]!=0,
(*find neighbour of v in e*)
w=vNeighbour[e,v];

(*IF W NOT IN FOREST*)
If[rootOfV[w]==Infinity,
(*then w must be in one of the matched edges*)
(*find the vertex x that w is matched to in M*)
x=vNeighbour[SelectFirst[M,MemberQ[#,w]&],w];
(*add to forest the edge (v,w) and (w,x)*)
rv=rootOfV[v];
AppendTo[rootOfV,w-> rv];
AppendTo[rootOfV,x->rv ];
forest=EdgeAdd[forest,{e,w\[UndirectedEdge]x}];
(*update the odd/ even labels of w an x*)
(*This makes sure all nodes in forest will always of odd/even assigned*)
AppendTo[vType,{w-> "odd",x-> "even"}];
AppendTo[unMarkedEvenV,x];
];

(*IF W IN FOREST*)
If[rootOfV[w]!=Infinity && vType[w]=="even",

(*IF V AND W IN DIFFERENT TREE, AUGMENTATION PATH FOUND*)
If[(rv=rootOfV[v])!=  (rw=rootOfV[w]),
p1=If[rv==v,{v},FindPath[forest,rv,v]];
p2=If[rw==w,{w},FindPath[forest,w,rw]];
augPath=Join[p1,p2];
augPath=Flatten[augPath];
Goto[end];
];

(*IF V AND W IN SAME TREE, THEN BLOSSOM FOUND*)
If[(rv=rootOfV[v])== (rw=rootOfV[w]),
blossomV=FindPath[forest,v,w][[1]];
blossom=createBlossom[blossomV];
(*name of the contracted vertex*)
contractedV=Min[VertexList[g]]-1;
{newG,newM}=contractBlossom[g,M,blossomV,contractedV];
(*Print[
HighlightGraph[g,M],
blossom,
HighlightGraph[newG,newM],
forest];*)

augPath=findAugPath[newG,newM];
 If[augPath!={},augPath=liftAugPathContraction[g,augPath,contractedV,blossom,M]];
 Goto[end];
];
];

(*mark edge e*)
(*markE[e];*)
unMarkedE=EdgeList[EdgeDelete[unMarkedE,e]];
If[augPath!={},Break[]];
(*If[counter++>10,Print["limit break"];Abort[]]; (*DELETE THIS LATER*)*)
];
(*mark vertex v*)
(*markV[v];*)
unMarkedV=DeleteCases[unMarkedV,v];unMarkedEvenV=DeleteCases[unMarkedEvenV,v];
If[augPath!={},Break[]];
(*If[counter++>10,Print["limit break"];Abort[]]; (*DELETE THIS LATER*)*)
];
Label[end];
augPath
]];


(* ::Subsubsection:: *)
(*Contracts a blossom*)


contractBlossom=Function[{g,M,blossomV,contractedV},
Module[{v,nv,newG,newM,newM1,newM2},
(*contract graph*)
(*find non duplicates neighbours of blossom vertices*)
v=DeleteDuplicates[Flatten[(AdjacencyList[g,#1]&)/@blossomV]];
nv=Complement[v,blossomV];
(*new index is lowes index -1*)
newG=VertexDelete[g,blossomV];
newG=EdgeAdd[newG,UndirectedEdge[contractedV,#]&/@nv];

(*contract matching*)
(*seperate the Matching that is not touching blossom*)
newM=M/. (#1->contractedV&)/@blossomV;
newM1=Select[newM,Not@MemberQ[#,contractedV]&];
(*select only one matched edge going to blossom*)
newM2=Complement[newM,newM1];
newM2=DeleteCases[newM2,contractedV\[UndirectedEdge]contractedV];
If[newM2!={},newM2={First[newM2]}];
(*combine two to make new matching*)
newM=Join[newM1,newM2];

{newG,newM}]];


(* ::Subsubsection:: *)
(*Lifts the contracted blossom in augmenting path*)


(*lift vertex that was contracted from blossom with matching M in uncontracted graph*)
liftAugPathContraction=Function[{g,augPath,contractedV,blossom,M},
Module[{pos,blossomPath,end,liftedPath,stemV,reverseDirectionQ},
(*position where contracted vertex lies in augmenting path*)
pos=FirstPosition[augPath,contractedV,{}];

(*if blossom vertex don't belong to augmenting path, then no need to lift contraction*)
If[pos == {}, liftedPath=augPath;Goto[end]];
pos=pos[[1]];
(*If augmenting path starts with contractedV*)
If[pos==1,
blossomPath=findBlossomExpansionPath[g,blossom,augPath[[pos+1]],M]];

(*If augmenting path ends with contractedV*)
If[pos==Length[augPath],blossomPath=Reverse@findBlossomExpansionPath[g,blossom,augPath[[pos-1]],M]];

(*If contractedV is in middle of augmenting path*)
If[1< pos< Length[augPath],
(* select stemV and reverse path from bloosom_root\[Rule]stemV, 
depending on where the contracted vertex lies*)
If[EvenQ[pos],blossomPath=Reverse@findBlossomExpansionPath[g,blossom,augPath[[pos-1]],M]];
If[OddQ[pos],blossomPath=findBlossomExpansionPath[g,blossom,augPath[[pos+1]],M]];
];

(*return lifted contraction on path*)
liftedPath=Flatten[augPath/.{contractedV-> blossomPath}];
Label[end];
liftedPath
]];


(* ::Subsubsection:: *)
(*Expands the blossom vertex in augmentation path *)


findBlossomExpansionPath=Function[{g,blossom,stemV,M},
Module[{blossomRoot,stemVNeighborsInBlossom,blossomWithStem,p},
(*blossom root is the node unmatched by edges within the blossom*)
(*it may/may not be matched by edges outsides outside*)
blossomRoot=Complement[VertexList[blossom],VertexList[Select[M,EdgeQ[blossom,#1]&]]][[1]];
(*blossomRoot=Complement[VertexList[blossom],VertexList[M]]\[LeftDoubleBracket]1\[RightDoubleBracket];*)
stemVNeighborsInBlossom=AdjacencyList[g,stemV]\[Intersection]VertexList[blossom];
Do[
blossomWithStem=EdgeAdd[blossom,stemV\[UndirectedEdge]v];
(*find path of odd length from blossom's root to the stem vertex*)
(*there should be only 2 paths of even and odd length*)
p=SelectFirst[FindPath[blossomWithStem,blossomRoot,stemV,\[Infinity],All],(*odd path lenght have even no of vertices*)EvenQ[Length[#1]]&,{}];
If[p!={},Break[]];
,{v,stemVNeighborsInBlossom}];
(*return the path bloossom\[Rule]stemV \ {stemV}*)
DeleteCases[p,stemV]
]];


(* ::Subsubsection:: *)
(*Creates a blossom using provided vertices*)


(*creates blossom graph from the blossom vertices*)
createBlossom[blossomV_]:=EdgeAdd[PathGraph[blossomV,VertexLabels->"Name"],First[blossomV]\[UndirectedEdge]Last[blossomV]]


(* ::Subsubsection:: *)
(*Checks if given path is an augmentation path*)


augmentingPathQ=Function[{path,M},
Module[{output,vInM,endVCheckQ,edgesInPath,oddEdges,oddCheckQ,evenEdges,evenCheckQ,end},
(*not augmenting if path length is even (i.e. odd vertices*)
If[OddQ[Length[path]],output=False;Goto[end]];
(*not augmenting if end points are in matching*)
vInM=VertexList[M];
endVCheckQ=(MemberQ[vInM,path[[1]]]==False)&&(MemberQ[vInM,path[[-1]]]==False);
If[endVCheckQ==False,output=False;Goto[end]];
(*convert list of veritces to list of edges*)
edgesInPath=EdgeList[PathGraph[path]];
(*check if all odd edges are not in matching*)
oddEdges=edgesInPath[[1;;All;;2]];
oddCheckQ=NoneTrue[oddEdges,MemberQ[M,#]&];
(*check if all even edges are not in matching*)
evenEdges=edgesInPath[[2;;All;;2]] ;(*works even if number of edges=1*)
evenCheckQ=If[evenEdges=={},True,AllTrue[evenEdges,MemberQ[M,#]&]];
output=evenCheckQ&&oddCheckQ;
(*label to jump if early condition not met*)
Label[end];
output
]];


End[];(*`Private`*)


EndPackage[];
