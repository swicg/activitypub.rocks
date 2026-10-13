default : build

build :
	hugo --gc --minify

build-staging :
	hugo --gc -e staging --destination public-staging

hugo-server :
	hugo server --buildDrafts --renderToMemory

clean :
	rm -rf public/ public-staging/ resources/_gen/

.PHONY: default build build-staging hugo-server clean
