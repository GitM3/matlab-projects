clear      % ���[�N�X�y�[�X���炷�ׂĂ̕ϐ�������
close all  % ���ׂĂ�Figure������
clc        % �R�}���h �E�B���h�E�̃N���A

%�^���N�V�X�e�������p�����[�^
A = 10.0;   %�^���N�̒f�ʐ�[m^2]
R = 0.8;    %�o����R[s/m^2]
q1 = 0.5;   %��������[m^3/s]

%�P���x��V�X�e���p�����[�^
K = R;      %�V�X�e���Q�C��
T = A*R;    %���萔

%Simulink�̎��s
Endtime = 60;           %�V�~�����[�V�������s����          
filename = 'Ex3_1_sim'; %�t�@�C�����i�g���q�Ȃ��j
open(filename);         %Simulink�t�@�C�����J��
sim(filename);          %Simulink�̎��s

%Figure�ɂ�錋�ʂ̕\��
t = simout.time;        %����
y = simout.Data(:, 1);  %����
u = simout.Data(:, 2);  %��������
%y�̕\��
subplot(2,1,1)      %Figure��(2�s1��ɕ�������1�s1���)
plot(t, y)          %y1�̕\��
grid on             %�O���b�h���C���̒ǉ�
ylim([0, 0.5])      %y���̕\���͈͂��w��
ylabel('y')         %y�����x��
%u�̕\��
subplot(2,1,2)      %Figure��(2�s1��ɕ�������2�s1���)
plot(t, u)          %y2�̕\��
grid on             %�O���b�h���C���̒ǉ�
ylim([0, 1.0])      %y���̕\���͈͂��w��
xlabel('t')         %x�����x��
ylabel('u')         %y�����x��