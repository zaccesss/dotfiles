function zacess_startup(pendingFile, toolsDir, fontFile, folderFile)
% applies a Zacess theme that zt left for MATLAB's next start, so zt never has to start MATLAB
% itself. startup.m calls this from the block each OS's apply script adds to it. the pending file
% holds one theme name (Zacess Deep Contrast Dark) and is removed once the theme is in place. the
% settings are written at once through zacess_apply. import_scheme from the Color Theme Extensions
% add-on in toolsDir needs the desktop, which is not ready while startup.m runs, so the scheme is
% applied from a timer once MATLAB is idle. MATLAB saves both when the session ends normally.
    if ~isfile(pendingFile)
        return
    end
    name = strtrim(fileread(pendingFile));
    here = fileparts(mfilename('fullpath'));
    themeFile = fullfile(here, 'themes', [name '.json']);
    schemeFile = fullfile(here, 'schemes', [name '.json']);
    if ~isfile(themeFile) || ~isfile(schemeFile)
        warning('zacess:theme', 'No Zacess theme called "%s" (from %s), so nothing was changed.', name, pendingFile);
        delete(pendingFile);
        return
    end
    addpath(toolsDir);
    % the settings lines zacess_apply prints are kept out of the Command Window
    evalc('zacess_apply(themeFile, fontFile, folderFile)');
    t = timer('Name', 'zacess-theme', 'StartDelay', 2, 'Period', 2, 'ExecutionMode', 'fixedSpacing', ...
        'TasksToExecute', 30, 'TimerFcn', @(t, ~) importScheme(t, schemeFile, pendingFile, name), ...
        'StopFcn', @(t, ~) delete(t));
    start(t);
end

function importScheme(t, schemeFile, pendingFile, name)
    try
        evalc('import_scheme(schemeFile)');
    catch err
        % the desktop may still be starting, so the timer tries again until its last run
        if t.TasksExecuted >= t.TasksToExecute
            warning('zacess:scheme', 'The %s colour scheme was not applied: %s', name, err.message);
        end
        return
    end
    stop(t);
    % zt may have left another theme while this one was being applied, so only this one's note goes
    if isfile(pendingFile) && strcmp(strtrim(fileread(pendingFile)), name)
        delete(pendingFile);
    end
end
