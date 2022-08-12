#!/bin/bash
clear
cd ../../../clientRepo/shop-angular-cloudfront
npm install
if [[ -e  ./dist/client-app.zip ]]
then
	rm ./dist/client-app.zip
fi
npm run build
zip -r ./dist/client-app.zip  ./dist/
