% CMDLNWIN   コマンドラインデモの実行のためのデモゲートウェイルーチン
% 
% CMDLNWIN(LabelList,NameList,FigureFlagList)は、ユーザのグラフィックス
% ユーザインタフェースを使わないで、コマンドウィンドウから操作するデモを
% 起動させる"Command Line Demos"ウィンドウを作成します。
% 
% LableList       "Command Line Demos"ウィンドウに表示されるデモの名前
%                 のリストを含んでいます。
% 
% NameList        デモを実行する実際の関数名を含んだものです。
% 
% FigureFlagList  デモ自身が他にもウィンドウを必要か否かを設定します。
% 
% これにより、MATLABデモのユーザは、何らかの理由のためにGUIツールを
% 使わないで、デモにアクセスできます。            
%
% これらのデモは、MATLABコマンドウィンドウとの入出力操作を行うので、
% コマンドウィンドウは他のウィンドウの後ろに隠れないようにしなければ
% なりません。 


%   Ned Gulley, 6-21-93, jae Roh 10-15-96
%   Copyright 1984-2004 The MathWorks, Inc.
