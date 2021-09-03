(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


BeginPackage["WeightedMatching`"];


findWeightedIndpendentEdges::usage =
"findWeightedIndpendentEdges[g,WFunction [,edgeCountRequired_:Infinity] [,d_:_] [,reverseWeightsQ_]]
Finds `edgeCountRequired' number of independent edges while trying 
to maximize/total weight  in an ad-hoc way. Wfunction gives 
weight of edes and takes takes argument [graph,degree_of_new_node]. 
`edgeCountRequried' whose value should be set to Infinity to find 
maximum possible edges. reverseWeights is used to choose direction (max or min)";


Begin["`Private`"];


(* ::Section:: *)
(*Weighted matching*)


findWeightedIndpendentEdges[g_,WFunction_,edgeCountRequired_:Infinity,d_:_,reverseWeightsQ_:False]:=
Module[{eWeights,edges,matching},
eWeights=WFunction[g,d];
eWeights=Transpose[{EdgeList[g],eWeights}];
edges=SortBy[eWeights,Last,Greater][[All,1]];
If[reverseWeightsQ,edges=Reverse[edges]];
matching=findIndependentEdges[g,edges,edgeCountRequired];
If[(edgeCountRequired!=Infinity)&&(Length[matching]<edgeCountRequired),
Throw["Weighted matching of size "<>ToString[edgeCountRequired]<>" not found."]];
matching]


(*Finds independent edges from list of edges passed*)
(*If given number of independent edges are not found, it returns maximal matching it found*)
(*edgeCountRequired=Infinity corresponds to randomized slection of maximal matching set*)
(*Useful to find independent edges from list that is sorted according to some weight*)
(*If random maximal matching is needed, simply randomize variable 'edges' before input*)
findIndependentEdges=Function[{g,edges,edgeCountRequired},
Module[{matching,edgeList,testSelection,e},
(*go through the list sequentially*)
matching={};
edgeList=edges;
While[(Length[matching]< edgeCountRequired) && (Length[edgeList]>0),
e=First@edgeList;
If[IndependentEdgeSetQ[g,Append[matching,e]],AppendTo[matching,e]];
edgeList=Rest[edgeList]];
matching
]];


End[];(*`Private`*)


EndPackage[];
