const express = require('express');
const proxy = require('http-proxy-middleware');

const PORT = 3000;
const HOST = '0.0.0.0';

// if https is requested
var httpsRouter = function(req) {   
    retVal = 'https://' + req.originalUrl.replace('/https/', '');
    return retVal
};

// if http is requested
var httpRouter = function(req) {
    retVal = 'http://' + req.originalUrl.replace('/http/', '');
    return retVal
};

// rewrite url
var httpsRewrite = function (path, req) {
    retVal = path.replace('https/'+(path.split('/')[2]), '');
    retVal = retVal.replace('//', '/');
    return retVal;
}

// rewrite url
var httpRewrite = function (path, req) {
    retVal = path.replace('http/'+(path.split('/')[2]), '');
    retVal = retVal.replace('//', '/');
    return retVal;
}

var app = express();
app.use('/https', proxy(
        {
            target: 'https://test.de',
            changeOrigin: true,
            prependPath: false,
            pathRewrite: httpsRewrite,
            router: httpsRouter
        }
    )
);

app.use('/http', proxy(
        {
            target: 'http://test.de',
            changeOrigin: true,
            prependPath: false,
            pathRewrite: httpRewrite,
            router: httpRouter
        }
    )
);

app.listen(PORT);
console.log(`Running on http://${HOST}:${PORT}`);