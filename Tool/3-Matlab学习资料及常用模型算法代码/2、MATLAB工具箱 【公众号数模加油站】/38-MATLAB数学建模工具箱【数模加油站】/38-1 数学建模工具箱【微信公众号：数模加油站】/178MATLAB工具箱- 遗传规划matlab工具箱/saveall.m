function saveall(vars)
%SAVEALL    Saves all the GPLAB algorithm variables to disk.
%   SAVEALL(VARIABLES) saves all the data stored in VARIABLES
%   into a file identified with the number of the current
%   generation, in the directory indicated in the algorithm
%   parameters.
%
%   Input arguments:
%      VARIABLES - contains: POP, PARAMS, STATE, DATA (struct)
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox


filename=[vars.params.savedir '/' num2str(vars.state.generation)];
save(filename,'vars');
