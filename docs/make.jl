using Documenter, ElectronDisplay

makedocs(
	modules=[ElectronDisplay],
	sitename="ElectronDisplay.jl",
	analytics="UA-132838790-1",
	pages=[
        "Introduction" => "index.md"
    ]
)

deploydocs(
    repo="github.com/queryverse/ElectronDisplay.jl.git"
)
