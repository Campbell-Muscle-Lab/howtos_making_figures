function figure_two_way_lmm
% Code runs two-way linear mixed model without grouping

% Variables
data_file_string = 'data/two_way_lmm_data.xlsx';

% Code

% Make a figure
sp = initialise_publication_quality_figure( ...
    'no_of_panels_wide', 1, ...
    'no_of_panels_high', 1, ...
    'x_to_y_axes_ratio', 1.5, ...
    'axes_padding_left', 1.5, ...
    'top_margin', 1);




for i = 1:2

    if (i==1)
        force_scale_factor = 0.001;
        norm_force_factor = [];
    else
        norm_force_factor = out.first_force;
    end
    
    out = display_slcontrol_records( ...
       'record_file_strings', slc_file_strings, ...
       'force_subplot', sp(i), ...
       'fl_subplot', sp(i+2), ...
       'start_time_s', t_start_s, ...
       'stop_time_s', t_stop_s, ...
       'force_scale_factor', force_scale_factor, ...
       'normalize_force_factor', norm_force_factor, ...
       'force_record_ktr_offset',-1, ...
       'trace_colors', cm, ...
       'trace_line_width', 2, ...
       'display_pCa_values', 0, ...
       'single_fl_color',[0 0 0], ...
       'force_smooth_n_points', 10, ...
       'fl_smooth_n_points', 10);

    % Tidy axes
    x_ticks = [t_start_s : 1 : t_stop_s];
    y_label_offset = -0.25;

    if (i==1)
        f_axis_label = {'Force','normalized','to area','(kN m^{-2})'};
        f_ticks = [0 multiple_greater_than(out.max_force, 10)];
    else
        f_axis_label = {'Force','normalized','to','isometric'};
        f_ticks = [0 multiple_greater_than(out.max_force, 1)]
    end
    
    subplot(sp(i));
    ax = improve_axes( ...
       'x_ticks', x_ticks, ...
       'y_ticks', f_ticks, ...
       'x_axis_off', 1, ...
       'y_axis_label', f_axis_label, ...
       'y_label_offset', y_label_offset, ...
       'y_tick_decimal_places', 0);

    subplot(sp(i+2));
    improve_axes( ...
       'x_ticks', x_ticks([1 end]), ...
       'x_tick_decimal_places', 1, ...
       'x_label_offset', -0.3, ...
       'x_axis_label', 'Time (s)', ...
       'y_ticks', [multiple_less_than(out.min_fl, 0.05) multiple_greater_than(out.max_fl, 0.05)], ...
       'y_axis_label',{'Relative','length'}, ...
       'y_label_offset', y_label_offset, ...
       'y_tick_decimal_places', 2);

    % Add in legend using plot_table
    if (i==1)
        tab_x = 3 + linspace(t_start_s + 0.7, t_stop_s-0.7, 5);
        tab_x(2:end) = tab_x(2:end) + 0.2
        y_range = ax.y_ticks(end) - ax.y_ticks(1);
        tab_y = ax.y_ticks(end) + y_range * linspace(0.7, 0.2, 5);

        for j=1:5
            for k=1:5
                text_strings{j,k}='';
                line_handes{j,k}=[];
            end
        end
        text_strings{1,4} = 'pCa';
        text_strings{2,3} = sprintf('%.1f', out.pCa(1));
        text_strings{2,4} = sprintf('%.1f', out.pCa(4));
        text_strings{2,5} = sprintf('%.1f', out.pCa(7));
        text_strings{4,1} = 'Vel (l_o s^{-1})';
        text_strings{3,2} = 'x.y';
        text_strings{4,2} = 'a.b';
        text_strings{5,2} = 'c.d';
        c = 0;
        for j=1:3
            for k=1:3
                c = c+1;
                line_handles(k+2,j+2) = out.h_force(c);
                line_lengths(k+2,j+2) = 0.3;
            end
        end

        subplot(sp(i));
        set(gca,'Clipping','off');
        plot_table( ...
            'x', tab_x, ...
            'y', tab_y, ...
            'text_strings', text_strings, ...
            'line_handles', line_handles, ...
            'line_lengths', line_lengths, ...
            'border_color', [0 0 0], ...
            'border_dx',[-0.7 0.5], ...
            'border_dy',out.max_force * [0.08 -0.08])
    end
end
    
    