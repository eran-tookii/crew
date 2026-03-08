.PHONY: release

release:
ifndef V
	$(error Usage: make release V=1.3.0)
endif
	sed -i '' 's/"version": "[^"]*"/"version": "$(V)"/' .claude-plugin/plugin.json .claude-plugin/marketplace.json
	git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
	git commit -m "chore: bump version to $(V)"
	git push
	gh release create v$(V) --title "v$(V)" --generate-notes
