Docker container for use with VSCode Remote:
* https://code.visualstudio.com/docs/remote/containers

Built image includes
* Debian (currently stretch/9)
* Common build dependencies
* Common build and developer tools
* Node JS LTS (currently 10) including npm and yarn
* Azure CLI, Azure function tools
* PowerShell Core, Az library
* eslint, tslint, and typescript

To build
```
# ensure you have the needed dependencies
bash script/bootstrap.sh
# create image
bash script/build.sh
# publish image
bash script/publish.sh
```

This source code is in the public domain.
The author disclaims copyright to this source code.  In place of
a legal notice, here is a blessing:
```
   May you do good and not evil.
   May you find forgiveness for yourself and forgive others.
   May you share freely, never taking more than you give.
```
