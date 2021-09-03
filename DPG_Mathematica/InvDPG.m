(* ::Package:: *)

(* Mathematica Package *)
(* Created in Mathematica 12.0 *)
(* :Author: Shubha Raj Kharel *)


BeginPackage["InvDPG`"];


inverseDPG::usage =
"inverseDPG[graph_,stubV_]
Reduces the graph through inverse DPG process
where stubV is neighbour of phantom node";


Begin["`Private`"];


(* ::Section:: *)
(*Inverse-DPG*)


inverseDPG[graph_,stubV_]:=Module[{g,u,v,newE,newStubV,gOld,count},
(*initialization*)
{g,u}={graph,stubV};
If[Not@SimpleGraphQ[graph],Throw["Input graph not simple."]];
While[VertexCount[g]>0,
  {v,newE,newStubV}=Catch[findInvDPGFesbleV[g,u]];
  If[v=="NotFound",Break[]];
  Sow[{GPlot[g,u],"Removing "<> ToString[v] <>"..."}];
  gOld=g;
  g=EdgeAdd[VertexDelete[g,v],newE];
  
  (*validity testing*)
(*  count=0;
  Do[
  If[VertexDegree[gOld,i]!=VertexDegree[g,i],count++]
  ,{i,VertexList[g]}];
  If[count>1,Print["Degree preseve test failed"]];
  If[Not@SimpleGraphQ[g],Print["Not Simple Graph."]];*)
  
  u=newStubV];
  Sow[{GPlot[g,u],"",""}];
  (*PrintTemporary[ToString[VertexCount[g]]<>"/"<>ToString[VertexCount[graph]]];*)
{g,u}];


(*finds invDPG feasible vertex in graph with stub at vertex stubV*)
findInvDPGFesbleV[g_,stubV_]:=Module[{stubQ,evenV,V,newEdges,outputV,d,feasibleQ,newStubV},
	(*create list of vertices that can be removed based on if graph as stub or not*)
	stubQ=stubV=!=Infinity;
	V=RandomSample[VertexList[g]];
	If[Length[V]==0,Throw[{"NotFound","",""}]];
	(*Searching feasible vertices*)
	feasibleQ=False;
	Do[
		d=VertexDegree[g,v];
		(*If[d==0 && stubV!=v, Continue[]];*) (*enable this if you dont want to remove isolated verted*)
		{feasibleQ,newEdges,newStubV}=If[EvenQ[d],evenInvDPGFeasibleQ,oddInvDPGFeasibleQ]@@{g,stubV,v};
		If[feasibleQ,outputV=v;Break[]]
	,{v,V}];
	If[feasibleQ==False,Throw[{"NotFound","",""}]];
	(*ouput*)
	{outputV,newEdges,newStubV}]


(*checks if an even degree node is feasile to be removed through DPG*)
evenInvDPGFeasibleQ[g_,stubV_,v_]:=Module[{M,feasibleQ,newStubV},
	M=rndMatching[FindIndependentEdgeSet][#]&@GraphComplement[VertexDelete[NeighborhoodGraph[g,v],v]];
	feasibleQ=2*Length[M]==VertexDegree[g,v];
	newStubV=If[v===stubV,Infinity,stubV] ;
	{feasibleQ,M,newStubV}]


(*checks if an odd degree node is feasile to be removed through DPG*)
oddInvDPGFeasibleQ[g_,stubV_,v_]:=
	Module[{feasibleQ,compNeighG,M,newEdges,V,newStubV,stubQ},
		feasibleQ=False;newEdges={};newStubV=stubV;
		stubQ=stubV=!=Infinity;

		If[stubQ && MemberQ[AdjacencyList[g,v],stubV], Goto[end]];
		compNeighG=GraphComplement@VertexDelete[NeighborhoodGraph[g,v],v];
		If[stubQ ,
			If[stubV !=v,
				V=Complement[VertexList[compNeighG],AdjacencyList[g,stubV]];
				V=RandomSample[V]
				,
				V=RandomSample[VertexList[compNeighG]]]
			,
			V=RandomSample[VertexList[compNeighG]]];
			
		Do[ 
			newEdges=M=rndMatching[FindIndependentEdgeSet][VertexDelete[compNeighG,u]];
			If[2Length[M]==VertexCount[compNeighG]-1,
				feasibleQ=True;
				newStubV=u;
				If[stubQ && stubV=!=v,AppendTo[newEdges,u\[UndirectedEdge]stubV];newStubV=Infinity];
				Break[]]
			,{u,V}];
		Label[end];
		{feasibleQ,newEdges,newStubV}];


(*finds all inverse dpg feasible vertices*)
allInvDPGFeasbleV[g_]:=Select[VertexList[g],
First[If[EvenQ[VertexDegree[g,#]],evenInvDPGFeasibleQ[g,Infinity,#],oddInvDPGFeasibleQ[g,Infinity,#]]]&]


fracInvDPGFesbleV[g_]:=Length[allInvDPGFeasbleV[g]]/VertexCount[g]//N


GPlot[g_,stubV_]:=Graph[g
,GraphLayout->"SpringElectricalEmbedding"
,EdgeStyle->Gray
,VertexStyle->If[stubV=!=\[Infinity],{stubV->Red},Gray]
,VertexLabels->Automatic]


(*Randomizes graph labels. Useful to find different matchings*)
randomizeGraphLabels[g_]:=Graph[RandomSample[VertexList[g]],EdgeList[g]];


(*Wraps function f to find matching around function that randomizes graph labels*)
rndMatching[f_]:=(f[randomizeGraphLabels[#]]&)


End[]; (*`Private`*)


EndPackage[];
