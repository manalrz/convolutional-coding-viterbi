function u = viterbi_decode(y, trellis)
    % Paramètres du code
    numStates = trellis.numStates;        % Nombre d'états
    numInputSymbols = trellis.numInputSymbols; % Symboles d'entrée (binaire)
    numOutputSymbols = trellis.numOutputSymbols; % Symboles de sortie
    n = log2(numOutputSymbols);          % Nombre de bits de sortie par entrée
    m = log2(numStates);                 % Mémoire du codeur
    L_coded = length(y) / n;             % Longueur du message codé (incluant les bits de terminaison)
    L = L_coded - m;                     % Longueur du message original

    % Initialisation des métriques de chemin
    pathMetrics = inf(numStates, 1);     % Mises à jour des métriques de chemin
    pathMetrics(1) = 0;                  % L'état initial (état 0) a une métrique nulle

    % Matrices pour stocker les survivants
    survivors = zeros(numStates, L_coded); % États précédents survivants
    inputs = zeros(numStates, L_coded);    % Entrées menant aux états courants

    % Boucle principale du décodage
    for l = 1:L_coded
        pathMetricsNew = inf(numStates, 1); % Mises à jour temporaires des métriques de chemin
        for s = 0:numStates-1
            for ps = 0:numStates-1
                for input = 0:numInputSymbols-1
                    nextState = trellis.nextStates(ps + 1, input + 1);
                    if nextState == s
                        output = trellis.outputs(ps + 1, input + 1);
                        
                        % Conversion de outputBits en vecteur ligne
                        outputBits = de2bi(output, n, 'left-msb');
                        if size(outputBits, 1) > size(outputBits, 2)
                            outputBits = outputBits';
                        end

                        % Correction de y_received
                        y_received = y((l - 1) * n + 1 : l * n);
                        if size(y_received, 1) > size(y_received, 2)
                            y_received = y_received';
                        end

                        % Calcul de la distance de Hamming
                        branchMetric = sum(outputBits ~= y_received);

                        % Calcul de la métrique totale
                        metric = pathMetrics(ps + 1) + branchMetric;

                        % Mise à jour si la nouvelle métrique est meilleure
                        if metric < pathMetricsNew(s + 1)
                            pathMetricsNew(s + 1) = metric;
                            survivors(s + 1, l) = ps;
                            inputs(s + 1, l) = input;
                        end
                    end
                end
            end
        end
        pathMetrics = pathMetricsNew;
    end

    % Récupération du chemin optimal (traceback)
    [~, state] = min(pathMetrics); % État final avec la métrique minimale
    state = state - 1;             % Ajustement pour l'indexation MATLAB

    % Reconstruction du message décodé
    u = zeros(L_coded, 1);
    for l = L_coded:-1:1
        input = inputs(state + 1, l);
        u(l) = input;
        state = survivors(state + 1, l);
    end

    % Suppression des bits de terminaison ajoutés pour fermer le treillis
    u = u(1:L);
end
