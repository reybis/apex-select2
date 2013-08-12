set define off
set verify off
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end;
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040200 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,55691954624826792581));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2012.01.01');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,64237);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...ui types
--
 
begin
 
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/item_type/be_ctb_select2
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'ITEM TYPE'
 ,p_name => 'BE.CTB.SELECT2'
 ,p_display_name => 'Select2'
 ,p_supported_ui_types => 'DESKTOP'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'-- GLOBAL CONSTANTS'||unistr('\000a')||
'gc_min_lov_cols constant number := 2;'||unistr('\000a')||
'gc_max_lov_cols constant number := 3;'||unistr('\000a')||
''||unistr('\000a')||
'gc_lov_display_col constant number := 1;'||unistr('\000a')||
'gc_lov_return_col  constant number := 2;'||unistr('\000a')||
'gc_lov_group_col   constant number := 3;'||unistr('\000a')||
''||unistr('\000a')||
'gc_contains_ignore_case    constant char(3) := ''CIC'';'||unistr('\000a')||
'gc_contains_case_sensitive constant char(3) := ''CCS'';'||unistr('\000a')||
'gc_exact_ignore_case       constant char(3) := ''EIC'';'||unistr('\000a')||
'gc_exact_case_sen'||
'sitive    constant char(3) := ''ECS'';'||unistr('\000a')||
''||unistr('\000a')||
'subtype gt_string is varchar2(32767);'||unistr('\000a')||
''||unistr('\000a')||
'type gt_optgroups'||unistr('\000a')||
'  is table of gt_string'||unistr('\000a')||
'  index by pls_integer;'||unistr('\000a')||
''||unistr('\000a')||
''||unistr('\000a')||
'-- UTIL'||unistr('\000a')||
'function boolean_to_string(p_boolean in boolean)'||unistr('\000a')||
'return varchar2 is'||unistr('\000a')||
'begin'||unistr('\000a')||
'  if (p_boolean) then'||unistr('\000a')||
'    return ''true'';'||unistr('\000a')||
'  elsif (not p_boolean) then'||unistr('\000a')||
'    return ''false'';'||unistr('\000a')||
'  else'||unistr('\000a')||
'    return '''';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'end boolean_to_string;'||unistr('\000a')||
''||unistr('\000a')||
'function add_js_attr(p_para'||
'm_name     in varchar2'||unistr('\000a')||
'                   , p_param_value    in varchar2'||unistr('\000a')||
'                   , p_include_quotes in boolean'||unistr('\000a')||
'                   , p_include_comma  in boolean default true)'||unistr('\000a')||
'return varchar2 is'||unistr('\000a')||
'  l_param_value gt_string;'||unistr('\000a')||
'  l_attr        gt_string;'||unistr('\000a')||
'begin'||unistr('\000a')||
'  if (p_param_value is not null) then'||unistr('\000a')||
'    if (p_include_quotes) then'||unistr('\000a')||
'      l_param_value := ''"'' || p_param_value || ''"'';'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'   '||
' l_attr := p_param_name || '': '' || nvl(l_param_value, p_param_value);'||unistr('\000a')||
'    if (p_include_comma) then'||unistr('\000a')||
'      l_attr := l_attr || '','';'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'  else'||unistr('\000a')||
'    l_attr := '''';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  return l_attr;'||unistr('\000a')||
'end add_js_attr;'||unistr('\000a')||
''||unistr('\000a')||
'function optgroup_exists(p_optgroups in gt_optgroups'||unistr('\000a')||
'                       , p_optgroup  in varchar2)'||unistr('\000a')||
'return boolean is'||unistr('\000a')||
'  l_index pls_integer := p_optgroups.first;'||unistr('\000a')||
'begin'||unistr('\000a')||
'  while (l_in'||
'dex is not null) loop'||unistr('\000a')||
'    if (p_optgroups(l_index) = p_optgroup) then'||unistr('\000a')||
'      return true;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    l_index := p_optgroups.next(l_index);'||unistr('\000a')||
'  end loop;'||unistr('\000a')||
'  '||unistr('\000a')||
'  return false;'||unistr('\000a')||
'end optgroup_exists;'||unistr('\000a')||
''||unistr('\000a')||
''||unistr('\000a')||
'-- FETCH LIST OF VALUES'||unistr('\000a')||
'function get_lov(p_item in apex_plugin.t_page_item)'||unistr('\000a')||
'return apex_plugin_util.t_column_value_list is'||unistr('\000a')||
'begin'||unistr('\000a')||
'  return apex_plugin_util.get_data('||unistr('\000a')||
'           p_sql_statement  => p_item.'||
'lov_definition,'||unistr('\000a')||
'           p_min_columns    => gc_min_lov_cols,'||unistr('\000a')||
'           p_max_columns    => gc_max_lov_cols,'||unistr('\000a')||
'           p_component_name => p_item.name'||unistr('\000a')||
'         );'||unistr('\000a')||
'end get_lov;'||unistr('\000a')||
''||unistr('\000a')||
'function get_tags_option(p_item             in apex_plugin.t_page_item,'||unistr('\000a')||
'                         p_select_list_type in varchar2)'||unistr('\000a')||
'return varchar2 is'||unistr('\000a')||
'  l_lov         apex_plugin_util.t_column_value_list;'||unistr('\000a')||
'  l_tags_option g'||
't_string;'||unistr('\000a')||
'begin'||unistr('\000a')||
'  l_lov := get_lov(p_item);'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (p_select_list_type = ''TAG'') then'||unistr('\000a')||
'    l_tags_option := ''tags: ['';'||unistr('\000a')||
'    for i in 1 .. l_lov(gc_lov_display_col).count loop'||unistr('\000a')||
'      if (p_item.escape_output) then'||unistr('\000a')||
'        l_tags_option := l_tags_option || ''"'' || sys.htf.escape_sc(l_lov(gc_lov_display_col)(i)) || ''",'';'||unistr('\000a')||
'      else'||unistr('\000a')||
'        l_tags_option := l_tags_option || ''"'' || l_lov(gc_lov_display_col'||
')(i) || ''",'';'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    end loop;'||unistr('\000a')||
'    if (l_lov(gc_lov_display_col).count > 0) then'||unistr('\000a')||
'      l_tags_option := substr(l_tags_option, 0, length(l_tags_option) - 1);'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    l_tags_option := l_tags_option || ''],'';'||unistr('\000a')||
'  else'||unistr('\000a')||
'    l_tags_option := '''';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  return l_tags_option;'||unistr('\000a')||
'end get_tags_option;'||unistr('\000a')||
''||unistr('\000a')||
''||unistr('\000a')||
'-- RENDER FUNCTION'||unistr('\000a')||
'function render(p_item                in apex_plugin.t_page_item,'||
''||unistr('\000a')||
'                p_plugin              in apex_plugin.t_plugin,'||unistr('\000a')||
'                p_value               in varchar2,'||unistr('\000a')||
'                p_is_readonly         in boolean,'||unistr('\000a')||
'                p_is_printer_friendly in boolean)'||unistr('\000a')||
'return apex_plugin.t_page_item_render_result is'||unistr('\000a')||
'  -- LOCAL VARIABLES'||unistr('\000a')||
'  l_no_matches_msg         gt_string := p_plugin.attribute_01;'||unistr('\000a')||
'  l_input_too_short_msg    gt_string := p_plugin.attr'||
'ibute_02;'||unistr('\000a')||
'  l_selection_too_big_msg  gt_string := p_plugin.attribute_03;'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_select_list_type       gt_string := p_item.attribute_01;'||unistr('\000a')||
'  l_min_results_for_search gt_string := p_item.attribute_02;'||unistr('\000a')||
'  l_min_input_length       gt_string := p_item.attribute_03;'||unistr('\000a')||
'  l_max_input_length       gt_string := p_item.attribute_04;'||unistr('\000a')||
'  l_max_selection_size     gt_string := p_item.attribute_05;'||unistr('\000a')||
'  l_rapid_selection'||
'        gt_string := p_item.attribute_06;'||unistr('\000a')||
'  l_select_on_blur         gt_string := p_item.attribute_07;'||unistr('\000a')||
'  l_search_logic           gt_string := p_item.attribute_08;'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_display_values apex_application_global.vc_arr2;'||unistr('\000a')||
'  l_lov            apex_plugin_util.t_column_value_list;'||unistr('\000a')||
'  laa_optgroups    gt_optgroups;'||unistr('\000a')||
'  l_multiselect    gt_string;'||unistr('\000a')||
'  l_placeholder    gt_string;'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_onload_code    gt_string'||
';'||unistr('\000a')||
'  l_render_result  apex_plugin.t_page_item_render_result;  '||unistr('\000a')||
'begin'||unistr('\000a')||
'  if apex_application.g_debug then'||unistr('\000a')||
'    apex_plugin_util.debug_page_item(p_plugin, p_item, p_value, p_is_readonly, p_is_printer_friendly);'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (p_is_readonly or p_is_printer_friendly) then'||unistr('\000a')||
'    apex_plugin_util.print_hidden_if_readonly(p_item.name, p_value, p_is_readonly, p_is_printer_friendly);'||unistr('\000a')||
'    '||unistr('\000a')||
'    l_display_valu'||
'es := apex_plugin_util.get_display_data('||unistr('\000a')||
'                          p_sql_statement     => p_item.lov_definition,'||unistr('\000a')||
'                          p_min_columns       => gc_min_lov_cols,'||unistr('\000a')||
'                          p_max_columns       => gc_max_lov_cols,'||unistr('\000a')||
'                          p_component_name    => p_item.name,'||unistr('\000a')||
'                          p_search_value_list => apex_util.string_to_table(p_value),'||unistr('\000a')||
'        '||
'                  p_display_extra     => p_item.lov_display_extra'||unistr('\000a')||
'                        );'||unistr('\000a')||
'    '||unistr('\000a')||
'    if (l_display_values.count = 1) then'||unistr('\000a')||
'      apex_plugin_util.print_display_only('||unistr('\000a')||
'        p_item_name        => p_item.name,'||unistr('\000a')||
'        p_display_value    => l_display_values(1),'||unistr('\000a')||
'        p_show_line_breaks => false,'||unistr('\000a')||
'        p_escape           => p_item.escape_output,'||unistr('\000a')||
'        p_attributes       => p_ite'||
'm.element_attributes'||unistr('\000a')||
'      );'||unistr('\000a')||
'    elsif (l_display_values.count > 1) then'||unistr('\000a')||
'      sys.htp.p('''||unistr('\000a')||
'        <ul id="'' || p_item.name || ''_DISPLAY"'||unistr('\000a')||
'            class="display_only">'');'||unistr('\000a')||
'      '||unistr('\000a')||
'      for i in 1 .. l_display_values.count loop'||unistr('\000a')||
'        if (p_item.escape_output) then'||unistr('\000a')||
'          sys.htp.p(''<li>'' || sys.htf.escape_sc(l_display_values(i)) || ''</li>'');'||unistr('\000a')||
'        else'||unistr('\000a')||
'          sys.htp.p(''<li>'' || l_dis'||
'play_values(i) || ''</li>'');'||unistr('\000a')||
'        end if;'||unistr('\000a')||
'      end loop;'||unistr('\000a')||
'      '||unistr('\000a')||
'      sys.htp.p(''</ul>'');'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    return l_render_result;'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  apex_javascript.add_library('||unistr('\000a')||
'    p_name      => ''select2.min'','||unistr('\000a')||
'    p_directory => p_plugin.file_prefix,'||unistr('\000a')||
'    p_version   => null'||unistr('\000a')||
'  );'||unistr('\000a')||
'  apex_css.add_file('||unistr('\000a')||
'    p_name      => ''select2'','||unistr('\000a')||
'    p_directory => p_plugin.file_prefix,'||unistr('\000a')||
'    p_version   => nul'||
'l'||unistr('\000a')||
'  );'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_lov := get_lov(p_item);'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (l_select_list_type = ''MULTI'') then'||unistr('\000a')||
'    l_multiselect := ''multiple'';'||unistr('\000a')||
'  else'||unistr('\000a')||
'    l_multiselect := '''';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (l_select_list_type = ''TAG'') then'||unistr('\000a')||
'    sys.htp.p('''||unistr('\000a')||
'      <input type="hidden"'||unistr('\000a')||
'             id="'' || p_item.name || ''"'||unistr('\000a')||
'             name="'' || apex_plugin.get_input_name_for_page_item(true) || ''"'||unistr('\000a')||
'             class="'' || p_item.element_c'||
'ss_classes || ''" '' ||'||unistr('\000a')||
'             p_item.element_attributes || ''>'');'||unistr('\000a')||
'  else'||unistr('\000a')||
'    sys.htp.p('''||unistr('\000a')||
'      <select '' || l_multiselect || '''||unistr('\000a')||
'              id="'' || p_item.name || ''"'||unistr('\000a')||
'              name="'' || apex_plugin.get_input_name_for_page_item(true) || ''"'||unistr('\000a')||
'              class="selectlist '' || p_item.element_css_classes || ''" '' ||'||unistr('\000a')||
'              p_item.element_attributes || ''>'');'||unistr('\000a')||
'    '||unistr('\000a')||
'    if (p_item.lov_di'||
'splay_null) then'||unistr('\000a')||
'      sys.htp.p(''<option></option>'');'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if (l_lov.exists(gc_lov_group_col)) then'||unistr('\000a')||
'      for i in 1 .. l_lov(gc_lov_display_col).count loop'||unistr('\000a')||
'        if (not optgroup_exists(laa_optgroups, l_lov(gc_lov_group_col)(i))) then'||unistr('\000a')||
'          sys.htp.p(''<optgroup label="'' || l_lov(gc_lov_group_col)(i) || ''">'');'||unistr('\000a')||
'          for j in 1 .. l_lov(gc_lov_display_col).count loop'||unistr('\000a')||
'    '||
'        if (l_lov(gc_lov_group_col)(i) = l_lov(gc_lov_group_col)(j)) then'||unistr('\000a')||
'              apex_plugin_util.print_option('||unistr('\000a')||
'                p_display_value => l_lov(gc_lov_display_col)(j),'||unistr('\000a')||
'                p_return_value  => l_lov(gc_lov_return_col)(j),'||unistr('\000a')||
'                p_is_selected   => apex_plugin_util.is_equal(l_lov(gc_lov_return_col)(j), p_value),'||unistr('\000a')||
'                p_attributes    => p_item.element_op'||
'tion_attributes,'||unistr('\000a')||
'                p_escape        => p_item.escape_output'||unistr('\000a')||
'              );'||unistr('\000a')||
'            end if;'||unistr('\000a')||
'          end loop;'||unistr('\000a')||
'          sys.htp.p(''</optgroup>'');'||unistr('\000a')||
'          '||unistr('\000a')||
'          laa_optgroups(i) := l_lov(gc_lov_group_col)(i);'||unistr('\000a')||
'        end if;'||unistr('\000a')||
'      end loop;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      for i in 1 .. l_lov(gc_lov_display_col).count loop'||unistr('\000a')||
'        apex_plugin_util.print_option('||unistr('\000a')||
'          p_display_value =>'||
' l_lov(gc_lov_display_col)(i),'||unistr('\000a')||
'          p_return_value  => l_lov(gc_lov_return_col)(i),'||unistr('\000a')||
'          p_is_selected   => apex_plugin_util.is_equal(l_lov(gc_lov_return_col)(i), p_value),'||unistr('\000a')||
'          p_attributes    => p_item.element_option_attributes,'||unistr('\000a')||
'          p_escape        => p_item.escape_output'||unistr('\000a')||
'        );'||unistr('\000a')||
'      end loop;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    sys.htp.p(''</select>'');'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (p_item.lov_di'||
'splay_null) then'||unistr('\000a')||
'    l_placeholder := p_item.lov_null_text;'||unistr('\000a')||
'  else'||unistr('\000a')||
'    l_placeholder := '''';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (l_rapid_selection is null) then'||unistr('\000a')||
'    l_rapid_selection := '''';'||unistr('\000a')||
'  else'||unistr('\000a')||
'    l_rapid_selection := ''false'';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (l_select_on_blur is null) then'||unistr('\000a')||
'    l_select_on_blur := '''';'||unistr('\000a')||
'  else'||unistr('\000a')||
'    l_select_on_blur := ''true'';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_onload_code := '''||unistr('\000a')||
'    $("#'' || p_item.name || ''").sele'||
'ct2({'' ||'||unistr('\000a')||
'      add_js_attr(''minimumInputLength'', l_min_input_length, false) ||'||unistr('\000a')||
'      add_js_attr(''maximumInputLength'', l_max_input_length, false) ||'||unistr('\000a')||
'      add_js_attr(''minimumResultsForSearch'', l_min_results_for_search, false) ||'||unistr('\000a')||
'      add_js_attr(''maximumSelectionSize'', l_max_selection_size, false) ||'||unistr('\000a')||
'      add_js_attr(''placeholder'', l_placeholder, true) || '''||unistr('\000a')||
'      separator: ":",'||unistr('\000a')||
'      allowCle'||
'ar: true,'' ||'||unistr('\000a')||
'      add_js_attr(''closeOnSelect'', l_rapid_selection, false) ||'||unistr('\000a')||
'      get_tags_option(p_item, l_select_list_type) ||'||unistr('\000a')||
'      add_js_attr(''selectOnBlur'', l_select_on_blur, false);'||unistr('\000a')||
'    '||unistr('\000a')||
'  if (l_no_matches_msg is not null) then'||unistr('\000a')||
'    l_onload_code := l_onload_code || '''||unistr('\000a')||
'      formatNoMatches: function(term) {'||unistr('\000a')||
'                         var msg = "'' || l_no_matches_msg || ''";'||unistr('\000a')||
'                  '||
'       msg = msg.replace("#TERM#", term);'||unistr('\000a')||
'                         return msg;'||unistr('\000a')||
'                       },'';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (l_input_too_short_msg is not null) then'||unistr('\000a')||
'    l_onload_code := l_onload_code || '''||unistr('\000a')||
'      formatInputTooShort: function(term, minLength) {'||unistr('\000a')||
'                             var msg = "'' || l_input_too_short_msg || ''";'||unistr('\000a')||
'                             msg = msg.replace("#TERM#", term);'||unistr('\000a')||
' '||
'                            msg = msg.replace("#MINLENGTH#", minLength);'||unistr('\000a')||
'                             return msg;'||unistr('\000a')||
'                           },'';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (l_selection_too_big_msg is not null) then'||unistr('\000a')||
'    l_onload_code := l_onload_code || '''||unistr('\000a')||
'      formatSelectionTooBig: function(maxSize) {'||unistr('\000a')||
'                               var msg = "'' || l_selection_too_big_msg || ''";'||unistr('\000a')||
'                          '||
'     msg = msg.replace("#MAXSIZE#", maxSize);'||unistr('\000a')||
'                               return msg;'||unistr('\000a')||
'                             },'';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  if (l_search_logic != gc_contains_ignore_case) then'||unistr('\000a')||
'    case l_search_logic'||unistr('\000a')||
'      when gc_contains_case_sensitive then l_search_logic := ''return text.indexOf(term) >= 0;'';'||unistr('\000a')||
'      when gc_exact_ignore_case then l_search_logic := ''return text.toUpperCase() == term.'||
'toUpperCase() || term.length === 0;'';'||unistr('\000a')||
'      when gc_exact_case_sensitive then l_search_logic := ''return text == term || term.length === 0;'';'||unistr('\000a')||
'      else l_search_logic := ''return text.toUpperCase().indexOf(term.toUpperCase()) >= 0;'';'||unistr('\000a')||
'    end case;'||unistr('\000a')||
'    '||unistr('\000a')||
'    l_onload_code := l_onload_code || '''||unistr('\000a')||
'      matcher: function(term, text) {'||unistr('\000a')||
'                 '' || l_search_logic || '''||unistr('\000a')||
'               },'';'||unistr('\000a')||
'  end if'||
';'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_onload_code := l_onload_code || ''width: "resolve"});'';'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_onload_code := l_onload_code || '''||unistr('\000a')||
'    apex.widget.selectList('||unistr('\000a')||
'      $("#'' || p_item.name || ''"),'||unistr('\000a')||
'      {'' ||'||unistr('\000a')||
'        add_js_attr(''nullValue'', p_item.lov_null_value, true) ||'||unistr('\000a')||
'        add_js_attr(''dependingOnSelector'', apex_plugin_util.page_item_names_to_jquery(p_item.lov_cascade_parent_items), true) ||'||unistr('\000a')||
'        add_js_attr(''pageI'||
'temsToSubmit'', apex_plugin_util.page_item_names_to_jquery(p_item.ajax_items_to_submit), true) ||'||unistr('\000a')||
'        add_js_attr(''optimizeRefresh'', boolean_to_string(p_item.ajax_optimize_refresh), false) ||'||unistr('\000a')||
'        add_js_attr(''ajaxIdentifier'', apex_plugin.get_ajax_identifier, true, false) || '''||unistr('\000a')||
'      }'||unistr('\000a')||
'    );'';'||unistr('\000a')||
'  '||unistr('\000a')||
'  apex_javascript.add_onload_code(l_onload_code);'||unistr('\000a')||
'  l_render_result.is_navigable := true;'||unistr('\000a')||
'  retu'||
'rn l_render_result;'||unistr('\000a')||
'end render;'||unistr('\000a')||
''||unistr('\000a')||
''||unistr('\000a')||
'-- AJAX FUNCTION'||unistr('\000a')||
'function ajax(p_item   in apex_plugin.t_page_item'||unistr('\000a')||
'            , p_plugin in apex_plugin.t_plugin)'||unistr('\000a')||
'return apex_plugin.t_page_item_ajax_result is'||unistr('\000a')||
'  l_lov           apex_plugin_util.t_column_value_list;'||unistr('\000a')||
'  l_display_value gt_string;'||unistr('\000a')||
'  l_json          gt_string;'||unistr('\000a')||
'  l_result        apex_plugin.t_page_item_ajax_result;'||unistr('\000a')||
'begin'||unistr('\000a')||
'  l_lov := get_lov(p_item);'||unistr('\000a')||
'  '||
''||unistr('\000a')||
'  if (l_lov.exists(gc_lov_group_col)) then'||unistr('\000a')||
'    l_json := ''{"values":['';'||unistr('\000a')||
'    '||unistr('\000a')||
'    for i in 1 .. l_lov(gc_lov_display_col).count loop'||unistr('\000a')||
'      if (p_item.escape_output) then'||unistr('\000a')||
'        l_display_value := sys.htf.escape_sc(l_lov(gc_lov_display_col)(i));'||unistr('\000a')||
'      else'||unistr('\000a')||
'        l_display_value := l_lov(gc_lov_display_col)(i);'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'      l_json := l_json || ''{"d":"'' || l_display_value || ''","r":"'' || l_'||
'lov(gc_lov_return_col)(i) || ''"},'';'||unistr('\000a')||
'    end loop;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if (l_lov(gc_lov_display_col).count > 0) then'||unistr('\000a')||
'      l_json := substr(l_json, 0, (length(l_json) - 1));'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    l_json := l_json || ''], "default":""}'';'||unistr('\000a')||
'    sys.htp.p(l_json);'||unistr('\000a')||
'  else'||unistr('\000a')||
'    apex_plugin_util.print_page_item_lov_as_json('||unistr('\000a')||
'      p_sql_statement  => p_item.lov_definition,'||unistr('\000a')||
'      p_page_item_name => p_item.name,'||unistr('\000a')||
'      p_e'||
'scape         => p_item.escape_output'||unistr('\000a')||
'    );'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  return l_result;'||unistr('\000a')||
'end ajax;'
 ,p_render_function => 'render'
 ,p_ajax_function => 'ajax'
 ,p_standard_attributes => 'VISIBLE:SESSION_STATE:READONLY:ESCAPE_OUTPUT:QUICKPICK:SOURCE:ELEMENT:ELEMENT_OPTION:ENCRYPT:LOV:LOV_REQUIRED:LOV_DISPLAY_NULL:CASCADING_LOV'
 ,p_sql_min_column_count => 2
 ,p_sql_max_column_count => 3
 ,p_sql_examples => '<span style="font-weight:bold;">1. Dynamic LOV</span>'||unistr('\000a')||
'<pre>SELECT ename, empno FROM emp ORDER by ename</pre>'||unistr('\000a')||
''||unistr('\000a')||
'<span style="font-weight:bold;">2. Dynamic LOV with option grouping</span>'||unistr('\000a')||
'<pre>'||unistr('\000a')||
'SELECT e.ename d'||unistr('\000a')||
'     , e.empno r'||unistr('\000a')||
'     , d.dname grp'||unistr('\000a')||
'  FROM emp e'||unistr('\000a')||
'  JOIN dept d ON d.deptno = e.deptno'||unistr('\000a')||
' ORDER BY grp, d'||unistr('\000a')||
'</pre>'
 ,p_substitute_attributes => true
 ,p_subscribe_plugin_settings => true
 ,p_version_identifier => '1.0'
 ,p_about_url => 'http://apex.oracle.com/pls/apex/f?p=64237:20'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24265098823114279611 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'No Matches Message'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => true
 ,p_help_text => 'The default message is "No matches found". It is possible to reference the substitution variable #TERM#.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24265100119017281604 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Input Too Short Message'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => true
 ,p_help_text => 'The default message is "Please enter x more characters". It is possible to reference the substitution variables #TERM# and #MINLENGTH#.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24265100716213282888 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Selection Too Big Message'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => true
 ,p_help_text => 'The default message is "You can only select x items". It is possible to reference the substitution variable #MAXSIZE#.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Select List Type'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'SINGLE'
 ,p_is_translatable => false
 ,p_help_text => 'A single-value select list allows the user to select one option, while the multi-value select list makes it possible to select multiple items. When tagging support is enabled, the user can select from pre-existing options or create new options on the fly.'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24264058015333104705 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Single-value Select List'
 ,p_return_value => 'SINGLE'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24264059213392041056 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Multi-value Select List'
 ,p_return_value => 'MULTI'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24264060310588042366 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 30
 ,p_display_value => 'Tagging Support'
 ,p_return_value => 'TAG'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24264511714180196436 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Minimum Results for Search Field'
 ,p_attribute_type => 'INTEGER'
 ,p_is_required => false
 ,p_display_length => 8
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'IN_LIST'
 ,p_depending_on_expression => 'SINGLE'
 ,p_help_text => 'The minimum number of results that must be populated in order to display the search field. A negative value always hides the search field.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24264651025166141947 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Minimum Input Length'
 ,p_attribute_type => 'INTEGER'
 ,p_is_required => false
 ,p_display_length => 8
 ,p_is_translatable => false
 ,p_help_text => 'The minimum length for a search term or a new option entered by the user.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24264654009208213932 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'Maximum Input Length'
 ,p_attribute_type => 'INTEGER'
 ,p_is_required => false
 ,p_display_length => 8
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'IN_LIST'
 ,p_depending_on_expression => 'TAG'
 ,p_help_text => 'Maximum number of characters that can be entered for a new option.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24264773723644222396 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'Maximum Selection Size'
 ,p_attribute_type => 'INTEGER'
 ,p_is_required => false
 ,p_display_length => 8
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'IN_LIST'
 ,p_depending_on_expression => 'MULTI,TAG'
 ,p_help_text => 'The maximum number of items that can be selected.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24264777012646162945 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 60
 ,p_prompt => 'Rapid Selection'
 ,p_attribute_type => 'CHECKBOXES'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 24264054218783103179 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'IN_LIST'
 ,p_depending_on_expression => 'MULTI,TAG'
 ,p_help_text => 'Keep open the options dropdown after a selection is made, allowing for rapid selection of multiple items.'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24264778611136163705 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24264777012646162945 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => ' '
 ,p_return_value => 'Y'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24264836611302224350 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 7
 ,p_display_sequence => 70
 ,p_prompt => 'Select on Blur'
 ,p_attribute_type => 'CHECKBOXES'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'Determines whether the currently highlighted option is selected when the select list loses focus.'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24264837110224224895 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24264836611302224350 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => ' '
 ,p_return_value => 'Y'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 24293771920476265284 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 8
 ,p_display_sequence => 80
 ,p_prompt => 'Search Logic'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'CIC'
 ,p_is_translatable => false
 ,p_help_text => 'Defines how the search with the entered value should be performed.'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24293774516162267247 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24293771920476265284 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Contains & Ignore Case'
 ,p_return_value => 'CIC'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24293775114221268129 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24293771920476265284 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Contains & Case Sensitive'
 ,p_return_value => 'CCS'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24293776311202269539 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24293771920476265284 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 30
 ,p_display_value => 'Exact & Ignore Case'
 ,p_return_value => 'EIC'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 24293779708614270700 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 24293771920476265284 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 40
 ,p_display_value => 'Exact & Case Sensitive'
 ,p_return_value => 'ECS'
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '47494638396110001000F40000FFFFFF000000F0F0F08A8A8AE0E0E04646467A7A7A000000585858242424ACACACBEBEBE1414149C9C9C040404363636686868000000000000000000000000000000000000000000000000000000000000000000000000';
wwv_flow_api.g_varchar2_table(2) := '00000000000000000021FF0B4E45545343415045322E30030100000021FE1A43726561746564207769746820616A61786C6F61642E696E666F0021F904090A0000002C0000000010001000000577202002020921E5A802444208C74190AB481C89E0C8C2';
wwv_flow_api.g_varchar2_table(3) := 'AC12B3C161B003A64482C210E640205EB61441E958F89050A440F1B822558382B3512309CEE142815C3B9FCD0BC331AA120C18056FCF3A32241A760340040A247C2C33040F0B0A0D04825F23020806000D6404803504063397220B73350B0B65210021F9';
wwv_flow_api.g_varchar2_table(4) := '04090A0000002C000000001000100000057620200202694065398E444108C941108CB28AC4F1C00E112FAB1960706824188D4361254020058CC7E97048A908089D10B078BD460281C275538914108301782385050D0404C22EBFDD84865914668E11044C';
wwv_flow_api.g_varchar2_table(5) := '025F2203050A700A33428357810410040B885D7C4C060D5C36927B7C7A9A389D375B37210021F904090A0000002C000000001000100000057820200202D90C65398E0444084522088FB28A8483C032722CAB17A07150C4148702800014186AB4C260F038';
wwv_flow_api.g_varchar2_table(6) := '100607EB12C240100838621648122C202AD1E230182DA60DF06D465718EEE439BD4C50A445332B020A1028820242220D060B668D7B882A42575F2F897F020D405F2489827E4B728137417237210021F904090A0000002C00000000100010000005762020';
wwv_flow_api.g_varchar2_table(7) := '0202D93465398E84210848F122CB2A128F1B0BD0518F2F4083B1882D0E1012813480100405C3A97010340E8C522BF7BC2D12079FE8B570AD08C8A760D1502896360883E1A09D1AF0552FFC2009080B2A2C0484290403282B2F5D226C4F852F862A416B91';
wwv_flow_api.g_varchar2_table(8) := '7F938A0B4B948C8A5D417E3636A036210021F904090A0000002C000000001000100000056C20200202691865398E042208C7F11ECB2A12871B0B0CBDBE00032DD6383048041282B1803D4E3BA10CD0CA11548445ECD010BD16AE15EE7115101AE8A4EDB1';
wwv_flow_api.g_varchar2_table(9) := '659E0CEA556F4B325F575AF2DD8C5689B4316A67570465407475482F2F77603F8589667E2392899636949323210021F904090A0000002C000000001000100000057E20200202B92C65398E82220883F11AC42A0A863B0C7052B3250284B0233006A49A60';
wwv_flow_api.g_varchar2_table(10) := 'A120C01A27C3639928A41603944A40401C1EBF17C1B512141A2F31C16903341088C260BD56AD1A89040342E2BE56040F0D757D842263070705614E692F0C075D070C29298D2D0708004C656C7F09070B6D697D0004070D6D655B2B210021F904090A0000';
wwv_flow_api.g_varchar2_table(11) := '002C000000001000100000057920200202491065398EC222084DF336C42AC2A8223745CD968481404728284C26D470716A405A85A789F9BA11200C84EF2540AD04100577AC5A29201084706C03280A8F8781D4AD8E080871F5752A131607075226630610';
wwv_flow_api.g_varchar2_table(12) := '090760070F2929280C070307737F5F4A9004883E5F5C0E07270E476D37088C242B210021F904090A0000002C000000001000100000057720200202491065398E022A2C8B2028C42ABE28FC42355B12311801B220A55AB2D349616821064797AA6578187A';
wwv_flow_api.g_varchar2_table(13) := 'B2EC4A308865BF36C0C240567C55AB0504F134BAB6446DB28525240ECD9BEB70180C0A095C07054700037809090D7D00402B047C040C0C020F073D2B0A0731932D09456135026C292B210021F904090A0000002C00000000100010000005792020020229';
wwv_flow_api.g_varchar2_table(14) := '9CE4A89E27419C4BA992AFE0DA8D2CA2B6FD0E049389455C286C839CA9263B35208DE01035124489C4198030E81EB3338261AC302D128B1590B52D1C0ED11DA1C01894048EC383704834141005560910250D690307030F0F0A705B52227C09028C02080E';
wwv_flow_api.g_varchar2_table(15) := '91230A9902090F3605695A7763772A210021F904090A0000002C000000001000100000057920200202299CE4A89E2C4B942AF9B6C4028BA8309F0B619A3BD78BD0B001593881626034E96EA41E0BC2A84262008262BB781CBE052CB1C1D41119BE91A0B1';
wwv_flow_api.g_varchar2_table(16) := 'CB16BECD13E4D128091207C8BDB01D20040B0806250A3E03070D08050B0C0A322A04070F028A02060F692A0B092F05053A10992B240303762A210021F904090A0000002C000000001000100000057520200202299CE4A89E6C5BAA24E10AB24A10715BA3';
wwv_flow_api.g_varchar2_table(17) := 'C2710C339960515BF80E351381F83A190E8A95F00449582130C072414438180C4376AB90C91405DC4850666911BEE469005194048F83415040701B1043060D2544000D500610040F5134360C05028A020D6963690210084E6A30770D842923210021F904';
wwv_flow_api.g_varchar2_table(18) := '090A0000002C000000001000100000057920200202299CE4A82E0C71BEA80A2C47020BAE4A10007228AF1C4A90380C088743F0E42A118A878642B42C991A8E85EA26183C0A85818CB4DB191268B10C577E2D10BC9160D12C090C8796F5A4182CEC3E0302';
wwv_flow_api.g_varchar2_table(19) := '10063B0A0D38524E3C2C0B0385103C31540F105D06020A9863049197270D716B240A40292321003B000000000000000000';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 24264136203860053936 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_file_name => 'select2-spinner.gif'
 ,p_mime_type => 'image/gif'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A56657273696F6E3A20332E342E312054696D657374616D703A20546875204A756E2032372031383A30323A31302050445420323031330A2A2F0A2E73656C656374322D636F6E7461696E6572207B0A202020206D617267696E3A20303B0A202020';
wwv_flow_api.g_varchar2_table(2) := '20706F736974696F6E3A2072656C61746976653B0A20202020646973706C61793A20696E6C696E652D626C6F636B3B0A202020202F2A20696E6C696E652D626C6F636B20666F7220696537202A2F0A202020207A6F6F6D3A20313B0A202020202A646973';
wwv_flow_api.g_varchar2_table(3) := '706C61793A20696E6C696E653B0A20202020766572746963616C2D616C69676E3A206D6964646C653B0A7D0A0A2E73656C656374322D636F6E7461696E65722C0A2E73656C656374322D64726F702C0A2E73656C656374322D7365617263682C0A2E7365';
wwv_flow_api.g_varchar2_table(4) := '6C656374322D73656172636820696E7075747B0A20202F2A0A20202020466F72636520626F726465722D626F7820736F2074686174202520776964746873206669742074686520706172656E740A20202020636F6E7461696E657220776974686F757420';
wwv_flow_api.g_varchar2_table(5) := '6F7665726C61702062656361757365206F66206D617267696E2F70616464696E672E0A0A202020204D6F726520496E666F203A20687474703A2F2F7777772E717569726B736D6F64652E6F72672F6373732F626F782E68746D6C0A20202A2F0A20202D77';
wwv_flow_api.g_varchar2_table(6) := '65626B69742D626F782D73697A696E673A20626F726465722D626F783B202F2A207765626B6974202A2F0A2020202D6B68746D6C2D626F782D73697A696E673A20626F726465722D626F783B202F2A206B6F6E717565726F72202A2F0A20202020202D6D';
wwv_flow_api.g_varchar2_table(7) := '6F7A2D626F782D73697A696E673A20626F726465722D626F783B202F2A2066697265666F78202A2F0A2020202020202D6D732D626F782D73697A696E673A20626F726465722D626F783B202F2A206965202A2F0A20202020202020202020626F782D7369';
wwv_flow_api.g_varchar2_table(8) := '7A696E673A20626F726465722D626F783B202F2A2063737333202A2F0A7D0A0A2E73656C656374322D636F6E7461696E6572202E73656C656374322D63686F696365207B0A20202020646973706C61793A20626C6F636B3B0A202020206865696768743A';
wwv_flow_api.g_varchar2_table(9) := '20323670783B0A2020202070616464696E673A203020302030203870783B0A202020206F766572666C6F773A2068696464656E3B0A20202020706F736974696F6E3A2072656C61746976653B0A0A20202020626F726465723A2031707820736F6C696420';
wwv_flow_api.g_varchar2_table(10) := '236161613B0A2020202077686974652D73706163653A206E6F777261703B0A202020206C696E652D6865696768743A20323670783B0A20202020636F6C6F723A20233434343B0A20202020746578742D6465636F726174696F6E3A206E6F6E653B0A0A20';
wwv_flow_api.g_varchar2_table(11) := '2020202D7765626B69742D626F726465722D7261646975733A203470783B0A202020202020202D6D6F7A2D626F726465722D7261646975733A203470783B0A202020202020202020202020626F726465722D7261646975733A203470783B0A0A20202020';
wwv_flow_api.g_varchar2_table(12) := '2D7765626B69742D6261636B67726F756E642D636C69703A2070616464696E672D626F783B0A202020202020202D6D6F7A2D6261636B67726F756E642D636C69703A2070616464696E673B0A2020202020202020202020206261636B67726F756E642D63';
wwv_flow_api.g_varchar2_table(13) := '6C69703A2070616464696E672D626F783B0A0A202020202D7765626B69742D746F7563682D63616C6C6F75743A206E6F6E653B0A2020202020202D7765626B69742D757365722D73656C6563743A206E6F6E653B0A202020202020202D6B68746D6C2D75';
wwv_flow_api.g_varchar2_table(14) := '7365722D73656C6563743A206E6F6E653B0A2020202020202020202D6D6F7A2D757365722D73656C6563743A206E6F6E653B0A202020202020202020202D6D732D757365722D73656C6563743A206E6F6E653B0A20202020202020202020202020207573';
wwv_flow_api.g_varchar2_table(15) := '65722D73656C6563743A206E6F6E653B0A0A202020206261636B67726F756E642D636F6C6F723A20236666663B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6772616469656E74286C696E6561722C206C65667420626F';
wwv_flow_api.g_varchar2_table(16) := '74746F6D2C206C65667420746F702C20636F6C6F722D73746F7028302C2023656565656565292C20636F6C6F722D73746F7028302E352C20776869746529293B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6C696E6561';
wwv_flow_api.g_varchar2_table(17) := '722D6772616469656E742863656E74657220626F74746F6D2C20236565656565652030252C20776869746520353025293B0A202020206261636B67726F756E642D696D6167653A202D6D6F7A2D6C696E6561722D6772616469656E742863656E74657220';
wwv_flow_api.g_varchar2_table(18) := '626F74746F6D2C20236565656565652030252C20776869746520353025293B0A202020206261636B67726F756E642D696D6167653A202D6F2D6C696E6561722D6772616469656E7428626F74746F6D2C20236565656565652030252C2023666666666666';
wwv_flow_api.g_varchar2_table(19) := '20353025293B0A202020206261636B67726F756E642D696D6167653A202D6D732D6C696E6561722D6772616469656E7428746F702C20236666666666662030252C202365656565656520353025293B0A2020202066696C7465723A2070726F6769643A44';
wwv_flow_api.g_varchar2_table(20) := '58496D6167655472616E73666F726D2E4D6963726F736F66742E6772616469656E74287374617274436F6C6F72737472203D202723666666666666272C20656E64436F6C6F72737472203D202723656565656565272C204772616469656E745479706520';
wwv_flow_api.g_varchar2_table(21) := '3D2030293B0A202020206261636B67726F756E642D696D6167653A206C696E6561722D6772616469656E7428746F702C20236666666666662030252C202365656565656520353025293B0A7D0A0A2E73656C656374322D636F6E7461696E65722E73656C';
wwv_flow_api.g_varchar2_table(22) := '656374322D64726F702D61626F7665202E73656C656374322D63686F696365207B0A20202020626F726465722D626F74746F6D2D636F6C6F723A20236161613B0A0A202020202D7765626B69742D626F726465722D7261646975733A3020302034707820';
wwv_flow_api.g_varchar2_table(23) := '3470783B0A202020202020202D6D6F7A2D626F726465722D7261646975733A30203020347078203470783B0A202020202020202020202020626F726465722D7261646975733A30203020347078203470783B0A0A202020206261636B67726F756E642D69';
wwv_flow_api.g_varchar2_table(24) := '6D6167653A202D7765626B69742D6772616469656E74286C696E6561722C206C65667420626F74746F6D2C206C65667420746F702C20636F6C6F722D73746F7028302C2023656565656565292C20636F6C6F722D73746F7028302E392C20776869746529';
wwv_flow_api.g_varchar2_table(25) := '293B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6C696E6561722D6772616469656E742863656E74657220626F74746F6D2C20236565656565652030252C20776869746520393025293B0A202020206261636B67726F75';
wwv_flow_api.g_varchar2_table(26) := '6E642D696D6167653A202D6D6F7A2D6C696E6561722D6772616469656E742863656E74657220626F74746F6D2C20236565656565652030252C20776869746520393025293B0A202020206261636B67726F756E642D696D6167653A202D6F2D6C696E6561';
wwv_flow_api.g_varchar2_table(27) := '722D6772616469656E7428626F74746F6D2C20236565656565652030252C20776869746520393025293B0A202020206261636B67726F756E642D696D6167653A202D6D732D6C696E6561722D6772616469656E7428746F702C2023656565656565203025';
wwv_flow_api.g_varchar2_table(28) := '2C2366666666666620393025293B0A2020202066696C7465723A2070726F6769643A4458496D6167655472616E73666F726D2E4D6963726F736F66742E6772616469656E7428207374617274436F6C6F727374723D2723666666666666272C20656E6443';
wwv_flow_api.g_varchar2_table(29) := '6F6C6F727374723D2723656565656565272C4772616469656E74547970653D3020293B0A202020206261636B67726F756E642D696D6167653A206C696E6561722D6772616469656E7428746F702C20236565656565652030252C23666666666666203930';
wwv_flow_api.g_varchar2_table(30) := '25293B0A7D0A0A2E73656C656374322D636F6E7461696E65722E73656C656374322D616C6C6F77636C656172202E73656C656374322D63686F696365202E73656C656374322D63686F73656E207B0A202020206D617267696E2D72696768743A20343270';
wwv_flow_api.g_varchar2_table(31) := '783B0A7D0A0A2E73656C656374322D636F6E7461696E6572202E73656C656374322D63686F696365203E202E73656C656374322D63686F73656E207B0A202020206D617267696E2D72696768743A20323670783B0A20202020646973706C61793A20626C';
wwv_flow_api.g_varchar2_table(32) := '6F636B3B0A202020206F766572666C6F773A2068696464656E3B0A0A2020202077686974652D73706163653A206E6F777261703B0A0A202020202D6D732D746578742D6F766572666C6F773A20656C6C69707369733B0A20202020202D6F2D746578742D';
wwv_flow_api.g_varchar2_table(33) := '6F766572666C6F773A20656C6C69707369733B0A2020202020202020746578742D6F766572666C6F773A20656C6C69707369733B0A7D0A0A2E73656C656374322D636F6E7461696E6572202E73656C656374322D63686F6963652061626272207B0A2020';
wwv_flow_api.g_varchar2_table(34) := '2020646973706C61793A206E6F6E653B0A2020202077696474683A20313270783B0A202020206865696768743A20313270783B0A20202020706F736974696F6E3A206162736F6C7574653B0A2020202072696768743A20323470783B0A20202020746F70';
wwv_flow_api.g_varchar2_table(35) := '3A203870783B0A0A20202020666F6E742D73697A653A203170783B0A20202020746578742D6465636F726174696F6E3A206E6F6E653B0A0A20202020626F726465723A20303B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F';
wwv_flow_api.g_varchar2_table(36) := '5052454649582373656C656374322E706E67272920726967687420746F70206E6F2D7265706561743B0A20202020637572736F723A20706F696E7465723B0A202020206F75746C696E653A20303B0A7D0A0A2E73656C656374322D636F6E7461696E6572';
wwv_flow_api.g_varchar2_table(37) := '2E73656C656374322D616C6C6F77636C656172202E73656C656374322D63686F6963652061626272207B0A20202020646973706C61793A20696E6C696E652D626C6F636B3B0A7D0A0A2E73656C656374322D636F6E7461696E6572202E73656C65637432';
wwv_flow_api.g_varchar2_table(38) := '2D63686F69636520616262723A686F766572207B0A202020206261636B67726F756E642D706F736974696F6E3A207269676874202D313170783B0A20202020637572736F723A20706F696E7465723B0A7D0A0A2E73656C656374322D64726F702D756E64';
wwv_flow_api.g_varchar2_table(39) := '65726D61736B207B0A20202020626F726465723A20303B0A202020206D617267696E3A20303B0A2020202070616464696E673A20303B0A20202020706F736974696F6E3A206162736F6C7574653B0A202020206C6566743A20303B0A20202020746F703A';
wwv_flow_api.g_varchar2_table(40) := '20303B0A202020207A2D696E6465783A20393939383B0A202020206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A2020202066696C7465723A20616C706861286F7061636974793D30293B0A7D0A0A2E73656C656374322D';
wwv_flow_api.g_varchar2_table(41) := '64726F702D6D61736B207B0A20202020626F726465723A20303B0A202020206D617267696E3A20303B0A2020202070616464696E673A20303B0A20202020706F736974696F6E3A206162736F6C7574653B0A202020206C6566743A20303B0A2020202074';
wwv_flow_api.g_varchar2_table(42) := '6F703A20303B0A202020207A2D696E6465783A20393939383B0A202020202F2A207374796C657320726571756972656420666F7220494520746F20776F726B202A2F0A202020206261636B67726F756E642D636F6C6F723A20236666663B0A202020206F';
wwv_flow_api.g_varchar2_table(43) := '7061636974793A20303B0A2020202066696C7465723A20616C706861286F7061636974793D30293B0A7D0A0A2E73656C656374322D64726F70207B0A2020202077696474683A20313030253B0A202020206D617267696E2D746F703A202D3170783B0A20';
wwv_flow_api.g_varchar2_table(44) := '202020706F736974696F6E3A206162736F6C7574653B0A202020207A2D696E6465783A20393939393B0A20202020746F703A20313030253B0A0A202020206261636B67726F756E643A20236666663B0A20202020636F6C6F723A20233030303B0A202020';
wwv_flow_api.g_varchar2_table(45) := '20626F726465723A2031707820736F6C696420236161613B0A20202020626F726465722D746F703A20303B0A0A202020202D7765626B69742D626F726465722D7261646975733A2030203020347078203470783B0A202020202020202D6D6F7A2D626F72';
wwv_flow_api.g_varchar2_table(46) := '6465722D7261646975733A2030203020347078203470783B0A202020202020202020202020626F726465722D7261646975733A2030203020347078203470783B0A0A202020202D7765626B69742D626F782D736861646F773A2030203470782035707820';
wwv_flow_api.g_varchar2_table(47) := '7267626128302C20302C20302C202E3135293B0A202020202020202D6D6F7A2D626F782D736861646F773A20302034707820357078207267626128302C20302C20302C202E3135293B0A202020202020202020202020626F782D736861646F773A203020';
wwv_flow_api.g_varchar2_table(48) := '34707820357078207267626128302C20302C20302C202E3135293B0A7D0A0A2E73656C656374322D64726F702D6175746F2D7769647468207B0A20202020626F726465722D746F703A2031707820736F6C696420236161613B0A2020202077696474683A';
wwv_flow_api.g_varchar2_table(49) := '206175746F3B0A7D0A0A2E73656C656374322D64726F702D6175746F2D7769647468202E73656C656374322D736561726368207B0A2020202070616464696E672D746F703A203470783B0A7D0A0A2E73656C656374322D64726F702E73656C656374322D';
wwv_flow_api.g_varchar2_table(50) := '64726F702D61626F7665207B0A202020206D617267696E2D746F703A203170783B0A20202020626F726465722D746F703A2031707820736F6C696420236161613B0A20202020626F726465722D626F74746F6D3A20303B0A0A202020202D7765626B6974';
wwv_flow_api.g_varchar2_table(51) := '2D626F726465722D7261646975733A2034707820347078203020303B0A202020202020202D6D6F7A2D626F726465722D7261646975733A2034707820347078203020303B0A202020202020202020202020626F726465722D7261646975733A2034707820';
wwv_flow_api.g_varchar2_table(52) := '347078203020303B0A0A202020202D7765626B69742D626F782D736861646F773A2030202D34707820357078207267626128302C20302C20302C202E3135293B0A202020202020202D6D6F7A2D626F782D736861646F773A2030202D3470782035707820';
wwv_flow_api.g_varchar2_table(53) := '7267626128302C20302C20302C202E3135293B0A202020202020202020202020626F782D736861646F773A2030202D34707820357078207267626128302C20302C20302C202E3135293B0A7D0A0A2E73656C656374322D64726F702D616374697665207B';
wwv_flow_api.g_varchar2_table(54) := '0A20202020626F726465723A2031707820736F6C696420233538393766623B0A20202020626F726465722D746F703A206E6F6E653B0A7D0A0A2E73656C656374322D64726F702E73656C656374322D64726F702D61626F76652E73656C656374322D6472';
wwv_flow_api.g_varchar2_table(55) := '6F702D616374697665207B0A20202020626F726465722D746F703A2031707820736F6C696420233538393766623B0A7D0A0A2E73656C656374322D636F6E7461696E6572202E73656C656374322D63686F696365202E73656C656374322D6172726F7720';
wwv_flow_api.g_varchar2_table(56) := '7B0A20202020646973706C61793A20696E6C696E652D626C6F636B3B0A2020202077696474683A20313870783B0A202020206865696768743A20313030253B0A20202020706F736974696F6E3A206162736F6C7574653B0A2020202072696768743A2030';
wwv_flow_api.g_varchar2_table(57) := '3B0A20202020746F703A20303B0A0A20202020626F726465722D6C6566743A2031707820736F6C696420236161613B0A202020202D7765626B69742D626F726465722D7261646975733A2030203470782034707820303B0A202020202020202D6D6F7A2D';
wwv_flow_api.g_varchar2_table(58) := '626F726465722D7261646975733A2030203470782034707820303B0A202020202020202020202020626F726465722D7261646975733A2030203470782034707820303B0A0A202020202D7765626B69742D6261636B67726F756E642D636C69703A207061';
wwv_flow_api.g_varchar2_table(59) := '6464696E672D626F783B0A202020202020202D6D6F7A2D6261636B67726F756E642D636C69703A2070616464696E673B0A2020202020202020202020206261636B67726F756E642D636C69703A2070616464696E672D626F783B0A0A202020206261636B';
wwv_flow_api.g_varchar2_table(60) := '67726F756E643A20236363633B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6772616469656E74286C696E6561722C206C65667420626F74746F6D2C206C65667420746F702C20636F6C6F722D73746F7028302C202363';
wwv_flow_api.g_varchar2_table(61) := '6363292C20636F6C6F722D73746F7028302E362C202365656529293B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6C696E6561722D6772616469656E742863656E74657220626F74746F6D2C20236363632030252C2023';
wwv_flow_api.g_varchar2_table(62) := '65656520363025293B0A202020206261636B67726F756E642D696D6167653A202D6D6F7A2D6C696E6561722D6772616469656E742863656E74657220626F74746F6D2C20236363632030252C202365656520363025293B0A202020206261636B67726F75';
wwv_flow_api.g_varchar2_table(63) := '6E642D696D6167653A202D6F2D6C696E6561722D6772616469656E7428626F74746F6D2C20236363632030252C202365656520363025293B0A202020206261636B67726F756E642D696D6167653A202D6D732D6C696E6561722D6772616469656E742874';
wwv_flow_api.g_varchar2_table(64) := '6F702C20236363636363632030252C202365656565656520363025293B0A2020202066696C7465723A2070726F6769643A4458496D6167655472616E73666F726D2E4D6963726F736F66742E6772616469656E74287374617274436F6C6F72737472203D';
wwv_flow_api.g_varchar2_table(65) := '202723656565656565272C20656E64436F6C6F72737472203D202723636363636363272C204772616469656E7454797065203D2030293B0A202020206261636B67726F756E642D696D6167653A206C696E6561722D6772616469656E7428746F702C2023';
wwv_flow_api.g_varchar2_table(66) := '6363636363632030252C202365656565656520363025293B0A7D0A0A2E73656C656374322D636F6E7461696E6572202E73656C656374322D63686F696365202E73656C656374322D6172726F772062207B0A20202020646973706C61793A20626C6F636B';
wwv_flow_api.g_varchar2_table(67) := '3B0A2020202077696474683A20313030253B0A202020206865696768743A20313030253B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322E706E672729206E6F2D72657065617420302031';
wwv_flow_api.g_varchar2_table(68) := '70783B0A7D0A0A2E73656C656374322D736561726368207B0A20202020646973706C61793A20696E6C696E652D626C6F636B3B0A2020202077696474683A20313030253B0A202020206D696E2D6865696768743A20323670783B0A202020206D61726769';
wwv_flow_api.g_varchar2_table(69) := '6E3A20303B0A2020202070616464696E672D6C6566743A203470783B0A2020202070616464696E672D72696768743A203470783B0A0A20202020706F736974696F6E3A2072656C61746976653B0A202020207A2D696E6465783A2031303030303B0A0A20';
wwv_flow_api.g_varchar2_table(70) := '20202077686974652D73706163653A206E6F777261703B0A7D0A0A2E73656C656374322D73656172636820696E707574207B0A2020202077696474683A20313030253B0A202020206865696768743A206175746F2021696D706F7274616E743B0A202020';
wwv_flow_api.g_varchar2_table(71) := '206D696E2D6865696768743A20323670783B0A2020202070616464696E673A20347078203230707820347078203570783B0A202020206D617267696E3A20303B0A0A202020206F75746C696E653A20303B0A20202020666F6E742D66616D696C793A2073';
wwv_flow_api.g_varchar2_table(72) := '616E732D73657269663B0A20202020666F6E742D73697A653A2031656D3B0A0A20202020626F726465723A2031707820736F6C696420236161613B0A202020202D7765626B69742D626F726465722D7261646975733A20303B0A202020202020202D6D6F';
wwv_flow_api.g_varchar2_table(73) := '7A2D626F726465722D7261646975733A20303B0A202020202020202020202020626F726465722D7261646975733A20303B0A0A202020202D7765626B69742D626F782D736861646F773A206E6F6E653B0A202020202020202D6D6F7A2D626F782D736861';
wwv_flow_api.g_varchar2_table(74) := '646F773A206E6F6E653B0A202020202020202020202020626F782D736861646F773A206E6F6E653B0A0A202020206261636B67726F756E643A20236666662075726C282723504C5547494E5F5052454649582373656C656374322E706E672729206E6F2D';
wwv_flow_api.g_varchar2_table(75) := '7265706561742031303025202D323270783B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322E706E672729206E6F2D7265706561742031303025202D323270782C202D7765626B69742D67';
wwv_flow_api.g_varchar2_table(76) := '72616469656E74286C696E6561722C206C65667420626F74746F6D2C206C65667420746F702C20636F6C6F722D73746F7028302E38352C207768697465292C20636F6C6F722D73746F7028302E39392C202365656565656529293B0A202020206261636B';
wwv_flow_api.g_varchar2_table(77) := '67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322E706E672729206E6F2D7265706561742031303025202D323270782C202D7765626B69742D6C696E6561722D6772616469656E742863656E74657220626F74746F';
wwv_flow_api.g_varchar2_table(78) := '6D2C207768697465203835252C202365656565656520393925293B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322E706E672729206E6F2D7265706561742031303025202D323270782C20';
wwv_flow_api.g_varchar2_table(79) := '2D6D6F7A2D6C696E6561722D6772616469656E742863656E74657220626F74746F6D2C207768697465203835252C202365656565656520393925293B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C';
wwv_flow_api.g_varchar2_table(80) := '656374322E706E672729206E6F2D7265706561742031303025202D323270782C202D6F2D6C696E6561722D6772616469656E7428626F74746F6D2C207768697465203835252C202365656565656520393925293B0A202020206261636B67726F756E643A';
wwv_flow_api.g_varchar2_table(81) := '2075726C282723504C5547494E5F5052454649582373656C656374322E706E672729206E6F2D7265706561742031303025202D323270782C202D6D732D6C696E6561722D6772616469656E7428746F702C2023666666666666203835252C202365656565';
wwv_flow_api.g_varchar2_table(82) := '656520393925293B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322E706E672729206E6F2D7265706561742031303025202D323270782C206C696E6561722D6772616469656E7428746F70';
wwv_flow_api.g_varchar2_table(83) := '2C2023666666666666203835252C202365656565656520393925293B0A7D0A0A2E73656C656374322D64726F702E73656C656374322D64726F702D61626F7665202E73656C656374322D73656172636820696E707574207B0A202020206D617267696E2D';
wwv_flow_api.g_varchar2_table(84) := '746F703A203470783B0A7D0A0A2E73656C656374322D73656172636820696E7075742E73656C656374322D616374697665207B0A202020206261636B67726F756E643A20236666662075726C282723504C5547494E5F5052454649582373656C65637432';
wwv_flow_api.g_varchar2_table(85) := '2D7370696E6E65722E6769662729206E6F2D72657065617420313030253B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322D7370696E6E65722E6769662729206E6F2D7265706561742031';
wwv_flow_api.g_varchar2_table(86) := '3030252C202D7765626B69742D6772616469656E74286C696E6561722C206C65667420626F74746F6D2C206C65667420746F702C20636F6C6F722D73746F7028302E38352C207768697465292C20636F6C6F722D73746F7028302E39392C202365656565';
wwv_flow_api.g_varchar2_table(87) := '656529293B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322D7370696E6E65722E6769662729206E6F2D72657065617420313030252C202D7765626B69742D6C696E6561722D6772616469';
wwv_flow_api.g_varchar2_table(88) := '656E742863656E74657220626F74746F6D2C207768697465203835252C202365656565656520393925293B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322D7370696E6E65722E67696627';
wwv_flow_api.g_varchar2_table(89) := '29206E6F2D72657065617420313030252C202D6D6F7A2D6C696E6561722D6772616469656E742863656E74657220626F74746F6D2C207768697465203835252C202365656565656520393925293B0A202020206261636B67726F756E643A2075726C2827';
wwv_flow_api.g_varchar2_table(90) := '23504C5547494E5F5052454649582373656C656374322D7370696E6E65722E6769662729206E6F2D72657065617420313030252C202D6F2D6C696E6561722D6772616469656E7428626F74746F6D2C207768697465203835252C20236565656565652039';
wwv_flow_api.g_varchar2_table(91) := '3925293B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322D7370696E6E65722E6769662729206E6F2D72657065617420313030252C202D6D732D6C696E6561722D6772616469656E742874';
wwv_flow_api.g_varchar2_table(92) := '6F702C2023666666666666203835252C202365656565656520393925293B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C656374322D7370696E6E65722E6769662729206E6F2D7265706561742031';
wwv_flow_api.g_varchar2_table(93) := '3030252C206C696E6561722D6772616469656E7428746F702C2023666666666666203835252C202365656565656520393925293B0A7D0A0A2E73656C656374322D636F6E7461696E65722D616374697665202E73656C656374322D63686F6963652C0A2E';
wwv_flow_api.g_varchar2_table(94) := '73656C656374322D636F6E7461696E65722D616374697665202E73656C656374322D63686F69636573207B0A20202020626F726465723A2031707820736F6C696420233538393766623B0A202020206F75746C696E653A206E6F6E653B0A0A202020202D';
wwv_flow_api.g_varchar2_table(95) := '7765626B69742D626F782D736861646F773A2030203020357078207267626128302C302C302C2E33293B0A202020202020202D6D6F7A2D626F782D736861646F773A2030203020357078207267626128302C302C302C2E33293B0A202020202020202020';
wwv_flow_api.g_varchar2_table(96) := '202020626F782D736861646F773A2030203020357078207267626128302C302C302C2E33293B0A7D0A0A2E73656C656374322D64726F70646F776E2D6F70656E202E73656C656374322D63686F696365207B0A20202020626F726465722D626F74746F6D';
wwv_flow_api.g_varchar2_table(97) := '2D636F6C6F723A207472616E73706172656E743B0A202020202D7765626B69742D626F782D736861646F773A2030203170782030202366666620696E7365743B0A202020202020202D6D6F7A2D626F782D736861646F773A203020317078203020236666';
wwv_flow_api.g_varchar2_table(98) := '6620696E7365743B0A202020202020202020202020626F782D736861646F773A2030203170782030202366666620696E7365743B0A0A202020202D7765626B69742D626F726465722D626F74746F6D2D6C6566742D7261646975733A20303B0A20202020';
wwv_flow_api.g_varchar2_table(99) := '202020202D6D6F7A2D626F726465722D7261646975732D626F74746F6D6C6566743A20303B0A202020202020202020202020626F726465722D626F74746F6D2D6C6566742D7261646975733A20303B0A0A202020202D7765626B69742D626F726465722D';
wwv_flow_api.g_varchar2_table(100) := '626F74746F6D2D72696768742D7261646975733A20303B0A20202020202020202D6D6F7A2D626F726465722D7261646975732D626F74746F6D72696768743A20303B0A202020202020202020202020626F726465722D626F74746F6D2D72696768742D72';
wwv_flow_api.g_varchar2_table(101) := '61646975733A20303B0A0A202020206261636B67726F756E642D636F6C6F723A20236565653B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6772616469656E74286C696E6561722C206C65667420626F74746F6D2C206C';
wwv_flow_api.g_varchar2_table(102) := '65667420746F702C20636F6C6F722D73746F7028302C207768697465292C20636F6C6F722D73746F7028302E352C202365656565656529293B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6C696E6561722D6772616469';
wwv_flow_api.g_varchar2_table(103) := '656E742863656E74657220626F74746F6D2C2077686974652030252C202365656565656520353025293B0A202020206261636B67726F756E642D696D6167653A202D6D6F7A2D6C696E6561722D6772616469656E742863656E74657220626F74746F6D2C';
wwv_flow_api.g_varchar2_table(104) := '2077686974652030252C202365656565656520353025293B0A202020206261636B67726F756E642D696D6167653A202D6F2D6C696E6561722D6772616469656E7428626F74746F6D2C2077686974652030252C202365656565656520353025293B0A2020';
wwv_flow_api.g_varchar2_table(105) := '20206261636B67726F756E642D696D6167653A202D6D732D6C696E6561722D6772616469656E7428746F702C20236666666666662030252C2365656565656520353025293B0A2020202066696C7465723A2070726F6769643A4458496D6167655472616E';
wwv_flow_api.g_varchar2_table(106) := '73666F726D2E4D6963726F736F66742E6772616469656E7428207374617274436F6C6F727374723D2723656565656565272C20656E64436F6C6F727374723D2723666666666666272C4772616469656E74547970653D3020293B0A202020206261636B67';
wwv_flow_api.g_varchar2_table(107) := '726F756E642D696D6167653A206C696E6561722D6772616469656E7428746F702C20236666666666662030252C2365656565656520353025293B0A7D0A0A2E73656C656374322D64726F70646F776E2D6F70656E2E73656C656374322D64726F702D6162';
wwv_flow_api.g_varchar2_table(108) := '6F7665202E73656C656374322D63686F6963652C0A2E73656C656374322D64726F70646F776E2D6F70656E2E73656C656374322D64726F702D61626F7665202E73656C656374322D63686F69636573207B0A20202020626F726465723A2031707820736F';
wwv_flow_api.g_varchar2_table(109) := '6C696420233538393766623B0A20202020626F726465722D746F702D636F6C6F723A207472616E73706172656E743B0A0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6772616469656E74286C696E6561722C206C656674';
wwv_flow_api.g_varchar2_table(110) := '20746F702C206C65667420626F74746F6D2C20636F6C6F722D73746F7028302C207768697465292C20636F6C6F722D73746F7028302E352C202365656565656529293B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6C69';
wwv_flow_api.g_varchar2_table(111) := '6E6561722D6772616469656E742863656E74657220746F702C2077686974652030252C202365656565656520353025293B0A202020206261636B67726F756E642D696D6167653A202D6D6F7A2D6C696E6561722D6772616469656E742863656E74657220';
wwv_flow_api.g_varchar2_table(112) := '746F702C2077686974652030252C202365656565656520353025293B0A202020206261636B67726F756E642D696D6167653A202D6F2D6C696E6561722D6772616469656E7428746F702C2077686974652030252C202365656565656520353025293B0A20';
wwv_flow_api.g_varchar2_table(113) := '2020206261636B67726F756E642D696D6167653A202D6D732D6C696E6561722D6772616469656E7428626F74746F6D2C20236666666666662030252C2365656565656520353025293B0A2020202066696C7465723A2070726F6769643A4458496D616765';
wwv_flow_api.g_varchar2_table(114) := '5472616E73666F726D2E4D6963726F736F66742E6772616469656E7428207374617274436F6C6F727374723D2723656565656565272C20656E64436F6C6F727374723D2723666666666666272C4772616469656E74547970653D3020293B0A2020202062';
wwv_flow_api.g_varchar2_table(115) := '61636B67726F756E642D696D6167653A206C696E6561722D6772616469656E7428626F74746F6D2C20236666666666662030252C2365656565656520353025293B0A7D0A0A2E73656C656374322D64726F70646F776E2D6F70656E202E73656C65637432';
wwv_flow_api.g_varchar2_table(116) := '2D63686F696365202E73656C656374322D6172726F77207B0A202020206261636B67726F756E643A207472616E73706172656E743B0A20202020626F726465722D6C6566743A206E6F6E653B0A2020202066696C7465723A206E6F6E653B0A7D0A2E7365';
wwv_flow_api.g_varchar2_table(117) := '6C656374322D64726F70646F776E2D6F70656E202E73656C656374322D63686F696365202E73656C656374322D6172726F772062207B0A202020206261636B67726F756E642D706F736974696F6E3A202D31387078203170783B0A7D0A0A2F2A20726573';
wwv_flow_api.g_varchar2_table(118) := '756C7473202A2F0A2E73656C656374322D726573756C7473207B0A202020206D61782D6865696768743A2032303070783B0A2020202070616464696E673A203020302030203470783B0A202020206D617267696E3A20347078203470782034707820303B';
wwv_flow_api.g_varchar2_table(119) := '0A20202020706F736974696F6E3A2072656C61746976653B0A202020206F766572666C6F772D783A2068696464656E3B0A202020206F766572666C6F772D793A206175746F3B0A202020202D7765626B69742D7461702D686967686C696768742D636F6C';
wwv_flow_api.g_varchar2_table(120) := '6F723A207267626128302C302C302C30293B0A7D0A0A2E73656C656374322D726573756C747320756C2E73656C656374322D726573756C742D737562207B0A202020206D617267696E3A20303B0A2020202070616464696E672D6C6566743A20303B0A7D';
wwv_flow_api.g_varchar2_table(121) := '0A0A2E73656C656374322D726573756C747320756C2E73656C656374322D726573756C742D737562203E206C69202E73656C656374322D726573756C742D6C6162656C207B2070616464696E672D6C6566743A2032307078207D0A2E73656C656374322D';
wwv_flow_api.g_varchar2_table(122) := '726573756C747320756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D737562203E206C69202E73656C656374322D726573756C742D6C6162656C207B2070616464696E672D6C6566743A203430707820';
wwv_flow_api.g_varchar2_table(123) := '7D0A2E73656C656374322D726573756C747320756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D737562203E206C69202E73656C656374322D72';
wwv_flow_api.g_varchar2_table(124) := '6573756C742D6C6162656C207B2070616464696E672D6C6566743A2036307078207D0A2E73656C656374322D726573756C747320756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73';
wwv_flow_api.g_varchar2_table(125) := '656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D737562203E206C69202E73656C656374322D726573756C742D6C6162656C207B2070616464696E672D6C6566743A2038307078207D0A2E73656C656374322D72';
wwv_flow_api.g_varchar2_table(126) := '6573756C747320756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E7365';
wwv_flow_api.g_varchar2_table(127) := '6C656374322D726573756C742D737562203E206C69202E73656C656374322D726573756C742D6C6162656C207B2070616464696E672D6C6566743A203130307078207D0A2E73656C656374322D726573756C747320756C2E73656C656374322D72657375';
wwv_flow_api.g_varchar2_table(128) := '6C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E7365';
wwv_flow_api.g_varchar2_table(129) := '6C656374322D726573756C742D737562203E206C69202E73656C656374322D726573756C742D6C6162656C207B2070616464696E672D6C6566743A203131307078207D0A2E73656C656374322D726573756C747320756C2E73656C656374322D72657375';
wwv_flow_api.g_varchar2_table(130) := '6C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D73756220756C2E7365';
wwv_flow_api.g_varchar2_table(131) := '6C656374322D726573756C742D73756220756C2E73656C656374322D726573756C742D737562203E206C69202E73656C656374322D726573756C742D6C6162656C207B2070616464696E672D6C6566743A203132307078207D0A0A2E73656C656374322D';
wwv_flow_api.g_varchar2_table(132) := '726573756C7473206C69207B0A202020206C6973742D7374796C653A206E6F6E653B0A20202020646973706C61793A206C6973742D6974656D3B0A202020206261636B67726F756E642D696D6167653A206E6F6E653B0A7D0A0A2E73656C656374322D72';
wwv_flow_api.g_varchar2_table(133) := '6573756C7473206C692E73656C656374322D726573756C742D776974682D6368696C6472656E203E202E73656C656374322D726573756C742D6C6162656C207B0A20202020666F6E742D7765696768743A20626F6C643B0A7D0A0A2E73656C656374322D';
wwv_flow_api.g_varchar2_table(134) := '726573756C7473202E73656C656374322D726573756C742D6C6162656C207B0A2020202070616464696E673A2033707820377078203470783B0A202020206D617267696E3A20303B0A20202020637572736F723A20706F696E7465723B0A0A202020206D';
wwv_flow_api.g_varchar2_table(135) := '696E2D6865696768743A2031656D3B0A0A202020202D7765626B69742D746F7563682D63616C6C6F75743A206E6F6E653B0A2020202020202D7765626B69742D757365722D73656C6563743A206E6F6E653B0A202020202020202D6B68746D6C2D757365';
wwv_flow_api.g_varchar2_table(136) := '722D73656C6563743A206E6F6E653B0A2020202020202020202D6D6F7A2D757365722D73656C6563743A206E6F6E653B0A202020202020202020202D6D732D757365722D73656C6563743A206E6F6E653B0A202020202020202020202020202075736572';
wwv_flow_api.g_varchar2_table(137) := '2D73656C6563743A206E6F6E653B0A7D0A0A2E73656C656374322D726573756C7473202E73656C656374322D686967686C696768746564207B0A202020206261636B67726F756E643A20233338373564373B0A20202020636F6C6F723A20236666663B0A';
wwv_flow_api.g_varchar2_table(138) := '7D0A0A2E73656C656374322D726573756C7473206C6920656D207B0A202020206261636B67726F756E643A20236665666664653B0A20202020666F6E742D7374796C653A206E6F726D616C3B0A7D0A0A2E73656C656374322D726573756C7473202E7365';
wwv_flow_api.g_varchar2_table(139) := '6C656374322D686967686C69676874656420656D207B0A202020206261636B67726F756E643A207472616E73706172656E743B0A7D0A0A2E73656C656374322D726573756C7473202E73656C656374322D686967686C69676874656420756C207B0A2020';
wwv_flow_api.g_varchar2_table(140) := '20206261636B67726F756E643A2077686974653B0A20202020636F6C6F723A20233030303B0A7D0A0A0A2E73656C656374322D726573756C7473202E73656C656374322D6E6F2D726573756C74732C0A2E73656C656374322D726573756C7473202E7365';
wwv_flow_api.g_varchar2_table(141) := '6C656374322D736561726368696E672C0A2E73656C656374322D726573756C7473202E73656C656374322D73656C656374696F6E2D6C696D6974207B0A202020206261636B67726F756E643A20236634663466343B0A20202020646973706C61793A206C';
wwv_flow_api.g_varchar2_table(142) := '6973742D6974656D3B0A7D0A0A2F2A0A64697361626C6564206C6F6F6B20666F722064697361626C65642063686F6963657320696E2074686520726573756C74732064726F70646F776E0A2A2F0A2E73656C656374322D726573756C7473202E73656C65';
wwv_flow_api.g_varchar2_table(143) := '6374322D64697361626C65642E73656C656374322D686967686C696768746564207B0A20202020636F6C6F723A20233636363B0A202020206261636B67726F756E643A20236634663466343B0A20202020646973706C61793A206C6973742D6974656D3B';
wwv_flow_api.g_varchar2_table(144) := '0A20202020637572736F723A2064656661756C743B0A7D0A2E73656C656374322D726573756C7473202E73656C656374322D64697361626C6564207B0A20206261636B67726F756E643A20236634663466343B0A2020646973706C61793A206C6973742D';
wwv_flow_api.g_varchar2_table(145) := '6974656D3B0A2020637572736F723A2064656661756C743B0A7D0A0A2E73656C656374322D726573756C7473202E73656C656374322D73656C6563746564207B0A20202020646973706C61793A206E6F6E653B0A7D0A0A2E73656C656374322D6D6F7265';
wwv_flow_api.g_varchar2_table(146) := '2D726573756C74732E73656C656374322D616374697665207B0A202020206261636B67726F756E643A20236634663466342075726C282723504C5547494E5F5052454649582373656C656374322D7370696E6E65722E6769662729206E6F2D7265706561';
wwv_flow_api.g_varchar2_table(147) := '7420313030253B0A7D0A0A2E73656C656374322D6D6F72652D726573756C7473207B0A202020206261636B67726F756E643A20236634663466343B0A20202020646973706C61793A206C6973742D6974656D3B0A7D0A0A2F2A2064697361626C65642073';
wwv_flow_api.g_varchar2_table(148) := '74796C6573202A2F0A0A2E73656C656374322D636F6E7461696E65722E73656C656374322D636F6E7461696E65722D64697361626C6564202E73656C656374322D63686F696365207B0A202020206261636B67726F756E642D636F6C6F723A2023663466';
wwv_flow_api.g_varchar2_table(149) := '3466343B0A202020206261636B67726F756E642D696D6167653A206E6F6E653B0A20202020626F726465723A2031707820736F6C696420236464643B0A20202020637572736F723A2064656661756C743B0A7D0A0A2E73656C656374322D636F6E746169';
wwv_flow_api.g_varchar2_table(150) := '6E65722E73656C656374322D636F6E7461696E65722D64697361626C6564202E73656C656374322D63686F696365202E73656C656374322D6172726F77207B0A202020206261636B67726F756E642D636F6C6F723A20236634663466343B0A2020202062';
wwv_flow_api.g_varchar2_table(151) := '61636B67726F756E642D696D6167653A206E6F6E653B0A20202020626F726465722D6C6566743A20303B0A7D0A0A2E73656C656374322D636F6E7461696E65722E73656C656374322D636F6E7461696E65722D64697361626C6564202E73656C65637432';
wwv_flow_api.g_varchar2_table(152) := '2D63686F6963652061626272207B0A20202020646973706C61793A206E6F6E653B0A7D0A0A0A2F2A206D756C746973656C656374202A2F0A0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D63686F69636573207B';
wwv_flow_api.g_varchar2_table(153) := '0A202020206865696768743A206175746F2021696D706F7274616E743B0A202020206865696768743A2031253B0A202020206D617267696E3A20303B0A2020202070616464696E673A20303B0A20202020706F736974696F6E3A2072656C61746976653B';
wwv_flow_api.g_varchar2_table(154) := '0A0A20202020626F726465723A2031707820736F6C696420236161613B0A20202020637572736F723A20746578743B0A202020206F766572666C6F773A2068696464656E3B0A0A202020206261636B67726F756E642D636F6C6F723A20236666663B0A20';
wwv_flow_api.g_varchar2_table(155) := '2020206261636B67726F756E642D696D6167653A202D7765626B69742D6772616469656E74286C696E6561722C2030252030252C20302520313030252C20636F6C6F722D73746F702831252C2023656565656565292C20636F6C6F722D73746F70283135';
wwv_flow_api.g_varchar2_table(156) := '252C202366666666666629293B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6C696E6561722D6772616469656E7428746F702C20236565656565652031252C202366666666666620313525293B0A202020206261636B67';
wwv_flow_api.g_varchar2_table(157) := '726F756E642D696D6167653A202D6D6F7A2D6C696E6561722D6772616469656E7428746F702C20236565656565652031252C202366666666666620313525293B0A202020206261636B67726F756E642D696D6167653A202D6F2D6C696E6561722D677261';
wwv_flow_api.g_varchar2_table(158) := '6469656E7428746F702C20236565656565652031252C202366666666666620313525293B0A202020206261636B67726F756E642D696D6167653A202D6D732D6C696E6561722D6772616469656E7428746F702C20236565656565652031252C2023666666';
wwv_flow_api.g_varchar2_table(159) := '66666620313525293B0A202020206261636B67726F756E642D696D6167653A206C696E6561722D6772616469656E7428746F702C20236565656565652031252C202366666666666620313525293B0A7D0A0A2E73656C656374322D6C6F636B6564207B0A';
wwv_flow_api.g_varchar2_table(160) := '202070616464696E673A203370782035707820337078203570782021696D706F7274616E743B0A7D0A0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D63686F69636573207B0A202020206D696E2D686569676874';
wwv_flow_api.g_varchar2_table(161) := '3A20323670783B0A7D0A0A2E73656C656374322D636F6E7461696E65722D6D756C74692E73656C656374322D636F6E7461696E65722D616374697665202E73656C656374322D63686F69636573207B0A20202020626F726465723A2031707820736F6C69';
wwv_flow_api.g_varchar2_table(162) := '6420233538393766623B0A202020206F75746C696E653A206E6F6E653B0A0A202020202D7765626B69742D626F782D736861646F773A2030203020357078207267626128302C302C302C2E33293B0A202020202020202D6D6F7A2D626F782D736861646F';
wwv_flow_api.g_varchar2_table(163) := '773A2030203020357078207267626128302C302C302C2E33293B0A202020202020202020202020626F782D736861646F773A2030203020357078207267626128302C302C302C2E33293B0A7D0A2E73656C656374322D636F6E7461696E65722D6D756C74';
wwv_flow_api.g_varchar2_table(164) := '69202E73656C656374322D63686F69636573206C69207B0A20202020666C6F61743A206C6566743B0A202020206C6973742D7374796C653A206E6F6E653B0A7D0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D63';
wwv_flow_api.g_varchar2_table(165) := '686F69636573202E73656C656374322D7365617263682D6669656C64207B0A202020206D617267696E3A20303B0A2020202070616464696E673A20303B0A2020202077686974652D73706163653A206E6F777261703B0A7D0A0A2E73656C656374322D63';
wwv_flow_api.g_varchar2_table(166) := '6F6E7461696E65722D6D756C7469202E73656C656374322D63686F69636573202E73656C656374322D7365617263682D6669656C6420696E707574207B0A2020202070616464696E673A203570783B0A202020206D617267696E3A2031707820303B0A0A';
wwv_flow_api.g_varchar2_table(167) := '20202020666F6E742D66616D696C793A2073616E732D73657269663B0A20202020666F6E742D73697A653A20313030253B0A20202020636F6C6F723A20233636363B0A202020206F75746C696E653A20303B0A20202020626F726465723A20303B0A2020';
wwv_flow_api.g_varchar2_table(168) := '20202D7765626B69742D626F782D736861646F773A206E6F6E653B0A202020202020202D6D6F7A2D626F782D736861646F773A206E6F6E653B0A202020202020202020202020626F782D736861646F773A206E6F6E653B0A202020206261636B67726F75';
wwv_flow_api.g_varchar2_table(169) := '6E643A207472616E73706172656E742021696D706F7274616E743B0A7D0A0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D63686F69636573202E73656C656374322D7365617263682D6669656C6420696E707574';
wwv_flow_api.g_varchar2_table(170) := '2E73656C656374322D616374697665207B0A202020206261636B67726F756E643A20236666662075726C282723504C5547494E5F5052454649582373656C656374322D7370696E6E65722E6769662729206E6F2D72657065617420313030252021696D70';
wwv_flow_api.g_varchar2_table(171) := '6F7274616E743B0A7D0A0A2E73656C656374322D64656661756C74207B0A20202020636F6C6F723A20233939392021696D706F7274616E743B0A7D0A0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D63686F6963';
wwv_flow_api.g_varchar2_table(172) := '6573202E73656C656374322D7365617263682D63686F696365207B0A2020202070616464696E673A20337078203570782033707820313870783B0A202020206D617267696E3A20337078203020337078203570783B0A20202020706F736974696F6E3A20';
wwv_flow_api.g_varchar2_table(173) := '72656C61746976653B0A0A202020206C696E652D6865696768743A20313370783B0A20202020636F6C6F723A20233333333B0A20202020637572736F723A2064656661756C743B0A20202020626F726465723A2031707820736F6C696420236161616161';
wwv_flow_api.g_varchar2_table(174) := '613B0A0A202020202D7765626B69742D626F726465722D7261646975733A203370783B0A202020202020202D6D6F7A2D626F726465722D7261646975733A203370783B0A202020202020202020202020626F726465722D7261646975733A203370783B0A';
wwv_flow_api.g_varchar2_table(175) := '0A202020202D7765626B69742D626F782D736861646F773A2030203020327078202366666666666620696E7365742C2030203170782030207267626128302C302C302C302E3035293B0A202020202020202D6D6F7A2D626F782D736861646F773A203020';
wwv_flow_api.g_varchar2_table(176) := '3020327078202366666666666620696E7365742C2030203170782030207267626128302C302C302C302E3035293B0A202020202020202020202020626F782D736861646F773A2030203020327078202366666666666620696E7365742C20302031707820';
wwv_flow_api.g_varchar2_table(177) := '30207267626128302C302C302C302E3035293B0A0A202020202D7765626B69742D6261636B67726F756E642D636C69703A2070616464696E672D626F783B0A202020202020202D6D6F7A2D6261636B67726F756E642D636C69703A2070616464696E673B';
wwv_flow_api.g_varchar2_table(178) := '0A2020202020202020202020206261636B67726F756E642D636C69703A2070616464696E672D626F783B0A0A202020202D7765626B69742D746F7563682D63616C6C6F75743A206E6F6E653B0A2020202020202D7765626B69742D757365722D73656C65';
wwv_flow_api.g_varchar2_table(179) := '63743A206E6F6E653B0A202020202020202D6B68746D6C2D757365722D73656C6563743A206E6F6E653B0A2020202020202020202D6D6F7A2D757365722D73656C6563743A206E6F6E653B0A202020202020202020202D6D732D757365722D73656C6563';
wwv_flow_api.g_varchar2_table(180) := '743A206E6F6E653B0A2020202020202020202020202020757365722D73656C6563743A206E6F6E653B0A0A202020206261636B67726F756E642D636F6C6F723A20236534653465343B0A2020202066696C7465723A2070726F6769643A4458496D616765';
wwv_flow_api.g_varchar2_table(181) := '5472616E73666F726D2E4D6963726F736F66742E6772616469656E7428207374617274436F6C6F727374723D2723656565656565272C20656E64436F6C6F727374723D2723663466346634272C204772616469656E74547970653D3020293B0A20202020';
wwv_flow_api.g_varchar2_table(182) := '6261636B67726F756E642D696D6167653A202D7765626B69742D6772616469656E74286C696E6561722C2030252030252C20302520313030252C20636F6C6F722D73746F70283230252C2023663466346634292C20636F6C6F722D73746F70283530252C';
wwv_flow_api.g_varchar2_table(183) := '2023663066306630292C20636F6C6F722D73746F70283532252C2023653865386538292C20636F6C6F722D73746F7028313030252C202365656565656529293B0A202020206261636B67726F756E642D696D6167653A202D7765626B69742D6C696E6561';
wwv_flow_api.g_varchar2_table(184) := '722D6772616469656E7428746F702C2023663466346634203230252C2023663066306630203530252C2023653865386538203532252C20236565656565652031303025293B0A202020206261636B67726F756E642D696D6167653A202D6D6F7A2D6C696E';
wwv_flow_api.g_varchar2_table(185) := '6561722D6772616469656E7428746F702C2023663466346634203230252C2023663066306630203530252C2023653865386538203532252C20236565656565652031303025293B0A202020206261636B67726F756E642D696D6167653A202D6F2D6C696E';
wwv_flow_api.g_varchar2_table(186) := '6561722D6772616469656E7428746F702C2023663466346634203230252C2023663066306630203530252C2023653865386538203532252C20236565656565652031303025293B0A202020206261636B67726F756E642D696D6167653A202D6D732D6C69';
wwv_flow_api.g_varchar2_table(187) := '6E6561722D6772616469656E7428746F702C2023663466346634203230252C2023663066306630203530252C2023653865386538203532252C20236565656565652031303025293B0A202020206261636B67726F756E642D696D6167653A206C696E6561';
wwv_flow_api.g_varchar2_table(188) := '722D6772616469656E7428746F702C2023663466346634203230252C2023663066306630203530252C2023653865386538203532252C20236565656565652031303025293B0A7D0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E7365';
wwv_flow_api.g_varchar2_table(189) := '6C656374322D63686F69636573202E73656C656374322D7365617263682D63686F696365202E73656C656374322D63686F73656E207B0A20202020637572736F723A2064656661756C743B0A7D0A2E73656C656374322D636F6E7461696E65722D6D756C';
wwv_flow_api.g_varchar2_table(190) := '7469202E73656C656374322D63686F69636573202E73656C656374322D7365617263682D63686F6963652D666F637573207B0A202020206261636B67726F756E643A20236434643464343B0A7D0A0A2E73656C656374322D7365617263682D63686F6963';
wwv_flow_api.g_varchar2_table(191) := '652D636C6F7365207B0A20202020646973706C61793A20626C6F636B3B0A2020202077696474683A20313270783B0A202020206865696768743A20313370783B0A20202020706F736974696F6E3A206162736F6C7574653B0A2020202072696768743A20';
wwv_flow_api.g_varchar2_table(192) := '3370783B0A20202020746F703A203470783B0A0A20202020666F6E742D73697A653A203170783B0A202020206F75746C696E653A206E6F6E653B0A202020206261636B67726F756E643A2075726C282723504C5547494E5F5052454649582373656C6563';
wwv_flow_api.g_varchar2_table(193) := '74322E706E67272920726967687420746F70206E6F2D7265706561743B0A7D0A0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D7365617263682D63686F6963652D636C6F7365207B0A202020206C6566743A2033';
wwv_flow_api.g_varchar2_table(194) := '70783B0A7D0A0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D63686F69636573202E73656C656374322D7365617263682D63686F696365202E73656C656374322D7365617263682D63686F6963652D636C6F7365';
wwv_flow_api.g_varchar2_table(195) := '3A686F766572207B0A20206261636B67726F756E642D706F736974696F6E3A207269676874202D313170783B0A7D0A2E73656C656374322D636F6E7461696E65722D6D756C7469202E73656C656374322D63686F69636573202E73656C656374322D7365';
wwv_flow_api.g_varchar2_table(196) := '617263682D63686F6963652D666F637573202E73656C656374322D7365617263682D63686F6963652D636C6F7365207B0A202020206261636B67726F756E642D706F736974696F6E3A207269676874202D313170783B0A7D0A0A2F2A2064697361626C65';
wwv_flow_api.g_varchar2_table(197) := '64207374796C6573202A2F0A2E73656C656374322D636F6E7461696E65722D6D756C74692E73656C656374322D636F6E7461696E65722D64697361626C6564202E73656C656374322D63686F696365737B0A202020206261636B67726F756E642D636F6C';
wwv_flow_api.g_varchar2_table(198) := '6F723A20236634663466343B0A202020206261636B67726F756E642D696D6167653A206E6F6E653B0A20202020626F726465723A2031707820736F6C696420236464643B0A20202020637572736F723A2064656661756C743B0A7D0A0A2E73656C656374';
wwv_flow_api.g_varchar2_table(199) := '322D636F6E7461696E65722D6D756C74692E73656C656374322D636F6E7461696E65722D64697361626C6564202E73656C656374322D63686F69636573202E73656C656374322D7365617263682D63686F696365207B0A2020202070616464696E673A20';
wwv_flow_api.g_varchar2_table(200) := '3370782035707820337078203570783B0A20202020626F726465723A2031707820736F6C696420236464643B0A202020206261636B67726F756E642D696D6167653A206E6F6E653B0A202020206261636B67726F756E642D636F6C6F723A202366346634';
wwv_flow_api.g_varchar2_table(201) := '66343B0A7D0A0A2E73656C656374322D636F6E7461696E65722D6D756C74692E73656C656374322D636F6E7461696E65722D64697361626C6564202E73656C656374322D63686F69636573202E73656C656374322D7365617263682D63686F696365202E';
wwv_flow_api.g_varchar2_table(202) := '73656C656374322D7365617263682D63686F6963652D636C6F7365207B20202020646973706C61793A206E6F6E653B0A202020206261636B67726F756E643A6E6F6E653B0A7D0A2F2A20656E64206D756C746973656C656374202A2F0A0A0A2E73656C65';
wwv_flow_api.g_varchar2_table(203) := '6374322D726573756C742D73656C65637461626C65202E73656C656374322D6D617463682C0A2E73656C656374322D726573756C742D756E73656C65637461626C65202E73656C656374322D6D61746368207B0A20202020746578742D6465636F726174';
wwv_flow_api.g_varchar2_table(204) := '696F6E3A20756E6465726C696E653B0A7D0A0A2E73656C656374322D6F666673637265656E2C202E73656C656374322D6F666673637265656E3A666F637573207B0A20202020636C69703A20726563742830203020302030293B0A202020207769647468';
wwv_flow_api.g_varchar2_table(205) := '3A203170783B0A202020206865696768743A203170783B0A20202020626F726465723A20303B0A202020206D617267696E3A20303B0A2020202070616464696E673A20303B0A202020206F766572666C6F773A2068696464656E3B0A20202020706F7369';
wwv_flow_api.g_varchar2_table(206) := '74696F6E3A206162736F6C7574653B0A202020206F75746C696E653A20303B0A202020206C6566743A203070783B0A7D0A0A2E73656C656374322D646973706C61792D6E6F6E65207B0A20202020646973706C61793A206E6F6E653B0A7D0A0A2E73656C';
wwv_flow_api.g_varchar2_table(207) := '656374322D6D6561737572652D7363726F6C6C626172207B0A20202020706F736974696F6E3A206162736F6C7574653B0A20202020746F703A202D313030303070783B0A202020206C6566743A202D313030303070783B0A2020202077696474683A2031';
wwv_flow_api.g_varchar2_table(208) := '303070783B0A202020206865696768743A2031303070783B0A202020206F766572666C6F773A207363726F6C6C3B0A7D0A2F2A20526574696E612D697A652069636F6E73202A2F0A0A406D65646961206F6E6C792073637265656E20616E6420282D7765';
wwv_flow_api.g_varchar2_table(209) := '626B69742D6D696E2D6465766963652D706978656C2D726174696F3A20312E35292C206F6E6C792073637265656E20616E6420286D696E2D7265736F6C7574696F6E3A203134346470692920207B0A20202E73656C656374322D73656172636820696E70';
wwv_flow_api.g_varchar2_table(210) := '75742C202E73656C656374322D7365617263682D63686F6963652D636C6F73652C202E73656C656374322D636F6E7461696E6572202E73656C656374322D63686F69636520616262722C202E73656C656374322D636F6E7461696E6572202E73656C6563';
wwv_flow_api.g_varchar2_table(211) := '74322D63686F696365202E73656C656374322D6172726F772062207B0A2020202020206261636B67726F756E642D696D6167653A2075726C282723504C5547494E5F5052454649582373656C6563743278322E706E6727292021696D706F7274616E743B';
wwv_flow_api.g_varchar2_table(212) := '0A2020202020206261636B67726F756E642D7265706561743A206E6F2D7265706561742021696D706F7274616E743B0A2020202020206261636B67726F756E642D73697A653A203630707820343070782021696D706F7274616E743B0A20207D0A20202E';
wwv_flow_api.g_varchar2_table(213) := '73656C656374322D73656172636820696E707574207B0A2020202020206261636B67726F756E642D706F736974696F6E3A2031303025202D323170782021696D706F7274616E743B0A20207D0A7D0A';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 24264138024926054949 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_file_name => 'select2.css'
 ,p_mime_type => 'text/css'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A436F7079726967687420323031322049676F72205661796E626572670A0A56657273696F6E3A20332E342E312054696D657374616D703A20546875204A756E2032372031383A30323A31302050445420323031330A0A5468697320736F66747761';
wwv_flow_api.g_varchar2_table(2) := '7265206973206C6963656E73656420756E6465722074686520417061636865204C6963656E73652C2056657273696F6E20322E3020287468652022417061636865204C6963656E73652229206F722074686520474E550A47656E6572616C205075626C69';
wwv_flow_api.g_varchar2_table(3) := '63204C6963656E73652076657273696F6E20322028746865202247504C204C6963656E736522292E20596F75206D61792063686F6F736520656974686572206C6963656E736520746F20676F7665726E20796F75720A757365206F66207468697320736F';
wwv_flow_api.g_varchar2_table(4) := '667477617265206F6E6C792075706F6E2074686520636F6E646974696F6E207468617420796F752061636365707420616C6C206F6620746865207465726D73206F662065697468657220746865204170616368650A4C6963656E7365206F722074686520';
wwv_flow_api.g_varchar2_table(5) := '47504C204C6963656E73652E0A0A596F75206D6179206F627461696E206120636F7079206F662074686520417061636865204C6963656E736520616E64207468652047504C204C6963656E73652061743A0A0A687474703A2F2F7777772E617061636865';
wwv_flow_api.g_varchar2_table(6) := '2E6F72672F6C6963656E7365732F4C4943454E53452D322E300A687474703A2F2F7777772E676E752E6F72672F6C6963656E7365732F67706C2D322E302E68746D6C0A0A556E6C657373207265717569726564206279206170706C696361626C65206C61';
wwv_flow_api.g_varchar2_table(7) := '77206F722061677265656420746F20696E2077726974696E672C20736F66747761726520646973747269627574656420756E6465722074686520417061636865204C6963656E73650A6F72207468652047504C204C696365736E73652069732064697374';
wwv_flow_api.g_varchar2_table(8) := '72696275746564206F6E20616E20224153204953222042415349532C20574954484F55542057415252414E54494553204F5220434F4E444954494F4E53204F4620414E59204B494E442C0A6569746865722065787072657373206F7220696D706C696564';
wwv_flow_api.g_varchar2_table(9) := '2E205365652074686520417061636865204C6963656E736520616E64207468652047504C204C6963656E736520666F7220746865207370656369666963206C616E677561676520676F7665726E696E670A7065726D697373696F6E7320616E64206C696D';
wwv_flow_api.g_varchar2_table(10) := '69746174696F6E7320756E6465722074686520417061636865204C6963656E736520616E64207468652047504C204C6963656E73652E0A2A2F0A2866756E6374696F6E2861297B612E666E2E65616368323D3D3D766F696420302626612E666E2E657874';
wwv_flow_api.g_varchar2_table(11) := '656E64287B65616368323A66756E6374696F6E2862297B666F722876617220633D61285B305D292C643D2D312C653D746869732E6C656E6774683B653E2B2B64262628632E636F6E746578743D635B305D3D746869735B645D292626622E63616C6C2863';
wwv_flow_api.g_varchar2_table(12) := '5B305D2C642C6329213D3D21313B293B72657475726E20746869737D7D297D29286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B66756E6374696F6E206D28612C62297B666F722876617220633D302C643D622E';
wwv_flow_api.g_varchar2_table(13) := '6C656E6774683B643E633B632B3D31296966286F28612C625B635D292972657475726E20633B72657475726E2D317D66756E6374696F6E206E28297B76617220623D61286C293B622E617070656E64546F2822626F647922293B76617220633D7B776964';
wwv_flow_api.g_varchar2_table(14) := '74683A622E776964746828292D625B305D2E636C69656E7457696474682C6865696768743A622E68656967687428292D625B305D2E636C69656E744865696768747D3B72657475726E20622E72656D6F766528292C637D66756E6374696F6E206F28612C';
wwv_flow_api.g_varchar2_table(15) := '63297B72657475726E20613D3D3D633F21303A613D3D3D627C7C633D3D3D623F21313A6E756C6C3D3D3D617C7C6E756C6C3D3D3D633F21313A612E636F6E7374727563746F723D3D3D537472696E673F612B22223D3D632B22223A632E636F6E73747275';
wwv_flow_api.g_varchar2_table(16) := '63746F723D3D3D537472696E673F632B22223D3D612B22223A21317D66756E6374696F6E207028622C63297B76617220642C652C663B6966286E756C6C3D3D3D627C7C313E622E6C656E6774682972657475726E5B5D3B666F7228643D622E73706C6974';
wwv_flow_api.g_varchar2_table(17) := '2863292C653D302C663D642E6C656E6774683B663E653B652B3D3129645B655D3D612E7472696D28645B655D293B72657475726E20647D66756E6374696F6E20712861297B72657475726E20612E6F757465725769647468282131292D612E7769647468';
wwv_flow_api.g_varchar2_table(18) := '28297D66756E6374696F6E20722863297B76617220643D226B657975702D6368616E67652D76616C7565223B632E6F6E28226B6579646F776E222C66756E6374696F6E28297B612E6461746128632C64293D3D3D622626612E6461746128632C642C632E';
wwv_flow_api.g_varchar2_table(19) := '76616C2829297D292C632E6F6E28226B65797570222C66756E6374696F6E28297B76617220653D612E6461746128632C64293B65213D3D622626632E76616C2829213D3D65262628612E72656D6F76654461746128632C64292C632E7472696767657228';
wwv_flow_api.g_varchar2_table(20) := '226B657975702D6368616E67652229297D297D66756E6374696F6E20732863297B632E6F6E28226D6F7573656D6F7665222C66756E6374696F6E2863297B76617220643D693B28643D3D3D627C7C642E78213D3D632E70616765587C7C642E79213D3D63';
wwv_flow_api.g_varchar2_table(21) := '2E70616765592926266128632E746172676574292E7472696767657228226D6F7573656D6F76652D66696C7465726564222C63297D297D66756E6374696F6E207428612C632C64297B643D647C7C623B76617220653B72657475726E2066756E6374696F';
wwv_flow_api.g_varchar2_table(22) := '6E28297B76617220623D617267756D656E74733B77696E646F772E636C65617254696D656F75742865292C653D77696E646F772E73657454696D656F75742866756E6374696F6E28297B632E6170706C7928642C62297D2C61297D7D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(23) := '20752861297B76617220632C623D21313B72657475726E2066756E6374696F6E28297B72657475726E20623D3D3D2131262628633D6128292C623D2130292C637D7D66756E6374696F6E207628612C62297B76617220633D7428612C66756E6374696F6E';
wwv_flow_api.g_varchar2_table(24) := '2861297B622E7472696767657228227363726F6C6C2D6465626F756E636564222C61297D293B622E6F6E28227363726F6C6C222C66756E6374696F6E2861297B6D28612E7461726765742C622E6765742829293E3D302626632861297D297D66756E6374';
wwv_flow_api.g_varchar2_table(25) := '696F6E20772861297B615B305D213D3D646F63756D656E742E616374697665456C656D656E74262677696E646F772E73657454696D656F75742866756E6374696F6E28297B76617220642C623D615B305D2C633D612E76616C28292E6C656E6774683B61';
wwv_flow_api.g_varchar2_table(26) := '2E666F63757328292C612E697328223A76697369626C6522292626623D3D3D646F63756D656E742E616374697665456C656D656E74262628622E73657453656C656374696F6E52616E67653F622E73657453656C656374696F6E52616E676528632C6329';
wwv_flow_api.g_varchar2_table(27) := '3A622E6372656174655465787452616E6765262628643D622E6372656174655465787452616E676528292C642E636F6C6C61707365282131292C642E73656C656374282929297D2C30297D66756E6374696F6E20782862297B623D612862295B305D3B76';
wwv_flow_api.g_varchar2_table(28) := '617220633D302C643D303B6966282273656C656374696F6E537461727422696E206229633D622E73656C656374696F6E53746172742C643D622E73656C656374696F6E456E642D633B656C7365206966282273656C656374696F6E22696E20646F63756D';
wwv_flow_api.g_varchar2_table(29) := '656E74297B622E666F63757328293B76617220653D646F63756D656E742E73656C656374696F6E2E63726561746552616E676528293B643D646F63756D656E742E73656C656374696F6E2E63726561746552616E676528292E746578742E6C656E677468';
wwv_flow_api.g_varchar2_table(30) := '2C652E6D6F766553746172742822636861726163746572222C2D622E76616C75652E6C656E677468292C633D652E746578742E6C656E6774682D647D72657475726E7B6F66667365743A632C6C656E6774683A647D7D66756E6374696F6E20792861297B';
wwv_flow_api.g_varchar2_table(31) := '612E70726576656E7444656661756C7428292C612E73746F7050726F7061676174696F6E28297D66756E6374696F6E207A2861297B612E70726576656E7444656661756C7428292C612E73746F70496D6D65646961746550726F7061676174696F6E2829';
wwv_flow_api.g_varchar2_table(32) := '7D66756E6374696F6E20412862297B6966282168297B76617220633D625B305D2E63757272656E745374796C657C7C77696E646F772E676574436F6D70757465645374796C6528625B305D2C6E756C6C293B683D6128646F63756D656E742E6372656174';
wwv_flow_api.g_varchar2_table(33) := '65456C656D656E7428226469762229292E637373287B706F736974696F6E3A226162736F6C757465222C6C6566743A222D31303030307078222C746F703A222D31303030307078222C646973706C61793A226E6F6E65222C666F6E7453697A653A632E66';
wwv_flow_api.g_varchar2_table(34) := '6F6E7453697A652C666F6E7446616D696C793A632E666F6E7446616D696C792C666F6E745374796C653A632E666F6E745374796C652C666F6E745765696768743A632E666F6E745765696768742C6C657474657253706163696E673A632E6C6574746572';
wwv_flow_api.g_varchar2_table(35) := '53706163696E672C746578745472616E73666F726D3A632E746578745472616E73666F726D2C776869746553706163653A226E6F77726170227D292C682E617474722822636C617373222C2273656C656374322D73697A657222292C612822626F647922';
wwv_flow_api.g_varchar2_table(36) := '292E617070656E642868297D72657475726E20682E7465787428622E76616C2829292C682E776964746828297D66756E6374696F6E204228622C632C64297B76617220652C672C663D5B5D3B653D622E617474722822636C61737322292C65262628653D';
wwv_flow_api.g_varchar2_table(37) := '22222B652C6128652E73706C69742822202229292E65616368322866756E6374696F6E28297B303D3D3D746869732E696E6465784F66282273656C656374322D22292626662E707573682874686973297D29292C653D632E617474722822636C61737322';
wwv_flow_api.g_varchar2_table(38) := '292C65262628653D22222B652C6128652E73706C69742822202229292E65616368322866756E6374696F6E28297B30213D3D746869732E696E6465784F66282273656C656374322D2229262628673D642874686973292C672626662E7075736828746869';
wwv_flow_api.g_varchar2_table(39) := '7329297D29292C622E617474722822636C617373222C662E6A6F696E2822202229297D66756E6374696F6E204328612C632C642C65297B76617220663D612E746F55707065724361736528292E696E6465784F6628632E746F5570706572436173652829';
wwv_flow_api.g_varchar2_table(40) := '292C673D632E6C656E6774683B72657475726E20303E663F28642E707573682865286129292C62293A28642E70757368286528612E737562737472696E6728302C662929292C642E7075736828223C7370616E20636C6173733D2773656C656374322D6D';
wwv_flow_api.g_varchar2_table(41) := '61746368273E22292C642E70757368286528612E737562737472696E6728662C662B672929292C642E7075736828223C2F7370616E3E22292C642E70757368286528612E737562737472696E6728662B672C612E6C656E6774682929292C62297D66756E';
wwv_flow_api.g_varchar2_table(42) := '6374696F6E20442861297B76617220623D7B225C5C223A22262339323B222C2226223A2226616D703B222C223C223A22266C743B222C223E223A222667743B222C2722273A222671756F743B222C2227223A22262333393B222C222F223A22262334373B';
wwv_flow_api.g_varchar2_table(43) := '227D3B72657475726E28612B2222292E7265706C616365282F5B263C3E22275C2F5C5C5D2F672C66756E6374696F6E2861297B72657475726E20625B615D7D297D66756E6374696F6E20452863297B76617220642C653D302C663D6E756C6C2C673D632E';
wwv_flow_api.g_varchar2_table(44) := '71756965744D696C6C69737C7C3130302C683D632E75726C2C693D746869733B72657475726E2066756E6374696F6E286A297B77696E646F772E636C65617254696D656F75742864292C643D77696E646F772E73657454696D656F75742866756E637469';
wwv_flow_api.g_varchar2_table(45) := '6F6E28297B652B3D313B76617220643D652C673D632E646174612C6B3D682C6C3D632E7472616E73706F72747C7C612E666E2E73656C656374322E616A617844656661756C74732E7472616E73706F72742C6D3D7B747970653A632E747970657C7C2247';
wwv_flow_api.g_varchar2_table(46) := '4554222C63616368653A632E63616368657C7C21312C6A736F6E7043616C6C6261636B3A632E6A736F6E7043616C6C6261636B7C7C622C64617461547970653A632E64617461547970657C7C226A736F6E227D2C6E3D612E657874656E64287B7D2C612E';
wwv_flow_api.g_varchar2_table(47) := '666E2E73656C656374322E616A617844656661756C74732E706172616D732C6D293B673D673F672E63616C6C28692C6A2E7465726D2C6A2E706167652C6A2E636F6E74657874293A6E756C6C2C6B3D2266756E6374696F6E223D3D747970656F66206B3F';
wwv_flow_api.g_varchar2_table(48) := '6B2E63616C6C28692C6A2E7465726D2C6A2E706167652C6A2E636F6E74657874293A6B2C662626662E61626F727428292C632E706172616D73262628612E697346756E6374696F6E28632E706172616D73293F612E657874656E64286E2C632E70617261';
wwv_flow_api.g_varchar2_table(49) := '6D732E63616C6C286929293A612E657874656E64286E2C632E706172616D7329292C612E657874656E64286E2C7B75726C3A6B2C64617461547970653A632E64617461547970652C646174613A672C737563636573733A66756E6374696F6E2861297B69';
wwv_flow_api.g_varchar2_table(50) := '66282128653E6429297B76617220623D632E726573756C747328612C6A2E70616765293B6A2E63616C6C6261636B2862297D7D7D292C663D6C2E63616C6C28692C6E297D2C67297D7D66756E6374696F6E20462863297B76617220652C662C643D632C67';
wwv_flow_api.g_varchar2_table(51) := '3D66756E6374696F6E2861297B72657475726E22222B612E746578747D3B612E69734172726179286429262628663D642C643D7B726573756C74733A667D292C612E697346756E6374696F6E2864293D3D3D2131262628663D642C643D66756E6374696F';
wwv_flow_api.g_varchar2_table(52) := '6E28297B72657475726E20667D293B76617220683D6428293B72657475726E20682E74657874262628673D682E746578742C612E697346756E6374696F6E2867297C7C28653D682E746578742C673D66756E6374696F6E2861297B72657475726E20615B';
wwv_flow_api.g_varchar2_table(53) := '655D7D29292C66756E6374696F6E2863297B76617220682C653D632E7465726D2C663D7B726573756C74733A5B5D7D3B72657475726E22223D3D3D653F28632E63616C6C6261636B28642829292C62293A28683D66756E6374696F6E28622C64297B7661';
wwv_flow_api.g_varchar2_table(54) := '7220662C693B696628623D625B305D2C622E6368696C6472656E297B663D7B7D3B666F72286920696E206229622E6861734F776E50726F7065727479286929262628665B695D3D625B695D293B662E6368696C6472656E3D5B5D2C6128622E6368696C64';
wwv_flow_api.g_varchar2_table(55) := '72656E292E65616368322866756E6374696F6E28612C62297B6828622C662E6368696C6472656E297D292C28662E6368696C6472656E2E6C656E6774687C7C632E6D61746368657228652C672866292C6229292626642E707573682866297D656C736520';
wwv_flow_api.g_varchar2_table(56) := '632E6D61746368657228652C672862292C62292626642E707573682862297D2C61286428292E726573756C7473292E65616368322866756E6374696F6E28612C62297B6828622C662E726573756C7473297D292C632E63616C6C6261636B2866292C6229';
wwv_flow_api.g_varchar2_table(57) := '7D7D66756E6374696F6E20472863297B76617220643D612E697346756E6374696F6E2863293B72657475726E2066756E6374696F6E2865297B76617220663D652E7465726D2C673D7B726573756C74733A5B5D7D3B6128643F6328293A63292E65616368';
wwv_flow_api.g_varchar2_table(58) := '2866756E6374696F6E28297B76617220613D746869732E74657874213D3D622C633D613F746869732E746578743A746869733B2822223D3D3D667C7C652E6D61746368657228662C6329292626672E726573756C74732E7075736828613F746869733A7B';
wwv_flow_api.g_varchar2_table(59) := '69643A746869732C746578743A746869737D297D292C652E63616C6C6261636B2867297D7D66756E6374696F6E204828622C63297B696628612E697346756E6374696F6E2862292972657475726E21303B69662821622972657475726E21313B7468726F';
wwv_flow_api.g_varchar2_table(60) := '77204572726F7228632B22206D75737420626520612066756E6374696F6E206F7220612066616C73792076616C756522297D66756E6374696F6E20492862297B72657475726E20612E697346756E6374696F6E2862293F6228293A627D66756E6374696F';
wwv_flow_api.g_varchar2_table(61) := '6E204A2862297B76617220633D303B72657475726E20612E6561636828622C66756E6374696F6E28612C62297B622E6368696C6472656E3F632B3D4A28622E6368696C6472656E293A632B2B7D292C637D66756E6374696F6E204B28612C632C642C6529';
wwv_flow_api.g_varchar2_table(62) := '7B76617220682C692C6A2C6B2C6C2C663D612C673D21313B69662821652E63726561746553656172636843686F6963657C7C21652E746F6B656E536570617261746F72737C7C313E652E746F6B656E536570617261746F72732E6C656E67746829726574';
wwv_flow_api.g_varchar2_table(63) := '75726E20623B666F72283B3B297B666F7228693D2D312C6A3D302C6B3D652E746F6B656E536570617261746F72732E6C656E6774683B6B3E6A2626286C3D652E746F6B656E536570617261746F72735B6A5D2C693D612E696E6465784F66286C292C2128';
wwv_flow_api.g_varchar2_table(64) := '693E3D3029293B6A2B2B293B696628303E6929627265616B3B696628683D612E737562737472696E6728302C69292C613D612E737562737472696E6728692B6C2E6C656E677468292C682E6C656E6774683E30262628683D652E63726561746553656172';
wwv_flow_api.g_varchar2_table(65) := '636843686F6963652E63616C6C28746869732C682C63292C68213D3D6226266E756C6C213D3D682626652E6964286829213D3D6226266E756C6C213D3D652E696428682929297B666F7228673D21312C6A3D302C6B3D632E6C656E6774683B6B3E6A3B6A';
wwv_flow_api.g_varchar2_table(66) := '2B2B296966286F28652E69642868292C652E696428635B6A5D2929297B673D21303B627265616B7D677C7C642868297D7D72657475726E2066213D3D613F613A627D66756E6374696F6E204C28622C63297B76617220643D66756E6374696F6E28297B7D';
wwv_flow_api.g_varchar2_table(67) := '3B72657475726E20642E70726F746F747970653D6E657720622C642E70726F746F747970652E636F6E7374727563746F723D642C642E70726F746F747970652E706172656E743D622E70726F746F747970652C642E70726F746F747970653D612E657874';
wwv_flow_api.g_varchar2_table(68) := '656E6428642E70726F746F747970652C63292C647D69662877696E646F772E53656C656374323D3D3D62297B76617220632C642C652C662C672C682C6A2C6B2C693D7B783A302C793A307D2C633D7B5441423A392C454E5445523A31332C4553433A3237';
wwv_flow_api.g_varchar2_table(69) := '2C53504143453A33322C4C4546543A33372C55503A33382C52494748543A33392C444F574E3A34302C53484946543A31362C4354524C3A31372C414C543A31382C504147455F55503A33332C504147455F444F574E3A33342C484F4D453A33362C454E44';
wwv_flow_api.g_varchar2_table(70) := '3A33352C4241434B53504143453A382C44454C4554453A34362C69734172726F773A66756E6374696F6E2861297B73776974636828613D612E77686963683F612E77686963683A61297B6361736520632E4C4546543A6361736520632E52494748543A63';
wwv_flow_api.g_varchar2_table(71) := '61736520632E55503A6361736520632E444F574E3A72657475726E21307D72657475726E21317D2C6973436F6E74726F6C3A66756E6374696F6E2861297B76617220623D612E77686963683B7377697463682862297B6361736520632E53484946543A63';
wwv_flow_api.g_varchar2_table(72) := '61736520632E4354524C3A6361736520632E414C543A72657475726E21307D72657475726E20612E6D6574614B65793F21303A21317D2C697346756E6374696F6E4B65793A66756E6374696F6E2861297B72657475726E20613D612E77686963683F612E';
wwv_flow_api.g_varchar2_table(73) := '77686963683A612C613E3D31313226263132333E3D617D7D2C6C3D223C64697620636C6173733D2773656C656374322D6D6561737572652D7363726F6C6C626172273E3C2F6469763E223B6A3D6128646F63756D656E74292C673D66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(74) := '297B76617220613D313B72657475726E2066756E6374696F6E28297B72657475726E20612B2B7D7D28292C6A2E6F6E28226D6F7573656D6F7665222C66756E6374696F6E2861297B692E783D612E70616765582C692E793D612E70616765597D292C643D';
wwv_flow_api.g_varchar2_table(75) := '4C284F626A6563742C7B62696E643A66756E6374696F6E2861297B76617220623D746869733B72657475726E2066756E6374696F6E28297B612E6170706C7928622C617267756D656E7473297D7D2C696E69743A66756E6374696F6E2863297B76617220';
wwv_flow_api.g_varchar2_table(76) := '642C652C682C692C663D222E73656C656374322D726573756C7473223B746869732E6F7074733D633D746869732E707265706172654F7074732863292C746869732E69643D632E69642C632E656C656D656E742E64617461282273656C65637432222921';
wwv_flow_api.g_varchar2_table(77) := '3D3D6226266E756C6C213D3D632E656C656D656E742E64617461282273656C6563743222292626632E656C656D656E742E64617461282273656C6563743222292E64657374726F7928292C746869732E636F6E7461696E65723D746869732E6372656174';
wwv_flow_api.g_varchar2_table(78) := '65436F6E7461696E657228292C746869732E636F6E7461696E657249643D22733269645F222B28632E656C656D656E742E617474722822696422297C7C226175746F67656E222B672829292C746869732E636F6E7461696E657253656C6563746F723D22';
wwv_flow_api.g_varchar2_table(79) := '23222B746869732E636F6E7461696E657249642E7265706C616365282F285B3B262C5C2E5C2B5C2A5C7E273A225C215C5E232425405C5B5C5D5C285C293D3E5C7C5D292F672C225C5C243122292C746869732E636F6E7461696E65722E61747472282269';
wwv_flow_api.g_varchar2_table(80) := '64222C746869732E636F6E7461696E65724964292C746869732E626F64793D752866756E6374696F6E28297B72657475726E20632E656C656D656E742E636C6F736573742822626F647922297D292C4228746869732E636F6E7461696E65722C74686973';
wwv_flow_api.g_varchar2_table(81) := '2E6F7074732E656C656D656E742C746869732E6F7074732E6164617074436F6E7461696E6572437373436C617373292C746869732E636F6E7461696E65722E637373284928632E636F6E7461696E657243737329292C746869732E636F6E7461696E6572';
wwv_flow_api.g_varchar2_table(82) := '2E616464436C617373284928632E636F6E7461696E6572437373436C61737329292C746869732E656C656D656E74546162496E6465783D746869732E6F7074732E656C656D656E742E617474722822746162696E64657822292C746869732E6F7074732E';
wwv_flow_api.g_varchar2_table(83) := '656C656D656E742E64617461282273656C65637432222C74686973292E617474722822746162696E646578222C222D3122292E6265666F726528746869732E636F6E7461696E6572292C746869732E636F6E7461696E65722E64617461282273656C6563';
wwv_flow_api.g_varchar2_table(84) := '7432222C74686973292C746869732E64726F70646F776E3D746869732E636F6E7461696E65722E66696E6428222E73656C656374322D64726F7022292C746869732E64726F70646F776E2E616464436C617373284928632E64726F70646F776E43737343';
wwv_flow_api.g_varchar2_table(85) := '6C61737329292C746869732E64726F70646F776E2E64617461282273656C65637432222C74686973292C746869732E726573756C74733D643D746869732E636F6E7461696E65722E66696E642866292C746869732E7365617263683D653D746869732E63';
wwv_flow_api.g_varchar2_table(86) := '6F6E7461696E65722E66696E642822696E7075742E73656C656374322D696E70757422292C746869732E726573756C7473506167653D302C746869732E636F6E746578743D6E756C6C2C746869732E696E6974436F6E7461696E657228292C7328746869';
wwv_flow_api.g_varchar2_table(87) := '732E726573756C7473292C746869732E64726F70646F776E2E6F6E28226D6F7573656D6F76652D66696C746572656420746F756368737461727420746F7563686D6F766520746F756368656E64222C662C746869732E62696E6428746869732E68696768';
wwv_flow_api.g_varchar2_table(88) := '6C69676874556E6465724576656E7429292C762838302C746869732E726573756C7473292C746869732E64726F70646F776E2E6F6E28227363726F6C6C2D6465626F756E636564222C662C746869732E62696E6428746869732E6C6F61644D6F72654966';
wwv_flow_api.g_varchar2_table(89) := '4E656564656429292C6128746869732E636F6E7461696E6572292E6F6E28226368616E6765222C222E73656C656374322D696E707574222C66756E6374696F6E2861297B612E73746F7050726F7061676174696F6E28297D292C6128746869732E64726F';
wwv_flow_api.g_varchar2_table(90) := '70646F776E292E6F6E28226368616E6765222C222E73656C656374322D696E707574222C66756E6374696F6E2861297B612E73746F7050726F7061676174696F6E28297D292C612E666E2E6D6F757365776865656C2626642E6D6F757365776865656C28';
wwv_flow_api.g_varchar2_table(91) := '66756E6374696F6E28612C622C632C65297B76617220663D642E7363726F6C6C546F7028293B653E302626303E3D662D653F28642E7363726F6C6C546F702830292C79286129293A303E652626642E6765742830292E7363726F6C6C4865696768742D64';
wwv_flow_api.g_varchar2_table(92) := '2E7363726F6C6C546F7028292B653C3D642E6865696768742829262628642E7363726F6C6C546F7028642E6765742830292E7363726F6C6C4865696768742D642E6865696768742829292C79286129297D292C722865292C652E6F6E28226B657975702D';
wwv_flow_api.g_varchar2_table(93) := '6368616E676520696E707574207061737465222C746869732E62696E6428746869732E757064617465526573756C747329292C652E6F6E2822666F637573222C66756E6374696F6E28297B652E616464436C617373282273656C656374322D666F637573';
wwv_flow_api.g_varchar2_table(94) := '656422297D292C652E6F6E2822626C7572222C66756E6374696F6E28297B652E72656D6F7665436C617373282273656C656374322D666F637573656422297D292C746869732E64726F70646F776E2E6F6E28226D6F7573657570222C662C746869732E62';
wwv_flow_api.g_varchar2_table(95) := '696E642866756E6374696F6E2862297B6128622E746172676574292E636C6F7365737428222E73656C656374322D726573756C742D73656C65637461626C6522292E6C656E6774683E30262628746869732E686967686C69676874556E6465724576656E';
wwv_flow_api.g_varchar2_table(96) := '742862292C746869732E73656C656374486967686C696768746564286229297D29292C746869732E64726F70646F776E2E6F6E2822636C69636B206D6F7573657570206D6F757365646F776E222C66756E6374696F6E2861297B612E73746F7050726F70';
wwv_flow_api.g_varchar2_table(97) := '61676174696F6E28297D292C612E697346756E6374696F6E28746869732E6F7074732E696E697453656C656374696F6E29262628746869732E696E697453656C656374696F6E28292C746869732E6D6F6E69746F72536F757263652829292C6E756C6C21';
wwv_flow_api.g_varchar2_table(98) := '3D3D632E6D6178696D756D496E7075744C656E6774682626746869732E7365617263682E6174747228226D61786C656E677468222C632E6D6178696D756D496E7075744C656E677468293B76617220683D632E656C656D656E742E70726F702822646973';
wwv_flow_api.g_varchar2_table(99) := '61626C656422293B683D3D3D62262628683D2131292C746869732E656E61626C65282168293B76617220693D632E656C656D656E742E70726F702822726561646F6E6C7922293B693D3D3D62262628693D2131292C746869732E726561646F6E6C792869';
wwv_flow_api.g_varchar2_table(100) := '292C6B3D6B7C7C6E28292C746869732E6175746F666F6375733D632E656C656D656E742E70726F7028226175746F666F63757322292C632E656C656D656E742E70726F7028226175746F666F637573222C2131292C746869732E6175746F666F63757326';
wwv_flow_api.g_varchar2_table(101) := '26746869732E666F63757328297D2C64657374726F793A66756E6374696F6E28297B76617220613D746869732E6F7074732E656C656D656E742C633D612E64617461282273656C6563743222293B746869732E70726F70657274794F6273657276657226';
wwv_flow_api.g_varchar2_table(102) := '262864656C65746520746869732E70726F70657274794F627365727665722C746869732E70726F70657274794F627365727665723D6E756C6C292C63213D3D62262628632E636F6E7461696E65722E72656D6F766528292C632E64726F70646F776E2E72';
wwv_flow_api.g_varchar2_table(103) := '656D6F766528292C612E72656D6F7665436C617373282273656C656374322D6F666673637265656E22292E72656D6F766544617461282273656C6563743222292E6F666628222E73656C6563743222292E70726F7028226175746F666F637573222C7468';
wwv_flow_api.g_varchar2_table(104) := '69732E6175746F666F6375737C7C2131292C746869732E656C656D656E74546162496E6465783F612E61747472287B746162696E6465783A746869732E656C656D656E74546162496E6465787D293A612E72656D6F7665417474722822746162696E6465';
wwv_flow_api.g_varchar2_table(105) := '7822292C612E73686F772829297D2C6F7074696F6E546F446174613A66756E6374696F6E2861297B72657475726E20612E697328226F7074696F6E22293F7B69643A612E70726F70282276616C756522292C746578743A612E7465787428292C656C656D';
wwv_flow_api.g_varchar2_table(106) := '656E743A612E67657428292C6373733A612E617474722822636C61737322292C64697361626C65643A612E70726F70282264697361626C656422292C6C6F636B65643A6F28612E6174747228226C6F636B656422292C226C6F636B656422297C7C6F2861';
wwv_flow_api.g_varchar2_table(107) := '2E6461746128226C6F636B656422292C2130297D3A612E697328226F707467726F757022293F7B746578743A612E6174747228226C6162656C22292C6368696C6472656E3A5B5D2C656C656D656E743A612E67657428292C6373733A612E617474722822';
wwv_flow_api.g_varchar2_table(108) := '636C61737322297D3A627D2C707265706172654F7074733A66756E6374696F6E2863297B76617220642C652C662C672C683D746869733B696628643D632E656C656D656E742C2273656C656374223D3D3D642E6765742830292E7461674E616D652E746F';
wwv_flow_api.g_varchar2_table(109) := '4C6F776572436173652829262628746869732E73656C6563743D653D632E656C656D656E74292C652626612E65616368285B226964222C226D756C7469706C65222C22616A6178222C227175657279222C2263726561746553656172636843686F696365';
wwv_flow_api.g_varchar2_table(110) := '222C22696E697453656C656374696F6E222C2264617461222C2274616773225D2C66756E6374696F6E28297B6966287468697320696E2063297468726F77204572726F7228224F7074696F6E2027222B746869732B2227206973206E6F7420616C6C6F77';
wwv_flow_api.g_varchar2_table(111) := '656420666F722053656C65637432207768656E20617474616368656420746F2061203C73656C6563743E20656C656D656E742E22297D292C633D612E657874656E64287B7D2C7B706F70756C617465526573756C74733A66756E6374696F6E28642C652C';
wwv_flow_api.g_varchar2_table(112) := '66297B76617220672C6C3D746869732E6F7074732E69643B673D66756E6374696F6E28642C652C69297B766172206A2C6B2C6D2C6E2C6F2C702C712C722C732C743B666F7228643D632E736F7274526573756C747328642C652C66292C6A3D302C6B3D64';
wwv_flow_api.g_varchar2_table(113) := '2E6C656E6774683B6B3E6A3B6A2B3D31296D3D645B6A5D2C6F3D6D2E64697361626C65643D3D3D21302C6E3D216F26266C286D29213D3D622C703D6D2E6368696C6472656E26266D2E6368696C6472656E2E6C656E6774683E302C713D6128223C6C693E';
wwv_flow_api.g_varchar2_table(114) := '3C2F6C693E22292C712E616464436C617373282273656C656374322D726573756C74732D646570742D222B69292C712E616464436C617373282273656C656374322D726573756C7422292C712E616464436C617373286E3F2273656C656374322D726573';
wwv_flow_api.g_varchar2_table(115) := '756C742D73656C65637461626C65223A2273656C656374322D726573756C742D756E73656C65637461626C6522292C6F2626712E616464436C617373282273656C656374322D64697361626C656422292C702626712E616464436C617373282273656C65';
wwv_flow_api.g_varchar2_table(116) := '6374322D726573756C742D776974682D6368696C6472656E22292C712E616464436C61737328682E6F7074732E666F726D6174526573756C74437373436C617373286D29292C723D6128646F63756D656E742E637265617465456C656D656E7428226469';
wwv_flow_api.g_varchar2_table(117) := '762229292C722E616464436C617373282273656C656374322D726573756C742D6C6162656C22292C743D632E666F726D6174526573756C74286D2C722C662C682E6F7074732E6573636170654D61726B7570292C74213D3D622626722E68746D6C287429';
wwv_flow_api.g_varchar2_table(118) := '2C712E617070656E642872292C70262628733D6128223C756C3E3C2F756C3E22292C732E616464436C617373282273656C656374322D726573756C742D73756222292C67286D2E6368696C6472656E2C732C692B31292C712E617070656E64287329292C';
wwv_flow_api.g_varchar2_table(119) := '712E64617461282273656C656374322D64617461222C6D292C652E617070656E642871297D2C6728652C642C30297D7D2C612E666E2E73656C656374322E64656661756C74732C63292C2266756E6374696F6E22213D747970656F6620632E6964262628';
wwv_flow_api.g_varchar2_table(120) := '663D632E69642C632E69643D66756E6374696F6E2861297B72657475726E20615B665D7D292C612E6973417272617928632E656C656D656E742E64617461282273656C6563743254616773222929297B696628227461677322696E2063297468726F7722';
wwv_flow_api.g_varchar2_table(121) := '746167732073706563696669656420617320626F746820616E206174747269627574652027646174612D73656C656374322D746167732720616E6420696E206F7074696F6E73206F662053656C6563743220222B632E656C656D656E742E617474722822';
wwv_flow_api.g_varchar2_table(122) := '696422293B632E746167733D632E656C656D656E742E64617461282273656C656374325461677322297D696628653F28632E71756572793D746869732E62696E642866756E6374696F6E2861297B76617220662C672C692C633D7B726573756C74733A5B';
wwv_flow_api.g_varchar2_table(123) := '5D2C6D6F72653A21317D2C653D612E7465726D3B693D66756E6374696F6E28622C63297B76617220643B622E697328226F7074696F6E22293F612E6D61746368657228652C622E7465787428292C62292626632E7075736828682E6F7074696F6E546F44';
wwv_flow_api.g_varchar2_table(124) := '617461286229293A622E697328226F707467726F75702229262628643D682E6F7074696F6E546F446174612862292C622E6368696C6472656E28292E65616368322866756E6374696F6E28612C62297B6928622C642E6368696C6472656E297D292C642E';
wwv_flow_api.g_varchar2_table(125) := '6368696C6472656E2E6C656E6774683E302626632E70757368286429297D2C663D642E6368696C6472656E28292C746869732E676574506C616365686F6C6465722829213D3D622626662E6C656E6774683E30262628673D746869732E676574506C6163';
wwv_flow_api.g_varchar2_table(126) := '65686F6C6465724F7074696F6E28292C67262628663D662E6E6F7428672929292C662E65616368322866756E6374696F6E28612C62297B6928622C632E726573756C7473297D292C612E63616C6C6261636B2863297D292C632E69643D66756E6374696F';
wwv_flow_api.g_varchar2_table(127) := '6E2861297B72657475726E20612E69647D2C632E666F726D6174526573756C74437373436C6173733D66756E6374696F6E2861297B72657475726E20612E6373737D293A22717565727922696E20637C7C2822616A617822696E20633F28673D632E656C';
wwv_flow_api.g_varchar2_table(128) := '656D656E742E646174612822616A61782D75726C22292C672626672E6C656E6774683E30262628632E616A61782E75726C3D67292C632E71756572793D452E63616C6C28632E656C656D656E742C632E616A617829293A226461746122696E20633F632E';
wwv_flow_api.g_varchar2_table(129) := '71756572793D4628632E64617461293A227461677322696E2063262628632E71756572793D4728632E74616773292C632E63726561746553656172636843686F6963653D3D3D62262628632E63726561746553656172636843686F6963653D66756E6374';
wwv_flow_api.g_varchar2_table(130) := '696F6E2861297B72657475726E7B69643A612C746578743A617D7D292C632E696E697453656C656374696F6E3D3D3D62262628632E696E697453656C656374696F6E3D66756E6374696F6E28642C65297B76617220663D5B5D3B61287028642E76616C28';
wwv_flow_api.g_varchar2_table(131) := '292C632E736570617261746F7229292E656163682866756E6374696F6E28297B76617220643D746869732C653D746869732C673D632E746167733B612E697346756E6374696F6E286729262628673D672829292C612867292E656163682866756E637469';
wwv_flow_api.g_varchar2_table(132) := '6F6E28297B72657475726E206F28746869732E69642C64293F28653D746869732E746578742C2131293A627D292C662E70757368287B69643A642C746578743A657D297D292C652866297D2929292C2266756E6374696F6E22213D747970656F6620632E';
wwv_flow_api.g_varchar2_table(133) := '7175657279297468726F772271756572792066756E6374696F6E206E6F7420646566696E656420666F722053656C6563743220222B632E656C656D656E742E617474722822696422293B72657475726E20637D2C6D6F6E69746F72536F757263653A6675';
wwv_flow_api.g_varchar2_table(134) := '6E6374696F6E28297B76617220632C613D746869732E6F7074732E656C656D656E743B612E6F6E28226368616E67652E73656C65637432222C746869732E62696E642866756E6374696F6E28297B746869732E6F7074732E656C656D656E742E64617461';
wwv_flow_api.g_varchar2_table(135) := '282273656C656374322D6368616E67652D7472696767657265642229213D3D21302626746869732E696E697453656C656374696F6E28297D29292C633D746869732E62696E642866756E6374696F6E28297B76617220642C663D612E70726F7028226469';
wwv_flow_api.g_varchar2_table(136) := '7361626C656422293B663D3D3D62262628663D2131292C746869732E656E61626C65282166293B76617220643D612E70726F702822726561646F6E6C7922293B643D3D3D62262628643D2131292C746869732E726561646F6E6C792864292C4228746869';
wwv_flow_api.g_varchar2_table(137) := '732E636F6E7461696E65722C746869732E6F7074732E656C656D656E742C746869732E6F7074732E6164617074436F6E7461696E6572437373436C617373292C746869732E636F6E7461696E65722E616464436C617373284928746869732E6F7074732E';
wwv_flow_api.g_varchar2_table(138) := '636F6E7461696E6572437373436C61737329292C4228746869732E64726F70646F776E2C746869732E6F7074732E656C656D656E742C746869732E6F7074732E616461707444726F70646F776E437373436C617373292C746869732E64726F70646F776E';
wwv_flow_api.g_varchar2_table(139) := '2E616464436C617373284928746869732E6F7074732E64726F70646F776E437373436C61737329297D292C612E6F6E282270726F70657274796368616E67652E73656C6563743220444F4D417474724D6F6469666965642E73656C65637432222C63292C';
wwv_flow_api.g_varchar2_table(140) := '746869732E6D75746174696F6E43616C6C6261636B3D3D3D62262628746869732E6D75746174696F6E43616C6C6261636B3D66756E6374696F6E2861297B612E666F72456163682863297D292C22756E646566696E656422213D747970656F6620576562';
wwv_flow_api.g_varchar2_table(141) := '4B69744D75746174696F6E4F62736572766572262628746869732E70726F70657274794F6273657276657226262864656C65746520746869732E70726F70657274794F627365727665722C746869732E70726F70657274794F627365727665723D6E756C';
wwv_flow_api.g_varchar2_table(142) := '6C292C746869732E70726F70657274794F627365727665723D6E6577205765624B69744D75746174696F6E4F6273657276657228746869732E6D75746174696F6E43616C6C6261636B292C746869732E70726F70657274794F627365727665722E6F6273';
wwv_flow_api.g_varchar2_table(143) := '6572766528612E6765742830292C7B617474726962757465733A21302C737562747265653A21317D29297D2C7472696767657253656C6563743A66756E6374696F6E2862297B76617220633D612E4576656E74282273656C656374322D73656C65637469';
wwv_flow_api.g_varchar2_table(144) := '6E67222C7B76616C3A746869732E69642862292C6F626A6563743A627D293B72657475726E20746869732E6F7074732E656C656D656E742E747269676765722863292C21632E697344656661756C7450726576656E74656428297D2C7472696767657243';
wwv_flow_api.g_varchar2_table(145) := '68616E67653A66756E6374696F6E2862297B623D627C7C7B7D2C623D612E657874656E64287B7D2C622C7B747970653A226368616E6765222C76616C3A746869732E76616C28297D292C746869732E6F7074732E656C656D656E742E6461746128227365';
wwv_flow_api.g_varchar2_table(146) := '6C656374322D6368616E67652D747269676765726564222C2130292C746869732E6F7074732E656C656D656E742E747269676765722862292C746869732E6F7074732E656C656D656E742E64617461282273656C656374322D6368616E67652D74726967';
wwv_flow_api.g_varchar2_table(147) := '6765726564222C2131292C746869732E6F7074732E656C656D656E742E636C69636B28292C746869732E6F7074732E626C75724F6E4368616E67652626746869732E6F7074732E656C656D656E742E626C757228297D2C6973496E74657266616365456E';
wwv_flow_api.g_varchar2_table(148) := '61626C65643A66756E6374696F6E28297B72657475726E20746869732E656E61626C6564496E746572666163653D3D3D21307D2C656E61626C65496E746572666163653A66756E6374696F6E28297B76617220613D746869732E5F656E61626C65642626';
wwv_flow_api.g_varchar2_table(149) := '21746869732E5F726561646F6E6C792C623D21613B72657475726E20613D3D3D746869732E656E61626C6564496E746572666163653F21313A28746869732E636F6E7461696E65722E746F67676C65436C617373282273656C656374322D636F6E746169';
wwv_flow_api.g_varchar2_table(150) := '6E65722D64697361626C6564222C62292C746869732E636C6F736528292C746869732E656E61626C6564496E746572666163653D612C2130297D2C656E61626C653A66756E6374696F6E2861297B72657475726E20613D3D3D62262628613D2130292C74';
wwv_flow_api.g_varchar2_table(151) := '6869732E5F656E61626C65643D3D3D613F21313A28746869732E5F656E61626C65643D612C746869732E6F7074732E656C656D656E742E70726F70282264697361626C6564222C2161292C746869732E656E61626C65496E7465726661636528292C2130';
wwv_flow_api.g_varchar2_table(152) := '297D2C726561646F6E6C793A66756E6374696F6E2861297B72657475726E20613D3D3D62262628613D2131292C746869732E5F726561646F6E6C793D3D3D613F21313A28746869732E5F726561646F6E6C793D612C746869732E6F7074732E656C656D65';
wwv_flow_api.g_varchar2_table(153) := '6E742E70726F702822726561646F6E6C79222C61292C746869732E656E61626C65496E7465726661636528292C2130297D2C6F70656E65643A66756E6374696F6E28297B72657475726E20746869732E636F6E7461696E65722E686173436C6173732822';
wwv_flow_api.g_varchar2_table(154) := '73656C656374322D64726F70646F776E2D6F70656E22297D2C706F736974696F6E44726F70646F776E3A66756E6374696F6E28297B76617220712C722C732C742C623D746869732E64726F70646F776E2C633D746869732E636F6E7461696E65722E6F66';
wwv_flow_api.g_varchar2_table(155) := '6673657428292C643D746869732E636F6E7461696E65722E6F75746572486569676874282131292C653D746869732E636F6E7461696E65722E6F757465725769647468282131292C663D622E6F75746572486569676874282131292C673D612877696E64';
wwv_flow_api.g_varchar2_table(156) := '6F77292E7363726F6C6C4C65667428292B612877696E646F77292E776964746828292C683D612877696E646F77292E7363726F6C6C546F7028292B612877696E646F77292E68656967687428292C693D632E746F702B642C6A3D632E6C6566742C6C3D68';
wwv_flow_api.g_varchar2_table(157) := '3E3D692B662C6D3D632E746F702D663E3D746869732E626F647928292E7363726F6C6C546F7028292C6E3D622E6F757465725769647468282131292C6F3D673E3D6A2B6E2C703D622E686173436C617373282273656C656374322D64726F702D61626F76';
wwv_flow_api.g_varchar2_table(158) := '6522293B746869732E6F7074732E64726F70646F776E4175746F57696474683F28743D6128222E73656C656374322D726573756C7473222C62295B305D2C622E616464436C617373282273656C656374322D64726F702D6175746F2D776964746822292C';
wwv_flow_api.g_varchar2_table(159) := '622E63737328227769647468222C2222292C6E3D622E6F757465725769647468282131292B28742E7363726F6C6C4865696768743D3D3D742E636C69656E744865696768743F303A6B2E7769647468292C6E3E653F653D6E3A6E3D652C6F3D673E3D6A2B';
wwv_flow_api.g_varchar2_table(160) := '6E293A746869732E636F6E7461696E65722E72656D6F7665436C617373282273656C656374322D64726F702D6175746F2D776964746822292C2273746174696322213D3D746869732E626F647928292E6373732822706F736974696F6E2229262628713D';
wwv_flow_api.g_varchar2_table(161) := '746869732E626F647928292E6F666673657428292C692D3D712E746F702C6A2D3D712E6C656674292C703F28723D21302C216D26266C262628723D213129293A28723D21312C216C26266D262628723D213029292C6F7C7C286A3D632E6C6566742B652D';
wwv_flow_api.g_varchar2_table(162) := '6E292C723F28693D632E746F702D662C746869732E636F6E7461696E65722E616464436C617373282273656C656374322D64726F702D61626F766522292C622E616464436C617373282273656C656374322D64726F702D61626F76652229293A28746869';
wwv_flow_api.g_varchar2_table(163) := '732E636F6E7461696E65722E72656D6F7665436C617373282273656C656374322D64726F702D61626F766522292C622E72656D6F7665436C617373282273656C656374322D64726F702D61626F76652229292C733D612E657874656E64287B746F703A69';
wwv_flow_api.g_varchar2_table(164) := '2C6C6566743A6A2C77696474683A657D2C4928746869732E6F7074732E64726F70646F776E43737329292C622E6373732873297D2C73686F756C644F70656E3A66756E6374696F6E28297B76617220623B72657475726E20746869732E6F70656E656428';
wwv_flow_api.g_varchar2_table(165) := '293F21313A746869732E5F656E61626C65643D3D3D21317C7C746869732E5F726561646F6E6C793D3D3D21303F21313A28623D612E4576656E74282273656C656374322D6F70656E696E6722292C746869732E6F7074732E656C656D656E742E74726967';
wwv_flow_api.g_varchar2_table(166) := '6765722862292C21622E697344656661756C7450726576656E7465642829297D2C636C65617244726F70646F776E416C69676E6D656E74507265666572656E63653A66756E6374696F6E28297B746869732E636F6E7461696E65722E72656D6F7665436C';
wwv_flow_api.g_varchar2_table(167) := '617373282273656C656374322D64726F702D61626F766522292C746869732E64726F70646F776E2E72656D6F7665436C617373282273656C656374322D64726F702D61626F766522297D2C6F70656E3A66756E6374696F6E28297B72657475726E207468';
wwv_flow_api.g_varchar2_table(168) := '69732E73686F756C644F70656E28293F28746869732E6F70656E696E6728292C2130293A21317D2C6F70656E696E673A66756E6374696F6E28297B66756E6374696F6E206928297B72657475726E7B77696474683A4D6174682E6D617828646F63756D65';
wwv_flow_api.g_varchar2_table(169) := '6E742E646F63756D656E74456C656D656E742E7363726F6C6C57696474682C612877696E646F77292E77696474682829292C6865696768743A4D6174682E6D617828646F63756D656E742E646F63756D656E74456C656D656E742E7363726F6C6C486569';
wwv_flow_api.g_varchar2_table(170) := '6768742C612877696E646F77292E6865696768742829297D7D76617220662C672C623D746869732E636F6E7461696E657249642C633D227363726F6C6C2E222B622C643D22726573697A652E222B622C653D226F7269656E746174696F6E6368616E6765';
wwv_flow_api.g_varchar2_table(171) := '2E222B623B746869732E636F6E7461696E65722E616464436C617373282273656C656374322D64726F70646F776E2D6F70656E22292E616464436C617373282273656C656374322D636F6E7461696E65722D61637469766522292C746869732E636C6561';
wwv_flow_api.g_varchar2_table(172) := '7244726F70646F776E416C69676E6D656E74507265666572656E636528292C746869732E64726F70646F776E5B305D213D3D746869732E626F647928292E6368696C6472656E28292E6C61737428295B305D2626746869732E64726F70646F776E2E6465';
wwv_flow_api.g_varchar2_table(173) := '7461636828292E617070656E64546F28746869732E626F64792829292C663D6128222373656C656374322D64726F702D6D61736B22292C303D3D662E6C656E677468262628663D6128646F63756D656E742E637265617465456C656D656E742822646976';
wwv_flow_api.g_varchar2_table(174) := '2229292C662E6174747228226964222C2273656C656374322D64726F702D6D61736B22292E617474722822636C617373222C2273656C656374322D64726F702D6D61736B22292C662E6869646528292C662E617070656E64546F28746869732E626F6479';
wwv_flow_api.g_varchar2_table(175) := '2829292C662E6F6E28226D6F757365646F776E20746F756368737461727420636C69636B222C66756E6374696F6E2862297B76617220642C633D6128222373656C656374322D64726F7022293B632E6C656E6774683E30262628643D632E646174612822';
wwv_flow_api.g_varchar2_table(176) := '73656C6563743222292C642E6F7074732E73656C6563744F6E426C75722626642E73656C656374486967686C696768746564287B6E6F466F6375733A21307D292C642E636C6F736528292C622E70726576656E7444656661756C7428292C622E73746F70';
wwv_flow_api.g_varchar2_table(177) := '50726F7061676174696F6E2829297D29292C746869732E64726F70646F776E2E7072657628295B305D213D3D665B305D2626746869732E64726F70646F776E2E6265666F72652866292C6128222373656C656374322D64726F7022292E72656D6F766541';
wwv_flow_api.g_varchar2_table(178) := '7474722822696422292C746869732E64726F70646F776E2E6174747228226964222C2273656C656374322D64726F7022292C673D6928292C662E6373732867292E73686F7728292C746869732E64726F70646F776E2E73686F7728292C746869732E706F';
wwv_flow_api.g_varchar2_table(179) := '736974696F6E44726F70646F776E28292C746869732E64726F70646F776E2E616464436C617373282273656C656374322D64726F702D61637469766522293B76617220683D746869733B746869732E636F6E7461696E65722E706172656E747328292E61';
wwv_flow_api.g_varchar2_table(180) := '64642877696E646F77292E656163682866756E6374696F6E28297B612874686973292E6F6E28642B2220222B632B2220222B652C66756E6374696F6E28297B76617220633D6928293B6128222373656C656374322D64726F702D6D61736B22292E637373';
wwv_flow_api.g_varchar2_table(181) := '2863292C682E706F736974696F6E44726F70646F776E28297D297D297D2C636C6F73653A66756E6374696F6E28297B696628746869732E6F70656E65642829297B76617220623D746869732E636F6E7461696E657249642C633D227363726F6C6C2E222B';
wwv_flow_api.g_varchar2_table(182) := '622C643D22726573697A652E222B622C653D226F7269656E746174696F6E6368616E67652E222B623B746869732E636F6E7461696E65722E706172656E747328292E6164642877696E646F77292E656163682866756E6374696F6E28297B612874686973';
wwv_flow_api.g_varchar2_table(183) := '292E6F66662863292E6F66662864292E6F66662865297D292C746869732E636C65617244726F70646F776E416C69676E6D656E74507265666572656E636528292C6128222373656C656374322D64726F702D6D61736B22292E6869646528292C74686973';
wwv_flow_api.g_varchar2_table(184) := '2E64726F70646F776E2E72656D6F7665417474722822696422292C746869732E64726F70646F776E2E6869646528292C746869732E636F6E7461696E65722E72656D6F7665436C617373282273656C656374322D64726F70646F776E2D6F70656E22292C';
wwv_flow_api.g_varchar2_table(185) := '746869732E726573756C74732E656D70747928292C746869732E636C65617253656172636828292C746869732E7365617263682E72656D6F7665436C617373282273656C656374322D61637469766522292C746869732E6F7074732E656C656D656E742E';
wwv_flow_api.g_varchar2_table(186) := '7472696767657228612E4576656E74282273656C656374322D636C6F73652229297D7D2C65787465726E616C5365617263683A66756E6374696F6E2861297B746869732E6F70656E28292C746869732E7365617263682E76616C2861292C746869732E75';
wwv_flow_api.g_varchar2_table(187) := '7064617465526573756C7473282131297D2C636C6561725365617263683A66756E6374696F6E28297B7D2C6765744D6178696D756D53656C656374696F6E53697A653A66756E6374696F6E28297B72657475726E204928746869732E6F7074732E6D6178';
wwv_flow_api.g_varchar2_table(188) := '696D756D53656C656374696F6E53697A65297D2C656E73757265486967686C6967687456697369626C653A66756E6374696F6E28297B76617220642C652C662C672C682C692C6A2C633D746869732E726573756C74733B696628653D746869732E686967';
wwv_flow_api.g_varchar2_table(189) := '686C6967687428292C2128303E6529297B696628303D3D652972657475726E20632E7363726F6C6C546F702830292C623B643D746869732E66696E64486967686C6967687461626C6543686F6963657328292E66696E6428222E73656C656374322D7265';
wwv_flow_api.g_varchar2_table(190) := '73756C742D6C6162656C22292C663D6128645B655D292C673D662E6F666673657428292E746F702B662E6F75746572486569676874282130292C653D3D3D642E6C656E6774682D312626286A3D632E66696E6428226C692E73656C656374322D6D6F7265';
wwv_flow_api.g_varchar2_table(191) := '2D726573756C747322292C6A2E6C656E6774683E30262628673D6A2E6F666673657428292E746F702B6A2E6F757465724865696768742821302929292C683D632E6F666673657428292E746F702B632E6F75746572486569676874282130292C673E6826';
wwv_flow_api.g_varchar2_table(192) := '26632E7363726F6C6C546F7028632E7363726F6C6C546F7028292B28672D6829292C693D662E6F666673657428292E746F702D632E6F666673657428292E746F702C303E692626226E6F6E6522213D662E6373732822646973706C617922292626632E73';
wwv_flow_api.g_varchar2_table(193) := '63726F6C6C546F7028632E7363726F6C6C546F7028292B69297D7D2C66696E64486967686C6967687461626C6543686F696365733A66756E6374696F6E28297B72657475726E20746869732E726573756C74732E66696E6428222E73656C656374322D72';
wwv_flow_api.g_varchar2_table(194) := '6573756C742D73656C65637461626C653A6E6F74282E73656C656374322D73656C6563746564293A6E6F74282E73656C656374322D64697361626C65642922297D2C6D6F7665486967686C696768743A66756E6374696F6E2862297B666F722876617220';
wwv_flow_api.g_varchar2_table(195) := '633D746869732E66696E64486967686C6967687461626C6543686F6963657328292C643D746869732E686967686C6967687428293B643E2D312626632E6C656E6774683E643B297B642B3D623B76617220653D6128635B645D293B696628652E68617343';
wwv_flow_api.g_varchar2_table(196) := '6C617373282273656C656374322D726573756C742D73656C65637461626C652229262621652E686173436C617373282273656C656374322D64697361626C65642229262621652E686173436C617373282273656C656374322D73656C6563746564222929';
wwv_flow_api.g_varchar2_table(197) := '7B746869732E686967686C696768742864293B627265616B7D7D7D2C686967686C696768743A66756E6374696F6E2863297B76617220652C662C643D746869732E66696E64486967686C6967687461626C6543686F6963657328293B72657475726E2030';
wwv_flow_api.g_varchar2_table(198) := '3D3D3D617267756D656E74732E6C656E6774683F6D28642E66696C74657228222E73656C656374322D686967686C69676874656422295B305D2C642E6765742829293A28633E3D642E6C656E677468262628633D642E6C656E6774682D31292C303E6326';
wwv_flow_api.g_varchar2_table(199) := '2628633D30292C746869732E726573756C74732E66696E6428222E73656C656374322D686967686C69676874656422292E72656D6F7665436C617373282273656C656374322D686967686C69676874656422292C653D6128645B635D292C652E61646443';
wwv_flow_api.g_varchar2_table(200) := '6C617373282273656C656374322D686967686C69676874656422292C746869732E656E73757265486967686C6967687456697369626C6528292C663D652E64617461282273656C656374322D6461746122292C662626746869732E6F7074732E656C656D';
wwv_flow_api.g_varchar2_table(201) := '656E742E74726967676572287B747970653A2273656C656374322D686967686C69676874222C76616C3A746869732E69642866292C63686F6963653A667D292C62297D2C636F756E7453656C65637461626C65526573756C74733A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(202) := '297B72657475726E20746869732E66696E64486967686C6967687461626C6543686F6963657328292E6C656E6774687D2C686967686C69676874556E6465724576656E743A66756E6374696F6E2862297B76617220633D6128622E746172676574292E63';
wwv_flow_api.g_varchar2_table(203) := '6C6F7365737428222E73656C656374322D726573756C742D73656C65637461626C6522293B696628632E6C656E6774683E30262621632E697328222E73656C656374322D686967686C6967687465642229297B76617220643D746869732E66696E644869';
wwv_flow_api.g_varchar2_table(204) := '67686C6967687461626C6543686F6963657328293B746869732E686967686C6967687428642E696E646578286329297D656C736520303D3D632E6C656E6774682626746869732E726573756C74732E66696E6428222E73656C656374322D686967686C69';
wwv_flow_api.g_varchar2_table(205) := '676874656422292E72656D6F7665436C617373282273656C656374322D686967686C69676874656422297D2C6C6F61644D6F726549664E65656465643A66756E6374696F6E28297B76617220632C613D746869732E726573756C74732C623D612E66696E';
wwv_flow_api.g_varchar2_table(206) := '6428226C692E73656C656374322D6D6F72652D726573756C747322292C653D746869732E726573756C7473506167652B312C663D746869732C673D746869732E7365617263682E76616C28292C683D746869732E636F6E746578743B30213D3D622E6C65';
wwv_flow_api.g_varchar2_table(207) := '6E677468262628633D622E6F666673657428292E746F702D612E6F666673657428292E746F702D612E68656967687428292C746869732E6F7074732E6C6F61644D6F726550616464696E673E3D63262628622E616464436C617373282273656C65637432';
wwv_flow_api.g_varchar2_table(208) := '2D61637469766522292C746869732E6F7074732E7175657279287B656C656D656E743A746869732E6F7074732E656C656D656E742C7465726D3A672C706167653A652C636F6E746578743A682C6D6174636865723A746869732E6F7074732E6D61746368';
wwv_flow_api.g_varchar2_table(209) := '65722C63616C6C6261636B3A746869732E62696E642866756E6374696F6E2863297B662E6F70656E65642829262628662E6F7074732E706F70756C617465526573756C74732E63616C6C28746869732C612C632E726573756C74732C7B7465726D3A672C';
wwv_flow_api.g_varchar2_table(210) := '706167653A652C636F6E746578743A687D292C662E706F737470726F63657373526573756C747328632C21312C2131292C632E6D6F72653D3D3D21303F28622E64657461636828292E617070656E64546F2861292E7465787428662E6F7074732E666F72';
wwv_flow_api.g_varchar2_table(211) := '6D61744C6F61644D6F726528652B3129292C77696E646F772E73657454696D656F75742866756E6374696F6E28297B662E6C6F61644D6F726549664E656564656428297D2C313029293A622E72656D6F766528292C662E706F736974696F6E44726F7064';
wwv_flow_api.g_varchar2_table(212) := '6F776E28292C662E726573756C7473506167653D652C662E636F6E746578743D632E636F6E74657874297D297D2929297D2C746F6B656E697A653A66756E6374696F6E28297B7D2C757064617465526573756C74733A66756E6374696F6E2863297B6675';
wwv_flow_api.g_varchar2_table(213) := '6E6374696F6E206C28297B642E72656D6F7665436C617373282273656C656374322D61637469766522292C682E706F736974696F6E44726F70646F776E28297D66756E6374696F6E206D2861297B652E68746D6C2861292C6C28297D76617220672C692C';
wwv_flow_api.g_varchar2_table(214) := '643D746869732E7365617263682C653D746869732E726573756C74732C663D746869732E6F7074732C683D746869732C6A3D642E76616C28292C6B3D612E6461746128746869732E636F6E7461696E65722C2273656C656374322D6C6173742D7465726D';
wwv_flow_api.g_varchar2_table(215) := '22293B69662828633D3D3D21307C7C216B7C7C216F286A2C6B2929262628612E6461746128746869732E636F6E7461696E65722C2273656C656374322D6C6173742D7465726D222C6A292C633D3D3D21307C7C746869732E73686F77536561726368496E';
wwv_flow_api.g_varchar2_table(216) := '707574213D3D21312626746869732E6F70656E6564282929297B766172206E3D746869732E6765744D6178696D756D53656C656374696F6E53697A6528293B6966286E3E3D31262628673D746869732E6461746128292C612E6973417272617928672926';
wwv_flow_api.g_varchar2_table(217) := '26672E6C656E6774683E3D6E26264828662E666F726D617453656C656374696F6E546F6F4269672C22666F726D617453656C656374696F6E546F6F4269672229292972657475726E206D28223C6C6920636C6173733D2773656C656374322D73656C6563';
wwv_flow_api.g_varchar2_table(218) := '74696F6E2D6C696D6974273E222B662E666F726D617453656C656374696F6E546F6F426967286E292B223C2F6C693E22292C623B696628642E76616C28292E6C656E6774683C662E6D696E696D756D496E7075744C656E6774682972657475726E204828';
wwv_flow_api.g_varchar2_table(219) := '662E666F726D6174496E707574546F6F53686F72742C22666F726D6174496E707574546F6F53686F727422293F6D28223C6C6920636C6173733D2773656C656374322D6E6F2D726573756C7473273E222B662E666F726D6174496E707574546F6F53686F';
wwv_flow_api.g_varchar2_table(220) := '727428642E76616C28292C662E6D696E696D756D496E7075744C656E677468292B223C2F6C693E22293A6D282222292C632626746869732E73686F775365617263682626746869732E73686F77536561726368282130292C623B696628662E6D6178696D';
wwv_flow_api.g_varchar2_table(221) := '756D496E7075744C656E6774682626642E76616C28292E6C656E6774683E662E6D6178696D756D496E7075744C656E6774682972657475726E204828662E666F726D6174496E707574546F6F4C6F6E672C22666F726D6174496E707574546F6F4C6F6E67';
wwv_flow_api.g_varchar2_table(222) := '22293F6D28223C6C6920636C6173733D2773656C656374322D6E6F2D726573756C7473273E222B662E666F726D6174496E707574546F6F4C6F6E6728642E76616C28292C662E6D6178696D756D496E7075744C656E677468292B223C2F6C693E22293A6D';
wwv_flow_api.g_varchar2_table(223) := '282222292C623B662E666F726D6174536561726368696E672626303D3D3D746869732E66696E64486967686C6967687461626C6543686F6963657328292E6C656E67746826266D28223C6C6920636C6173733D2773656C656374322D736561726368696E';
wwv_flow_api.g_varchar2_table(224) := '67273E222B662E666F726D6174536561726368696E6728292B223C2F6C693E22292C642E616464436C617373282273656C656374322D61637469766522292C693D746869732E746F6B656E697A6528292C69213D6226266E756C6C213D692626642E7661';
wwv_flow_api.g_varchar2_table(225) := '6C2869292C746869732E726573756C7473506167653D312C662E7175657279287B656C656D656E743A662E656C656D656E742C7465726D3A642E76616C28292C706167653A746869732E726573756C7473506167652C636F6E746578743A6E756C6C2C6D';
wwv_flow_api.g_varchar2_table(226) := '6174636865723A662E6D6174636865722C63616C6C6261636B3A746869732E62696E642866756E6374696F6E2867297B76617220693B72657475726E20746869732E6F70656E656428293F28746869732E636F6E746578743D672E636F6E746578743D3D';
wwv_flow_api.g_varchar2_table(227) := '3D623F6E756C6C3A672E636F6E746578742C746869732E6F7074732E63726561746553656172636843686F69636526262222213D3D642E76616C2829262628693D746869732E6F7074732E63726561746553656172636843686F6963652E63616C6C2868';
wwv_flow_api.g_varchar2_table(228) := '2C642E76616C28292C672E726573756C7473292C69213D3D6226266E756C6C213D3D692626682E6964286929213D3D6226266E756C6C213D3D682E69642869292626303D3D3D6128672E726573756C7473292E66696C7465722866756E6374696F6E2829';
wwv_flow_api.g_varchar2_table(229) := '7B72657475726E206F28682E69642874686973292C682E6964286929297D292E6C656E6774682626672E726573756C74732E756E7368696674286929292C303D3D3D672E726573756C74732E6C656E67746826264828662E666F726D61744E6F4D617463';
wwv_flow_api.g_varchar2_table(230) := '6865732C22666F726D61744E6F4D61746368657322293F286D28223C6C6920636C6173733D2773656C656374322D6E6F2D726573756C7473273E222B662E666F726D61744E6F4D61746368657328642E76616C2829292B223C2F6C693E22292C62293A28';
wwv_flow_api.g_varchar2_table(231) := '652E656D70747928292C682E6F7074732E706F70756C617465526573756C74732E63616C6C28746869732C652C672E726573756C74732C7B7465726D3A642E76616C28292C706167653A746869732E726573756C7473506167652C636F6E746578743A6E';
wwv_flow_api.g_varchar2_table(232) := '756C6C7D292C672E6D6F72653D3D3D213026264828662E666F726D61744C6F61644D6F72652C22666F726D61744C6F61644D6F72652229262628652E617070656E6428223C6C6920636C6173733D2773656C656374322D6D6F72652D726573756C747327';
wwv_flow_api.g_varchar2_table(233) := '3E222B682E6F7074732E6573636170654D61726B757028662E666F726D61744C6F61644D6F726528746869732E726573756C74735061676529292B223C2F6C693E22292C77696E646F772E73657454696D656F75742866756E6374696F6E28297B682E6C';
wwv_flow_api.g_varchar2_table(234) := '6F61644D6F726549664E656564656428297D2C313029292C746869732E706F737470726F63657373526573756C747328672C63292C6C28292C746869732E6F7074732E656C656D656E742E74726967676572287B747970653A2273656C656374322D6C6F';
wwv_flow_api.g_varchar2_table(235) := '61646564222C6974656D733A677D292C6229293A28746869732E7365617263682E72656D6F7665436C617373282273656C656374322D61637469766522292C62297D297D297D7D2C63616E63656C3A66756E6374696F6E28297B746869732E636C6F7365';
wwv_flow_api.g_varchar2_table(236) := '28297D2C626C75723A66756E6374696F6E28297B746869732E6F7074732E73656C6563744F6E426C75722626746869732E73656C656374486967686C696768746564287B6E6F466F6375733A21307D292C746869732E636C6F736528292C746869732E63';
wwv_flow_api.g_varchar2_table(237) := '6F6E7461696E65722E72656D6F7665436C617373282273656C656374322D636F6E7461696E65722D61637469766522292C746869732E7365617263685B305D3D3D3D646F63756D656E742E616374697665456C656D656E742626746869732E7365617263';
wwv_flow_api.g_varchar2_table(238) := '682E626C757228292C746869732E636C65617253656172636828292C746869732E73656C656374696F6E2E66696E6428222E73656C656374322D7365617263682D63686F6963652D666F63757322292E72656D6F7665436C617373282273656C65637432';
wwv_flow_api.g_varchar2_table(239) := '2D7365617263682D63686F6963652D666F63757322297D2C666F6375735365617263683A66756E6374696F6E28297B7728746869732E736561726368297D2C73656C656374486967686C6967687465643A66756E6374696F6E2861297B76617220623D74';
wwv_flow_api.g_varchar2_table(240) := '6869732E686967686C6967687428292C633D746869732E726573756C74732E66696E6428222E73656C656374322D686967686C69676874656422292C643D632E636C6F7365737428222E73656C656374322D726573756C7422292E64617461282273656C';
wwv_flow_api.g_varchar2_table(241) := '656374322D6461746122293B643F28746869732E686967686C696768742862292C746869732E6F6E53656C65637428642C6129293A612626612E6E6F466F6375732626746869732E636C6F736528297D2C676574506C616365686F6C6465723A66756E63';
wwv_flow_api.g_varchar2_table(242) := '74696F6E28297B76617220613B72657475726E20746869732E6F7074732E656C656D656E742E617474722822706C616365686F6C64657222297C7C746869732E6F7074732E656C656D656E742E617474722822646174612D706C616365686F6C64657222';
wwv_flow_api.g_varchar2_table(243) := '297C7C746869732E6F7074732E656C656D656E742E646174612822706C616365686F6C64657222297C7C746869732E6F7074732E706C616365686F6C6465727C7C2828613D746869732E676574506C616365686F6C6465724F7074696F6E282929213D3D';
wwv_flow_api.g_varchar2_table(244) := '623F612E7465787428293A62297D2C676574506C616365686F6C6465724F7074696F6E3A66756E6374696F6E28297B696628746869732E73656C656374297B76617220613D746869732E73656C6563742E6368696C6472656E28292E666972737428293B';
wwv_flow_api.g_varchar2_table(245) := '696628746869732E6F7074732E706C616365686F6C6465724F7074696F6E213D3D622972657475726E226669727374223D3D3D746869732E6F7074732E706C616365686F6C6465724F7074696F6E2626617C7C2266756E6374696F6E223D3D747970656F';
wwv_flow_api.g_varchar2_table(246) := '6620746869732E6F7074732E706C616365686F6C6465724F7074696F6E2626746869732E6F7074732E706C616365686F6C6465724F7074696F6E28746869732E73656C656374293B69662822223D3D3D612E746578742829262622223D3D3D612E76616C';
wwv_flow_api.g_varchar2_table(247) := '28292972657475726E20617D7D2C696E6974436F6E7461696E657257696474683A66756E6374696F6E28297B66756E6374696F6E206328297B76617220632C642C652C662C673B696628226F6666223D3D3D746869732E6F7074732E7769647468297265';
wwv_flow_api.g_varchar2_table(248) := '7475726E206E756C6C3B69662822656C656D656E74223D3D3D746869732E6F7074732E77696474682972657475726E20303D3D3D746869732E6F7074732E656C656D656E742E6F757465725769647468282131293F226175746F223A746869732E6F7074';
wwv_flow_api.g_varchar2_table(249) := '732E656C656D656E742E6F757465725769647468282131292B227078223B69662822636F7079223D3D3D746869732E6F7074732E77696474687C7C227265736F6C7665223D3D3D746869732E6F7074732E7769647468297B696628633D746869732E6F70';
wwv_flow_api.g_varchar2_table(250) := '74732E656C656D656E742E6174747228227374796C6522292C63213D3D6229666F7228643D632E73706C697428223B22292C663D302C673D642E6C656E6774683B673E663B662B3D3129696628653D645B665D2E7265706C616365282F5C732F672C2222';
wwv_flow_api.g_varchar2_table(251) := '292E6D61746368282F77696474683A28285B2D2B5D3F285B302D395D2A5C2E293F5B302D395D2B292870787C656D7C65787C257C696E7C636D7C6D6D7C70747C706329292F69292C6E756C6C213D3D652626652E6C656E6774683E3D312972657475726E';
wwv_flow_api.g_varchar2_table(252) := '20655B315D3B72657475726E227265736F6C7665223D3D3D746869732E6F7074732E77696474683F28633D746869732E6F7074732E656C656D656E742E6373732822776964746822292C632E696E6465784F6628222522293E303F633A303D3D3D746869';
wwv_flow_api.g_varchar2_table(253) := '732E6F7074732E656C656D656E742E6F757465725769647468282131293F226175746F223A746869732E6F7074732E656C656D656E742E6F757465725769647468282131292B22707822293A6E756C6C7D72657475726E20612E697346756E6374696F6E';
wwv_flow_api.g_varchar2_table(254) := '28746869732E6F7074732E7769647468293F746869732E6F7074732E776964746828293A746869732E6F7074732E77696474687D76617220643D632E63616C6C2874686973293B6E756C6C213D3D642626746869732E636F6E7461696E65722E63737328';
wwv_flow_api.g_varchar2_table(255) := '227769647468222C64297D7D292C653D4C28642C7B637265617465436F6E7461696E65723A66756E6374696F6E28297B76617220623D6128646F63756D656E742E637265617465456C656D656E7428226469762229292E61747472287B22636C61737322';
wwv_flow_api.g_varchar2_table(256) := '3A2273656C656374322D636F6E7461696E6572227D292E68746D6C285B223C6120687265663D276A6176617363726970743A766F696428302927206F6E636C69636B3D2772657475726E2066616C73653B2720636C6173733D2773656C656374322D6368';
wwv_flow_api.g_varchar2_table(257) := '6F6963652720746162696E6465783D272D31273E222C222020203C7370616E20636C6173733D2773656C656374322D63686F73656E273E266E6273703B3C2F7370616E3E3C6162627220636C6173733D2773656C656374322D7365617263682D63686F69';
wwv_flow_api.g_varchar2_table(258) := '63652D636C6F7365273E3C2F616262723E222C222020203C7370616E20636C6173733D2773656C656374322D6172726F77273E3C623E3C2F623E3C2F7370616E3E222C223C2F613E222C223C696E70757420636C6173733D2773656C656374322D666F63';
wwv_flow_api.g_varchar2_table(259) := '75737365722073656C656374322D6F666673637265656E2720747970653D2774657874272F3E222C223C64697620636C6173733D2773656C656374322D64726F702073656C656374322D646973706C61792D6E6F6E65273E222C222020203C6469762063';
wwv_flow_api.g_varchar2_table(260) := '6C6173733D2773656C656374322D736561726368273E222C22202020202020203C696E70757420747970653D277465787427206175746F636F6D706C6574653D276F666627206175746F636F72726563743D276F666627206175746F6361706974616C69';
wwv_flow_api.g_varchar2_table(261) := '7A653D276F666627207370656C6C636865636B3D2766616C73652720636C6173733D2773656C656374322D696E707574272F3E222C222020203C2F6469763E222C222020203C756C20636C6173733D2773656C656374322D726573756C7473273E222C22';
wwv_flow_api.g_varchar2_table(262) := '2020203C2F756C3E222C223C2F6469763E225D2E6A6F696E28222229293B72657475726E20627D2C656E61626C65496E746572666163653A66756E6374696F6E28297B746869732E706172656E742E656E61626C65496E746572666163652E6170706C79';
wwv_flow_api.g_varchar2_table(263) := '28746869732C617267756D656E7473292626746869732E666F6375737365722E70726F70282264697361626C6564222C21746869732E6973496E74657266616365456E61626C65642829297D2C6F70656E696E673A66756E6374696F6E28297B76617220';
wwv_flow_api.g_varchar2_table(264) := '622C632C643B746869732E6F7074732E6D696E696D756D526573756C7473466F725365617263683E3D302626746869732E73686F77536561726368282130292C746869732E706172656E742E6F70656E696E672E6170706C7928746869732C617267756D';
wwv_flow_api.g_varchar2_table(265) := '656E7473292C746869732E73686F77536561726368496E707574213D3D21312626746869732E7365617263682E76616C28746869732E666F6375737365722E76616C2829292C746869732E7365617263682E666F63757328292C623D746869732E736561';
wwv_flow_api.g_varchar2_table(266) := '7263682E6765742830292C622E6372656174655465787452616E67653F28633D622E6372656174655465787452616E676528292C632E636F6C6C61707365282131292C632E73656C6563742829293A622E73657453656C656374696F6E52616E67652626';
wwv_flow_api.g_varchar2_table(267) := '28643D746869732E7365617263682E76616C28292E6C656E6774682C622E73657453656C656374696F6E52616E676528642C6429292C746869732E666F6375737365722E70726F70282264697361626C6564222C2130292E76616C282222292C74686973';
wwv_flow_api.g_varchar2_table(268) := '2E757064617465526573756C7473282130292C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E74282273656C656374322D6F70656E2229297D2C636C6F73653A66756E6374696F6E28297B746869732E6F70656E656428';
wwv_flow_api.g_varchar2_table(269) := '29262628746869732E706172656E742E636C6F73652E6170706C7928746869732C617267756D656E7473292C746869732E666F6375737365722E72656D6F766541747472282264697361626C656422292C746869732E666F6375737365722E666F637573';
wwv_flow_api.g_varchar2_table(270) := '2829297D2C666F6375733A66756E6374696F6E28297B746869732E6F70656E656428293F746869732E636C6F736528293A28746869732E666F6375737365722E72656D6F766541747472282264697361626C656422292C746869732E666F637573736572';
wwv_flow_api.g_varchar2_table(271) := '2E666F6375732829297D2C6973466F63757365643A66756E6374696F6E28297B72657475726E20746869732E636F6E7461696E65722E686173436C617373282273656C656374322D636F6E7461696E65722D61637469766522297D2C63616E63656C3A66';
wwv_flow_api.g_varchar2_table(272) := '756E6374696F6E28297B746869732E706172656E742E63616E63656C2E6170706C7928746869732C617267756D656E7473292C746869732E666F6375737365722E72656D6F766541747472282264697361626C656422292C746869732E666F6375737365';
wwv_flow_api.g_varchar2_table(273) := '722E666F63757328297D2C696E6974436F6E7461696E65723A66756E6374696F6E28297B76617220642C653D746869732E636F6E7461696E65722C663D746869732E64726F70646F776E3B303E746869732E6F7074732E6D696E696D756D526573756C74';
wwv_flow_api.g_varchar2_table(274) := '73466F725365617263683F746869732E73686F77536561726368282131293A746869732E73686F77536561726368282130292C746869732E73656C656374696F6E3D643D652E66696E6428222E73656C656374322D63686F69636522292C746869732E66';
wwv_flow_api.g_varchar2_table(275) := '6F6375737365723D652E66696E6428222E73656C656374322D666F63757373657222292C746869732E666F6375737365722E6174747228226964222C22733269645F6175746F67656E222B672829292C6128226C6162656C5B666F723D27222B74686973';
wwv_flow_api.g_varchar2_table(276) := '2E6F7074732E656C656D656E742E617474722822696422292B22275D22292E617474722822666F72222C746869732E666F6375737365722E61747472282269642229292C746869732E666F6375737365722E617474722822746162696E646578222C7468';
wwv_flow_api.g_varchar2_table(277) := '69732E656C656D656E74546162496E646578292C746869732E7365617263682E6F6E28226B6579646F776E222C746869732E62696E642866756E6374696F6E2861297B696628746869732E6973496E74657266616365456E61626C65642829297B696628';
wwv_flow_api.g_varchar2_table(278) := '612E77686963683D3D3D632E504147455F55507C7C612E77686963683D3D3D632E504147455F444F574E2972657475726E20792861292C623B73776974636828612E7768696368297B6361736520632E55503A6361736520632E444F574E3A7265747572';
wwv_flow_api.g_varchar2_table(279) := '6E20746869732E6D6F7665486967686C6967687428612E77686963683D3D3D632E55503F2D313A31292C792861292C623B6361736520632E454E5445523A72657475726E20746869732E73656C656374486967686C69676874656428292C792861292C62';
wwv_flow_api.g_varchar2_table(280) := '3B6361736520632E5441423A72657475726E20746869732E73656C656374486967686C696768746564287B6E6F466F6375733A21307D292C623B6361736520632E4553433A72657475726E20746869732E63616E63656C2861292C792861292C627D7D7D';
wwv_flow_api.g_varchar2_table(281) := '29292C746869732E7365617263682E6F6E2822626C7572222C746869732E62696E642866756E6374696F6E28297B646F63756D656E742E616374697665456C656D656E743D3D3D746869732E626F647928292E676574283029262677696E646F772E7365';
wwv_flow_api.g_varchar2_table(282) := '7454696D656F757428746869732E62696E642866756E6374696F6E28297B746869732E7365617263682E666F63757328297D292C30297D29292C746869732E666F6375737365722E6F6E28226B6579646F776E222C746869732E62696E642866756E6374';
wwv_flow_api.g_varchar2_table(283) := '696F6E2861297B696628746869732E6973496E74657266616365456E61626C656428292626612E7768696368213D3D632E544142262621632E6973436F6E74726F6C286129262621632E697346756E6374696F6E4B65792861292626612E776869636821';
wwv_flow_api.g_varchar2_table(284) := '3D3D632E455343297B696628746869732E6F7074732E6F70656E4F6E456E7465723D3D3D21312626612E77686963683D3D3D632E454E5445522972657475726E20792861292C623B696628612E77686963683D3D632E444F574E7C7C612E77686963683D';
wwv_flow_api.g_varchar2_table(285) := '3D632E55507C7C612E77686963683D3D632E454E5445522626746869732E6F7074732E6F70656E4F6E456E746572297B696628612E616C744B65797C7C612E6374726C4B65797C7C612E73686966744B65797C7C612E6D6574614B65792972657475726E';
wwv_flow_api.g_varchar2_table(286) := '3B72657475726E20746869732E6F70656E28292C792861292C627D72657475726E20612E77686963683D3D632E44454C4554457C7C612E77686963683D3D632E4241434B53504143453F28746869732E6F7074732E616C6C6F77436C6561722626746869';
wwv_flow_api.g_varchar2_table(287) := '732E636C65617228292C792861292C62293A627D7D29292C7228746869732E666F637573736572292C746869732E666F6375737365722E6F6E28226B657975702D6368616E676520696E707574222C746869732E62696E642866756E6374696F6E286129';
wwv_flow_api.g_varchar2_table(288) := '7B696628746869732E6F7074732E6D696E696D756D526573756C7473466F725365617263683E3D30297B696628612E73746F7050726F7061676174696F6E28292C746869732E6F70656E656428292972657475726E3B746869732E6F70656E28297D7D29';
wwv_flow_api.g_varchar2_table(289) := '292C642E6F6E28226D6F757365646F776E222C2261626272222C746869732E62696E642866756E6374696F6E2861297B746869732E6973496E74657266616365456E61626C65642829262628746869732E636C65617228292C7A2861292C746869732E63';
wwv_flow_api.g_varchar2_table(290) := '6C6F736528292C746869732E73656C656374696F6E2E666F6375732829297D29292C642E6F6E28226D6F757365646F776E222C746869732E62696E642866756E6374696F6E2862297B746869732E636F6E7461696E65722E686173436C61737328227365';
wwv_flow_api.g_varchar2_table(291) := '6C656374322D636F6E7461696E65722D61637469766522297C7C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E74282273656C656374322D666F6375732229292C746869732E6F70656E656428293F746869732E636C6F';
wwv_flow_api.g_varchar2_table(292) := '736528293A746869732E6973496E74657266616365456E61626C656428292626746869732E6F70656E28292C792862297D29292C662E6F6E28226D6F757365646F776E222C746869732E62696E642866756E6374696F6E28297B746869732E7365617263';
wwv_flow_api.g_varchar2_table(293) := '682E666F63757328297D29292C642E6F6E2822666F637573222C746869732E62696E642866756E6374696F6E2861297B792861297D29292C746869732E666F6375737365722E6F6E2822666F637573222C746869732E62696E642866756E6374696F6E28';
wwv_flow_api.g_varchar2_table(294) := '297B746869732E636F6E7461696E65722E686173436C617373282273656C656374322D636F6E7461696E65722D61637469766522297C7C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E74282273656C656374322D666F';
wwv_flow_api.g_varchar2_table(295) := '6375732229292C746869732E636F6E7461696E65722E616464436C617373282273656C656374322D636F6E7461696E65722D61637469766522297D29292E6F6E2822626C7572222C746869732E62696E642866756E6374696F6E28297B746869732E6F70';
wwv_flow_api.g_varchar2_table(296) := '656E656428297C7C28746869732E636F6E7461696E65722E72656D6F7665436C617373282273656C656374322D636F6E7461696E65722D61637469766522292C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E74282273';
wwv_flow_api.g_varchar2_table(297) := '656C656374322D626C7572222929297D29292C746869732E7365617263682E6F6E2822666F637573222C746869732E62696E642866756E6374696F6E28297B746869732E636F6E7461696E65722E686173436C617373282273656C656374322D636F6E74';
wwv_flow_api.g_varchar2_table(298) := '61696E65722D61637469766522297C7C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E74282273656C656374322D666F6375732229292C746869732E636F6E7461696E65722E616464436C617373282273656C65637432';
wwv_flow_api.g_varchar2_table(299) := '2D636F6E7461696E65722D61637469766522297D29292C746869732E696E6974436F6E7461696E6572576964746828292C746869732E6F7074732E656C656D656E742E616464436C617373282273656C656374322D6F666673637265656E22292C746869';
wwv_flow_api.g_varchar2_table(300) := '732E736574506C616365686F6C64657228297D2C636C6561723A66756E6374696F6E2861297B76617220623D746869732E73656C656374696F6E2E64617461282273656C656374322D6461746122293B69662862297B76617220633D746869732E676574';
wwv_flow_api.g_varchar2_table(301) := '506C616365686F6C6465724F7074696F6E28293B746869732E6F7074732E656C656D656E742E76616C28633F632E76616C28293A2222292C746869732E73656C656374696F6E2E66696E6428222E73656C656374322D63686F73656E22292E656D707479';
wwv_flow_api.g_varchar2_table(302) := '28292C746869732E73656C656374696F6E2E72656D6F766544617461282273656C656374322D6461746122292C746869732E736574506C616365686F6C64657228292C61213D3D2131262628746869732E6F7074732E656C656D656E742E747269676765';
wwv_flow_api.g_varchar2_table(303) := '72287B747970653A2273656C656374322D72656D6F766564222C76616C3A746869732E69642862292C63686F6963653A627D292C746869732E747269676765724368616E6765287B72656D6F7665643A627D29297D7D2C696E697453656C656374696F6E';
wwv_flow_api.g_varchar2_table(304) := '3A66756E6374696F6E28297B696628746869732E6973506C616365686F6C6465724F7074696F6E53656C6563746564282929746869732E75706461746553656C656374696F6E285B5D292C746869732E636C6F736528292C746869732E736574506C6163';
wwv_flow_api.g_varchar2_table(305) := '65686F6C64657228293B656C73657B76617220633D746869733B746869732E6F7074732E696E697453656C656374696F6E2E63616C6C286E756C6C2C746869732E6F7074732E656C656D656E742C66756E6374696F6E2861297B61213D3D6226266E756C';
wwv_flow_api.g_varchar2_table(306) := '6C213D3D61262628632E75706461746553656C656374696F6E2861292C632E636C6F736528292C632E736574506C616365686F6C6465722829297D297D7D2C6973506C616365686F6C6465724F7074696F6E53656C65637465643A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(307) := '297B76617220613B72657475726E28613D746869732E676574506C616365686F6C6465724F7074696F6E282929213D3D622626612E697328223A73656C656374656422297C7C22223D3D3D746869732E6F7074732E656C656D656E742E76616C28297C7C';
wwv_flow_api.g_varchar2_table(308) := '746869732E6F7074732E656C656D656E742E76616C28293D3D3D627C7C6E756C6C3D3D3D746869732E6F7074732E656C656D656E742E76616C28297D2C707265706172654F7074733A66756E6374696F6E28297B76617220623D746869732E706172656E';
wwv_flow_api.g_varchar2_table(309) := '742E707265706172654F7074732E6170706C7928746869732C617267756D656E7473292C633D746869733B72657475726E2273656C656374223D3D3D622E656C656D656E742E6765742830292E7461674E616D652E746F4C6F7765724361736528293F62';
wwv_flow_api.g_varchar2_table(310) := '2E696E697453656C656374696F6E3D66756E6374696F6E28612C62297B76617220643D612E66696E6428223A73656C656374656422293B6228632E6F7074696F6E546F44617461286429297D3A226461746122696E2062262628622E696E697453656C65';
wwv_flow_api.g_varchar2_table(311) := '6374696F6E3D622E696E697453656C656374696F6E7C7C66756E6374696F6E28632C64297B76617220653D632E76616C28292C663D6E756C6C3B622E7175657279287B6D6174636865723A66756E6374696F6E28612C632C64297B76617220673D6F2865';
wwv_flow_api.g_varchar2_table(312) := '2C622E6964286429293B72657475726E2067262628663D64292C677D2C63616C6C6261636B3A612E697346756E6374696F6E2864293F66756E6374696F6E28297B642866297D3A612E6E6F6F707D297D292C627D2C676574506C616365686F6C6465723A';
wwv_flow_api.g_varchar2_table(313) := '66756E6374696F6E28297B72657475726E20746869732E73656C6563742626746869732E676574506C616365686F6C6465724F7074696F6E28293D3D3D623F623A746869732E706172656E742E676574506C616365686F6C6465722E6170706C79287468';
wwv_flow_api.g_varchar2_table(314) := '69732C617267756D656E7473297D2C736574506C616365686F6C6465723A66756E6374696F6E28297B76617220613D746869732E676574506C616365686F6C64657228293B696628746869732E6973506C616365686F6C6465724F7074696F6E53656C65';
wwv_flow_api.g_varchar2_table(315) := '637465642829262661213D3D62297B696628746869732E73656C6563742626746869732E676574506C616365686F6C6465724F7074696F6E28293D3D3D622972657475726E3B746869732E73656C656374696F6E2E66696E6428222E73656C656374322D';
wwv_flow_api.g_varchar2_table(316) := '63686F73656E22292E68746D6C28746869732E6F7074732E6573636170654D61726B7570286129292C746869732E73656C656374696F6E2E616464436C617373282273656C656374322D64656661756C7422292C746869732E636F6E7461696E65722E72';
wwv_flow_api.g_varchar2_table(317) := '656D6F7665436C617373282273656C656374322D616C6C6F77636C65617222297D7D2C706F737470726F63657373526573756C74733A66756E6374696F6E28612C632C64297B76617220653D302C663D746869733B696628746869732E66696E64486967';
wwv_flow_api.g_varchar2_table(318) := '686C6967687461626C6543686F6963657328292E65616368322866756E6374696F6E28612C63297B72657475726E206F28662E696428632E64617461282273656C656374322D646174612229292C662E6F7074732E656C656D656E742E76616C2829293F';
wwv_flow_api.g_varchar2_table(319) := '28653D612C2131293A627D292C64213D3D2131262628633D3D3D21302626653E3D303F746869732E686967686C696768742865293A746869732E686967686C69676874283029292C633D3D3D2130297B76617220683D746869732E6F7074732E6D696E69';
wwv_flow_api.g_varchar2_table(320) := '6D756D526573756C7473466F725365617263683B683E3D302626746869732E73686F77536561726368284A28612E726573756C7473293E3D68297D7D2C73686F775365617263683A66756E6374696F6E2862297B746869732E73686F7753656172636849';
wwv_flow_api.g_varchar2_table(321) := '6E707574213D3D62262628746869732E73686F77536561726368496E7075743D622C746869732E64726F70646F776E2E66696E6428222E73656C656374322D73656172636822292E746F67676C65436C617373282273656C656374322D7365617263682D';
wwv_flow_api.g_varchar2_table(322) := '68696464656E222C2162292C746869732E64726F70646F776E2E66696E6428222E73656C656374322D73656172636822292E746F67676C65436C617373282273656C656374322D6F666673637265656E222C2162292C6128746869732E64726F70646F77';
wwv_flow_api.g_varchar2_table(323) := '6E2C746869732E636F6E7461696E6572292E746F67676C65436C617373282273656C656374322D776974682D736561726368626F78222C6229297D2C6F6E53656C6563743A66756E6374696F6E28612C62297B696628746869732E747269676765725365';
wwv_flow_api.g_varchar2_table(324) := '6C656374286129297B76617220633D746869732E6F7074732E656C656D656E742E76616C28292C643D746869732E6461746128293B746869732E6F7074732E656C656D656E742E76616C28746869732E6964286129292C746869732E7570646174655365';
wwv_flow_api.g_varchar2_table(325) := '6C656374696F6E2861292C746869732E6F7074732E656C656D656E742E74726967676572287B747970653A2273656C656374322D73656C6563746564222C76616C3A746869732E69642861292C63686F6963653A617D292C746869732E636C6F73652829';
wwv_flow_api.g_varchar2_table(326) := '2C622626622E6E6F466F6375737C7C746869732E73656C656374696F6E2E666F63757328292C6F28632C746869732E6964286129297C7C746869732E747269676765724368616E6765287B61646465643A612C72656D6F7665643A647D297D7D2C757064';
wwv_flow_api.g_varchar2_table(327) := '61746553656C656374696F6E3A66756E6374696F6E2861297B76617220642C652C633D746869732E73656C656374696F6E2E66696E6428222E73656C656374322D63686F73656E22293B746869732E73656C656374696F6E2E64617461282273656C6563';
wwv_flow_api.g_varchar2_table(328) := '74322D64617461222C61292C632E656D70747928292C643D746869732E6F7074732E666F726D617453656C656374696F6E28612C632C746869732E6F7074732E6573636170654D61726B7570292C64213D3D622626632E617070656E642864292C653D74';
wwv_flow_api.g_varchar2_table(329) := '6869732E6F7074732E666F726D617453656C656374696F6E437373436C61737328612C63292C65213D3D622626632E616464436C6173732865292C746869732E73656C656374696F6E2E72656D6F7665436C617373282273656C656374322D6465666175';
wwv_flow_api.g_varchar2_table(330) := '6C7422292C746869732E6F7074732E616C6C6F77436C6561722626746869732E676574506C616365686F6C6465722829213D3D622626746869732E636F6E7461696E65722E616464436C617373282273656C656374322D616C6C6F77636C65617222290A';
wwv_flow_api.g_varchar2_table(331) := '7D2C76616C3A66756E6374696F6E28297B76617220612C633D21312C643D6E756C6C2C653D746869732C663D746869732E6461746128293B696628303D3D3D617267756D656E74732E6C656E6774682972657475726E20746869732E6F7074732E656C65';
wwv_flow_api.g_varchar2_table(332) := '6D656E742E76616C28293B696628613D617267756D656E74735B305D2C617267756D656E74732E6C656E6774683E31262628633D617267756D656E74735B315D292C746869732E73656C65637429746869732E73656C6563742E76616C2861292E66696E';
wwv_flow_api.g_varchar2_table(333) := '6428223A73656C656374656422292E65616368322866756E6374696F6E28612C62297B72657475726E20643D652E6F7074696F6E546F446174612862292C21317D292C746869732E75706461746553656C656374696F6E2864292C746869732E73657450';
wwv_flow_api.g_varchar2_table(334) := '6C616365686F6C64657228292C632626746869732E747269676765724368616E6765287B61646465643A642C72656D6F7665643A667D293B656C73657B6966282161262630213D3D612972657475726E20746869732E636C6561722863292C623B696628';
wwv_flow_api.g_varchar2_table(335) := '746869732E6F7074732E696E697453656C656374696F6E3D3D3D62297468726F77204572726F72282263616E6E6F742063616C6C2076616C282920696620696E697453656C656374696F6E2829206973206E6F7420646566696E656422293B746869732E';
wwv_flow_api.g_varchar2_table(336) := '6F7074732E656C656D656E742E76616C2861292C746869732E6F7074732E696E697453656C656374696F6E28746869732E6F7074732E656C656D656E742C66756E6374696F6E2861297B652E6F7074732E656C656D656E742E76616C28613F652E696428';
wwv_flow_api.g_varchar2_table(337) := '61293A2222292C652E75706461746553656C656374696F6E2861292C652E736574506C616365686F6C64657228292C632626652E747269676765724368616E6765287B61646465643A612C72656D6F7665643A667D297D297D7D2C636C65617253656172';
wwv_flow_api.g_varchar2_table(338) := '63683A66756E6374696F6E28297B746869732E7365617263682E76616C282222292C746869732E666F6375737365722E76616C282222297D2C646174613A66756E6374696F6E28612C63297B76617220643B72657475726E20303D3D3D617267756D656E';
wwv_flow_api.g_varchar2_table(339) := '74732E6C656E6774683F28643D746869732E73656C656374696F6E2E64617461282273656C656374322D6461746122292C643D3D62262628643D6E756C6C292C64293A286126262222213D3D613F28643D746869732E6461746128292C746869732E6F70';
wwv_flow_api.g_varchar2_table(340) := '74732E656C656D656E742E76616C28613F746869732E69642861293A2222292C746869732E75706461746553656C656374696F6E2861292C632626746869732E747269676765724368616E6765287B61646465643A612C72656D6F7665643A647D29293A';
wwv_flow_api.g_varchar2_table(341) := '746869732E636C6561722863292C62297D7D292C663D4C28642C7B637265617465436F6E7461696E65723A66756E6374696F6E28297B76617220623D6128646F63756D656E742E637265617465456C656D656E7428226469762229292E61747472287B22';
wwv_flow_api.g_varchar2_table(342) := '636C617373223A2273656C656374322D636F6E7461696E65722073656C656374322D636F6E7461696E65722D6D756C7469227D292E68746D6C285B223C756C20636C6173733D2773656C656374322D63686F69636573273E222C2220203C6C6920636C61';
wwv_flow_api.g_varchar2_table(343) := '73733D2773656C656374322D7365617263682D6669656C64273E222C22202020203C696E70757420747970653D277465787427206175746F636F6D706C6574653D276F666627206175746F636F72726563743D276F666627206175746F6361706974696C';
wwv_flow_api.g_varchar2_table(344) := '697A653D276F666627207370656C6C636865636B3D2766616C73652720636C6173733D2773656C656374322D696E707574273E222C2220203C2F6C693E222C223C2F756C3E222C223C64697620636C6173733D2773656C656374322D64726F702073656C';
wwv_flow_api.g_varchar2_table(345) := '656374322D64726F702D6D756C74692073656C656374322D646973706C61792D6E6F6E65273E222C222020203C756C20636C6173733D2773656C656374322D726573756C7473273E222C222020203C2F756C3E222C223C2F6469763E225D2E6A6F696E28';
wwv_flow_api.g_varchar2_table(346) := '222229293B72657475726E20627D2C707265706172654F7074733A66756E6374696F6E28297B76617220623D746869732E706172656E742E707265706172654F7074732E6170706C7928746869732C617267756D656E7473292C633D746869733B726574';
wwv_flow_api.g_varchar2_table(347) := '75726E2273656C656374223D3D3D622E656C656D656E742E6765742830292E7461674E616D652E746F4C6F7765724361736528293F622E696E697453656C656374696F6E3D66756E6374696F6E28612C62297B76617220643D5B5D3B612E66696E642822';
wwv_flow_api.g_varchar2_table(348) := '3A73656C656374656422292E65616368322866756E6374696F6E28612C62297B642E7075736828632E6F7074696F6E546F44617461286229297D292C622864297D3A226461746122696E2062262628622E696E697453656C656374696F6E3D622E696E69';
wwv_flow_api.g_varchar2_table(349) := '7453656C656374696F6E7C7C66756E6374696F6E28632C64297B76617220653D7028632E76616C28292C622E736570617261746F72292C663D5B5D3B622E7175657279287B6D6174636865723A66756E6374696F6E28632C642C67297B76617220683D61';
wwv_flow_api.g_varchar2_table(350) := '2E6772657028652C66756E6374696F6E2861297B72657475726E206F28612C622E6964286729297D292E6C656E6774683B72657475726E20682626662E707573682867292C687D2C63616C6C6261636B3A612E697346756E6374696F6E2864293F66756E';
wwv_flow_api.g_varchar2_table(351) := '6374696F6E28297B666F722876617220613D5B5D2C633D303B652E6C656E6774683E633B632B2B29666F722876617220673D655B635D2C683D303B662E6C656E6774683E683B682B2B297B76617220693D665B685D3B6966286F28672C622E6964286929';
wwv_flow_api.g_varchar2_table(352) := '29297B612E707573682869292C662E73706C69636528682C31293B627265616B7D7D642861297D3A612E6E6F6F707D297D292C627D2C73656C65637443686F6963653A66756E6374696F6E2861297B76617220623D746869732E636F6E7461696E65722E';
wwv_flow_api.g_varchar2_table(353) := '66696E6428222E73656C656374322D7365617263682D63686F6963652D666F63757322293B622E6C656E6774682626612626615B305D3D3D625B305D7C7C28622E6C656E6774682626746869732E6F7074732E656C656D656E742E747269676765722822';
wwv_flow_api.g_varchar2_table(354) := '63686F6963652D646573656C6563746564222C62292C622E72656D6F7665436C617373282273656C656374322D7365617263682D63686F6963652D666F63757322292C612626612E6C656E677468262628746869732E636C6F736528292C612E61646443';
wwv_flow_api.g_varchar2_table(355) := '6C617373282273656C656374322D7365617263682D63686F6963652D666F63757322292C746869732E6F7074732E656C656D656E742E74726967676572282263686F6963652D73656C6563746564222C612929297D2C696E6974436F6E7461696E65723A';
wwv_flow_api.g_varchar2_table(356) := '66756E6374696F6E28297B76617220652C643D222E73656C656374322D63686F69636573223B746869732E736561726368436F6E7461696E65723D746869732E636F6E7461696E65722E66696E6428222E73656C656374322D7365617263682D6669656C';
wwv_flow_api.g_varchar2_table(357) := '6422292C746869732E73656C656374696F6E3D653D746869732E636F6E7461696E65722E66696E642864293B76617220663D746869733B746869732E73656C656374696F6E2E6F6E28226D6F757365646F776E222C222E73656C656374322D7365617263';
wwv_flow_api.g_varchar2_table(358) := '682D63686F696365222C66756E6374696F6E28297B662E7365617263685B305D2E666F63757328292C662E73656C65637443686F6963652861287468697329297D292C746869732E7365617263682E6174747228226964222C22733269645F6175746F67';
wwv_flow_api.g_varchar2_table(359) := '656E222B672829292C6128226C6162656C5B666F723D27222B746869732E6F7074732E656C656D656E742E617474722822696422292B22275D22292E617474722822666F72222C746869732E7365617263682E61747472282269642229292C746869732E';
wwv_flow_api.g_varchar2_table(360) := '7365617263682E6F6E2822696E707574207061737465222C746869732E62696E642866756E6374696F6E28297B746869732E6973496E74657266616365456E61626C65642829262628746869732E6F70656E656428297C7C746869732E6F70656E282929';
wwv_flow_api.g_varchar2_table(361) := '7D29292C746869732E7365617263682E617474722822746162696E646578222C746869732E656C656D656E74546162496E646578292C746869732E6B6579646F776E733D302C746869732E7365617263682E6F6E28226B6579646F776E222C746869732E';
wwv_flow_api.g_varchar2_table(362) := '62696E642866756E6374696F6E2861297B696628746869732E6973496E74657266616365456E61626C65642829297B2B2B746869732E6B6579646F776E733B76617220643D652E66696E6428222E73656C656374322D7365617263682D63686F6963652D';
wwv_flow_api.g_varchar2_table(363) := '666F63757322292C663D642E7072657628222E73656C656374322D7365617263682D63686F6963653A6E6F74282E73656C656374322D6C6F636B65642922292C673D642E6E65787428222E73656C656374322D7365617263682D63686F6963653A6E6F74';
wwv_flow_api.g_varchar2_table(364) := '282E73656C656374322D6C6F636B65642922292C683D7828746869732E736561726368293B696628642E6C656E677468262628612E77686963683D3D632E4C4546547C7C612E77686963683D3D632E52494748547C7C612E77686963683D3D632E424143';
wwv_flow_api.g_varchar2_table(365) := '4B53504143457C7C612E77686963683D3D632E44454C4554457C7C612E77686963683D3D632E454E54455229297B76617220693D643B72657475726E20612E77686963683D3D632E4C4546542626662E6C656E6774683F693D663A612E77686963683D3D';
wwv_flow_api.g_varchar2_table(366) := '632E52494748543F693D672E6C656E6774683F673A6E756C6C3A612E77686963683D3D3D632E4241434B53504143453F28746869732E756E73656C65637428642E66697273742829292C746869732E7365617263682E7769647468283130292C693D662E';
wwv_flow_api.g_varchar2_table(367) := '6C656E6774683F663A67293A612E77686963683D3D632E44454C4554453F28746869732E756E73656C65637428642E66697273742829292C746869732E7365617263682E7769647468283130292C693D672E6C656E6774683F673A6E756C6C293A612E77';
wwv_flow_api.g_varchar2_table(368) := '686963683D3D632E454E544552262628693D6E756C6C292C746869732E73656C65637443686F6963652869292C792861292C692626692E6C656E6774687C7C746869732E6F70656E28292C627D69662828612E77686963683D3D3D632E4241434B535041';
wwv_flow_api.g_varchar2_table(369) := '43452626313D3D746869732E6B6579646F776E737C7C612E77686963683D3D632E4C454654292626303D3D682E6F6666736574262621682E6C656E6774682972657475726E20746869732E73656C65637443686F69636528652E66696E6428222E73656C';
wwv_flow_api.g_varchar2_table(370) := '656374322D7365617263682D63686F6963653A6E6F74282E73656C656374322D6C6F636B65642922292E6C6173742829292C792861292C623B696628746869732E73656C65637443686F696365286E756C6C292C746869732E6F70656E65642829297377';
wwv_flow_api.g_varchar2_table(371) := '6974636828612E7768696368297B6361736520632E55503A6361736520632E444F574E3A72657475726E20746869732E6D6F7665486967686C6967687428612E77686963683D3D3D632E55503F2D313A31292C792861292C623B6361736520632E454E54';
wwv_flow_api.g_varchar2_table(372) := '45523A72657475726E20746869732E73656C656374486967686C69676874656428292C792861292C623B6361736520632E5441423A72657475726E20746869732E73656C656374486967686C696768746564287B6E6F466F6375733A21307D292C746869';
wwv_flow_api.g_varchar2_table(373) := '732E636C6F736528292C623B6361736520632E4553433A72657475726E20746869732E63616E63656C2861292C792861292C627D696628612E7768696368213D3D632E544142262621632E6973436F6E74726F6C286129262621632E697346756E637469';
wwv_flow_api.g_varchar2_table(374) := '6F6E4B65792861292626612E7768696368213D3D632E4241434B53504143452626612E7768696368213D3D632E455343297B696628612E77686963683D3D3D632E454E544552297B696628746869732E6F7074732E6F70656E4F6E456E7465723D3D3D21';
wwv_flow_api.g_varchar2_table(375) := '312972657475726E3B696628612E616C744B65797C7C612E6374726C4B65797C7C612E73686966744B65797C7C612E6D6574614B65792972657475726E7D746869732E6F70656E28292C28612E77686963683D3D3D632E504147455F55507C7C612E7768';
wwv_flow_api.g_varchar2_table(376) := '6963683D3D3D632E504147455F444F574E292626792861292C612E77686963683D3D3D632E454E5445522626792861297D7D7D29292C746869732E7365617263682E6F6E28226B65797570222C746869732E62696E642866756E6374696F6E28297B7468';
wwv_flow_api.g_varchar2_table(377) := '69732E6B6579646F776E733D302C746869732E726573697A6553656172636828297D29292C746869732E7365617263682E6F6E2822626C7572222C746869732E62696E642866756E6374696F6E2862297B746869732E636F6E7461696E65722E72656D6F';
wwv_flow_api.g_varchar2_table(378) := '7665436C617373282273656C656374322D636F6E7461696E65722D61637469766522292C746869732E7365617263682E72656D6F7665436C617373282273656C656374322D666F637573656422292C746869732E73656C65637443686F696365286E756C';
wwv_flow_api.g_varchar2_table(379) := '6C292C746869732E6F70656E656428297C7C746869732E636C65617253656172636828292C622E73746F70496D6D65646961746550726F7061676174696F6E28292C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E7428';
wwv_flow_api.g_varchar2_table(380) := '2273656C656374322D626C75722229297D29292C746869732E636F6E7461696E65722E6F6E2822636C69636B222C642C746869732E62696E642866756E6374696F6E2862297B746869732E6973496E74657266616365456E61626C656428292626286128';
wwv_flow_api.g_varchar2_table(381) := '622E746172676574292E636C6F7365737428222E73656C656374322D7365617263682D63686F69636522292E6C656E6774683E307C7C28746869732E73656C65637443686F696365286E756C6C292C746869732E636C656172506C616365686F6C646572';
wwv_flow_api.g_varchar2_table(382) := '28292C746869732E636F6E7461696E65722E686173436C617373282273656C656374322D636F6E7461696E65722D61637469766522297C7C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E74282273656C656374322D66';
wwv_flow_api.g_varchar2_table(383) := '6F6375732229292C746869732E6F70656E28292C746869732E666F63757353656172636828292C622E70726576656E7444656661756C74282929297D29292C746869732E636F6E7461696E65722E6F6E2822666F637573222C642C746869732E62696E64';
wwv_flow_api.g_varchar2_table(384) := '2866756E6374696F6E28297B746869732E6973496E74657266616365456E61626C65642829262628746869732E636F6E7461696E65722E686173436C617373282273656C656374322D636F6E7461696E65722D61637469766522297C7C746869732E6F70';
wwv_flow_api.g_varchar2_table(385) := '74732E656C656D656E742E7472696767657228612E4576656E74282273656C656374322D666F6375732229292C746869732E636F6E7461696E65722E616464436C617373282273656C656374322D636F6E7461696E65722D61637469766522292C746869';
wwv_flow_api.g_varchar2_table(386) := '732E64726F70646F776E2E616464436C617373282273656C656374322D64726F702D61637469766522292C746869732E636C656172506C616365686F6C6465722829297D29292C746869732E696E6974436F6E7461696E6572576964746828292C746869';
wwv_flow_api.g_varchar2_table(387) := '732E6F7074732E656C656D656E742E616464436C617373282273656C656374322D6F666673637265656E22292C746869732E636C65617253656172636828297D2C656E61626C65496E746572666163653A66756E6374696F6E28297B746869732E706172';
wwv_flow_api.g_varchar2_table(388) := '656E742E656E61626C65496E746572666163652E6170706C7928746869732C617267756D656E7473292626746869732E7365617263682E70726F70282264697361626C6564222C21746869732E6973496E74657266616365456E61626C65642829297D2C';
wwv_flow_api.g_varchar2_table(389) := '696E697453656C656374696F6E3A66756E6374696F6E28297B69662822223D3D3D746869732E6F7074732E656C656D656E742E76616C2829262622223D3D3D746869732E6F7074732E656C656D656E742E746578742829262628746869732E7570646174';
wwv_flow_api.g_varchar2_table(390) := '6553656C656374696F6E285B5D292C746869732E636C6F736528292C746869732E636C6561725365617263682829292C746869732E73656C6563747C7C2222213D3D746869732E6F7074732E656C656D656E742E76616C2829297B76617220633D746869';
wwv_flow_api.g_varchar2_table(391) := '733B746869732E6F7074732E696E697453656C656374696F6E2E63616C6C286E756C6C2C746869732E6F7074732E656C656D656E742C66756E6374696F6E2861297B61213D3D6226266E756C6C213D3D61262628632E75706461746553656C656374696F';
wwv_flow_api.g_varchar2_table(392) := '6E2861292C632E636C6F736528292C632E636C6561725365617263682829297D297D7D2C636C6561725365617263683A66756E6374696F6E28297B76617220613D746869732E676574506C616365686F6C64657228292C633D746869732E6765744D6178';
wwv_flow_api.g_varchar2_table(393) := '536561726368576964746828293B61213D3D622626303D3D3D746869732E67657456616C28292E6C656E6774682626746869732E7365617263682E686173436C617373282273656C656374322D666F637573656422293D3D3D21313F28746869732E7365';
wwv_flow_api.g_varchar2_table(394) := '617263682E76616C2861292E616464436C617373282273656C656374322D64656661756C7422292C746869732E7365617263682E776964746828633E303F633A746869732E636F6E7461696E65722E63737328227769647468222929293A746869732E73';
wwv_flow_api.g_varchar2_table(395) := '65617263682E76616C282222292E7769647468283130297D2C636C656172506C616365686F6C6465723A66756E6374696F6E28297B746869732E7365617263682E686173436C617373282273656C656374322D64656661756C7422292626746869732E73';
wwv_flow_api.g_varchar2_table(396) := '65617263682E76616C282222292E72656D6F7665436C617373282273656C656374322D64656661756C7422297D2C6F70656E696E673A66756E6374696F6E28297B746869732E636C656172506C616365686F6C64657228292C746869732E726573697A65';
wwv_flow_api.g_varchar2_table(397) := '53656172636828292C746869732E706172656E742E6F70656E696E672E6170706C7928746869732C617267756D656E7473292C746869732E666F63757353656172636828292C746869732E757064617465526573756C7473282130292C746869732E7365';
wwv_flow_api.g_varchar2_table(398) := '617263682E666F63757328292C746869732E6F7074732E656C656D656E742E7472696767657228612E4576656E74282273656C656374322D6F70656E2229297D2C636C6F73653A66756E6374696F6E28297B746869732E6F70656E656428292626746869';
wwv_flow_api.g_varchar2_table(399) := '732E706172656E742E636C6F73652E6170706C7928746869732C617267756D656E7473297D2C666F6375733A66756E6374696F6E28297B746869732E636C6F736528292C746869732E7365617263682E666F63757328297D2C6973466F63757365643A66';
wwv_flow_api.g_varchar2_table(400) := '756E6374696F6E28297B72657475726E20746869732E7365617263682E686173436C617373282273656C656374322D666F637573656422297D2C75706461746553656C656374696F6E3A66756E6374696F6E2862297B76617220633D5B5D2C643D5B5D2C';
wwv_flow_api.g_varchar2_table(401) := '653D746869733B612862292E656163682866756E6374696F6E28297B303E6D28652E69642874686973292C6329262628632E7075736828652E6964287468697329292C642E70757368287468697329297D292C623D642C746869732E73656C656374696F';
wwv_flow_api.g_varchar2_table(402) := '6E2E66696E6428222E73656C656374322D7365617263682D63686F69636522292E72656D6F766528292C612862292E656163682866756E6374696F6E28297B652E61646453656C656374656443686F6963652874686973297D292C652E706F737470726F';
wwv_flow_api.g_varchar2_table(403) := '63657373526573756C747328297D2C746F6B656E697A653A66756E6374696F6E28297B76617220613D746869732E7365617263682E76616C28293B613D746869732E6F7074732E746F6B656E697A65722E63616C6C28746869732C612C746869732E6461';
wwv_flow_api.g_varchar2_table(404) := '746128292C746869732E62696E6428746869732E6F6E53656C656374292C746869732E6F707473292C6E756C6C213D61262661213D62262628746869732E7365617263682E76616C2861292C612E6C656E6774683E302626746869732E6F70656E282929';
wwv_flow_api.g_varchar2_table(405) := '7D2C6F6E53656C6563743A66756E6374696F6E28612C62297B746869732E7472696767657253656C656374286129262628746869732E61646453656C656374656443686F6963652861292C746869732E6F7074732E656C656D656E742E74726967676572';
wwv_flow_api.g_varchar2_table(406) := '287B747970653A2273656C6563746564222C76616C3A746869732E69642861292C63686F6963653A617D292C28746869732E73656C6563747C7C21746869732E6F7074732E636C6F73654F6E53656C656374292626746869732E706F737470726F636573';
wwv_flow_api.g_varchar2_table(407) := '73526573756C747328292C746869732E6F7074732E636C6F73654F6E53656C6563743F28746869732E636C6F736528292C746869732E7365617263682E776964746828313029293A746869732E636F756E7453656C65637461626C65526573756C747328';
wwv_flow_api.g_varchar2_table(408) := '293E303F28746869732E7365617263682E7769647468283130292C746869732E726573697A6553656172636828292C746869732E6765744D6178696D756D53656C656374696F6E53697A6528293E302626746869732E76616C28292E6C656E6774683E3D';
wwv_flow_api.g_varchar2_table(409) := '746869732E6765744D6178696D756D53656C656374696F6E53697A6528292626746869732E757064617465526573756C7473282130292C746869732E706F736974696F6E44726F70646F776E2829293A28746869732E636C6F736528292C746869732E73';
wwv_flow_api.g_varchar2_table(410) := '65617263682E776964746828313029292C746869732E747269676765724368616E6765287B61646465643A617D292C622626622E6E6F466F6375737C7C746869732E666F6375735365617263682829297D2C63616E63656C3A66756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(411) := '746869732E636C6F736528292C746869732E666F63757353656172636828297D2C61646453656C656374656443686F6963653A66756E6374696F6E2863297B766172206A2C6B2C643D21632E6C6F636B65642C653D6128223C6C6920636C6173733D2773';
wwv_flow_api.g_varchar2_table(412) := '656C656374322D7365617263682D63686F696365273E202020203C6469763E3C2F6469763E202020203C6120687265663D272327206F6E636C69636B3D2772657475726E2066616C73653B2720636C6173733D2773656C656374322D7365617263682D63';
wwv_flow_api.g_varchar2_table(413) := '686F6963652D636C6F73652720746162696E6465783D272D31273E3C2F613E3C2F6C693E22292C663D6128223C6C6920636C6173733D2773656C656374322D7365617263682D63686F6963652073656C656374322D6C6F636B6564273E3C6469763E3C2F';
wwv_flow_api.g_varchar2_table(414) := '6469763E3C2F6C693E22292C673D643F653A662C683D746869732E69642863292C693D746869732E67657456616C28293B6A3D746869732E6F7074732E666F726D617453656C656374696F6E28632C672E66696E64282264697622292C746869732E6F70';
wwv_flow_api.g_varchar2_table(415) := '74732E6573636170654D61726B7570292C6A213D622626672E66696E64282264697622292E7265706C6163655769746828223C6469763E222B6A2B223C2F6469763E22292C6B3D746869732E6F7074732E666F726D617453656C656374696F6E43737343';
wwv_flow_api.g_varchar2_table(416) := '6C61737328632C672E66696E6428226469762229292C6B213D622626672E616464436C617373286B292C642626672E66696E6428222E73656C656374322D7365617263682D63686F6963652D636C6F736522292E6F6E28226D6F757365646F776E222C79';
wwv_flow_api.g_varchar2_table(417) := '292E6F6E2822636C69636B2064626C636C69636B222C746869732E62696E642866756E6374696F6E2862297B746869732E6973496E74657266616365456E61626C656428292626286128622E746172676574292E636C6F7365737428222E73656C656374';
wwv_flow_api.g_varchar2_table(418) := '322D7365617263682D63686F69636522292E666164654F7574282266617374222C746869732E62696E642866756E6374696F6E28297B746869732E756E73656C656374286128622E74617267657429292C746869732E73656C656374696F6E2E66696E64';
wwv_flow_api.g_varchar2_table(419) := '28222E73656C656374322D7365617263682D63686F6963652D666F63757322292E72656D6F7665436C617373282273656C656374322D7365617263682D63686F6963652D666F63757322292C746869732E636C6F736528292C746869732E666F63757353';
wwv_flow_api.g_varchar2_table(420) := '656172636828297D29292E6465717565756528292C79286229297D29292E6F6E2822666F637573222C746869732E62696E642866756E6374696F6E28297B746869732E6973496E74657266616365456E61626C65642829262628746869732E636F6E7461';
wwv_flow_api.g_varchar2_table(421) := '696E65722E616464436C617373282273656C656374322D636F6E7461696E65722D61637469766522292C746869732E64726F70646F776E2E616464436C617373282273656C656374322D64726F702D6163746976652229297D29292C672E646174612822';
wwv_flow_api.g_varchar2_table(422) := '73656C656374322D64617461222C63292C672E696E736572744265666F726528746869732E736561726368436F6E7461696E6572292C692E707573682868292C746869732E73657456616C2869297D2C756E73656C6563743A66756E6374696F6E286129';
wwv_flow_api.g_varchar2_table(423) := '7B76617220632C642C623D746869732E67657456616C28293B696628613D612E636C6F7365737428222E73656C656374322D7365617263682D63686F69636522292C303D3D3D612E6C656E677468297468726F7722496E76616C696420617267756D656E';
wwv_flow_api.g_varchar2_table(424) := '743A20222B612B222E204D757374206265202E73656C656374322D7365617263682D63686F696365223B633D612E64617461282273656C656374322D6461746122292C63262628643D6D28746869732E69642863292C62292C643E3D30262628622E7370';
wwv_flow_api.g_varchar2_table(425) := '6C69636528642C31292C746869732E73657456616C2862292C746869732E73656C6563742626746869732E706F737470726F63657373526573756C74732829292C612E72656D6F766528292C746869732E6F7074732E656C656D656E742E747269676765';
wwv_flow_api.g_varchar2_table(426) := '72287B747970653A2272656D6F766564222C76616C3A746869732E69642863292C63686F6963653A637D292C746869732E747269676765724368616E6765287B72656D6F7665643A637D29297D2C706F737470726F63657373526573756C74733A66756E';
wwv_flow_api.g_varchar2_table(427) := '6374696F6E28612C622C63297B76617220643D746869732E67657456616C28292C653D746869732E726573756C74732E66696E6428222E73656C656374322D726573756C7422292C663D746869732E726573756C74732E66696E6428222E73656C656374';
wwv_flow_api.g_varchar2_table(428) := '322D726573756C742D776974682D6368696C6472656E22292C673D746869733B652E65616368322866756E6374696F6E28612C62297B76617220633D672E696428622E64617461282273656C656374322D646174612229293B6D28632C64293E3D302626';
wwv_flow_api.g_varchar2_table(429) := '28622E616464436C617373282273656C656374322D73656C656374656422292C622E66696E6428222E73656C656374322D726573756C742D73656C65637461626C6522292E616464436C617373282273656C656374322D73656C65637465642229297D29';
wwv_flow_api.g_varchar2_table(430) := '2C662E65616368322866756E6374696F6E28612C62297B622E697328222E73656C656374322D726573756C742D73656C65637461626C6522297C7C30213D3D622E66696E6428222E73656C656374322D726573756C742D73656C65637461626C653A6E6F';
wwv_flow_api.g_varchar2_table(431) := '74282E73656C656374322D73656C65637465642922292E6C656E6774687C7C622E616464436C617373282273656C656374322D73656C656374656422297D292C2D313D3D746869732E686967686C696768742829262663213D3D21312626672E68696768';
wwv_flow_api.g_varchar2_table(432) := '6C696768742830292C21746869732E6F7074732E63726561746553656172636843686F696365262621652E66696C74657228222E73656C656374322D726573756C743A6E6F74282E73656C656374322D73656C65637465642922292E6C656E6774683E30';
wwv_flow_api.g_varchar2_table(433) := '26262821617C7C61262621612E6D6F72652626303D3D3D746869732E726573756C74732E66696E6428222E73656C656374322D6E6F2D726573756C747322292E6C656E6774682926264828672E6F7074732E666F726D61744E6F4D6174636865732C2266';
wwv_flow_api.g_varchar2_table(434) := '6F726D61744E6F4D61746368657322292626746869732E726573756C74732E617070656E6428223C6C6920636C6173733D2773656C656374322D6E6F2D726573756C7473273E222B672E6F7074732E666F726D61744E6F4D61746368657328672E736561';
wwv_flow_api.g_varchar2_table(435) := '7263682E76616C2829292B223C2F6C693E22297D2C6765744D617853656172636857696474683A66756E6374696F6E28297B72657475726E20746869732E73656C656374696F6E2E776964746828292D7128746869732E736561726368297D2C72657369';
wwv_flow_api.g_varchar2_table(436) := '7A655365617263683A66756E6374696F6E28297B76617220612C622C632C642C652C663D7128746869732E736561726368293B613D4128746869732E736561726368292B31302C623D746869732E7365617263682E6F666673657428292E6C6566742C63';
wwv_flow_api.g_varchar2_table(437) := '3D746869732E73656C656374696F6E2E776964746828292C643D746869732E73656C656374696F6E2E6F666673657428292E6C6566742C653D632D28622D64292D662C613E65262628653D632D66292C34303E65262628653D632D66292C303E3D652626';
wwv_flow_api.g_varchar2_table(438) := '28653D61292C746869732E7365617263682E77696474682865297D2C67657456616C3A66756E6374696F6E28297B76617220613B72657475726E20746869732E73656C6563743F28613D746869732E73656C6563742E76616C28292C6E756C6C3D3D3D61';
wwv_flow_api.g_varchar2_table(439) := '3F5B5D3A61293A28613D746869732E6F7074732E656C656D656E742E76616C28292C7028612C746869732E6F7074732E736570617261746F7229297D2C73657456616C3A66756E6374696F6E2862297B76617220633B746869732E73656C6563743F7468';
wwv_flow_api.g_varchar2_table(440) := '69732E73656C6563742E76616C2862293A28633D5B5D2C612862292E656163682866756E6374696F6E28297B303E6D28746869732C63292626632E707573682874686973297D292C746869732E6F7074732E656C656D656E742E76616C28303D3D3D632E';
wwv_flow_api.g_varchar2_table(441) := '6C656E6774683F22223A632E6A6F696E28746869732E6F7074732E736570617261746F722929297D2C6275696C644368616E676544657461696C733A66756E6374696F6E28612C62297B666F722876617220623D622E736C6963652830292C613D612E73';
wwv_flow_api.g_varchar2_table(442) := '6C6963652830292C633D303B622E6C656E6774683E633B632B2B29666F722876617220643D303B612E6C656E6774683E643B642B2B296F28746869732E6F7074732E696428625B635D292C746869732E6F7074732E696428615B645D2929262628622E73';
wwv_flow_api.g_varchar2_table(443) := '706C69636528632C31292C632D2D2C612E73706C69636528642C31292C642D2D293B72657475726E7B61646465643A622C72656D6F7665643A617D7D2C76616C3A66756E6374696F6E28632C64297B76617220652C663D746869733B696628303D3D3D61';
wwv_flow_api.g_varchar2_table(444) := '7267756D656E74732E6C656E6774682972657475726E20746869732E67657456616C28293B696628653D746869732E6461746128292C652E6C656E6774687C7C28653D5B5D292C2163262630213D3D632972657475726E20746869732E6F7074732E656C';
wwv_flow_api.g_varchar2_table(445) := '656D656E742E76616C282222292C746869732E75706461746553656C656374696F6E285B5D292C746869732E636C65617253656172636828292C642626746869732E747269676765724368616E6765287B61646465643A746869732E6461746128292C72';
wwv_flow_api.g_varchar2_table(446) := '656D6F7665643A657D292C623B696628746869732E73657456616C2863292C746869732E73656C65637429746869732E6F7074732E696E697453656C656374696F6E28746869732E73656C6563742C746869732E62696E6428746869732E757064617465';
wwv_flow_api.g_varchar2_table(447) := '53656C656374696F6E29292C642626746869732E747269676765724368616E676528746869732E6275696C644368616E676544657461696C7328652C746869732E64617461282929293B656C73657B696628746869732E6F7074732E696E697453656C65';
wwv_flow_api.g_varchar2_table(448) := '6374696F6E3D3D3D62297468726F77204572726F72282276616C28292063616E6E6F742062652063616C6C656420696620696E697453656C656374696F6E2829206973206E6F7420646566696E656422293B746869732E6F7074732E696E697453656C65';
wwv_flow_api.g_varchar2_table(449) := '6374696F6E28746869732E6F7074732E656C656D656E742C66756E6374696F6E2862297B76617220633D612E6D617028622C662E6964293B662E73657456616C2863292C662E75706461746553656C656374696F6E2862292C662E636C65617253656172';
wwv_flow_api.g_varchar2_table(450) := '636828292C642626662E747269676765724368616E676528746869732E6275696C644368616E676544657461696C7328652C746869732E64617461282929297D297D746869732E636C65617253656172636828297D2C6F6E536F727453746172743A6675';
wwv_flow_api.g_varchar2_table(451) := '6E6374696F6E28297B696628746869732E73656C656374297468726F77204572726F722822536F7274696E67206F6620656C656D656E7473206973206E6F7420737570706F72746564207768656E20617474616368656420746F203C73656C6563743E2E';
wwv_flow_api.g_varchar2_table(452) := '2041747461636820746F203C696E70757420747970653D2768696464656E272F3E20696E73746561642E22293B746869732E7365617263682E77696474682830292C746869732E736561726368436F6E7461696E65722E6869646528297D2C6F6E536F72';
wwv_flow_api.g_varchar2_table(453) := '74456E643A66756E6374696F6E28297B76617220623D5B5D2C633D746869733B746869732E736561726368436F6E7461696E65722E73686F7728292C746869732E736561726368436F6E7461696E65722E617070656E64546F28746869732E7365617263';
wwv_flow_api.g_varchar2_table(454) := '68436F6E7461696E65722E706172656E742829292C746869732E726573697A6553656172636828292C746869732E73656C656374696F6E2E66696E6428222E73656C656374322D7365617263682D63686F69636522292E656163682866756E6374696F6E';
wwv_flow_api.g_varchar2_table(455) := '28297B622E7075736828632E6F7074732E696428612874686973292E64617461282273656C656374322D64617461222929297D292C746869732E73657456616C2862292C746869732E747269676765724368616E676528297D2C646174613A66756E6374';
wwv_flow_api.g_varchar2_table(456) := '696F6E28632C64297B76617220662C672C653D746869733B72657475726E20303D3D3D617267756D656E74732E6C656E6774683F746869732E73656C656374696F6E2E66696E6428222E73656C656374322D7365617263682D63686F69636522292E6D61';
wwv_flow_api.g_varchar2_table(457) := '702866756E6374696F6E28297B72657475726E20612874686973292E64617461282273656C656374322D6461746122297D292E67657428293A28673D746869732E6461746128292C637C7C28633D5B5D292C663D612E6D617028632C66756E6374696F6E';
wwv_flow_api.g_varchar2_table(458) := '2861297B72657475726E20652E6F7074732E69642861297D292C746869732E73657456616C2866292C746869732E75706461746553656C656374696F6E2863292C746869732E636C65617253656172636828292C642626746869732E7472696767657243';
wwv_flow_api.g_varchar2_table(459) := '68616E676528746869732E6275696C644368616E676544657461696C7328672C746869732E64617461282929292C62297D7D292C612E666E2E73656C656374323D66756E6374696F6E28297B76617220642C672C682C692C6A2C633D41727261792E7072';
wwv_flow_api.g_varchar2_table(460) := '6F746F747970652E736C6963652E63616C6C28617267756D656E74732C30292C6B3D5B2276616C222C2264657374726F79222C226F70656E6564222C226F70656E222C22636C6F7365222C22666F637573222C226973466F6375736564222C22636F6E74';
wwv_flow_api.g_varchar2_table(461) := '61696E6572222C2264726F70646F776E222C226F6E536F72745374617274222C226F6E536F7274456E64222C22656E61626C65222C22726561646F6E6C79222C22706F736974696F6E44726F70646F776E222C2264617461222C22736561726368225D2C';
wwv_flow_api.g_varchar2_table(462) := '6C3D5B2276616C222C226F70656E6564222C226973466F6375736564222C22636F6E7461696E6572222C2264617461225D2C6E3D7B7365617263683A2265787465726E616C536561726368227D3B72657475726E20746869732E656163682866756E6374';
wwv_flow_api.g_varchar2_table(463) := '696F6E28297B696628303D3D3D632E6C656E6774687C7C226F626A656374223D3D747970656F6620635B305D29643D303D3D3D632E6C656E6774683F7B7D3A612E657874656E64287B7D2C635B305D292C642E656C656D656E743D612874686973292C22';
wwv_flow_api.g_varchar2_table(464) := '73656C656374223D3D3D642E656C656D656E742E6765742830292E7461674E616D652E746F4C6F7765724361736528293F6A3D642E656C656D656E742E70726F7028226D756C7469706C6522293A286A3D642E6D756C7469706C657C7C21312C22746167';
wwv_flow_api.g_varchar2_table(465) := '7322696E2064262628642E6D756C7469706C653D6A3D213029292C673D6A3F6E657720663A6E657720652C672E696E69742864293B656C73657B69662822737472696E6722213D747970656F6620635B305D297468726F7722496E76616C696420617267';
wwv_flow_api.g_varchar2_table(466) := '756D656E747320746F2073656C6563743220706C7567696E3A20222B633B696628303E6D28635B305D2C6B29297468726F7722556E6B6E6F776E206D6574686F643A20222B635B305D3B696628693D622C673D612874686973292E64617461282273656C';
wwv_flow_api.g_varchar2_table(467) := '6563743222292C673D3D3D622972657475726E3B696628683D635B305D2C22636F6E7461696E6572223D3D3D683F693D672E636F6E7461696E65723A2264726F70646F776E223D3D3D683F693D672E64726F70646F776E3A286E5B685D262628683D6E5B';
wwv_flow_api.g_varchar2_table(468) := '685D292C693D675B685D2E6170706C7928672C632E736C69636528312929292C6D28635B305D2C6C293E3D302972657475726E21317D7D292C693D3D3D623F746869733A697D2C612E666E2E73656C656374322E64656661756C74733D7B77696474683A';
wwv_flow_api.g_varchar2_table(469) := '22636F7079222C6C6F61644D6F726550616464696E673A302C636C6F73654F6E53656C6563743A21302C6F70656E4F6E456E7465723A21302C636F6E7461696E65724373733A7B7D2C64726F70646F776E4373733A7B7D2C636F6E7461696E6572437373';
wwv_flow_api.g_varchar2_table(470) := '436C6173733A22222C64726F70646F776E437373436C6173733A22222C666F726D6174526573756C743A66756E6374696F6E28612C622C632C64297B76617220653D5B5D3B72657475726E204328612E746578742C632E7465726D2C652C64292C652E6A';
wwv_flow_api.g_varchar2_table(471) := '6F696E282222297D2C666F726D617453656C656374696F6E3A66756E6374696F6E28612C632C64297B72657475726E20613F6428612E74657874293A627D2C736F7274526573756C74733A66756E6374696F6E2861297B72657475726E20617D2C666F72';
wwv_flow_api.g_varchar2_table(472) := '6D6174526573756C74437373436C6173733A66756E6374696F6E28297B72657475726E20627D2C666F726D617453656C656374696F6E437373436C6173733A66756E6374696F6E28297B72657475726E20627D2C666F726D61744E6F4D6174636865733A';
wwv_flow_api.g_varchar2_table(473) := '66756E6374696F6E28297B72657475726E224E6F206D61746368657320666F756E64227D2C666F726D6174496E707574546F6F53686F72743A66756E6374696F6E28612C62297B76617220633D622D612E6C656E6774683B72657475726E22506C656173';
wwv_flow_api.g_varchar2_table(474) := '6520656E74657220222B632B22206D6F726520636861726163746572222B28313D3D633F22223A227322297D2C666F726D6174496E707574546F6F4C6F6E673A66756E6374696F6E28612C62297B76617220633D612E6C656E6774682D623B7265747572';
wwv_flow_api.g_varchar2_table(475) := '6E22506C656173652064656C65746520222B632B2220636861726163746572222B28313D3D633F22223A227322297D2C666F726D617453656C656374696F6E546F6F4269673A66756E6374696F6E2861297B72657475726E22596F752063616E206F6E6C';
wwv_flow_api.g_varchar2_table(476) := '792073656C65637420222B612B22206974656D222B28313D3D613F22223A227322297D2C666F726D61744C6F61644D6F72653A66756E6374696F6E28297B72657475726E224C6F6164696E67206D6F726520726573756C74732E2E2E227D2C666F726D61';
wwv_flow_api.g_varchar2_table(477) := '74536561726368696E673A66756E6374696F6E28297B72657475726E22536561726368696E672E2E2E227D2C6D696E696D756D526573756C7473466F725365617263683A302C6D696E696D756D496E7075744C656E6774683A302C6D6178696D756D496E';
wwv_flow_api.g_varchar2_table(478) := '7075744C656E6774683A6E756C6C2C6D6178696D756D53656C656374696F6E53697A653A302C69643A66756E6374696F6E2861297B72657475726E20612E69647D2C6D6174636865723A66756E6374696F6E28612C62297B72657475726E2822222B6229';
wwv_flow_api.g_varchar2_table(479) := '2E746F55707065724361736528292E696E6465784F66282822222B61292E746F5570706572436173652829293E3D307D2C736570617261746F723A222C222C746F6B656E536570617261746F72733A5B5D2C746F6B656E697A65723A4B2C657363617065';
wwv_flow_api.g_varchar2_table(480) := '4D61726B75703A442C626C75724F6E4368616E67653A21312C73656C6563744F6E426C75723A21312C6164617074436F6E7461696E6572437373436C6173733A66756E6374696F6E2861297B72657475726E20617D2C616461707444726F70646F776E43';
wwv_flow_api.g_varchar2_table(481) := '7373436C6173733A66756E6374696F6E28297B72657475726E206E756C6C7D7D2C612E666E2E73656C656374322E616A617844656661756C74733D7B7472616E73706F72743A612E616A61782C706172616D733A7B747970653A22474554222C63616368';
wwv_flow_api.g_varchar2_table(482) := '653A21312C64617461547970653A226A736F6E227D7D2C77696E646F772E53656C656374323D7B71756572793A7B616A61783A452C6C6F63616C3A462C746167733A477D2C7574696C3A7B6465626F756E63653A742C6D61726B4D617463683A432C6573';
wwv_flow_api.g_varchar2_table(483) := '636170654D61726B75703A447D2C22636C617373223A7B226162737472616374223A642C73696E676C653A652C6D756C74693A667D7D7D7D286A5175657279293B';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 24264139602373120573 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_file_name => 'select2.min.js'
 ,p_mime_type => 'text/javascript'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D494844520000003C000000280806000000A2BB99FF0000022C4944415478DAEDD9CF4B14611CC7F1B5084A8C85D62E625D2A28C9880E1176A964D60DA23C14FDA01F5004FD038621520771B754E8D0A148042308BC471411';
wwv_flow_api.g_varchar2_table(2) := '79ED52D8AFA58B9485814874304C983EBD85EFE139B82C6D29DBD779E07598D9857DDE3BCFCC0EB32949CB4A12BC2C83FFC7512814EEE358B01DE11E56B80B26EA12844F68C24614210C7B0C6EC67B089398802CFAA0D7255D8FD7901947638AE135780B';
wwv_flow_api.g_varchar2_table(3) := '3E40E633B6BB0C26AC0593C1321E0B96F799250FE643D3C82C62F0450813D88075C1393D543698379DC4299C089C45BAC2090DE3F1221FE50BD8116C6FC6795BD26583AF4308BDC39A0A26B20BBF2044A9A51FE5836DA2239099C3CE0ABFF951C8BCC5AA';
wwv_flow_api.g_varchar2_table(4) := '6A0DDE8419080315C67640080D5465B04DB81FDFFFE2DCBD863BB81DE8FBD747399BCDD66208A7837D873188CC9F04AFC7BE54950FA23A20C468430B66203C74F73B4C54039E4198C50F08CFD1ECF24E2B8AA21AE25E40A688D56E6F2D89DB8F2F909946';
wwv_flow_api.g_varchar2_table(5) := 'CE65306147F03358C68F82E5DDED31F8288497A8C34A8C42E8F1BAA45BD1106C6770C0D9922E3F92E02438094E82ABE191CE5A34CECBE7F335AE8389ECC214645EA1DD65306177218CE3326E41E6B8AB608272109E221DECDF8D6F9846BDA7E041C4D8BA';
wwv_flow_api.g_varchar2_table(6) := 'C06B5720E43C058F60D62E52A58E7EBBA7E07E08874A3C068EB1D75370138429B4D9BE3A7442F8E8F12A7D0E32457C854C8C1B1E7F87F7E001DE600C57D157EA31B0E77F0F7B217313B5AE832DBA1B73105ADD075BF413C4D8B650F06F7CE77D1E7108BF';
wwv_flow_api.g_varchar2_table(7) := 'D90000000049454E44AE426082';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 24264140512588121527 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_file_name => 'select2.png'
 ,p_mime_type => 'image/png'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D4948445200000078000000500806000000D29BB189000003144944415478DAED9DB16E13411040234111098A43A4051D257FE1025C50DD27A4A2F617208BCA1220512141759474FE04FF81AF44C2082B052D6E5C9824B78C';
wwv_flow_api.g_varchar2_table(2) := 'A58D345ADD66EF84386EEC77D22B925D29F2BDECECCCECE572E29C8303E6E86F008201C1806068C9CD359BCDCA3D27914BCF41B01DB438E7092537CE41B011B4B888E4E81C04DB13AC29B55C041B252171A5BF2644DB4FB25C0A922C7B82BB482E29938C';
wwv_flow_api.g_varchar2_table(3) := '115EB784E5950C5307B3821D37953D18C8A2813A18E8647522D6809FEE6918A2177D002545AE3E741E0C739AD4227CAC05D792F57F10BC503F7F110C731EDC42F0A883E051CF356321B88002C1DDF787790BB97399DA6738CB22D1652D64086E87DEE736';
wwv_flow_api.g_varchar2_table(4) := '31B97E2CEF59F0547011A608367A437562952047700BF4150B897DEE793AB14AB0407037C1B1846BD4A3E020B14A5220B87B59320F13ABFE04772FDB2CD5C1E3F1B814A275B09EF34F04EB84CB935377FE355A9CF384921BE6C4251F7D6B7068687111C9';
wwv_flow_api.g_varchar2_table(5) := 'B1391C361814AC29B55C041B25217115F93EE7C1468887E1383CD1614C7017C93C93658DF0BA252CF354252B18C1ECC140160DD4C140270B3AF7A209D1019C26016FD90104038201C1806040F0D173F43700C1806040302018100C081EF0FB4332612254';
wwv_flow_api.g_varchar2_table(6) := '82136AC5D28F656AFE1E041B792561D1F047F37580137E0905820DA0E49E0B7520F55AB8F25C37883E47F0B0D12B57AFD8DFC277E1A5F0587824BC1256C22EF84528103C60FC9EBB51C2B6C27BE1B4617F7E287CF2736ACF46C8103C5CC113256B27BC4B';
wwv_flow_api.g_varchar2_table(7) := 'BCD4EC8EF041B8542B7982E0E10A5EAAFDF69B704FF98C493E152E94E00AC10325D87B27CA634AF26B9D782178E082BDAC271D043F17AE106C4BF0530413A26F04CF08D106085A925F85FB2DE49E09174AF012C1C32E937483E3A3703791417FA64CB2D7';
wwv_flow_api.g_varchar2_table(8) := 'E8A83D5B2FF0AC41EE03E18BB055727742A6A62178A0AD4ADD7EBC147E086F8467C20BE1ADF053AF5C4589600B870DE14143FCB0C1355022D8D67161AD08C5EE6292116CE7C07FD920B8F2639950C62423F8F0FFAD5D8960F382D392116C5D705A728560';
wwv_flow_api.g_varchar2_table(9) := 'D382D392116C5C702819C1F649F5A92B25788A6040F031F0073126286D57A6B1DB0000000049454E44AE426082';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 24264141700886058095 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 24264049604131094730 + wwv_flow_api.g_id_offset
 ,p_file_name => 'select2x2.png'
 ,p_mime_type => 'image/png'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

commit;
begin
execute immediate 'begin sys.dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
set define on
prompt  ...done