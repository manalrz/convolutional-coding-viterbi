% Vaude Kenzo & Rhazza Manâl

clear;
close all;
clc;

%% Définition des treillis
trellis_1 = poly2trellis(3, [1 5 7]);
trellis_2 = poly2trellis(3, [5 7]);
trellis_3 = poly2trellis(4, [13 15]);
trellis_4 = poly2trellis(4, [1 13 15]);

% Liste des treillis et leurs étiquettes pour l'affichage
trellis_liste = {trellis_1, trellis_2, trellis_3, trellis_4};
trellis_labels = {'récursif (1, 5/7)', 'non récursif (5,7)', 'non récursif (13 15)', 'récursif (1, 13/15)'};
num_trellis_liste = length(trellis_liste);

%% Paramètres de simulation
K = 1024; % Nombre de bits de message

% Calcul du taux du code pour chaque treillis (par défaut, taux 1/2)
code_rate = 1/2;
N = K / code_rate; % Nombre de bits codés par trame

R = K / N; % Rendement de la communication

M = 2;   % Modulation BPSK

EbN0dB_min  = -2; % Minimum de Eb/N0 en dB
EbN0dB_max  = 8; % Maximum de Eb/N0 en dB
EbN0dB_step = 1/2; % Pas de Eb/N0 en dB

EbN0dB  = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de Eb/N0 en dB à simuler
EbN0    = 10.^(EbN0dB/10); % Points de Eb/N0 à simuler
EsN0    = R*log2(M)*EbN0;  % Points de Es/N0
sigmaz2 = 1./(2 * EsN0);   % Variance de bruit pour chaque Eb/N0

%% Initialisation des matrices de résultats
TEB = zeros(num_trellis_liste, length(EbN0dB));
TEP = zeros(num_trellis_liste, length(EbN0dB));

Pb_u = qfunc(sqrt(2*EbN0)); % Probabilité d'erreur non codée
Pe_u = 1 - (1 - Pb_u).^K;

%% Préparation de l'affichage
figure(1)
semilogy(EbN0dB, Pb_u, '--', 'LineWidth', 1.5, 'DisplayName', 'Pb (BPSK non codé)');
hold all

xlabel('$\frac{E_b}{N_0}$ en dB', 'Interpreter', 'latex', 'FontSize', 14)
ylabel('TEB', 'Interpreter', 'latex', 'FontSize', 14)
title('Taux d''Erreur Binaire (TEB) récursif et non récursif')
grid on
legend('show')

%% Préparation de l'affichage en console
line       =  '|------------|------------|------------|------------|----------|----------|------------------|-------------------|\n';
msg_header =  '|  Eb/N0 dB  |  Bit nbr   |  Bit err   |  Pqt err   |   TEB    |   TEP    |     Débit Tx     |      Débit Rx     |\n';
msgFormat  =  '|   %7.2f  |  %8d  |  %8d |  %8d | %2.2e | %2.2e |  %10.2f MO/s |   %10.2f MO/s |\n';

%% Simulation pour chaque treillis
for idx_trellis = 1:num_trellis_liste
    trellis = trellis_liste{idx_trellis};
    fprintf('\n%s\n', line);
    fprintf('Simulation pour le treillis %s\n', trellis_labels{idx_trellis});
    fprintf(line);
    fprintf(msg_header);
    fprintf(line);
    
    % Initialisation des vecteurs de résultats pour ce treillis
    TEB_current = zeros(1, length(EbN0dB));
    TEP_current = zeros(1, length(EbN0dB));
    
    % Préparation des handles pour les courbes
    hTEB = semilogy(EbN0dB, TEB_current, 'LineWidth', 1.5, 'XDataSource', 'EbN0dB', 'YDataSource', 'TEB_current', 'DisplayName', ['TEB Treillis ' trellis_labels{idx_trellis}]);
    
    % Boucle sur les valeurs de Eb/N0
    for iSNR = 1:length(EbN0dB)
        % Initialisation
        bitErr = 0; % Nombre total d'erreurs accumulées
        totalBits = 0; % Nombre total de bits simulés
        pqtNbr = 0; % Nombre de paquets simulés
        maxErrors = 100; % Arrêter après au moins 100 erreurs
        maxBits = 1e7; % Limite du nombre total de bits simulés
    
        while (bitErr < maxErrors) && (totalBits < maxBits)
            pqtNbr = pqtNbr + 1;
    
            %% Emetteur
            u = randi([0, 1], K, 1); % Génération du message
            c = cc_encode(u, trellis); % Encodage convolutif
            x = 1 - 2 * c; % Modulation BPSK
    
            %% Canal
            z = sqrt(sigmaz2(iSNR)) * randn(size(x)); % Bruit AWGN
            y = x + z; % Signal bruité
    
            %% Récepteur
            u_rec = viterbi_decode(y < 0, trellis); % Décodage
    
            %% Calcul des erreurs
            bitErr = bitErr + sum(u ~= u_rec(1:K)); % Bits erronés
            totalBits = totalBits + K; % Bits simulés
        end
    
        % Calcul des métriques
        TEB_current(iSNR) = bitErr / totalBits;
        TEP_current(iSNR) = (bitErr > 0) / pqtNbr;
    
        % Ajouter la condition pour arrêter si TEB < 3e-6
        if TEB_current(iSNR) < 3e-6
            fprintf('TEB atteint le seuil minimal à Eb/N0 = %.2f dB, simulation arrêtée pour les treillis restants.\n', EbN0dB(iSNR));
            break;
        end
    
        % Mise à jour graphique
        refreshdata(hTEB);
        drawnow limitrate;
    
        % Affichage des résultats intermédiaires
        fprintf(msgFormat, EbN0dB(iSNR), totalBits, bitErr, (bitErr > 0), TEB_current(iSNR), TEP_current(iSNR), 0, 0);
    end
end

% Affichage final du graphique TEB
figure(1)
xlabel('$\frac{E_b}{N_0}$ en dB', 'Interpreter', 'latex', 'FontSize', 14)
ylabel('TEB', 'Interpreter', 'latex', 'FontSize', 14)
title('Taux d''Erreur Binaire (TEB) pour différents treillis')
grid on
legend('show')

% Tracé des TEP pour chaque treillis
figure(2)
semilogy(EbN0dB, Pe_u, '--', 'LineWidth', 1.5, 'DisplayName', 'Pe (BPSK non codé)');
hold all
grid on

for idx_trellis = 1:num_trellis_liste
    semilogy(EbN0dB, TEP(idx_trellis, :), 'LineWidth', 1.5, 'DisplayName', ['TEP Treillis ' trellis_labels{idx_trellis}]);
end

xlabel('$\frac{E_b}{N_0}$ en dB', 'Interpreter', 'latex', 'FontSize', 14)
ylabel('TEP', 'Interpreter', 'latex', 'FontSize', 14)
title('Taux d''Erreur par Paquet (TEP) pour différents treillis')
legend('show')

% Sauvegarde des résultats
save('resultats.mat', 'EbN0dB', 'TEB', 'TEP', 'R', 'K', 'N', 'Pb_u', 'Pe_u');