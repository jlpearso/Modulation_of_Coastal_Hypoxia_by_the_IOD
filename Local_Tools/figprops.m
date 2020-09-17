function figprops

    % set latex interpreter
    set(groot,'defaultTextInterpreter','latex');  
    set(groot,'defaultAxesTickLabelInterpreter','latex');  
    set(groot,'defaultLegendInterpreter','latex'); 

    %figure properties
    set(groot,'defaultFigureColor',[1 1 1])
    
    %axes and font properties
    set(groot,{'defaultTextFontsize','defaultAxesFontsize'},{14,14}); 
    set(groot,'defaultAxesFontName','palatino')
    
    %line properties
    set(groot,'defaultLineLineWidth',2)
    set(groot,'defaultLineMarkerSize', 10);
end