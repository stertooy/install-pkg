GHA_ArchiveFormats := [ ".tar.gz", ".tar.bz2", ".zip" ]

GHA_InstallPackage := function ( string, args... )
    local version;
    version := true;
    if Length( args ) = 1 then
        version := args[1];
    fi;
    NormalizeWhitespace( string );
    if ForAny( GHA_ArchiveFormats, ext -> EndsWith( string, ext ) ) then
        return GHA_InstallPackageFromArchive( string );
    elif EndsWith( string, ".git" ) then
        return GHA_InstallPackageFromGit( string, interactive );
    elif EndsWith( string, "PackageInfo.g" ) then
        return GHA_InstallPackageFromInfo( string );
    fi;
    # TODO: install from repo if string contains slash?
    return InstallPackageFromName( string, version );
end;

