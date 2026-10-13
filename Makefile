default : build

build :
	hugo --gc --minify

build-staging :
	hugo --gc -e staging --destination public-staging

serve :
	hugo server --buildDrafts

clean :
	rm -rf public/ public-staging/ resources/_gen/

.PHONY: default build build-staging serve clean
