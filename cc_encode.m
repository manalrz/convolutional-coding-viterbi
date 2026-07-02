function c = cc_encode(u, trellis)
    k = length(u); % Nombre de symboles dans le message
    c = [];
    state = 0;
    m = log2(trellis.numStates); % Mémoire (bits de l'état)
    n = ceil(log2(max(trellis.outputs(:)) + 1)); % Nombre de bits de sortie par transition

    % Parcourir les symboles d'entrée
    for i = 1:k
        % Encodage
        next_state = trellis.nextStates(state + 1, u(i) + 1);
        output_symbol = trellis.outputs(state + 1, u(i) + 1);
        % Mise à jour
        c = [c, de2bi(output_symbol, n, 'left-msb')];
        state = next_state;
    end

    % Fermeture du treillis
    for i = 1:m
        output_symbol = trellis.outputs(state + 1, 1);
        c = [c, de2bi(output_symbol, n, 'left-msb')];
        next_state = trellis.nextStates(state + 1, 1);
        state = next_state;
    end

    % Vérification de l'état final
    if state ~= 0
        error('Le treillis n est pas correctement fermé.');
    end
end
