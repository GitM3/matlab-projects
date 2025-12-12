clear
close all
clc
m1=5;           %アーム１の質量[kg]
m2=5;           %アーム２の質量[kg]
a1=1;           %アーム１の長さ[m]
a2=1;           %アーム２の長さ[m]
I1=m1*a1^2/3;   %アーム１の慣性モーメント
I2=m2*a2^2/3;   %アーム２の慣性モーメント
l1=0.5;         %関節１からアーム１の重心点までの距離
l2=0.5;         %関節２からアーム２の重心点までの距離
g=9.8;
parameters=[m1,m2,I1,I2,a1,a2,l1,l2,g]; %以上のパラメータ
statei=[[0;0],[0;0],[0;0]]; %初期状態
q_start = [[0;0],[0;0],[0;0]];
q_mid_1=[[-pi/2;3*pi/4],[0;0],[0;0]];
q_mid_2=[[pi/4;3*pi/4],[0;0],[0;0]];
q_final = [[pi/2;0],[0;0],[0;0]];
%Simulinkの実行
filename='Lagrange'; %ファイル名（拡張子なし）
%open(filename);      %Simulinkファイルを開く
sim(filename);       %Simulinkを実行
%Simulinkの実行結果を描く
drawLag
%anim