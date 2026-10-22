function zacess_apply(themeFile, fontFile, folderFile)
% sets MATLAB's desktop theme, colours and fonts from a theme file and a font file. an optional
% third file sets its start folder. each is a JSON object whose "settings" map a setting path
% (matlab.colors.KeywordColor) to its value, written through MATLAB's settings API as personal
% values. a value starting with ~/ is a folder under the home folder, made when it is missing, so
% one file serves every OS. each setting is printed as added, changed or unchanged, so a second run
% with the same files changes nothing.
    s = settings;
    pairs = [entries(themeFile); entries(fontFile)];
    if nargin > 2
        pairs = [pairs; entries(folderFile)];
    end
    for i = 1:size(pairs, 1)
        value = pairs{i, 2};
        if ischar(value) && startsWith(value, '~/')
            value = fullfile(char(java.lang.System.getProperty('user.home')), strrep(value(3:end), '/', filesep));
            if ~isfolder(value)
                mkdir(value);
            end
        end
        apply(s, pairs{i, 1}, value);
    end
end

function out = entries(file)
    data = jsondecode(fileread(file));
    keys = fieldnames(data.settings);
    out = cell(numel(keys), 2);
    for i = 1:numel(keys)
        % jsondecode turns the dots in each key into underscores, so the original key is read
        % from the file's own order
        out{i, 1} = keys{i};
        out{i, 2} = data.settings.(keys{i});
    end
    raw = regexp(fileread(file), '"(matlab\.[^"]+)"\s*:', 'tokens');
    for i = 1:numel(raw)
        out{i, 1} = raw{i}{1};
    end
end

function apply(s, path, value)
    parts = strsplit(path, '.');
    node = s;
    for i = 1:numel(parts)
        node = node.(parts{i});
    end
    if isnumeric(value)
        value = reshape(double(value), 1, []);
    else
        value = string(value);
    end
    if hasPersonalValue(node)
        old = node.PersonalValue;
        if isequal(double(old), double(value)) || (isstring(value) && string(old) == value)
            fprintf('  unchanged  settings  %s\n', path);
            return
        end
        status = 'changed  ';
    else
        status = 'added    ';
    end
    node.PersonalValue = value;
    fprintf('  %s  settings  %s\n', status, path);
end
