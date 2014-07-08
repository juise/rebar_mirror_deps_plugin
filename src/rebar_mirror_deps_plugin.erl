-module(rebar_mirror_deps_plugin).

-export(['pre_get-deps'/2,
         'post_get-deps'/2]).

'pre_get-deps'(Config, _AppFile) ->
    process_deps(Config, fun get_dep_mirror/4, get_dep_mirror).

'post_get-deps'(Config, _AppFile) ->
    process_deps(Config, fun upd_dep_mirror/4, upd_dep_mirror).

process_deps(Config, Fun, Op) ->
    Cmd = rebar_config:get(Config, Op, []),
    Deps = rebar_config:get_local(Config, deps, []),
    DepsDir = rebar_config:get_xconf(Config, deps_dir),
    BaseDir = rebar_config:get_xconf(Config, base_dir),
    {ok, rebar_config:set_xconf(Config, rebar_deps, process_deps_ll(Fun, Cmd, Deps, DepsDir, BaseDir))}.

process_deps_ll(Fun, Cmd, Deps, DepsDir, BaseDir) ->
    Dir = prepare_dir(DepsDir, BaseDir),
    lists:map(
        fun({App, _Vsn, {_VCS, _Url, Rev}}) ->
            File = prepare_file(App, Rev),
            try
                Fun(App, File, Dir, Cmd)
            catch
                _C:_R -> pass
            end,
            filename:join(Dir, atom_to_list(App))
        end, Deps).

get_dep_mirror(_App, File, Dir, Cmd) ->
        rebar_utils:sh(lists:flatten(io_lib:format(Cmd, [File, File])), [{use_stdout, false}, {cd, Dir}]),
        rebar_utils:sh("tar -xzf " ++ File, [{use_stdout, false}, {cd, Dir}]).

upd_dep_mirror(App, File, Dir, Cmd) ->
        rebar_utils:sh("tar -czf " ++ File ++ " " ++ atom_to_list(App), [{use_stdout, false}, {cd, Dir}]),
        rebar_utils:sh(lists:flatten(io_lib:format(Cmd, [File, File])), [{use_stdout, false}, {cd, Dir}]).

prepare_dir(DepsDir, BaseDir) ->
    Dir = filename:join(BaseDir, DepsDir),
    file:make_dir(Dir),
    Dir.

prepare_file(App, Rev) ->
    MD5 = [io_lib:format("~2.16.0b", [D]) || <<D>> <= erlang:md5(erlang:term_to_binary(Rev))],
    lists:flatten([atom_to_list(App), "_", MD5, ".tgz"]).

