clear      % ���[�N�X�y�[�X���炷�ׂĂ̕ϐ�������
close all  % ���ׂĂ�Figure������
clc        % �R�}���h �E�B���h�E�̃N���A


%�V�X�e���̕����p�����[�^
u = 1.0;    %���͓d��[V]
R = 5.0;    %�d�C�q��R[��]
L = 1e-3;   %�C���_�N�^���X[H]
K_e = 5e-2; %�t�N�d�͒萔[Vs/rad]
K_t = 5e-2; %�g���N�萔[Nm/A]
D = 1e-5;   %�S�����C�W��[Nmrad/s]
J = 1e-5;   %�������[�����g[kgm^2]


%Simulink�̎��s
Endtime = 0.2;          %�V�~�����[�V�������s����          
filename = 'Ex3_3_a_sim'; %�t�@�C�����i�g���q�Ȃ��j
open(filename);         %Simulink�t�@�C�����J��
sim(filename);          %Simulink�̎��s

%Figure�ɂ�錋�ʂ̕\��
t = simout.time;        %����
y = simout.Data(:, 1);  %��]�p���x
u = simout.Data(:, 2);  %���͓d��
%y�̕\��
subplot(2,1,1)      %Figure��(2�s1��ɕ�������1�s1���)
plot(t, y)          %y1�̕\��
grid on             %�O���b�h���C���̒ǉ�
ylim([0, 25.0])      %y���̕\���͈͂��w��
ylabel('y')         %y�����x��
%u�̕\��
subplot(2,1,2)      %Figure��(2�s1��ɕ�������2�s1���)
plot(t, u)          %y2�̕\��
grid on             %�O���b�h���C���̒ǉ�
ylim([0, 2.0])      %y���̕\���͈͂��w��
xlabel('t')         %x�����x��
ylabel('u')         %y�����x��