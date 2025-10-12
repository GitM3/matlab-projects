clear      % ���[�N�X�y�[�X���炷�ׂĂ̕ϐ�������
close all  % ���ׂĂ�Figure������
clc        % �R�}���h �E�B���h�E�̃N���A

%�}�X-�o�l-�_���p�V�X�e�������p�����[�^
k = 2.0;      %�o�l�萔[N/m]
M = 0.5;    %����[kg]
D = 0.1;    %�S���W��[Ns/m]

%�Q���x��V�X�e���p�����[�^
K = 1/k;                %�V�X�e���Q�C��
omega = sqrt(k/M);      %���U���g��
zeta = sqrt(D^2/(M*k)); %�����W��

%Simulink�̎��s
Endtime = 10;           %�V�~�����[�V�������s����          
filename = 'Ex3_2_sim'; %�t�@�C�����i�g���q�Ȃ��j
open(filename);         %Simulink�t�@�C�����J��
sim(filename);          %Simulink�̎��s

%Figure�ɂ�錋�ʂ̕\��
t = simout.time;        %����
y = simout.Data(:, 1);  %�ψ�
u = simout.Data(:, 2);  %����
%y�̕\��
subplot(2,1,1)      %Figure��(2�s1��ɕ�������1�s1���)
plot(t, y)          %y1�̕\��
grid on             %�O���b�h���C���̒ǉ�
ylim([0, 1.0])      %y���̕\���͈͂��w��
ylabel('y')         %y�����x��
%u�̕\��
subplot(2,1,2)      %Figure��(2�s1��ɕ�������2�s1���)
plot(t, u)          %y2�̕\��
grid on             %�O���b�h���C���̒ǉ�
ylim([0, 2.0])      %y���̕\���͈͂��w��
xlabel('t')         %x�����x��
ylabel('u')         %y�����x��