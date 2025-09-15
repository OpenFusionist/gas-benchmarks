.PHONY: prepare_tools clean

prepare_tools:
	git clone https://github.com/NethermindEth/nethermind nethermind
	# use jul 26, 2025 commit
	cd nethermind && git checkout 5aa6d6a2b890540f1f978b7dda987d7d88061eed && cd ..
	dotnet build ./nethermind/tools/Nethermind.Tools.Kute -c Release --property WarningLevel=0
clean:
	rm -rf nethermind