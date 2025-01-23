.PHONY: prepare_tools clean

prepare_tools:
	@if [ ! -d "nethermind" ]; then \
		git clone https://github.com/NethermindEth/nethermind nethermind; \
	else \
		echo "nethermind directory exists, updating..."; \
		cd nethermind && git pull; \
	fi
	dotnet build ./nethermind/tools/Nethermind.Tools.Kute -c Release --property WarningLevel=0

clean:
	rm -rf nethermind