# Generic Makefile

You know, for `make`. It is usefull for Symfony/Docker/Npm projects for the most frequently used commands. Don`t hasitate give me some advices about it. Cheers

## Help 

Run `make` without params

## Configuration

Disable docker support

```bash
export APP_DOCKER=0
```

## Installation

```
cd /path/to/your/repository
git submodule add git@github.com:hubertinio/makefile-php-docker-npm.git [your-path]
git submodule update --init --recursive

git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   .gitmodules
        new file:   [your-path]

git add .gitmodules [your-path]
git commit -m "Added hubertinio/makefile-php-docker-npm as a submodule in [your-path]"
```

```
cd /path/to/your/repository
ln -s [your-path]/Makefile Makefile
echo Makefile >> .gitignore
```

## Update 

```
git submodule update --init --recursive
```

## Deps

* [composer](https://getcomposer.org/download/)
* [symfony-cmd](https://github.com/symfony-cli/symfony-cli)
* (optional) [webpack-bundle-analyzer](https://www.npmjs.com/package/webpack-bundle-analyzer)
* (optional) [hautelook/alice-bundle](https://github.com/theofidry/AliceBundle)

