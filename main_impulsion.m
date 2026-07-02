clear;
close all;
clc;

%% Définition des treillis
trellis_1 = poly2trellis(2, [2 3]);
trellis_2 = poly2trellis(3, [5 7]);
trellis_3 = poly2trellis(4, [13 15]);
trellis_4 = poly2trellis(7, [133 171]);

% Liste des treillis et leurs étiquettes pour l'affichage
trellis_liste = {trellis_1, trellis_2, trellis_3, trellis_4};
trellis_labels = {'(2, [2 3])', '(3, [5 7])', '(4, [13 15])', '(7, [133 171])'};
num_trellis_liste = length(trellis_liste);

%% Paramètres de simulation
K = 1024; % Nombre de bits de message

M = 2;   % Modulation BPSK

EbN0dB_min  = 0; % Minimum de Eb/N0 en dB
EbN0dB_max  = 6; % Maximum de Eb/N0 en dB
EbN0dB_step = 1; % Pas de Eb/N0 en dB

EbN0dB  = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de Eb/N0 en dB à simuler
EbN0    = 10.^(EbN0dB/10); % Points de Eb/N0 à simuler

%% Préparation de l'affichage
figure(1)
hold on
xlabel('$\frac{E_b}{N_0}$ en dB', 'Interpreter', 'latex', 'FontSize', 14)
ylabel('TEP', 'Interpreter', 'latex', 'FontSize', 14)
title('Estimation du TEP par la méthode de l''impulsion')
grid on
legend('show')

%% Paramètres pour la méthode de l'impulsion
d_0 = 1;
d_1 = 100;

%% Calcul du TEP pour chaque treillis en utilisant la méthode de l'impulsion
for idx_trellis = 1:num_trellis_liste
    trellis = trellis_liste{idx_trellis};

    % Calcul du taux du code R pour le treillis courant
    k = log2(trellis.numInputSymbols);  % Nombre de bits par symbole d'entrée
    n = log2(trellis.numOutputSymbols); % Nombre de bits par symbole de sortie
    code_rate = k / n;
    N = K / code_rate; % Ajustement de N en fonction du taux du code
    R = code_rate;

    % Appel de la méthode de l'impulsion pour estimer le TEP
    TEP_impulsion = impulsion(d_0, d_1, K, N, EbN0, trellis);

    % Tracé du TEP estimé par la méthode de l'impulsion
    figure(1)
    semilogy(EbN0dB, TEP_impulsion, 'LineWidth', 1.5, 'DisplayName', ['TEP Treillis ' trellis_labels{idx_trellis}]);
    legend('show');
end

% Affichage final du graphique TEP
figure(1)
xlabel('$\frac{E_b}{N_0}$ en dB', 'Interpreter', 'latex', 'FontSize', 14)
ylabel('TEP', 'Interpreter', 'latex', 'FontSize', 14)
title('Estimation du TEP par la méthode de l''impulsion pour différents treillis')
grid on
legend('show')

% Sauvegarde des résultats
save('resultats_impulsion.mat', 'EbN0dB', 'TEP_impulsion', 'K', 'trellis_labels');