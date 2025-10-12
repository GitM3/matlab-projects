clear      % ���[�N�X�y�[�X���炷�ׂĂ̕ϐ�������
close all  % ���ׂĂ�Figure������
clc        % �R�}���h �E�B���h�E�̃N���A

%��H�f�q�̃p�����[�^
R = 100;         %��R[��]
C = 1e-6;        %�Ód�e��[C]
L = 5e-3;        %�C���_�N�^���X[H]

%Simulink�̎��s
Endtime = 1.0e-3;           %�V�~�����[�V�������s����
filename = 'Ex2_2_sim';     %�t�@�C�����i�g���q�Ȃ��j
open(filename);             %Simulink�t�@�C�����J��
sim(filename);              %Simulink�̎��s

%Figure�ɂ�錋�ʂ̕\��
t = simout.time;        %����
y = simout.Data(:, 1);  %�o�͓d��[V]
u = simout.Data(:, 2);  %���͓d��[V]
subplot(2,1,1)          %Figure��(2�s1��ɕ�������1�s1���)
plot(t, y, '-b')        %y�̕\���i�C�����j
ylabel('y[V]')          %y�����x��
grid on                 %�O���b�h���C���̒ǉ�
ylim([0, 1.5])          %y���̕\���͈͂��w��i�ŏ��l0�C�ő�l1.5�j
subplot(2,1,2)          %Figure��(2�s1��ɕ�������2�s1���)
plot(t, u, '-b')        %u�̕\���i�C�����j
grid on                 %�O���b�h���C���̒ǉ�
ylim([0, 1.5])          %y���̕\���͈͂��w��i�ŏ��l0�C�ő�l1.5�j
xlabel('t[s]')          %x�����x��
ylabel('u[V]')          %y�����x��