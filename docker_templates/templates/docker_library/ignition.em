Maintainers: @(',\n             '.join(maintainers))
GitRepo: @(repo_url)
@[for release_name, release_data in release_names.items()]@

################################################################################
# Release: @(release_name)

@[    for os_name, os_data in release_data['os_names'].items()]@
@[        for os_code_name, os_code_data in os_data['os_code_names'].items()]@
@[            if os_code_data['tag_names'] is not None]@
########################################
# Distro: @(os_name):@(os_code_name)

@[                for tag_name, tag_data in os_code_data['tag_names'].items()]@
Tags: @(', '.join(tag_data['Tags']))
Architectures: @(', '.join(tag_data['Architectures']))
GitCommit: @(tag_data['GitCommit'])
Directory: @(tag_data['Directory'])

@[                end for]@
@[            end if]@
@[        end for]@
@[    end for]@
@[end for]@
