rebar_mirror_deps_plugin
========================

## Installation ##

Add the following to your top-level rebar.config (by example with [rebar_lock_deps_plugin](https://github.com/seth/rebar_lock_deps_plugin)):

    %% Plugin dependency
    {deps, [
        {rebar_lock_deps_plugin, ".*",
            {git, "git://github.com/seth/rebar_lock_deps_plugin.git", {branch, "master"}}},
        {rebar_mirror_deps_plugin, ".*",
            {git, "git://github.com/juise/rebar_mirror_deps_plugin.git", {branch, "master"}}}
    ]}.

    %% Plugin usage
    {plugins, [rebar_lock_deps_plugin, rebar_mirror_deps_plugin]}.

    %% rebar_mirror_deps_plugin hooks
    {get_dep_mirror, "cp /tmp/~s ~s"}.
    {upd_dep_mirror, "cp ~s /tmp/~s"}.
