using BinDeps

@BinDeps.setup

mongodb = binary_dependency("mongod")

provides(Sources, {
    URI("http://github.com/mongodb/mongo/archive/r2.4.11.tar.gz") => mongodb
    })

provides(
    BuildProcess,
    Autotools(bintarget = "mongod"),
    mongodb,
    os = :Unix
    )
            
@osx_only begin
    using Homebrew
    provides(Homebrew.HB, {"mongodb" => mongodb})
end

@BinDeps.install [:mongodb => :mongodb]
