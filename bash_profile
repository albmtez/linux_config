# Dev environment configuration

# Dev base dir
export DEV_BASE=$HOME/dev

# Git config
export GIT_HOME=$DEV_BASE/git/default
export PATH=$GIT_HOME/bin:$PATH

# Python config
export PYTHONPATH=$DEV_BASE/python/default
export PATH=$PYTHONPATH/bin:$PATH

# Go config
export GOROOT=$DEV_BASE/go/default
export GOPATH=$DEV_BASE/code/go
export PATH=$GOROOT/bin:$PATH
