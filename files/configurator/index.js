#!/usr/bin/env node

const fs = require( 'fs' );
const prompt = require( 'prompt' );

var config = require( './../gitlab-webhook-publish/config/local.json' );

var man = 'Usage : \n' +
    '     gitlab_token \n' +
    '     gitlab_admin_login \n' +
    '     gitlab_admin_password \n' +
    '     npm_login \n' +
    '     npm_password \n' +
    '     npm_email \n';

prompt.start();

prompt.get( ['gitlab_token', 'gitlab_admin_login', 'gitlab_admin_password', 'npm_login', 'npm_password', 'npm_email'], function ( err, result ) {

    if ( err )
        throw err;

    var values = [result.gitlab_token, result.gitlab_admin_login, result.gitlab_admin_password, result.npm_login, result.npm_password, result.npm_email];

    if ( values.indexOf( undefined ) !== -1 )
        throw new Error( man );

    else {

        config.gitlab.token = result.gitlab_token;
        config.gitlab.admin_login = result.gitlab_admin_login;
        config.gitlab.admin_password = result.gitlab_admin_password;

        config.npm_registry.login = result.npm_login;
        config.npm_registry.password = result.npm_password;
        config.npm_registry.email = result.npm_email;

        fs.writeFileSync( './../gitlab-webhook-publish/config/local.json', JSON.stringify( config, null, 2 ) );

        console.log( 'Config updated with these values:' );
        console.log( '  gitlab_token: ' + result.gitlab_token );
        console.log( '  gitlab_admin_login: ' + result.gitlab_admin_login );
        console.log( '  gitlab_admin_password: ' + result.gitlab_admin_password );
        console.log( '  npm_login: ' + result.npm_login );
        console.log( '  npm_password: ' + result.npm_password );
        console.log( '  npm_email: ' + result.npm_email );
        console.log( 'You have to restart the system to apply modifications.' );

        process.exit();

    }

} );