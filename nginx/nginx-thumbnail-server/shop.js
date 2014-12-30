var util = require('util'),
    colors = require('colors'),
    http = require('http'),
    httpProxy = require('http-proxy');
cluster = require('cluster');
var mysql = require('mysql');
var Memcached = require('memcached');
var memcached = new Memcached('10.5.7.75:11211');
Memcached.config.poolSize = 10;

var log4js = require('log4js');
log4js.configure({
  "appenders": [
      {
          type: "console"
        , category: "serverlog"
      },
      {
          "type": "file",
          "filename": "/www/target/nodejs/logs/serverlog.log",
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
    dbHost: '10.5.7.54',
    dbUser: 'b2b_business',
    dbPort: 3306,
    dbPassword: 'b2b_business.dev',
    supplierWebUrl: 'http://10.5.7.57:8084',
    developerWebUrl: 'http://10.5.7.57:8083',
    numCPUs: 2,
    serverPort: 9500
};

var numCPUs = config.numCPUs;
if (cluster.isMaster) {
    // Fork workers.
    for (var i = 0; i < numCPUs - 1; i++) {
        cluster.fork();
    }
    cluster.on('exit', function (worker, code, signal) {
        logger.error('worker ' + worker.process.pid + ' died');
		memcached.end();
    });
} else {

    http.createServer(function (req, res) {
        var p = url.parse(req.url)
        var hostPorts = req.headers.host.split(":")
        var hosts = hostPorts[0];
        var host = hosts.split(".");
        var hostPrefix = host[0].toLowerCase();
		logger.info("req received");
		//根据规则进行路由，k00001类的路由到开发商，g0001类的路由到供应商
		if(hostPrefix.match(/^k\d{6,}$/)){
			logger.info("rewrite to developer by rule.");
			proxy.web(req, res, {
					target: config.developerWebUrl
				});
			return;
		} else if(hostPrefix.match(/^g\d{6,}$/)) {
			logger.info("rewrite to supplier by rule.");
			proxy.web(req, res, {
				target: config.supplierWebUrl
			});
			return;
		}
		
        logger.debug("request host is " + hostPrefix)
        setTimeout(function () {
            memcached.get("DOMAIN_" + hostPrefix, function (err, data) {
                if (err) {
                    logger.error('Memcache Connection Error: ' + err.message);
					handle404Error(req,res);
                    return;
                }

                if (data) {
					logger.info("found data in cache");
                    var arr = data.split("|")
                    if (arr.length == 2) {
                        var companyId = arr[0];
                        var companyType = parseInt(arr[1]);
                        if (companyId != null && companyType != null) {
                            logger.info('1.Company id is :' + companyId + ", company type is :" + companyType)
                            var url = null;
                            if (companyType == 1) {
                                url = config.developerWebUrl;
                            } else if(companyType == 2) {
                                url = config.supplierWebUrl;
                            } else {
								handle404Error(req,res);
							}

							logger.info(url)

                            proxy.web(req, res, {
                                target: url
                            });
                            return;

                        }

                    } else {
						handle404Error(req,res);
						return;
                    }
                } else {
					logger.info("no data found");
                        var connection = mysql.createConnection({host: config.dbHost, port: config.dbPort, user: config.dbUser, password: config.dbPassword})
                        connection.connect(function (err) {
                            if (err) {
                                logger.error('Mysql Connection Error: ' + error.message);
                                return;
                            }
                            logger.info('Connected to MySQL');
                            ClientConnectionReady(connection, host[0], req, res);
                        });
					return;
				}
            });

            }, 10);
        }).listen(config.serverPort);
    }

    ClientConnectionReady = function (connection, hostPrefix, req, res) {
        connection.query('use b2b_business', function (error, results) {
            if (error) {
                logger.error('ClientConnectionReady Error: ' + error.message);
                connection.end();
                return;
            }
            GetData(connection, hostPrefix, req, res);
        });
    };

    GetData = function (connection, hostPrefix, req, res) {
        connection.query(
            'SELECT company_id,type FROM bsp_domain where prefix=?', [hostPrefix],
            function selectCb(error, results, fields) {
                if (error) {
                    logger.error('GetData Error: ' + error.message);
                    connection.end();
                    return;
                }

                if (results.length > 0) {
                    logger.info('根据域名查询公司成功');
                    var firstResult = results[0];

                    var companyId = firstResult['company_id'];
                    var companyType = firstResult['type']

					logger.info("companyType",companyType);
                    if (companyId != null && companyType != null) {
                        logger.info('2.Company id is :' + companyId + ", company type is :" + companyType)
                        var url = null;
                        if (companyType == 1) {
                                url = config.developerWebUrl;
						} else if(companyType == 2) {
							url = config.supplierWebUrl;
						} else {
							handle404Error(req,res);
						}

                        connection.end();
                        logger.info('Connection closed');

                        proxy.web(req, res, {
                            target: url
                        });
                        //10分钟失效
                        memcached.add("DOMAIN_" + hostPrefix, companyId + "|" + companyType, 600, function (err) {
							logger.error('Memcache add data Error: ' + err);
						});
		
                    } else {
                        connection.end();
                        logger.info('Connection closed');
						handle404Error(req,res);

	
						console.log('has domain mapping in db but data dirty');
						memcached.add("DOMAIN_" + hostPrefix, "invalid", 600, function (err) {
							if(err) {
								logger.error('Memcache add data Error. ');
								return;
							}
							logger.info("add data to memcache:" + "DOMAIN_" + hostPrefix)

						});

                    }
                } else {
                    connection.end();
                    logger.info('Connection closed');
                    handle404Error(req,res);

					memcached.add("DOMAIN_" + hostPrefix, "invalid", 600, function (err) {
						if(err) {
							logger.error('Memcache add data Error. ');
							return;
						}
						logger.info("add data to memcache:" + "DOMAIN_" + hostPrefix)

					});
                }

            });


    };


	handle404Error = function (req, res) {
        var body = '404 error';
		res.writeHead(404, {
			'Content-Length': body.length,
			'Content-Type': 'text/plain' });
		res.write(body);
		res.end();
		console.log('404 error occured.');
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



