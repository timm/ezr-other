SHELL     := bash 
MAKEFLAGS += --warn-undefined-variables
.SILENT: 

help          :  ## show help
		awk 'BEGIN {FS = ":.*?## "; print "\nmake [WHAT]" } \
				/^[^[:space:]].*##/ {printf "   \033[36m%-10s\033[0m : %s\n", $$1, $$2} \
				' $(MAKEFILE_LIST)

saved         : ## save and push to main branch 
		read -p "commit msg> " x; y=$${x:-saved}; git commit -am "$$y}"; git push;  git status; echo "$$y, saved!"
	 

 
name:
		read -p "word> " w; figlet -f mini -W $$w  | gawk '$$0 {print "#        "$$0}' |pbcopy
	
~/tmp/%.html : %.lua
		pycco -d ~/tmp $^
		echo 'p {text-align:right;}' >> ~/tmp/pycco.css


~/tmp/%.pdf: %.lua  ## make pdf
		mkdir -p ~/tmp
		echo "a2ps: $^ -> $@" 
		a2ps                          \
			-qBr                         \
			--chars-per-line 90           \
			--file-align=fill              \
			--line-numbers=1                \
			--borders=no                     \
			--pro=color                       \
			--columns  3                       \
			-M letter                           \
			--pretty-print="../etc/lua.ssh"   \
			-o ~/tmp/$^.ps $^ ;               \
		ps2pdf ~/tmp/$^.ps $@ ;  rm ~/tmp/$^.ps; \
	  open $@


PY=$(wildcard *.py)  
LUA=$(wildcard *.lua)
docs: 
		echo "docs..."
		mkdir -p ~/tmp
		$(MAKE) -B $(addprefix ~/tmp/, $(PY:.py=.pdf))  $(addprefix ~/tmp/, $(PY:.py=.html))
		$(MAKE) -B $(addprefix ~/tmp/, $(LUA:.lua=.pdf))  $(addprefix ~/tmp/, $(LUA:.lua=.html)