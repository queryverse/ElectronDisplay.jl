using Documenter, ElectronDisplay

makedocs(
	modules=[ElectronDisplay],
	sitename="ElectronDisplay.jl",
	format = Documenter.HTML(analytics = "UA-132838790-1"),
	warnonly = [:missing_docs],
	pages=[
        "Introduction" => "index.md"
    ]
)

deploydocs(
    repo="github.com/queryverse/ElectronDisplay.jl.git"
)
