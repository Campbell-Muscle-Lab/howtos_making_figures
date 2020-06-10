function merge_nanostring_and_deidentified_clinical_data
% Function takes nanostring data and deidentified clinical data
% and merges them into a single file based on the hashcode

% The hashcodes are column labels in the nanostring

% Variables
nanostring_data_file_string = 'data/final_normalized_data_24Aug2017.csv';
clin_data_file_string = 'data/deidentified_clinical_data_09-Jun-2020_19_39_33.xlsx';

merged_data_file_string = 'data/merged_data.xlsx';

% Code

% Read in nanostring data
nano_d = readtable(nanostring_data_file_string, 'ReadVariableNames',true);
nano_fields = nano_d.Properties.VariableNames';

% Tidy up the gene-names so that they are valid MATLAB table fields
nano_d.GeneName = strrep(nano_d.GeneName,'-','_');

% Pull out the hashcodes
nano_hc = nano_fields(3:end);

% Create a new table
merged_data.hashcode = nano_hc';

gene_names = nano_d.GeneName;
for i=1:numel(gene_names)
    % Get the row number for the gene
    vi = find(strcmp(nano_d.GeneName, gene_names{i}));
    
    for j=1:numel(nano_hc)
        % Column number for hashcode j is j+2
        merged_data.(gene_names{i})(j) = nano_d.(nano_hc{j})(vi);
    end
end

% Flip fields and convert to table
fn = fieldnames(merged_data);
for i=1:numel(fn)
    merged_data.(fn{i}) = merged_data.(fn{i})';
end
merged_data = struct2table(merged_data);

% Now tidy up the hashcodes by removing anything related to LV position
% Also drop any preceding 'x' (required to make a label starting with
% a digit a valid column header during the import
merged_data.hashcode = strrep(merged_data.hashcode, 'x', '');
for i=1:numel(merged_data.hashcode);
    vi = regexp(merged_data.hashcode{i},'_');
    if (numel(vi)>0)
        merged_data.hashcode{i} = merged_data.hashcode{i}(1:(vi-1));
    end
end

% At this point we have a clear set of nanostring data

% Now merge in the clinical data
clin_data = load_REDCap_clinical_data_as_table(clin_data_file_string);
clin_fields = clin_data.Properties.VariableNames';

% Cycle through merged_data.hashcodes
for i=1:numel(merged_data.hashcode)
    % Find the corresponding row in the clinical data
    clin_row = find(strcmp(clin_data.record_id, merged_data.hashcode{i}));
    
    % Now add in the fields
    for j=1:numel(clin_fields)
        % Get the value
        x = clin_data.(clin_fields{j})(clin_row);
        % If it is a string, replace ' ' with '_'
        % for easier processing later
        if (iscell(x))
            x = strrep(x, ' ', '_');
        end
        merged_data.(clin_fields{j})(i) = x;
    end
end

head(merged_data)

% Write table
try
    delete(merged_data_file_string);
end
writetable(merged_data, merged_data_file_string);

