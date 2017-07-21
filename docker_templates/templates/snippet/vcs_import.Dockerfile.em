@[if 'vcs' in locals()]@
@[if vcs]@
@[for i, (imports_name, imports) in enumerate(vcs.items())]@
RUN wget @(imports['repos']) \
    && vcs import @(ws) < @(imports['repos'].split('/')[-1])
@[end for]@
@[end if]@
@[end if]@
