var util = require('util'),
    http = require('http'),
    httpProxy = require('http-proxy');
cluster = require('cluster');

var log4js = require('log4js');
log4js.configure({
  "appenders": [
      {
          type: "console"
        , category: "serverlog"
      },
      {
          "type": "file",
          "filename": "/www/target/nodejs/logs/thumbnail.log",
          "maxLogSize": 1024*1024*1024,
          "backups": 3,
          "category": "serverlog"
      }
  ]
});


var logger = log4js.getLogger('serverlog');
logger.setLevel('DEBUG');


/**
 系统配置。
 **/
var config = {
    numCPUs: 2,
    serverPort: 9600,
	imageServerUrl:"http://10.5.7.72:1080/",
	password:"mysoft.cloud"
};

var crypto = require('crypto');
/**
 *  * aes加密
 *   * @param data
 *    * @param secretKey
/**
 *  * aes加密
 *   * @param data
 *    * @param secretKey
 *     */
aesEncrypt = function(data, secretKey) {
        var cipher = crypto.createCipher('aes-128-ecb',secretKey, "");
        return cipher.update(data,'utf8','base64') + cipher.final('base64');
}

/**
 *  * aes解密
 *   * @param data
 *    * @param secretKey
 *     * @returns {*}
 *      */
aesDecrypt = function(data, secretKey) {
	try {
        	var cipher = crypto.createDecipher('aes-128-ecb',secretKey,"");
        	return cipher.update(data,'base64','utf8') + cipher.final('utf8');
	}
	catch(ex){
		return null;
	}
}

  function convertToDateTime(s) {
    var strDate = s.replace("-/g", "/");
    var d = new Date(strDate)
    return d;
}

var numCPUs = config.numCPUs;
if (cluster.isMaster) {
    // Fork workers.
    for (var i = 0; i < numCPUs - 1; i++) {
        cluster.fork();
    }
    cluster.on('exit', function (worker, code, signal) {
        logger.error('worker ' + worker.process.pid + ' died');
    });
} else {

    http.createServer(function (req, res) {
		var urlObject = url.parse(req.url, true);
        var p = urlObject.query;

	    var fileStr = aesDecrypt(p.token, config.password);
		logger.info(fileStr);

		if(fileStr == null){
			logger.info("decript failed.");
			handle404Error(req,res);
			return;
		}

		var arr = fileStr.split('|')

		if(arr.length != 2) {
				handle403Error(req,res);
				return;
		}
		var fileId = arr[0];
		var timeStr = arr[1];

		//expired after 6 hour later
		if(parseInt(timeStr) + 1000*60*60*6 < new Date().getTime()) {
			logger.info("token expired.")
			handle403Error(req,res);
			return;
		}
		var pathname = urlObject.pathname;
		if(pathname.indexOf(fileId) == -1) {
			logger.info("path not match")
			handle403Error(req,res);
			return;
		}

		logger.info("request received");

		proxy.web(req, res, {
				target: config.imageServerUrl
			});
		return;
      
        }).listen(config.serverPort);
    }


	handle404Error = function (req, res) {
        var body = '404 error';
		res.writeHead(404, {
			'Content-Length': body.length,
			'Content-Type': 'text/plain' });
		res.write(body);
		res.end();
		logger.info('404 error occured.');
    };
	handle403Error = function (req, res) {
        var body = '404 error';
		res.writeHead(403, {
			'Content-Length': body.length,
			'Content-Type': 'text/plain' });
		res.write(body);
		res.end();
		logger.info('404 error occured.');
    };
	//
// Http Server with proxyRequest Handler and Latency
//
    var proxy = new httpProxy.createProxyServer();
    var url = require('url');

//
// Listen for the `error` event on `proxy`.
    proxy.on('error', function (err, req, res) {
        res.writeHead(500, {
            'Content-Type': 'text/plain'
        });

        res.end('Something went wrong. And we are reporting a custom error message.');
    });



