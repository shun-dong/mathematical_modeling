clc

disp ('Display various measures on the Werner states');
disp ('   ');

N = 30;

X_enthropy               = NaNs(1,N+1);
X_relative_entanglement  = NaNs(1,N+1);
X_relative_entropy       = NaNs(1,N+1);
X_negativity             = NaNs(1,N+1);
X_logarithmic_negativity = NaNs(1,N+1);
X_concurrence            = NaNs(1,N+1);

mixings = [0:N]/N;

start_time = clock();
for k=1:(N+1)
    fprintf ('%d of %d. ', k, N+1);
    
    dm = Werner(mixings(k));
    
    X_enthropy(k)               = S_Von_Neumann(dm);
    X_relative_entanglement(k)  = relative_entanglement(dm);
    X_relative_entropy(k)       = relative_entropy(dm);
    X_negativity(k)             = negativity(dm);
    X_logarithmic_negativity(k) = logarithmic_negativity(dm);
    X_concurrence(k)            = concurrence(dm);
    fprintf ('Time remaining estimate: ~%s\n', ...
        format_delta_t(etime(clock(),start_time)/k*(N+1-k)));

    figure(1); clf;
    plot(mixings, X_enthropy, 'k-', 'LineWidth',2); hold on;
    plot(mixings, X_relative_entanglement, 'b-', 'LineWidth',2); hold on;
    plot(mixings, X_relative_entropy, 'c-', 'LineWidth',2); hold on;
    plot(mixings, X_negativity, 'mx', 'LineWidth',2); hold on;
    plot(mixings, X_logarithmic_negativity, 'r-', 'LineWidth', 2); hold on;
    plot(mixings, X_concurrence, 'g:', 'LineWidth', 2); hold on;
    legend({'Enthropy', 'Rel Entangle', 'Rel Entropy', 'Negativity', 'LogNeg','Concurrence'},...
                'location','Best');
    xlabel ('Mixing (0 = Mixed, 1 = EPR)');
    grid on; axis tight;
    title ('Werner measures');
    drawnow;
end


filename = 'Werner_measures';
print ('-dpng', filename);
print ('-depsc2', filename);

