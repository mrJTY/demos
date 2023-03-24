clean:
	rm *.zip

zip: clean pdf
	zip -r z5232245-as2.zip bin/ contracts/ migrations/ test/ *.bazel *.json *.md *.js *.pdf Makefile

pdf:
	./node_modules/.bin/markdown-pdf README.md
