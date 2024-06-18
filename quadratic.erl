-module(quadratic).
-compile(export_all).

% this implemtation is the first (inefficient/quadratic) implementation which is mentioned in the paper

% Step 1 Compositional E-Summary
% Defining a datatype for expressions
-type name() :: string().

-type expr() :: {var, name()} 
                | {lam, name(), expr()} 
                | {app, expr(), expr()}.

buildExPr({var, X}) -> {var, X};
buildExPr({lam, V, E}) -> {lam, V, buildExPr(E)};
buildExPr({app, E1, E2}) -> {app, buildExPr(E1), buildExPr(E2)}.

% E-Summary is a pair of structure and free map variable

%postree is a skeleton tree
-type posTree() :: {pthere, 'nil'}
                 | {ptleftonly, posTree()}
                 | {ptrightonly, posTree()}
                 | {ptboth, posTree(), posTree()}.


emptyPT() -> {pthere, 'nil'}.

buildPt(left) -> {ptleftonly, emptyPT()};
buildPt(right) -> {ptrightonly, emptyPT()};
buildPt(both) -> {ptboth, buildPt(left), buildPt(right)}.


-type structure() :: {svar, 'nil'}
                  | {slam, posTree(), structure()}
                  | {sapp, structure(), structure()}.

emptyStruct() -> {svar, 'nil'}.
buildStruct(lam) -> {slam, emptyPT(), emptyStruct()};
buildStruct(app) -> {sapp, emptyStruct(), emptyStruct()}.

%variable map
singletonVM(X) -> #{X => emptyPT()}.

% removes one item from the map
% the variable mapped to, or nothing if it was not in map
removeFromVM(X, VM) -> 
    Prev_mapped = maps:get(X, VM, #{}),
    {maps:remove(X, VM), Prev_mapped}.

unionVM(M1, M2) ->
    % need to add specific conditions for merge
    maps:merge(M1,M2).

% esummary = {structure, varmap}

getLamExpr(X,E) ->
    {Str_body, VM_body} = summariseExpr(E),
    {E_map, X_pos} = removeFromVM(X, VM_body),
    {{slam, X_pos, Str_body}, E_map}.

getSApp(E1, E2) -> 
    {Str1, Map1} = summariseExpr(E1),
    {Str2, Map2} = summariseExpr(E2),
    {sapp, Str1, Str2, unionVM(Map1, Map2)}.

% summariseExpr(E) ->
%     case E of
%     {var, X} -> {emptyStruct(),singletonVM(X)};
%     {lam, X, E} -> getLamExpr(X,E);
%     {app, E1, E2} -> getSApp(E1, E2)
%     end.

summariseExpr({var, X}) -> 
    {svar, singletonVM(X)};
summariseExpr({lam, X, E}) -> 
    getLamExpr(X,E);
summariseExpr({app, E1, E2}) -> 
    getSApp(E1, E2).

test() ->
    summariseExpr({var, x}).
% summariseExpr({var, "a"}).
% {svar,#{"a" => {pthere,nil}}}
% 110> Y.
% {lam,e,{var,x}}
% summariseExpr(Y).
% {{slam,#{},svar},#{x => {pthere,nil}}}
% 112> Z.
% {app,{var,x},{var,x}}
% summariseExpr(Z).
% {sapp,svar,svar,#{x => {pthere,nil}}}
